{% raw %}
# Reducing Residual CVE Risk with Compensating Controls - Solution Guide <!-- omit in toc -->

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

When a critical CVE drops, the ticket says 9.8 and someone asks whether the fleet is exposed. Security maps the advisory to "whatever hardening we think we have." Engineers SSH into a handful of hosts and run `getenforce`, `sysctl`, and `update-crypto-policies --show`. The report, if there is one, is a pass/fail spreadsheet with no number attached to residual risk. CVSS environmental scoring was supposed to help. In practice almost nobody uses it, because it asks an analyst to guess.

Patching remains the fix. This guide does not pretend otherwise. What it does is turn **compensating controls** into Ansible: query which defenses actually attenuate this CVE, verify them read-only across the fleet, remediate what is safe to change, and return a modified CVSS vector with per-control attribution -- so residual risk is a measurement, not a feeling.

> **This guide is compensating controls, not the vendor patch.**
>
> For SIEM detection, emergency containment, OPA-gated vendor patching, CIS hardening, and hardened container delivery, see [Defend, Contain, Comply](README-DCC.md). The shared example CVE (CVE-2024-38476) is intentional: DCC patches httpd; this guide scores and applies host mitigations while you wait for the errata.

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [Compensating Controls Workflow](#compensating-controls-workflow)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Architecture Diagram](#workflow-architecture-diagram)
- [Solution Walkthrough](#solution-walkthrough)
  - [1. Query CME for Mitigating Controls](#1-query-cme-for-mitigating-controls)
  - [2. Verify Current Security Posture (PRE)](#2-verify-current-security-posture-pre)
  - [3. Remediate Controls That Ansible Can Change](#3-remediate-controls-that-ansible-can-change)
  - [4. Re-Verify and Report (POST)](#4-re-verify-and-report-post)
  - [5. Score Residual CVSS and Configure the Controller](#5-score-residual-cvss-and-configure-the-controller)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**CVE** names a specific vulnerability. **CWE** names the class of weakness that caused it. Neither tells you whether the host in front of you is actually harder to exploit than the advisory implies, or how to prove that to an auditor at 2 a.m.

**Common Mitigation Enumeration (CME)** is the third layer of that conversation: a taxonomy of 118 defensive controls -- kernel hardening, mandatory access control, cryptographic policy, syscall filtering, detection, and recovery -- each cataloged with the CVSS metrics it changes, the CWE classes it mitigates, and machine-runnable verification commands. CME-301 (SELinux Enforcing) is typical: Scope Changed becomes Unchanged (a compromised process stays in its SELinux domain), Confidentiality High becomes Low (it cannot read files outside policy). That mapping is a lookup table, not an analyst's dropdown.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://cmetaxonomy.org">CME taxonomy -- cmetaxonomy.org</a>

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/security/what-is-vulnerability-management">What is vulnerability management? -- redhat.com</a>

Traditional vulnerability management stops at the vendor patch. That is the right long-term answer, and it is the path in [Defend, Contain, Comply](README-DCC.md). The gap is the hours or days before the errata is available, tested, and approved. During that window the host may already have ASLR, SELinux, kernel lockdown, and a FUTURE crypto policy. Those controls change exploitability. They do not show up on the ticket, and no standard tool verifies them at fleet scale or rewrites the CVSS vector from what is actually active.

**Compliance-as-code** closes that gap by expressing each CME entry as an Ansible role with two jobs that stay separate on purpose: `verify.yml` (read-only audit) and `tasks/main.yml` (converge, then re-verify). Combined with the CME MCP server for vector mathematics, the pipeline starts with a CVE and ends with a scored posture report.

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **CME taxonomy and MCP server** for control knowledge, CVE-to-control mapping, and deterministic CVSS attenuation <a target="_blank" href="https://cmetaxonomy.org">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e6.png" width="20" style="vertical-align:text-bottom;"> **cme.controls Ansible collection** for 118 generated roles (`cme_101`, `cme_301`, ...), `cme_query` / `cme_score` modules, profiles, and HTML reports <a target="_blank" href="https://github.com/nmartins0611/cme/tree/main/collection">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** for orchestration, surveys, workflow approval gates, and RBAC <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** as the optional Run-stage front door -- a scanner webhook can launch the same playbook; no rulebook ships in this collection <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5a5.png" width="20" style="vertical-align:text-bottom;"> **RHEL 9** as the primary target platform -- `sysctl`, SELinux, crypto policies, and package-backed controls <a target="_blank" href="https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux">[Link]</a>

> **Roles stay in lockstep with the taxonomy.**
>
> `scripts/generate_collection.py` reads `data/entries/*.json` and writes the role tree. You do not hand-maintain 118 copies of verify logic. When a new CME entry lands, regenerate the collection.

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **Security Operations Engineer** | Manually mapping CVEs to hardening, SSH-ing into hosts, and assembling evidence with no standard format -- triage takes hours per CVE | `cme_query` maps vector and CWE to controls in seconds; `verify.yml` audits the fleet without changes; HTML reports are the audit artifact |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Automation Architect** | Compliance checks are one-off scripts; there is no reusable way to express "SELinux enforcing attenuates Scope" as code | 118 idempotent roles with a consistent verify/remediate split, profile-driven execution, and Controller configuration-as-code |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bc.png" width="20" style="vertical-align:text-bottom;"> **CISO / Security Director** | Cannot quantify how existing defenses reduce CVE risk; reports show pass/fail counts but not residual exposure | CVSS attenuation with per-metric attribution (for example 9.8 Critical toward a materially lower environmental score) while the patch is still in flight |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **Compliance Officer** | Evidence is terminal output pasted into spreadsheets, uncorrelated to any framework | Timestamped PRE/POST HTML reports with control-level pass/fail, tactic tags, and vector modifications |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f310.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://cmetaxonomy.org">Browse the CME catalog</a> -- 118 controls, CWE cross-reference, CVSS attenuation details
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://github.com/nmartins0611/cme">cme.controls collection</a> -- roles, playbooks, and MCP server in one repository
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3d7.png" width="20" style="vertical-align:text-bottom;"> [Defend, Contain, Comply](README-DCC.md) -- pair this guide with the vendor-patch lifecycle for the same CVE

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** -- required for Automation Controller workflow approval nodes. Event-Driven Ansible is optional and only needed at the Run stage (see [Maturity Path](#maturity-path)).

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/posix/">ansible.posix</a> | Certified | `sysctl`, `selinux` for kernel hardening and MAC enforcement |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/general/">community.general</a> | Community | Supporting utilities used by generated roles |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Controller configuration-as-code: organizations, job templates, workflows, credentials |
| <a target="_blank" href="https://github.com/nmartins0611/cme">cme.controls</a> | Custom | 118 CME roles (verify + remediate), `cme_score` and `cme_query` modules, filter plugins, profiles |

> **cme.controls is not on Automation Hub yet.**
>
> Install from the Git repository (`ansible-galaxy collection install ./collection` in a clone, or point a Project at the repo). An execution environment definition ships under `ee/` in the same tree.

### External Systems

| System | Required | Examples |
|--------|----------|----------|
| CME MCP Server | Yes | Public endpoint at `https://cmetaxonomy.org/mcp`, or self-hosted via Docker Compose in the CME repo. Offline scoring can use a local SQLite copy (`database_path`) |
| Target hosts | Yes | RHEL 8/9 (primary). Roles gate on `ansible_os_family` |
| Vulnerability scanner | Optional | Qualys, Tenable, Rapid7, RHACS -- any source that can supply CVE ID, CVSS vector, and CWE IDs as extra vars |
| SIEM / SOAR | Optional | Splunk, ServiceNow -- webhook notification on workflow completion |

**Operational Impact:** None for query, verify, score, and report. **High** for remediation (sysctl, SELinux mode, crypto policy, packages, services).

### Profiles

| Profile | Controls | Intent |
|---------|----------|--------|
| `minimal` | 25 | High-confidence kernel, MAC, and crypto. Start here. |
| `rhel9_baseline` | 55 | Remediable Red Hat baseline |
| `container_host` | 16 | Syscall and runtime isolation |
| `full` | 118 | Entire taxonomy, including verify-only entries |

Custom profiles are a YAML list of role names (`cme_101`, `cme_301`, `cme_601`) passed as `cme_profile_path`. Skip flags (`cme_301_skip: true`) and per-control defaults (`cme_401_crypto_policy: FIPS`) live in host_vars like any other collection.

<h2 id="compensating-controls-workflow"></h2>

## Compensating Controls Workflow

The workflow starts with a CVE identifier, a CVSS vector string, and optional CWE IDs -- typed into a job-template survey, passed as extra vars, or later injected by a scanner webhook. Phase 1 calls the CME MCP server: which of the 118 controls attenuate this vector or mitigate these weakness classes? The result is written to disk as a dynamic profile. Phase 2 runs every matched role's `verify.yml` across the inventory with no changes. Phase 3 applies remediation through a block/rescue wrapper so one failed role does not abort the fleet. Phase 4 re-verifies and writes PRE/POST HTML per host. Phase 5 sends the active-control lists to `cme_score` and returns the modified vector.

Not every control can be auto-remediated, and the collection is honest about that. Firewall rules are organization-specific. Container isolation depends on the orchestrator. Application input validation lives in code. Those roles verify and set `manual_remediation_required`. Hardware and compile-time controls (Secure Boot, FIPS, LUKS) emit a message and fall through. In a live RHEL 9 run of the `minimal` profile, posture moved from 12/25 to 15/25: three controls auto-fixed (kernel module loading, kexec restriction, crypto policy FUTURE); the remaining failures were not software-remediable.

### Operational Impact per Stage

| Stage | Impact | Description |
|-------|--------|-------------|
| 1. Query CME | None | Localhost-only MCP API call; no changes to target hosts |
| 2. PRE verify | None | Read-only shell commands and asserts; results land in `cme_results` |
| 3. Remediate | **High** | Modifies sysctl, SELinux mode, crypto policies, packages, and services |
| 4. POST verify + report | None | Read-only re-audit; HTML delegated to localhost |
| 5. CVSS scoring + CaC | None / Low | Localhost MCP call for scoring; CaC changes Controller objects only |

### Workflow Architecture Diagram

```
CVE advisory / survey extra vars
        |
        v
[cme.controls.cme_query] --> dynamic profile (role names)
        |
        v
[PRE verify.yml] --> cme_results (passed / failed)
        |
        v
[_apply_control.yml block/rescue] --> sysctl, SELinux, crypto, packages
        |
        v
[POST verify + HTML] --> PRE/POST reports per host
        |
        v
[cme.controls.cme_score] --> modified CVSS vector + per-metric attribution
```

On Automation Controller the same flow is a workflow template with an approval gate:

```
[Verify Posture] --> [Approve Remediation] --> [Remediate] --> [Posture Report + Score]
```

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

The featured playbook is `collection/playbooks/cve_response.yml` (collection path `cme.controls.cve_response`). Five plays, one CVE.

### 1. Query CME for Mitigating Controls

**Operational Impact:** None

The `cme.controls.cme_query` module asks the MCP server two questions: which controls attenuate metrics that are high-severity in this CVSS vector, and which controls mitigate these CWE IDs? Results are deduplicated, normalized to role names (`CME-301` becomes `cme_301`), and written as a dynamic profile.

**Featured Tasks:**

```yaml
- name: Query CME MCP for mitigating controls
  cme.controls.cme_query:
    cvss_vector: "{{ cvss_vector }}"
    cwe_ids: "{{ cwe_ids }}"
    mcp_endpoint: "{{ cme_mcp_endpoint }}"
  register: cme_query_result

- name: Build dynamic profile
  ansible.builtin.set_fact:
    cme_dynamic_profile:
      controls: "{{ cme_query_result.cme_ids | map('lower') | map('replace', '-', '_') | list }}"
```

> **RBAC:** Restrict MCP credential access.
>
> Assign the CME MCP Endpoint custom credential only to job templates that query or score. Do not attach it to generic machine-credential templates.

**Job Template Configuration:**

| Field | Value |
|-------|-------|
| **Name** | `CME -- CVE Response` |
| **Inventory** | `CME Target Hosts` |
| **Project** | `CME Compliance Collection` |
| **Playbook** | `collection/playbooks/cve_response.yml` |
| **Credentials** | `CME Machine Credential`, `CME MCP Server` |
| **Survey** | CVE ID, CVSS Vector, CWE IDs |

### 2. Verify Current Security Posture (PRE)

**Operational Impact:** None

The playbook loops the dynamic profile and includes each role's `verify.yml`. Verification commands come from the CME entry (for SELinux, `getenforce` must return `Enforcing`). Each role appends a structured dict to `cme_results`. Nothing on the host changes.

**Featured Tasks:**

```yaml
- name: Verify each control
  ansible.builtin.include_role:
    name: "{{ control_id }}"
    tasks_from: verify.yml
  loop: "{{ cme_target_controls }}"
  loop_control:
    loop_var: control_id
  ignore_errors: true

- name: Save PRE results
  ansible.builtin.set_fact:
    cme_pre_results: "{{ cme_results }}"
    cme_pre_passed: "{{ cme_results | selectattr('status', 'equalto', 'passed') | list }}"
    cme_pre_failed: "{{ cme_results | selectattr('status', 'equalto', 'failed') | list }}"
```

Standalone audit without a CVE query uses a named profile:

```bash
ansible-playbook cme.controls.verify -i inventory.yml -e cme_profile=minimal
```

### 3. Remediate Controls That Ansible Can Change

**Operational Impact:** High

Each control is applied through `_apply_control.yml` so an individual role failure is logged and the loop continues. Remediation is ordinary Ansible: kernel hardening via `ansible.posix.sysctl`, MAC via `ansible.posix.selinux`, crypto via `update-crypto-policies`, packages via `ansible.builtin.package`.

**Featured Tasks:**

```yaml
# _apply_control.yml -- block/rescue wrapper
- name: "Apply control {{ control_id }}"
  block:
    - name: "Include role {{ control_id }}"
      ansible.builtin.include_role:
        name: "{{ control_id }}"
  rescue:
    - name: "Log failure for {{ control_id }}"
      ansible.builtin.debug:
        msg: "Control {{ control_id }} remediation failed -- continuing with next control"
```

Example role remediation (CME-301, SELinux):

```yaml
- name: "CME-301 | Ensure SELinux packages are installed"
  ansible.builtin.package:
    name:
      - libselinux
      - policycoreutils
      - selinux-policy-targeted
    state: present
  when: ansible_os_family == 'RedHat'

- name: "CME-301 | Set SELinux to enforcing"
  ansible.posix.selinux:
    policy: targeted
    state: enforcing
  when: ansible_os_family == 'RedHat'
```

> **Warning:** Remediation modifies system state.
>
> FIPS mode, Secure Boot, and LUKS encryption require reboots or hardware support and cannot be applied in-place. Those roles emit a debug message and fall through to verify-only. Network, container, and application-layer roles set `manual_remediation_required` rather than inventing org-specific firewall rules.

> **RBAC:** Gate Execute on Remediate.
>
> Assign `Execute` on the Remediate and CVE Response templates only to the security operations team. Keep Verify available more broadly -- it is read-only.

### 4. Re-Verify and Report (POST)

**Operational Impact:** None

The playbook re-runs `verify.yml` on every control in the dynamic profile, diffs POST against PRE, and writes per-host HTML from `templates/verify_report.html.j2`. Report generation is delegated to localhost.

**Featured Tasks:**

```yaml
- name: Calculate remediation gains
  ansible.builtin.set_fact:
    cme_newly_passed: >-
      {{ (cme_post_passed | map(attribute='cme_id') | list)
         | difference(cme_pre_passed | map(attribute='cme_id') | list) }}

- name: Generate POST report
  ansible.builtin.template:
    src: "{{ playbook_dir }}/../templates/verify_report.html.j2"
    dest: "{{ cme_report_dir }}/cve_{{ cve_id }}_{{ inventory_hostname }}_POST.html"
    mode: "0644"
  delegate_to: localhost
```

`drift_check.yml` is the scheduled cousin of this step: save a baseline with `cme_save_baseline=true`, then re-run later to report controls that were active and are now inactive.

### 5. Score Residual CVSS and Configure the Controller

**Operational Impact:** None (scoring) / Low (Controller objects only)

`cme.controls.cme_score` sends the list of controls that actually passed verification to the MCP server (or a local SQLite file). Optional `base_score` and `base_vector` turn attenuation into a full simulation: original 9.8, modified vector, modification count. PRE and POST are both scored so the delta is visible.

**Featured Tasks:**

```yaml
- name: Calculate POST attenuation score
  cme.controls.cme_score:
    active_controls: "{{ all_post_active }}"
    mcp_endpoint: "{{ cme_mcp_endpoint }}"
    base_score: 9.8
    base_vector: "{{ cvss_vector }}"
  register: post_score
```

The module returns per-metric attribution:

```json
{
  "attenuation": [
    {"metric": "AC", "modified_to": "H", "contributing_controls": ["CME-101", "CME-104", "CME-109"]},
    {"metric": "AV", "modified_to": "A", "contributing_controls": ["CME-201"]},
    {"metric": "C",  "modified_to": "L", "contributing_controls": ["CME-108", "CME-406"]}
  ],
  "simulation": {
    "original": {"score": 9.8, "severity": "Critical"},
    "modified": {"score": 4.2, "severity": "Medium"},
    "modifications_applied": 26
  }
}
```

`collection/playbooks/configure_controller.yml` provisions the AAP side in one run: organization, custom credential type for the MCP URL, project, inventory, four job templates, a workflow with a 3600-second approval node, and an optional webhook notification.

```yaml
- name: Create CVE Response job template
  ansible.controller.job_template:
    name: "CME -- CVE Response"
    organization: "{{ cme_org_name }}"
    project: "{{ cme_project_name }}"
    playbook: "collection/playbooks/cve_response.yml"
    inventory: "{{ cme_inventory_name }}"
    credential: "{{ cme_credential_name }}"
    execution_environment: "{{ cme_ee_name }}"
    become_enabled: true
    survey_enabled: true
    survey_spec:
      name: "CVE Details"
      spec:
        - question_name: "CVE ID"
          variable: cve_id
          type: text
          required: true
        - question_name: "CVSS Vector"
          variable: cvss_vector
          type: text
          required: true
```

**Job Template Configuration (CaC):**

| Field | Value |
|-------|-------|
| **Name** | `CME -- Configure Controller` |
| **Inventory** | `localhost` |
| **Project** | `CME Compliance Collection` |
| **Playbook** | `collection/playbooks/configure_controller.yml` |
| **Credentials** | Automation Controller API token |
| **Extra Vars** | `controller_host`, `controller_oauthtoken`, `cme_scm_url` |

> **RBAC:** Limit controller configuration access.
>
> Only the automation architect team should have `Execute` on this template. It creates organizations, credentials, and job templates with `become_enabled`.

<h2 id="validation"></h2>

## Validation

### Test

Run the CVE response playbook from the CLI against a lab host. Use the public MCP or a local Docker Compose stack.

```bash
ansible-playbook collection/playbooks/cve_response.yml \
  -e cme_mcp_endpoint=http://localhost:8000 \
  -e 'cvss_vector=CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H' \
  -e '{"cwe_ids": ["CWE-829"]}' \
  -e cve_id=CVE-2024-38476 \
  -e cme_report_dir=./reports \
  -i inventory.yml
```

Or launch via the Controller API after CaC has created the template:

```bash
curl -sk https://controller.example.com/api/v2/job_templates/CME%20--%20CVE%20Response/launch/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"extra_vars": {"cve_id": "CVE-2024-38476", "cvss_vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H", "cwe_ids": ["CWE-829"]}}' \
  | jq .status
```

### Expected Result

Query returns a non-empty `cme_ids` list. PRE verify records passed/failed without `changed`. Remediation may change a subset of software-remediable controls. POST HTML files exist under `cme_report_dir`. The final summary resembles:

```
TASK [Display final CVE response summary] *************************************
ok: [localhost] => {
    "msg": "CVE RESPONSE SUMMARY -- CVE-2024-38476
             POSTURE:
               PRE:     24 controls active
               POST:    24 controls active
               GAINED:  +3 remediated
             CVSS ATTENUATION:
               POST: 7 metrics attenuated
                     AC: -> H  (19 controls)
                     AV: -> A  (1 control)
                     PR: -> H  (3 controls)"
}

PLAY RECAP *********************************************************************
localhost  : ok=12   changed=2    unreachable=0    failed=0    skipped=0
rhel-vm    : ok=48   changed=5    unreachable=0    failed=0    skipped=3
```

Exact pass counts depend on the host. A `minimal` profile run on a default RHEL 9 VM in testing moved 12/25 to 15/25; remaining failures were hardware or compile-time controls. Do not expect 118/118 green on `full`.

Confirm reports:

```bash
ls reports/cve_CVE-2024-38476_*_PRE.html reports/cve_CVE-2024-38476_*_POST.html
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `cme_query` returns an empty `cme_ids` list | MCP server unreachable, or CVSS vector format invalid | Verify the endpoint (`curl -sS "$CME_MCP/mcp"`). Vector must start with `CVSS:3.1/` or `CVSS:4.0/` |
| Remediation fails with `No route to host` | Target unreachable via SSH | Check network, SSH key or Machine credential, and inventory address |
| Package install fails on a role | Host not registered to repositories | `subscription-manager register` or configure local repos before Remediate |
| `cme_score` returns no attenuation | No passed controls were handed to the module | Confirm `cme_pre_passed` / `cme_post_passed` is non-empty; at least one control must be `passed` |
| Workflow approval node times out | No user with Approve is logged in | Assign the `Approve` role on the workflow and process within the timeout (default 3600s) |
| Role YAML parse error after a taxonomy update | Generator escaping drifted | Regenerate with `python scripts/generate_collection.py` from the CME repo |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Description |
|----------|-------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Run `cme.controls.verify` with the `minimal` profile (25 controls) on a single host. Read-only, no remediation. Review HTML from `verify_report.yml`. Zero operational risk; you learn which controls are already true. |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | Deploy `configure_controller.yml`. Use the Full Compliance Cycle workflow with the approval gate and `rhel9_baseline` (55 controls). Enable `cme_score` against the MCP. Security reviews PRE reports before Remediate runs. |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Point a scanner or the DCC Splunk/EDA pipeline at the CVE Response job template, passing `cve_id`, `cvss_vector`, and `cwe_ids`. The rulebook is an integration you write (or reuse from [Defend, Contain, Comply](README-DCC.md)); it is not a file in `cme.controls`. Policy-based severity gates can replace human approval for known CVEs. |

> **Crawl is the highest-value entry point.**
>
> A read-only `minimal` verify on one host produces the first honest posture number. Measure that before you enable Remediate.

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **[Defend, Contain, Comply](README-DCC.md)** -- SIEM detection, EDA containment, OPA-gated vendor patching, CIS hardening, and container delivery for the same CVE class
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **[Zero Trust Operations with Ansible](README-ZTA.md)** -- AAP as PEP, OPA as PDP, short-lived credentials, and automated credential revocation
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f517.png" width="20" style="vertical-align:text-bottom;"> **[AIOps automation with Ansible](README-AIOps.md)** -- event-driven plus AI workflows when you want diagnosis and playbook generation in front of this pipeline

<h2 id="summary"></h2>

## Summary

This solution turns 118 CME defensive controls into compliance-as-code Ansible roles so residual CVE risk is scored from what is actually running, not guessed in a CVSS environmental dropdown. Query maps a vector and CWE list to a dynamic profile. Verify is read-only. Remediate applies the subset Ansible can change, wrapped so one failure does not halt the fleet. Score returns a modified vector with per-control attribution. In testing against CVE-2024-38476, the pipeline showed measurable posture gains on remediable controls and left hardware-backed failures explicit instead of fake-green. Crawl is a single-host `minimal` audit; Walk adds Controller approval and scoring; Run attaches a scanner or the DCC EDA path to the same job template.

## Sources

- <a target="_blank" href="https://cmetaxonomy.org">Common Mitigation Enumeration -- cmetaxonomy.org</a>
- <a target="_blank" href="https://github.com/nmartins0611/cme">cme.controls collection -- GitHub</a>
- <a target="_blank" href="https://d3fend.mitre.org/">MITRE D3FEND</a>
- <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">Red Hat Ansible Automation Platform</a>
- <a target="_blank" href="https://access.redhat.com/security/cve/CVE-2024-38476">CVE-2024-38476 -- access.redhat.com</a>
{% endraw %}
