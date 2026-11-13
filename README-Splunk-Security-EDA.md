{% raw %}
<div class="guide-header">

<h1>Security automation with Splunk and Event-Driven Ansible</h1>

<span class="guide-type-badge guide-type-badge--solution"><i class="fas fa-check-circle" aria-hidden="true"></i> Solution Guide</span>

</div>

<div class="guide-hero-callout guide-hero-partner guide-hero-partner--splunk" role="img" aria-label="Ansible Automation Platform and Splunk">
  <img src="assets/images/logos/aap-ansible-icon.png" alt="" class="guide-hero-callout__icon" width="36" height="36">
  <span class="guide-hero-partner__plus" aria-hidden="true">+</span>
  <span class="guide-hero-partner__partner card-partner-logo-set">
    <img src="assets/images/logos/splunk-logo.png" alt="Splunk" class="card-partner-logo card-partner-logo--light" width="106" height="32">
    <img src="assets/images/logos/splunk-logo-dark.png" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true" width="106" height="32">
  </span>
</div>

## Overview

Security operations still lose time between detection and durable change. A Splunk alert lands, analysts open tickets, and containment or patching waits on manual SSH and spreadsheet evidence -- giving attackers room to pivot, or leaving CVE windows open for tens of minutes per host.

This guide shows how **Splunk**, **Event-Driven Ansible (EDA)**, and **Ansible Automation Platform (AAP)** close that gap for three operational outcomes:

- **[Use Case A: Automated brute-force remediation](#use-case-a-automated-brute-force-remediation)** -- SSH authentication failures trigger EDA, which revokes HashiCorp Vault database credentials and stops the compromised service in seconds.
- **[Use Case B: Automated CVE response](#use-case-b-automated-cve-response)** -- Splunk CVE alerts drive DEFEND containment, OPA-gated CONTAIN patching with human approval, then COMPLY evidence and a scanned container image.
- **[Use Case C: Splunk ES investigation lifecycle](#use-case-c-splunk-es-investigation-lifecycle)** -- The `splunk.es` collection closes the loop: correlation searches as code, automated findings, investigations, and response plans managed entirely through Ansible.

| Use case | Primary outcome | Operational impact | Maturity fit |
|----------|-----------------|-------------------|--------------|
| **A. Brute-force remediation** | Instant credential and service containment | High | Crawl alert; Walk approve; Run closed-loop revoke |
| **B. CVE response** | Contain, policy-gated patch, prove | High | Crawl alert; Walk EDA contain; Run full DEFEND/CONTAIN/COMPLY |
| **C. ES investigation lifecycle** | Detection-as-code and SOC write-back | Medium | Crawl audit searches; Walk findings write-back; Run full investigation lifecycle |

> **AIOps Splunk is separate.**
>
> Predictive ITSI and RHEL/network AIOps patterns live in [AIOps with Splunk and Event-Driven Ansible](README-AIOps-Splunk-ITSI.md). This guide is the **Security** track.

## Table of Contents

- [Background](#background)
- [Solution](#solution)
- [Prerequisites](#prerequisites)
- **[Use Case A: Automated brute-force remediation](#use-case-a-automated-brute-force-remediation)**
- **[Use Case B: Automated CVE response](#use-case-b-automated-cve-response)**
- **[Use Case C: Splunk ES investigation lifecycle](#use-case-c-splunk-es-investigation-lifecycle)**
- [Maturity Path](#maturity-path)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Background

**Splunk** aggregates authentication and vulnerability signals and can forward alerts through the Ansible add-on (or HTTP Event Collector) into EDA. **Event-Driven Ansible** evaluates rulebooks and launches approved AAP jobs or workflows. **Ansible Automation Platform** executes governed remediations with credentials, RBAC, and job history.

Under **Zero Trust Architecture (ZTA)** (NIST SP 800-207), trust is continuously evaluated. When a workload shows brute-force behavior or a known CVE, policy enforcement points must restrict access or harden before the ticket queue drains. EDA connects the Policy Information Point (Splunk) to enforcement (Vault, firewall, services, patch workflows).

Two gaps this guide closes:

- **Brute-force blast radius (Use Case A)** -- Manual revoke and service stop leave active Vault leases and DB sessions open during triage.
- **CVE response chain (Use Case B)** -- Containment, patching policy, and compliance evidence are separate manual steps; OPA and workflows make gates and proof part of the same pipeline.

## Solution

What makes up the solution?

- **Splunk Enterprise** -- Brute-force and CVE detection; Ansible add-on webhooks (both)
- **Event-Driven Ansible** -- Rulebooks that launch job or workflow templates (both)
- **Ansible Automation Platform 2.5+** -- Orchestration, approvals, audit (all)
- **HashiCorp Vault** -- Dynamic DB leases and revocation (Use Case A)
- **Open Policy Agent (OPA)** -- Patch and execution policy gates (Use Case B)
- **RHEL 9 targets** -- firewalld, SELinux, httpd, Podman for containment and compliance (Use Case B)

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **IT Ops / SRE** | 3 AM manual revoke or 45+ minutes SSH per CVE host | Closed-loop containment; patching after gates and approval |
| **Security Architect** | Response times miss policy; patch rules live in docs | Code-driven revoke and OPA-enforced patch prerequisites |
| **Compliance / CISO** | Weak evidence and supply-chain provenance | AAP job trails; before/after HTML evidence; labeled scanned images (Use Case B) |
| **SOC Analyst** | Context-switching between SIEM and remediation tools | Findings, investigations, and response plan status visible in Splunk ES console (Use Case C) |

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.4+** for EDA (Use Case A minimum); **2.5+** recommended for Use Case B workflows. **2.6** recommended for Token Event Stream enhancements.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | Webhook / event stream sources and rulebook actions (all) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/splunk/es/">splunk.es</a> | Certified | Manage ES correlation searches, findings, investigations, response plans, adaptive response notable events, and data inputs (Use Cases A, B, C) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/hashi_vault/">community.hashi_vault</a> / <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/collections/published/hashicorp/vault/details">hashicorp.vault</a> | Community / Certified | Vault APIs (Use Case A) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Workflow control and set_stats (Use Case B) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/posix/">ansible.posix</a> | Certified | firewalld, SELinux, sysctl (Use Case B) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/containers/podman/">containers.podman</a> | Certified | Build, scan, push (Use Case B) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/redhat/rhel_system_roles/">redhat.rhel_system_roles</a> | Certified | CIS hardening (Use Case B) |

### External Systems

| System | Required | Details |
|--------|----------|---------|
| Splunk | Required | Enterprise with Ansible add-on (all); HEC optional for Use Case B; Enterprise Security (ES) app required for Use Case C and `splunk.es` write-back in A and B |
| HashiCorp Vault | Use Case A | Dynamic DB credentials and lease revoke |
| Open Policy Agent | Use Case B | Patch and execution policies (for example port 8181) |
| RHEL 9 lab hosts | Use Case B | httpd, firewalld, SELinux targeted, Podman |

**Operational Impact:** High for Use Cases A and B -- credential revoke / service stop (A); interface isolation, advisory patch, CIS and container changes (B). Medium for Use Case C (ES configuration changes). Lab first.

> **Warning:** TLS in production
>
> Code examples use `validate_certs: false` for lab convenience. Production deployments must use proper TLS certificates and set `validate_certs: true`.

---

<h2 id="use-case-a-automated-brute-force-remediation">Use Case A: Automated brute-force remediation</h2>

### Overview

When Splunk detects rapid SSH authentication failures, EDA launches an AAP job that authenticates to HashiCorp Vault, revokes the application's database lease, removes the credential env file, and stops the compromised service -- closed-loop containment without waiting for a ticket.

### Demos and labs

- <a target="_blank" href="https://github.com/ansible/workshops">Zero Trust Architecture Workshop</a>

### Workflow

```mermaid
graph LR
  Splunk([Splunk SIEM]) -->|Webhook| EDA[EDA rulebook]
  EDA -->|API trigger| AAP[AAP Controller]
  AAP -->|Revoke lease| Vault([HashiCorp Vault])
  Vault -->|Drop DB user| DB([Application database])
  AAP -->|Stop service| Host([Target server])
```

### Solution Walkthrough

#### Step 1: Point Splunk at the EDA event stream

**Operational Impact:** Low

Create an External Event Stream in AAP and configure the Ansible add-on webhook endpoint:

```yaml
    - name: Update EDA environment webhook endpoint
      ansible.builtin.uri:
        url: "{{ splunk_mgmt }}/servicesNS/nobody/ansible_addon_for_splunk/ansible_addon_for_splunk_environment/ZTA"
        method: POST
        user: admin
        password: "{{ splunk_password }}"
        force_basic_auth: true
        validate_certs: false
        body_format: form-urlencoded
        body:
          webhook_endpoint: "{{ eda_event_stream_url }}"
          auth_type: apikey
          token: "{{ eda_token }}"
        status_code: [200]
```

#### Step 2: EDA rulebook for SSH brute-force

**Operational Impact:** None

```yaml
- name: Splunk Brute-Force to Credential Revocation
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

Inject a Controller token into EDA with a custom credential so the rulebook can launch the job template.

#### Step 3: Revoke Vault lease and stop the application

**Operational Impact:** High

Authenticate to Vault, read the active lease, revoke it, remove credentials on disk, and stop the service:

```yaml
    - name: Authenticate to Vault with userpass
      uri:
        url: "{{ vault_addr }}/v1/auth/userpass/login/{{ vault_username }}"
        method: POST
        body_format: json
        body:
          password: "{{ vault_password }}"
        validate_certs: false
      register: vault_login
      delegate_to: localhost

    - name: Revoke the database credentials in Vault
      command: "vault lease revoke {{ lease_raw.content | b64decode | trim }}"
      environment:
        VAULT_ADDR: "{{ vault_addr }}"
        VAULT_TOKEN: "{{ vault_login.json.auth.client_token }}"
      when: lease_raw is succeeded and lease_raw.content is defined

    - name: Remove application environment file (contains credentials)
      file:
        path: "/opt/app/env"
        state: absent

    - name: Stop the application service
      systemd:
        name: ztaapp
        state: stopped
```

> **Warning:** PostgreSQL existing connections
>
> `vault lease revoke` drops the generated user for new connections. Configure PostgreSQL to terminate sessions for dropped users, or add an explicit kill-sessions task.

#### Step 4: Write back to Splunk ES

**Operational Impact:** Low

After remediation, write a finding and notable event back into Splunk Enterprise Security so SOC analysts see the outcome without leaving Splunk:

```yaml
    - name: Create ES finding for brute-force remediation
      splunk.es.splunk_finding:
        title: "Brute-force remediation completed - {{ affected_host }}"
        description: >
          Vault lease revoked, service stopped by AAP job {{ tower_job_id }}.
          Lease ID: {{ lease_id | default('unknown') }}.
        security_domain: access
        entity: "{{ affected_host }}"
        entity_type: system
        finding_score: 80
        owner: unassigned
        status: resolved
        urgency: critical
        disposition: true_positive

    - name: Attach remediation notes to the finding
      splunk.es.splunk_notes:
        target_type: finding
        finding_ref_id: "{{ finding_ref_id }}"
        content: >
          Vault lease {{ lease_id }} revoked. Service ztaapp stopped.
          AAP job {{ tower_job_id }}.
```

> **Tip:** `splunk.es` httpapi connection
>
> Run these tasks against the Splunk host, not localhost. Set `ansible_connection: httpapi`, `ansible_network_os: splunk.es.splunk`, `ansible_httpapi_port: 8089`, `ansible_httpapi_use_ssl: true`, and `ansible_httpapi_validate_certs: true` in inventory or group vars. Pass `affected_host` from the remediation job. On this play, `inventory_hostname` is the Splunk server, not the endpoint that was remediated. `splunk_finding` returns `finding.after`. It does not document a ref id, so set `finding_ref_id` from `splunk.es.splunk_finding_info` (format `uuid@@notable@@time{timestamp}`) before the notes task.

### Validation

#### Test

```bash
ansible-playbook section5/playbooks/simulate-bruteforce.yml
```

Wait 20-30 seconds for Splunk to index, evaluate the saved search, and POST to EDA.

#### Expected Result

EDA activation fire count increments. Job **Emergency: Revoke App Credentials** succeeds and summarizes Vault revoke, env file removal, and service stop -- application has no DB access.

#### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Splunk detects but EDA silent | Webhook URL or network | Match add-on endpoint to Event Stream; open firewall |
| Job `401` to Vault | Bad token / AppRole | Rotate credential; confirm revoke permission |
| App still has DB access | Lingering sessions | Terminate sessions for dropped users |

### Summary

Use Case A turns a Splunk brute-force alert into governed Vault revoke and host isolation at machine speed.

---

<h2 id="use-case-b-automated-cve-response">Use Case B: Automated CVE response</h2>

### Overview

Three phases map to real CVE response: **DEFEND** (EDA containment in seconds from a Splunk alert), **CONTAIN** (OPA patch gates plus human approval, then advisory update), and **COMPLY** (before/after evidence, CIS hardening, scanned container with advisory label).

### Workflow

```mermaid
graph LR
  Alert([Splunk CVE alert]) --> EDA[EDA rulebook]
  EDA --> Defend[DEFEND containment]
  Defend --> OPA{OPA patch gates}
  OPA -->|pass| Approve[Approval node]
  OPA -->|fail| Block([Fail with gate name])
  Approve --> Patch[CONTAIN advisory patch]
  Patch --> Comply[COMPLY audit and image]
```

### Solution Walkthrough

#### Step 1: EDA triggers containment

**Operational Impact:** Medium

```yaml
sources:
  - ansible.eda.webhook:
      host: 0.0.0.0
      port: 5000
      token: "{{ EDA_WEBHOOK_TOKEN | default('') }}"
rules:
  - name: CVE alert from Splunk -- trigger containment
    condition: event.payload.search_name is search("CVE Alert")
    actions:
      - run_workflow_template:
          name: "Vulnerability Containment"
          organization: Default
          job_args:
            limit: "{{ event.payload.results.host }}"
```

DEFEND confirms the CVE on-host, moves `eth0` to an `internal-only` firewalld zone, hardens httpd, sets SELinux booleans against SSRF, and activates AIDE -- graduated containment, not a kill switch.

#### Step 2: OPA-gated patching with approval

**Operational Impact:** High

```yaml
- name: Query OPA patch policy
  ansible.builtin.uri:
    url: "{{ opa_url }}/v1/data/dcc/patch_policy/result"
    method: POST
    body_format: json
    body:
      input:
        current_hour: "{{ ansible_date_time.hour | int }}"
        backup_age_hours: "{{ backup_age_hours | float }}"
        free_disk_gb: "{{ free_disk_gb | float }}"
        service_state: "{{ _service_state.status.ActiveState }}"
  register: _opa_response

- name: Apply advisory patch
  ansible.builtin.dnf:
    name: "*"
    state: latest
    bugfix: false
    security: true
    advisory: "{{ rhsa_id }}"
  register: patch_result
```

If `allow_patch` is false, the workflow fails with the violated gate and never reaches approval. Approval timeout fails safe (no patch). A second OPA execution policy can block who may launch patching even as a Controller admin.

> **Warning:** OPA gates block patching, not containment.
>
> DEFEND runs immediately without patch gates. Gates apply only to CONTAIN.

#### Step 3: Compliance evidence and supply chain

**Operational Impact:** Medium

Audit controls before and after CIS hardening, publish HTML evidence, then build and scan a UBI9-minimal image labeled with the advisory:

```yaml
- name: Build hardened container with advisory label
  containers.podman.podman_image:
    name: "parasol-app"
    tag: "{{ rhsa_id }}"
    path: "{{ playbook_dir }}/../container/"
    build:
      extra_args: "--label security.advisory={{ rhsa_id }}"
    push: true
    push_args:
      dest: "{{ registry_url }}/parasol-app:{{ rhsa_id }}"
```

#### Step 4: Write findings back to Splunk ES

**Operational Impact:** Low

After COMPLY completes, write findings and investigation notes back into Splunk ES for SOC traceability:

```yaml
    - name: Create ES finding for CVE remediation
      splunk.es.splunk_finding:
        title: "CVE remediation completed - {{ rhsa_id }} on {{ affected_host }}"
        description: >
          DEFEND: eth0 isolated, httpd hardened, SELinux enforced.
          CONTAIN: Advisory {{ rhsa_id }} applied.
          COMPLY: CIS evidence generated, container image scanned.
        security_domain: endpoint
        entity: "{{ affected_host }}"
        entity_type: system
        finding_score: 70
        owner: unassigned
        status: resolved
        urgency: high
        disposition: true_positive

    - name: Create ES investigation for CVE response chain
      splunk.es.splunk_investigation:
        name: "CVE Response - {{ rhsa_id }}"
        description: >
          Automated DEFEND/CONTAIN/COMPLY response for {{ rhsa_id }}.
          AAP workflow {{ tower_job_id }}.
        status: resolved
        owner: unassigned
        urgency: high
        sensitivity: amber
        disposition: true_positive

    - name: Attach evidence notes to the investigation
      splunk.es.splunk_notes:
        target_type: investigation
        investigation_ref_id: "{{ investigation_ref_id }}"
        content: >
          Before/after evidence: {{ evidence_url }}.
          Container image: {{ registry_url }}/parasol-app:{{ rhsa_id }}.
          OPA gates: all passed. Approval: granted.
```

> **Tip:** Investigation UUID
>
> `splunk_investigation` returns `investigation.after` and does not document an id. Set `investigation_ref_id` from `splunk.es.splunk_investigation_info` before attaching notes.

### Validation

#### Test

1. Fire a CVE alert (or lab webhook) and confirm **Vulnerability Containment** isolates `eth0` and hardens httpd while the service still answers internally.
2. Remove `/var/log/last-backup-timestamp` and confirm the OPA pre-patch check fails by gate name; restore and confirm it passes.
3. After patch and COMPLY, confirm before/after reports and a clean scanned image with the advisory label.

#### Expected Result

```
DEFEND completes in seconds; OPA blocks when gates fail; approved CONTAIN applies advisory;
COMPLY shows improved controls; registry lists parasol-app tagged with RHSA id.
```

#### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| EDA fires, workflow missing | Event Stream token | Rotate Controller token; match Splunk URL |
| OPA connection refused | OPA down / wrong port | `curl http://<opa-host>:8181/health` from EE |
| Approval timeout | No notifier | Email/webhook on approval step |
| Advisory not found | RHSM / repos | `subscription-manager refresh`; enable channel |

### Summary

Use Case B automates detect-contain-patch-prove: Splunk to EDA for immediate DEFEND, OPA and approval for CONTAIN, then COMPLY evidence and a labeled scanned image.

---

<h2 id="use-case-c-splunk-es-investigation-lifecycle">Use Case C: Splunk ES investigation lifecycle</h2>

### Overview

Use Cases A and B remediate and write findings back to Splunk ES. This use case goes further: manage the full Splunk Enterprise Security lifecycle -- correlation searches, findings, investigations, response plans, and notes -- as code through the `splunk.es` certified Ansible collection. Detection-as-code means reproducible, version-controlled security posture across environments.

### Workflow

```mermaid
graph LR
  Git([Git repo]) -->|splunk_correlation_searches| Splunk([Splunk ES])
  Splunk -->|Alert| EDA[EDA rulebook]
  EDA -->|Remediate| AAP[AAP Controller]
  AAP -->|splunk_finding| Splunk
  AAP -->|splunk_investigation| Splunk
  AAP -->|splunk_response_plan_execution| Splunk
```

### Solution Walkthrough

#### Step 1: Define correlation searches as code

**Operational Impact:** Medium

Version-control your Splunk ES correlation searches so detection rules are reproducible and auditable across dev, staging, and production:

```yaml
    - name: Ensure SSH brute-force correlation search exists
      splunk.es.splunk_correlation_searches:
        config:
          - name: "SSH Brute Force Detected"
            description: Failed SSH passwords above threshold
            search: >
              index=main sourcetype=linux_secure "Failed password"
              | stats count by src_ip
              | where count > 5
            scheduling: realtime
            cron_schedule: "*/5 * * * *"
        state: merged

    - name: Ensure CVE correlation search exists
      splunk.es.splunk_correlation_searches:
        config:
          - name: "CVE Alert"
            description: Critical or high CVE events in linux_secure
            search: >
              index=main sourcetype=linux_secure tag=vulnerability
              | lookup cve_database cve_id OUTPUT severity
              | where severity="critical" OR severity="high"
            scheduling: realtime
            cron_schedule: "*/10 * * * *"
        state: merged
```

> **Tip:** Audit existing searches first.
>
> Use `splunk.es.splunk_correlation_search_info` to gather current correlation searches before overwriting. Export, review, then converge.

#### Step 2: Automate investigation and response plan lifecycle

**Operational Impact:** Low

Create investigation types and response plans that standardize SOC workflows:

```yaml
    - name: Create investigation type for automated responses
      splunk.es.splunk_investigation_type:
        name: "Automated Remediation"
        description: "Investigations created by AAP automated response workflows"

    - name: Define response plan for brute-force incidents
      splunk.es.splunk_response_plan:
        name: "Brute Force Response Plan"
        description: >
          Standard response: revoke credentials, stop service,
          verify containment, close investigation.
        template_status: published
        phases:
          - name: Containment
            tasks:
              - name: Revoke credentials and stop service
                description: Vault lease revoke and ztaapp stop
                is_note_required: true
                owner: unassigned

    - name: Define response plan for CVE incidents
      splunk.es.splunk_response_plan:
        name: "CVE Response Plan"
        description: >
          Standard response: DEFEND containment, OPA-gated CONTAIN patch,
          COMPLY evidence collection, close investigation.
        template_status: published
        phases:
          - name: Containment
            tasks:
              - name: Contain patch and collect evidence
                description: DEFEND, CONTAIN, and COMPLY stages
                is_note_required: true
                owner: unassigned
```

#### Step 3: Apply response plans to active investigations

**Operational Impact:** Low

When remediation completes, apply the matching response plan to the investigation and mark tasks complete:

```yaml
    - name: Apply response plan to investigation
      splunk.es.splunk_response_plan_execution:
        investigation_ref_id: "{{ investigation_ref_id }}"
        response_plan: "Brute Force Response Plan"
        state: present
        tasks:
          - phase_name: Containment
            task_name: Revoke credentials and stop service
            status: ended
            owner: unassigned

    - name: Attach closing notes with evidence
      splunk.es.splunk_notes:
        target_type: investigation
        investigation_ref_id: "{{ investigation_ref_id }}"
        content: >
          Response plan executed. Containment task ended by AAP.
          Job ID: {{ tower_job_id }}.
          Evidence: {{ evidence_url | default('see AAP job artifacts') }}.
```

#### Step 4: Configure adaptive response notable events

**Operational Impact:** Low

Set up adaptive response actions that create notable events with consistent metadata:

```yaml
    - name: Configure adaptive response for credential revocation
      splunk.es.splunk_adaptive_response_notable_events:
        config:
          - correlation_search_name: "SSH Brute Force Detected"
            name: ssh_brute_force_notable
            description: Automated credential revocation triggered by brute-force detection
            default_owner: unassigned
            security_domain: access
            severity: critical
        state: merged

    - name: Configure adaptive response for CVE detection
      splunk.es.splunk_adaptive_response_notable_events:
        config:
          - correlation_search_name: "CVE Alert"
            name: cve_alert_notable
            description: Automated CVE response triggered
            default_owner: unassigned
            security_domain: endpoint
            severity: high
        state: merged
```

#### Step 5: Bootstrap Splunk data inputs with Ansible

**Operational Impact:** Medium

Automate the data input configuration that feeds correlation searches, so new Splunk deployments are production-ready:

```yaml
    - name: Configure syslog data input for authentication events
      splunk.es.splunk_data_inputs_network:
        config:
          - name: "9514"
            protocol: udp
            sourcetype: linux_secure
            index: main
        state: merged

    - name: Configure file monitor for authentication logs
      splunk.es.splunk_data_inputs_monitor:
        config:
          - name: "/var/log/secure"
            index: main
            sourcetype: linux_secure
        state: merged
```

### Validation

#### Test

1. Run the correlation search playbook against a lab Splunk instance. Confirm searches appear in **Settings > Correlation Searches** in Splunk ES.
2. Trigger a brute-force simulation and confirm an investigation is created with the correct response plan applied and notes attached.
3. Use `splunk.es.splunk_correlation_search_info` and `splunk.es.splunk_finding_info` to verify state matches what was declared.

#### Expected Result

```
Correlation searches appear in ES with the declared SPL and cron schedule. Notable events use the declared security domain and severity.
Findings and investigations created programmatically match declared state.
Response plans applied to investigations; tasks and notes visible in ES console.
```

#### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `splunk.es` modules fail to connect | httpapi misconfiguration | Set `ansible_connection: httpapi`, `ansible_network_os: splunk.es.splunk`, `ansible_httpapi_port: 8089`, `ansible_httpapi_use_ssl: true` |
| Correlation search not firing | Schedule or search syntax | Test the SPL in Splunk. On each `config` item, `scheduling` is `realtime` or `continuous`, and `cron_schedule` is a sibling of `scheduling` |
| Finding or investigation not visible in ES | Missing required create fields | Supply `security_domain`, `entity`, `entity_type`, and `finding_score` on create. Confirm Enterprise Security is installed |
| Notes task fails on id | Ref id was not returned by create | Look up `finding_ref_id` or `investigation_ref_id` with the matching `*_info` module |

### Summary

Use Case C treats Splunk ES configuration as code. Correlation searches, response plans, and investigation types live in Git, deploy through AAP, and stay consistent across environments. Combined with the write-back steps in Use Cases A and B, the integration is fully bidirectional -- Splunk detects, Ansible remediates, and results flow back into ES for SOC visibility.

---

## Maturity Path

| Maturity | Use Case A | Use Case B | Use Case C |
|----------|------------|------------|------------|
| **Crawl** | Splunk alert to Slack/ITSM; manual revoke | Alert only; manual SSH harden and patch tracking | `splunk_correlation_search_info` audit of existing searches |
| **Walk** | ITSM approval then AAP revoke playbook; ES finding write-back | EDA DEFEND automatic; operator approves patch; ES finding write-back | Correlation searches as code; `splunk_finding` write-back after remediation |
| **Run** | EDA auto-revoke Vault lease and stop service; full ES notable event | Full DEFEND / CONTAIN / COMPLY with OPA, evidence, and ES investigation | Full investigation lifecycle: auto-create investigations, apply response plans, close with evidence notes; correlation searches version-controlled in Git |

## Summary

Splunk plus EDA and AAP delivers three Security outcomes on one platform: **instant brute-force containment** via Vault and service isolation, **policy-gated CVE response** with automated compliance proof, and **bidirectional Splunk ES lifecycle management** through the `splunk.es` collection. The `splunk.es` integration closes the loop -- detection rules deploy as code, remediation results write back as findings and investigations, and response plans execute programmatically. Shared webhook and rulebook patterns keep all paths auditable; AIOps Splunk patterns remain in the separate AIOps Solution Guide.

## Next Steps

1. Start a free <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/trial">Ansible Automation Platform trial</a> including Event-Driven Ansible.
2. Work the <a target="_blank" href="https://github.com/ansible/workshops">Zero Trust Architecture workshop</a> for Use Case A patterns; apply Use Case B OPA and compliance stages in a RHEL 9 lab.
3. For Splunk AIOps (ITSI / RHEL / network), open [AIOps with Splunk and Event-Driven Ansible](README-AIOps-Splunk-ITSI.md).
4. For Splunk SOAR integration patterns beyond `splunk.es`, see <a target="_blank" href="https://docs.splunk.com/Documentation/SOAR/">Splunk SOAR documentation</a>.
5. Engage <a target="_blank" href="https://www.redhat.com/en/services/consulting">Red Hat Consulting</a> or <a target="_blank" href="https://www.redhat.com/en/services/training-and-certification">Training</a> for production security automation.
{% endraw %}
