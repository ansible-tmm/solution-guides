{% raw %}
# Zero Trust Operations with Ansible Automation Platform - Solution Guide <!-- omit in toc -->

> **Knowledge Base Article**: [https://access.redhat.com/articles/XXXXXXX](https://access.redhat.com/articles/XXXXXXX)
>
> While this Solution Guide can be found on the customer portal, this document is the source of truth.

<style>
  div#toc {
    display: none;
  }
</style>

<h2 id="overview"></h2>

## Overview

In most enterprises, any user who can reach the automation platform can launch any playbook. There is no deny-by-default at the automation layer -- access controls rely on network perimeter trust that collapses the moment a threat is already inside, a credential is compromised, or a lateral-movement attack is in progress. Manual access reviews, static SSH keys, and one-off firewall rules cannot scale to the speed of modern threats.

This guide demonstrates how to implement **Zero Trust Architecture (ZTA)** using Ansible Automation Platform as the central **Policy Enforcement Point (PEP)**, aligned with NIST Special Publication 800-207. Every job launch is evaluated against live identity, policy, and infrastructure state before execution begins. Short-lived credentials eliminate standing access. Event-Driven Ansible closes the loop -- when a SIEM detects an attack, credentials are revoked automatically in under 30 seconds.

> **This is a reference architecture.**
>
> It covers the full five-layer ZTA journey: integrations, short-lived credentials, platform policy gating, workload identity, and automated incident response. For the AI-driven AIOps extension of this pattern -- where the same EDA pipeline also enriches and remediates ServiceNow tickets -- see [AIOps automation with Ansible](README-AIOps.md).

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [ZTA Workflow Architecture](#zta-workflow-architecture)
  - [NIST 800-207 Component Mapping](#nist-800-207-component-mapping)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Diagram](#workflow-diagram)
- [Solution Walkthrough](#solution-walkthrough)
  - [1. Wire Identity and Policy Integrations](#1-wire-identity-and-policy-integrations)
  - [2. Deploy with Short-Lived Credentials](#2-deploy-with-short-lived-credentials)
  - [3. Platform-Gated Access Control (AAP Policy as Code)](#3-platform-gated-access-control-aap-policy-as-code)
  - [4. SPIFFE Workload Identity and Dual OPA Rings](#4-spiffe-workload-identity-and-dual-opa-rings)
  - [5. Automated Incident Response](#5-automated-incident-response)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**Zero Trust Architecture** is a security model defined in NIST SP 800-207. It replaces implicit perimeter trust with three operating principles: strong identity on every request, explicit policy evaluated on every action, and continuous verification rather than one-time authentication.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://csrc.nist.gov/publications/detail/sp/800-207/final">NIST SP 800-207 Zero Trust Architecture -- nist.gov</a>

The NIST model separates ZTA into three logical roles. A **Policy Decision Point (PDP)** evaluates every request against policy rules and returns allow or deny. A **Policy Enforcement Point (PEP)** sits in the execution path and acts on that decision -- if the PDP says no, the action never happens. **Policy Information Points (PIPs)** feed live context to the PDP: who is this user, what state is the infrastructure in, and are there active threats?

Ansible Automation Platform maps naturally to this model. The controller acts as the PEP -- every job launch is a decision point. Open Policy Agent (OPA) with versioned Rego policies is the PDP. IdM, HashiCorp Vault, NetBox, and a SIEM are the PIPs. The result is a single, auditable enforcement layer that spans RHEL hosts, network devices, databases, and cloud resources.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/security/what-is-zero-trust">What is Zero Trust? -- redhat.com</a>

The eight Zero Trust principles and where each appears in this guide:

| Principle | Description | Where You See It |
|-----------|-------------|-----------------|
| **Never trust, always verify** | Every request re-checked -- no persistent trust | Every AAP job queries OPA for a fresh allow/deny |
| **Deny by default** | Start from "no"; only allow on explicit policy match | OPA returns `allowed: false` unless every rule passes |
| **Least privilege** | Only what is needed, only for as long as needed | Vault DB credentials scoped to SELECT/INSERT/UPDATE with a 5-minute TTL |
| **Short-lived credentials** | Credentials that expire automatically, not manually | Vault dynamic PostgreSQL users and time-bound SSH certificates |
| **Identity-driven access** | Decisions based on who (or what) is asking | IdM groups flow into AAP teams; OPA checks teams before allowing templates to launch |
| **Workload identity** | Services prove their identity cryptographically | SPIFFE/SPIRE issues X.509 SVIDs to the AAP controller; OPA verifies the SVID before allowing network changes |
| **Micro-segmentation** | Network zones with explicit, minimal traffic allowances | Arista cEOS ACLs enforce app-to-database paths; valid credentials alone are not enough |
| **Assume breach** | Design for fast containment when (not if) an attack succeeds | Splunk detects a brute-force pattern and EDA revokes app credentials in under 30 seconds |

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** as the Policy Enforcement Point -- every job launch is a policy decision <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Open Policy Agent (OPA)** as the Policy Decision Point -- evaluates versioned Rego policies <a target="_blank" href="https://www.openpolicyagent.org/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f511.png" width="20" style="vertical-align:text-bottom;"> **HashiCorp Vault** for dynamic database credentials, Vault-signed SSH certificates, and AAP credential lookups <a target="_blank" href="https://www.vaultproject.io/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f464.png" width="20" style="vertical-align:text-bottom;"> **Red Hat IdM (FreeIPA)** as the identity provider -- users, groups, LDAP, Kerberos, and CA trust chain <a target="_blank" href="https://www.freeipa.org/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5c4.png" width="20" style="vertical-align:text-bottom;"> **NetBox** as the CMDB and source of truth -- dynamic inventory and infrastructure state for OPA <a target="_blank" href="https://netbox.dev/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f194.png" width="20" style="vertical-align:text-bottom;"> **SPIFFE/SPIRE** for workload identity -- cryptographic SVIDs prove the automation platform's identity <a target="_blank" href="https://spiffe.io/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** for automated incident response -- SIEM alert to credential revocation in seconds <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f50d.png" width="20" style="vertical-align:text-bottom;"> **Splunk Enterprise** as the SIEM signal source -- detects attack patterns and fires webhooks to EDA <a target="_blank" href="https://www.splunk.com/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5a7.png" width="20" style="vertical-align:text-bottom;"> **Arista cEOS** for network micro-segmentation -- ACLs enforce least-privilege paths between tiers <a target="_blank" href="https://www.arista.com/">[Link]</a>

> **EDA is part of Ansible Automation Platform.**
>
> EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event. Think of it simply as inputs and outputs -- EDA is the automatic trigger for AAP, where Automation Controller is the enforcement output.

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **IT Ops Engineer / SRE** | Static SSH keys accumulate, credential rotations are manual, and anyone who can reach AAP can run anything -- one compromised account means full automation platform access | Every job launch checks live policy and identity before executing; Vault-issued credentials expire automatically; EDA contains breaches without human intervention |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Automation / Security Architect** | Wiring identity, secrets, policy, CMDB, and SIEM to the automation platform requires building one-off integrations for every combination -- no standard enforcement model exists | A production-ready reference architecture: OPA Rego policies version-controlled alongside playbooks, dual enforcement rings (platform + playbook), and a SIEM-to-EDA revocation pipeline |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **CISO / IT Director** | NIST SP 800-207 compliance requires continuous verification and least privilege -- but most automation platforms are a blind spot, with no audit trail from authorisation decision to execution | Complete chain of evidence: IdM group membership drives OPA decision, OPA decision drives AAP launch gate, Vault issues time-limited credentials, every action is logged -- auditable end-to-end |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3d7.png" width="20" style="vertical-align:text-bottom;"> [ZTA Workshop for Ansible Automation Platform](https://github.com/nmartins0611/zta-workshop-aap) -- the hands-on lab this guide is based on

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.6+** -- Required for the **Policy as Code** feature (OPA integration at the platform gateway). The `FEATURE_POLICY_AS_CODE_ENABLED: True` installer flag must be set, and OPA settings must be configured under `api/controller/v2/settings/policyascode/`.

> **Policy as Code is an AAP 2.6 feature.**
>
> Steps 1 through 2 (identity integration and short-lived credentials) work on AAP 2.5+. Step 3 onwards requires AAP 2.6 with the Policy as Code flag enabled. Organisations on 2.5 can implement playbook-level OPA checks (the inner ring) as an equivalent.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | EDA event sources and filters -- webhook, Kafka, and Azure Service Bus sources |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | AAP Configuration as Code -- credentials, job templates, RBAC, EDA objects |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/redhat/rhel_idm/">redhat.rhel_idm</a> | Certified | IdM/FreeIPA user, group, and HBAC management |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/netbox/netbox/">netbox.netbox</a> | Certified | NetBox CMDB seeding and dynamic inventory plugin |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/arista/eos/">arista.eos</a> | Certified | Arista EOS switch VLAN and ACL management |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/netcommon/">ansible.netcommon</a> | Certified | Network device connectivity modules |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/general/">community.general</a> | Community | firewalld, Podman, and general Linux modules |

### External Systems

| System | Required | Notes |
|--------|----------|-------|
| Open Policy Agent (OPA) | Yes | Policy Decision Point; must be reachable from AAP controller on its internal IP (not hostname) |
| HashiCorp Vault | Yes | Dynamic database secrets engine and SSH CA; AAP credential lookups pull secrets at job time |
| Red Hat IdM / FreeIPA | Yes | LDAP authentication for AAP; group memberships drive team assignments and OPA decisions |
| NetBox | Yes | Dynamic inventory for AAP; infrastructure state fed to OPA as a PIP |
| SPIFFE/SPIRE | Yes (Step 4) | Workload identity for AAP; SPIRE agent runs on the controller node |
| Splunk Enterprise | Yes (Step 5) | SIEM; saved search alert fires a webhook to EDA on brute-force detection |
| Arista cEOS or equivalent | Yes (Step 2) | Network micro-segmentation; ACLs between app and data tiers |
| Git server (Gitea/GitHub/GitLab) | Yes | AAP projects sync playbooks and OPA policies from version control |

**Operational Impact:** Varies per stage -- see table in the Workflow section below.

<h2 id="zta-workflow-architecture"></h2>

## ZTA Workflow Architecture

This solution implements the five-layer ZTA journey for IT operations. Each layer adds a policy control ring -- from basic identity integration through to fully automated breach response.

### NIST 800-207 Component Mapping

| NIST Component | Role | Implementation |
|---------------|------|---------------|
| **Policy Decision Point (PDP)** | Evaluates every request against policy; returns allow/deny | **Open Policy Agent** -- versioned Rego policies stored in Git |
| **Policy Enforcement Point (PEP)** | Sits in the execution path; enforces the PDP decision | **AAP Controller** (platform gateway) + **playbook-level OPA checks** |
| **Policy Information Point (PIP)** | Feeds live context to the PDP | **IdM** (identity), **NetBox** (infrastructure state), **Vault** (credential status), **Splunk** (threat signals) |

### Operational Impact per Stage

| Stage | Operational Impact | Why |
|-------|-------------------|-----|
| **1. Wire integrations** | **None** | Read-only verification -- no changes to infrastructure |
| **2. Short-lived credentials** | **Low** | Vault issues ephemeral DB user; Arista opens a scoped ACL |
| **3. Platform-gated patching** | **Low** | Hardening changes (SSH config, login banner, audit rules) on managed hosts |
| **4. SPIFFE + network changes** | **Low** | VLAN created on switches; NetBox CMDB updated |
| **5. Incident response** | **Medium** | Vault credentials revoked; application stopped to contain breach |

### Workflow Diagram

```
User launches AAP job
        │
        ▼
┌─────────────────────────────────┐
│  OUTER RING: AAP Policy as Code │  ◄── OPA aap.gateway policy
│  Is this team allowed to run    │      checks template name vs.
│  this class of job template?    │      AAP team membership
└────────────┬────────────────────┘
             │  ALLOWED
             ▼
┌─────────────────────────────────┐
│  PIPs: Vault + NetBox + IdM     │  ◄── Credential lookups,
│  Pull credentials; verify       │      dynamic inventory,
│  infrastructure state           │      group membership
└────────────┬────────────────────┘
             │
             ▼
┌─────────────────────────────────┐
│  INNER RING: Playbook OPA check │  ◄── OPA zta.db_access or
│  Does this specific request     │      zta.network policy
│  satisfy fine-grained policy?   │      (optional SPIFFE check)
└────────────┬────────────────────┘
             │  ALLOWED
             ▼
        Execute action
  (deploy app / patch / configure VLAN)
             │
             ▼
     SIEM continuous monitoring
  Splunk/Wazuh watches for anomalies
             │  ATTACK DETECTED
             ▼
    EDA webhook → revoke credentials
      (blast radius contained in
         under 30 seconds)
```

The two OPA rings provide defence in depth. The **outer ring** (AAP Policy as Code) stops wrong users before a single task runs. The **inner ring** (playbook-level OPA check) validates fine-grained conditions -- VLAN ranges, SPIFFE workload identity, database permissions -- that the platform gate cannot evaluate. Both rings query the same OPA instance, ensuring a single source of policy truth.

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

### 1. Wire Identity and Policy Integrations

**Operational Impact:** None

Before enforcing Zero Trust, every service in the ZTA stack must be reachable and trusted by AAP. This stage connects AAP to IdM (LDAP authentication and team mapping), OPA (policy engine), Vault (secrets with credential lookups -- no passwords stored in AAP), and NetBox (dynamic inventory). Verification job templates confirm each integration independently.

The OPA policy gate pattern used throughout this guide follows a consistent three-task structure: query IdM for authoritative group membership, POST the request context to OPA, then assert the decision.

```yaml
- name: Query IdM for launcher group membership
  ansible.builtin.command:
    cmd: "ipa user-show {{ awx_user_name | quote }}"
  register: ipa_user_out
  changed_when: false

- name: Query OPA for database access decision
  ansible.builtin.uri:
    url: "{{ opa_url }}/v1/data/zta/db_access/decision"
    method: POST
    body_format: json
    body:
      input:
        user: "{{ awx_user_name }}"
        user_groups: "{{ requesting_groups }}"
        target_database: "{{ db_name }}"
        requested_permissions: ["SELECT", "INSERT", "UPDATE"]
  register: opa_decision

- name: Enforce OPA decision
  ansible.builtin.assert:
    that:
      - opa_decision.json.result.allow | default(false)
    fail_msg: |
      ACCESS DENIED by OPA policy.
      User '{{ awx_user_name }}' is not authorised to request database credentials.
      Reason: {{ opa_decision.json.result.reason | default('unknown') }}
    success_msg: "OPA policy check passed -- proceeding with credential issuance"
```

> **IdM is the authoritative source for group membership.**
>
> AAP's `awx_user_groups` variable can lag after LDAP group changes. Always query IdM directly (`ipa user-show`) for group membership in OPA inputs -- IdM is the source of truth.

**AAP configuration for this step:**

| Field | Value |
|-------|-------|
| **LDAP authenticator** | `ldap://idm.zta.lab` -- maps `cn=infrastructure,cn=groups` to AAP team `Infrastructure` |
| **OPA settings** | `api/controller/v2/settings/policyascode/` -- set OPA URL to the controller IP (not hostname) |
| **Vault credential type** | Custom lookup credential -- `secret/machine/rhel` and `secret/network/arista` paths |
| **NetBox inventory source** | `nb_inventory` plugin with `compose` for SSH host routing through containers |

### 2. Deploy with Short-Lived Credentials

**Operational Impact:** Low

This is the core least-privilege pattern: Vault issues a database user scoped to `SELECT`, `INSERT`, `UPDATE` with a five-minute TTL. After the TTL expires, Vault revokes the user automatically -- no manual rotation required. An Arista ACL opens the network path from the app tier to the database tier only for the duration of the deployment.

The workflow has four jobs chained in sequence:

```
Check DB Access Policy → Create DB Credential → Configure DB Access List → Deploy Application
```

The second job requests the dynamic credential from Vault:

```yaml
- name: Request dynamic database credentials from Vault
  ansible.builtin.command:
    cmd: "vault read -format=json {{ vault_db_secrets_path }}/creds/{{ vault_db_role_name }}"
  environment: "{{ vault_env }}"
  register: vault_creds_raw
  no_log: true

- name: Parse Vault response
  ansible.builtin.set_fact:
    db_dynamic_user: "{{ (vault_creds_raw.stdout | from_json).data.username }}"
    db_lease_id: "{{ (vault_creds_raw.stdout | from_json).lease_id }}"
    db_lease_duration: "{{ (vault_creds_raw.stdout | from_json).lease_duration }}"
  no_log: true

- name: Store lease ID for rotation and revocation
  ansible.builtin.copy:
    dest: /tmp/zta-db-lease
    content: "{{ db_lease_id }}"
    mode: '0600'

- name: Pass credentials to downstream workflow jobs
  ansible.builtin.set_stats:
    data:
      db_dynamic_user: "{{ db_dynamic_user }}"
      db_dynamic_password: "{{ db_dynamic_password }}"
      db_lease_id: "{{ db_lease_id }}"
    per_host: false
```

> **Launching as the wrong user demonstrates deny-by-default.**
>
> Launch the workflow as a user not in the `app-deployers` IdM group. OPA denies at Step 1 -- Vault is never contacted, the ACL is never opened, and the application is never deployed. Switch to the authorised user and the workflow completes in full.

> **RBAC:** Scope the Vault credential tightly.
>
> The Vault database role should grant only `SELECT`, `INSERT`, `UPDATE` on the specific application schema. Do not use a superuser Vault role for application deployments.

### 3. Platform-Gated Access Control (AAP Policy as Code)

**Operational Impact:** Low

AAP 2.6 Policy as Code evaluates a Rego policy at the **platform gateway** -- before any task runs, before any credential is issued, before any inventory is queried. The policy receives the full job context: template name, launcher username, AAP team memberships, and playbook path. If OPA returns `allowed: false`, the job is blocked at the platform level.

The `aap_gateway.rego` policy maps template name patterns to required AAP teams:

```rego
package aap.gateway

import rego.v1

# Default: allow unless a deny rule fires
default decision := {"allowed": true, "violations": []}

# Team-to-template pattern mapping
patching_teams := {"Infrastructure", "Security"}
network_teams  := {"Infrastructure"}
app_teams      := {"Applications", "DevOps"}

user_teams := {name | name := input.created_by.teams[_].name}

template_name := lower(input.name)

is_patching_template if contains(template_name, "patch")
is_network_template  if contains(template_name, "vlan")
is_network_template  if contains(template_name, "network")
is_app_template      if contains(template_name, "deploy")
is_app_template      if contains(template_name, "credential")

# Deny patching to unauthorised teams
decision := {
    "allowed": false,
    "violations": [sprintf(
        "user '%s' is not in an authorised team for patching (requires: %v, has: %v)",
        [input.created_by.username, patching_teams, user_teams],
    )],
} if {
    not input.created_by.is_superuser
    is_patching_template
    not team_match(patching_teams)
}
```

The AAP Organisation must have `policy_enforcement` set to `aap/gateway/decision` to activate the outer ring. Once enabled, a user not on the `Infrastructure` team attempting to launch any template with "Patch" in the name receives a platform-level block -- the job never starts.

> **Policy as Code lives in the same Git repo as your playbooks.**
>
> Store `opa-policies/*.rego` alongside your automation code. Treat policy changes as code changes -- reviewed, approved, and merged via pull request. The OPA decision log provides a complete audit trail of every allow/deny, which user, and which policy version was evaluated.

**AAP setup for the outer ring:**

| Field | Value |
|-------|-------|
| **OPA URL** | `http://192.168.1.11:8181` -- use IP, not hostname (controller cannot resolve lab DNS) |
| **Policy path** | `aap/gateway/decision` |
| **Organisation policy enforcement** | Set under Organisation → Edit → `policy_enforcement` field |

### 4. SPIFFE Workload Identity and Dual OPA Rings

**Operational Impact:** Low

For sensitive operations like network configuration changes, identity checks apply at two layers: the outer ring verifies the human user's team, and the inner ring verifies the **automation workload's identity** using a SPIFFE X.509 SVID. This ensures the request comes from the trusted AAP controller, not from anything impersonating it.

The inner OPA policy (`zta.network`) requires four conditions to all pass:

```rego
allow if {
    condition_user_authorized      # user is in network-admins (IdM group)
    condition_valid_vlan           # VLAN ID is in the 100-999 range
    condition_action_permitted     # action is in the allowed set
    condition_workload_verified    # SPIFFE ID matches the registered workload
}

allowed_spiffe_ids := {
    "spiffe://zta.lab/workload/network-automation",
}

condition_workload_verified if {
    allowed_spiffe_ids[input.spiffe_id]
}
```

The playbook fetches the SVID from the SPIRE agent, includes it in the OPA input, and enforces the decision before touching the switches:

```yaml
- name: Fetch X.509 SVID from SPIRE Agent
  ansible.builtin.command: >
    {{ spire_install_dir }}/bin/spire-agent api fetch x509
    -socketPath {{ spire_agent_socket }}
  register: svid_result

- name: Parse SPIFFE ID from SVID
  ansible.builtin.set_fact:
    workload_spiffe_id: >-
      {{ svid_result.stdout | regex_search('SPIFFE ID:\s+(spiffe://\S+)', '\1') | first }}

- name: Query OPA network policy (inner ring)
  ansible.builtin.uri:
    url: "{{ opa_url }}/v1/data/zta/network/decision"
    method: POST
    body_format: json
    body:
      input:
        user: "{{ awx_user_name }}"
        user_groups: "{{ network_user_groups }}"
        action: "create_vlan"
        vlan_id: "{{ new_vlan_id | int }}"
        spiffe_id: "{{ workload_spiffe_id }}"
  register: opa_decision

- name: Enforce OPA decision
  ansible.builtin.assert:
    that:
      - opa_decision.json.result.allow == true
    fail_msg: "VLAN CONFIGURATION DENIED. Reason: {{ opa_decision.json.result.reason }}"
    success_msg: "OPA policy check PASSED -- proceeding with VLAN configuration"
```

Once OPA approves, the playbook configures the VLAN on the Arista cEOS switches and updates NetBox -- recording both the human identity and the workload SPIFFE ID in the CMDB record.

```yaml
- name: Create VLAN on all cEOS switches
  arista.eos.eos_vlans:
    config:
      - vlan_id: "{{ new_vlan_id | int }}"
        name: "{{ new_vlan_name }}"
        state: active
    state: merged

- name: Create VLAN record in NetBox
  ansible.builtin.uri:
    url: "{{ netbox_url }}/api/ipam/vlans/"
    method: POST
    headers:
      Authorization: "Token {{ netbox_token }}"
    body_format: json
    body:
      vid: "{{ new_vlan_id | int }}"
      name: "{{ new_vlan_name }}"
      description: >-
        Created by {{ awx_user_name }} (workload: {{ workload_spiffe_id }})
```

> **Stop the SPIRE agent to test the workload check.**
>
> With SPIRE stopped on the controller, the SVID fetch fails and OPA denies the request -- even if the user is in `network-admins`. This confirms that both the human identity and the workload identity must be verified independently.

### 5. Automated Incident Response

**Operational Impact:** Medium (credential revocation stops the application)

When Splunk detects a brute-force SSH attack, it fires a webhook alert to the EDA Controller. The EDA rulebook matches the alert name, then immediately triggers the **Emergency: Revoke App Credentials** job template -- with no human in the loop. Vault revokes the database lease, the app's credential file is removed, and the application service is stopped. The blast radius is contained in under 30 seconds.

The EDA rulebook is intentionally minimal -- it matches one event type and runs one remediation job:

```yaml
- name: Splunk Brute-Force → Credential Revocation
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000
  rules:
    - name: Revoke credentials on SSH brute-force detection
      condition: event.payload.search_name is search("SSH Brute Force Detected")
      action:
        run_job_template:
          name: "Emergency: Revoke App Credentials"
          organization: Default
```

The revocation playbook does three things: revokes the specific Vault lease, revokes all leases for the DB role as a safety net, and stops the application service:

```yaml
- name: Revoke the database credentials in Vault
  ansible.builtin.command:
    cmd: "vault lease revoke {{ lease_id }}"
  environment: "{{ vault_env }}"

- name: Revoke ALL leases for the app DB role (safety net)
  ansible.builtin.command:
    cmd: "vault lease revoke -prefix {{ vault_db_secrets_path }}/creds/{{ vault_db_role_name }}"
  environment: "{{ vault_env }}"
  failed_when: false

- name: Remove credential file and stop application
  ansible.builtin.file:
    path: "{{ app_deploy_dir }}/env"
    state: absent

- name: Stop the application service
  ansible.builtin.systemd:
    name: ztaapp
    state: stopped
```

After revocation, the application's `/health` endpoint returns an error -- confirming no database access remains. Restoration requires a deliberate human action: launching the **Restore App Credentials** template after investigation.

> **Configure Splunk to send alerts to EDA.**
>
> In Splunk, create a saved search named "ZTA: SSH Brute Force Detected" and add an **Alert Action** of type Webhook pointing to `http://eda.zta.lab:5000/endpoint`. Include the search name in the payload -- the EDA rulebook condition matches on this string.

**EDA setup:**

| Field | Value |
|-------|-------|
| **Decision Environment** | Must include `ansible.eda` and match the EDA Controller version |
| **Webhook token** | Store in Vault at a known path; inject into EDA via a custom credential type |
| **Rulebook Activation** | Set to `Always` restart policy so EDA recovers from transient failures |

<h2 id="validation"></h2>

## Validation

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| **1. Integrations** | All ZTA services reachable and authenticated | Verify ZTA Services job template completes green; Vault, OPA, NetBox endpoints return HTTP 200 |
| **2. Short-lived credentials** | DB user exists then self-revokes after TTL | `psql -h db.zta.lab -U <dynamic_user>` succeeds; same command fails after 5 minutes |
| **3. Policy enforcement** | Wrong user is blocked; correct user is allowed | Launching as `neteng` (Readonly team) returns platform-level "denied" before any task runs; launching as `appdev` succeeds |
| **4. Workload identity** | SPIFFE check is evaluated for network changes | OPA decision log shows `condition_workload_verified: true`; stopping the SPIRE agent causes the VLAN job to fail at the OPA check |
| **5. Incident response** | EDA revokes credentials automatically | `curl http://app.zta.lab:8081/health` returns an error within 30 seconds of the simulated brute-force; Vault shows no active leases for the DB role |

**Quick end-to-end validation test** -- simulate the brute-force event:

```bash
# Trigger the Splunk saved search manually from the AAP controller
curl -s -X POST "https://splunk.zta.lab:8089/services/saved/searches/ZTA%3A%20SSH%20Brute%20Force%20Detected/dispatch" \
  -u admin:password \
  -d "dispatch.now=true" | grep sid

# Verify the application lost database access
sleep 30
curl -s http://app.zta.lab:8081/health | jq .status
# Expected: "error" or "unhealthy"

# Confirm Vault has no active leases for the app role
vault list database/creds/app-role 2>&1
# Expected: "No value found at database/creds/app-role"
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| OPA always allows -- `aap_gateway.rego` never fires | `policy_enforcement` not set on the AAP Organisation, or Policy as Code feature flag not enabled | Verify `FEATURE_POLICY_AS_CODE_ENABLED: True` in the installer config; confirm `policy_enforcement` is set on the Organisation; check the OPA URL uses the controller's IP (not hostname) |
| Vault credential lookup returns empty -- job fails with missing credential | AAP credential lookup path is wrong or Vault engine is not initialised | Verify the Vault path matches what was configured in the credential type (`secret/machine/rhel` not `secret/data/machine/rhel`); run `vault read <path>` from the controller to confirm |
| OPA `condition_workload_verified` is always false | SPIRE agent not running on the controller, or the registered SPIFFE ID does not match the policy | Run `spire-agent api fetch x509 -socketPath <socket>` on the controller; compare the SPIFFE ID in the output against `allowed_spiffe_ids` in `network.rego` |
| EDA rulebook is active but Splunk alert does not trigger | Splunk saved search webhook URL is wrong or Splunk EDA add-on is not installed | Verify the webhook points to `http://eda.zta.lab:5000/endpoint`; confirm the Ansible Add-on for Splunk is installed and the token matches the EDA credential |
| `neteng` user is allowed when they should be denied | User was temporarily added to a permitted IdM group during testing | Run `ipa user-show neteng` and verify group membership; remove from `app-deployers` or `network-admins` if present |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Workshop Stages | Approach | What Is Automated |
|----------|----------------|----------|-------------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Stages 1-2 | **Identity integration + short-lived credentials** | AAP authenticates via LDAP; playbooks query OPA before acting; Vault issues ephemeral DB credentials with automatic TTL expiry |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | Stages 3-4 | **Platform policy gating + workload identity** | AAP Policy as Code blocks wrong users before any task runs; SPIFFE SVIDs verify the automation workload; dual OPA rings enforce defence in depth on all sensitive operations |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Stages 5-6 | **Automated breach response + layered hardening** | SIEM detects attack patterns; EDA revokes credentials automatically in seconds; SSH hardened with four independent layers (firewall, HBAC, Vault SSH CA, SIEM monitoring); break-glass procedures provide auditable emergency access |

> **Crawl is the highest-value entry point.**
>
> Vault dynamic credentials (Stage 2) alone eliminate the largest ZTA risk: standing database credentials stored in configuration files. Deploy Crawl first, measure the reduction in standing access, then build the case for Walk and Run.

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **Score residual CVE risk:** See [Reducing Residual CVE Risk with Compensating Controls](README-CME.md) to verify and quantify host mitigations while a patch is still in flight.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **Inventory and remediate quantum-vulnerable crypto:** See [Post-Quantum Cryptography Readiness for RHEL](README-PQC.md) to reuse Vault as a PKI CA, produce a CBOM, and stage ML-KEM hybrid remediations.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Extend ZTA with AI-driven remediation:** See [AIOps automation with Ansible](README-AIOps.md) to add AI root cause analysis and Lightspeed playbook generation to the same EDA incident response pipeline.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **Add ITSM to the incident response loop:** See [Reducing MTTR with Automated ServiceNow Ticket Enrichment](README-AIOps-ServiceNow.md) to route EDA-triggered events into ServiceNow incidents with AI-enriched context.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> **Deploy the AI inference backend:** See [AI Infrastructure automation with Ansible](README-IA.md) for automating Red Hat AI provisioning with the `infra.ai` and `redhat.ai` collections -- required if extending this guide with AI-assisted remediation.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2601.png" width="20" style="vertical-align:text-bottom;"> **Azure event transport layer:** See [Event-Driven Remediation with Azure Service Bus and Ansible](README-AIOps-Azure-Service-Bus.md) to replace the Splunk webhook with Azure Service Bus as the EDA event source for hybrid Azure + on-prem environments.

---

## Summary

With Ansible Automation Platform as the Policy Enforcement Point, every operational action flows through the same identity, policy, and secrets checks -- regardless of whether it touches a RHEL host, a network switch, a database, or a cloud resource. Vault eliminates standing credentials. OPA Policy as Code enforces role-based launch control before a single task executes. SPIFFE workload identity extends verification to the automation platform itself. And when a SIEM detects an active threat, Event-Driven Ansible contains the blast radius in seconds -- not hours.

This is Zero Trust as an operational discipline, not a point product: strong identity on every request, deny by default, least privilege enforced automatically, and breach response that does not wait for a human to notice.

---

<img width="400" src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/aap_logo.png">
{% endraw %}
