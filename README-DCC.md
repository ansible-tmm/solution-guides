{% raw %}
# Defend, Contain, Comply - Solution Guide <!-- omit in toc -->

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

When a critical CVE drops, most organizations scramble. Security operations investigates SIEM alerts manually, engineers SSH into hosts to apply ad-hoc firewall rules, patching waits for the next change window with no policy enforcement, and compliance teams assemble evidence by hand. Each step is slow, error-prone, and unauditable. For a CVSS 9.8 vulnerability like CVE-2024-38476 (Apache httpd SSRF via mod_rewrite), every hour of exposure is a breach waiting to happen.

This guide demonstrates how to automate the **full vulnerability lifecycle** -- from SIEM detection through emergency containment, policy-gated patching, CIS-aligned hardening, and hardened container delivery -- using Ansible Automation Platform. The result is a closed-loop pipeline that reduces mean time to containment (MTTC) from hours to seconds, enforces patching policy through OPA gates, and produces auditable compliance evidence at every stage.

> **This guide covers three phases of vulnerability response.**
>
> **Defend** -- detect and contain a vulnerability in seconds via Event-Driven Ansible. **Contain** -- remediate through policy-gated patching with approval workflows. **Comply** -- prove compliance posture, harden to CIS benchmarks, and deliver a trusted container image.

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [Defend, Contain, Comply Workflow](#defend-contain-comply-workflow)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Architecture Diagram](#workflow-architecture-diagram)
- [Solution Walkthrough](#solution-walkthrough)
  - [1. Event-Driven Vulnerability Containment (Defend)](#1-event-driven-vulnerability-containment-defend)
  - [2. Policy-Gated Patching with OPA (Contain)](#2-policy-gated-patching-with-opa-contain)
  - [3. Compliance Audit, CIS Hardening, and Container Delivery (Comply)](#3-compliance-audit-cis-hardening-and-container-delivery-comply)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**Vulnerability lifecycle management** is the process of identifying, evaluating, remediating, and verifying security vulnerabilities across an organization's infrastructure. The lifecycle spans five stages: detection (something is wrong), containment (limit the blast radius), remediation (fix the root cause), verification (prove the fix worked), and hardening (raise the baseline so the class of issue doesn't recur).

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/security/what-is-vulnerability-management">What is vulnerability management? -- redhat.com</a>

Most organizations handle these stages with disconnected tools and manual handoffs. A SIEM like Splunk detects the issue. An engineer investigates. A ticket gets filed. A change advisory board approves the patch days later. Someone applies it manually. Compliance runs a separate scan weeks after that. Each handoff adds latency and risk -- and none of it produces a unified audit trail.

**Policy-as-code** changes this model by making patching decisions programmable and auditable. Instead of relying on human judgment for every patch ("Is it in a maintenance window? Is there a recent backup? Is there enough disk space?"), an **Open Policy Agent (OPA)** instance evaluates these conditions against versioned Rego policies and returns an allow or deny decision. The automation platform acts on that decision -- if the policy says no, the patch does not proceed. This pattern is applicable to any gated operation: patching, configuration changes, certificate rotations, or container promotions.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.openpolicyagent.org/">Open Policy Agent -- openpolicyagent.org</a>

**CIS Benchmarks** provide industry-accepted hardening baselines for operating systems, cloud platforms, and applications. They define specific controls -- SSH configuration, kernel parameters, file permissions, service minimization -- with testable pass/fail criteria. Automating CIS-aligned hardening means every host reaches the same baseline, and pre/post audits produce the evidence auditors need.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.cisecurity.org/cis-benchmarks">CIS Benchmarks -- cisecurity.org</a>

Ansible Automation Platform ties these stages together. **Event-Driven Ansible** reacts to SIEM alerts in real time. **AAP workflows** orchestrate multi-step remediation with approval gates. **OPA integration** enforces policy before any change executes. The result is a single, auditable pipeline from detection to delivery.

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f50d.png" width="20" style="vertical-align:text-bottom;"> **Splunk Enterprise** for centralized log ingestion, CVE alert correlation, and saved search triggers <a target="_blank" href="https://www.splunk.com/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f517.png" width="20" style="vertical-align:text-bottom;"> **Red Hat Event-Driven Ansible Add-on for Splunk** to bridge Splunk saved searches to the EDA Controller via webhook <a target="_blank" href="https://splunkbase.splunk.com/app/7868">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** to receive Splunk alerts via Token Event Streams and trigger containment workflows <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** for workflow orchestration, approval nodes, and `set_stats` artifact passing <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Open Policy Agent (OPA)** as the policy decision point -- evaluates patch readiness and compliance controls via Rego policies <a target="_blank" href="https://www.openpolicyagent.org/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e6.png" width="20" style="vertical-align:text-bottom;"> **Podman** for building, scanning, and pushing hardened container images to a trusted registry <a target="_blank" href="https://podman.io/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e1.png" width="20" style="vertical-align:text-bottom;"> **RHEL 9** as the target platform -- SELinux, firewalld, AIDE, and CIS-aligned hardening <a target="_blank" href="https://www.redhat.com/en/technologies/linux-platforms/enterprise-linux">[Link]</a>

> **EDA is part of Ansible Automation Platform.**
>
> EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event. Think of it simply as inputs and outputs -- EDA is the automatic trigger for AAP, where Automation Controller is the enforcement output.

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **Security Operations Engineer** | Manually triaging SIEM alerts, SSH-ing into hosts to apply ad-hoc firewall rules, and hoping nothing was missed -- containment takes 45+ minutes per host | EDA-triggered containment executes in seconds: firewall lockdown, SELinux enforcement, module disabling, and AIDE monitoring -- all with a Splunk audit trail |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Platform Engineer** | Patching is either ungoverned (ad-hoc `dnf update` over SSH) or too slow (waiting days for CAB approval with no automated policy checks) | OPA policy gates enforce maintenance windows, backup recency, disk space, and service health automatically -- the patch only proceeds when every gate passes and a human approves |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **Compliance Officer** | Assembling audit evidence manually -- screenshotting configurations, copying terminal output into spreadsheets, running separate scans weeks after remediation | Automated before/after OPA compliance audits with timestamped HTML reports, CIS control-level pass/fail scoring, and workflow artifacts that form a continuous chain of evidence |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bc.png" width="20" style="vertical-align:text-bottom;"> **IT Director** | Vulnerability exposure windows measured in days, no way to prove remediation to auditors, and container deployments with unknown provenance | End-to-end pipeline from CVE detection to hardened container delivery -- measurable MTTC reduction, OPA-enforced policy compliance, and container images traceable to specific advisories |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3d7.png" width="20" style="vertical-align:text-bottom;"> [Defend, Contain, Comply Workshop](https://rhdp.redhat.com) -- the hands-on lab this guide is based on

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** -- Required for enterprise Event-Driven Ansible (EDA Controller) support, Token Event Streams, and workflow approval nodes.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | EDA event sources (`pg_listener` for Token Event Streams) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/posix/">ansible.posix</a> | Certified | `firewalld`, `seboolean`, `sysctl`, `selinux` for containment and hardening |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/containers/podman/">containers.podman</a> | Certified | `podman_image`, `podman_container`, `podman_tag`, `podman_image_info` for container lifecycle |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/community/general/">community.general</a> | Community | General-purpose utilities |

### External Systems

| System | Required | Examples |
|--------|----------|----------|
| SIEM | Yes | Splunk Enterprise or Splunk Cloud |
| Policy engine | Yes | Open Policy Agent (OPA) |
| Container registry | Yes | Any OCI-compliant registry (Quay, Harbor, local registry) |
| SCM | Yes | Gitea, GitHub, GitLab |

**Operational Impact:** Low (scan and audit phases) to Medium (patching, firewall changes, CIS hardening)

<h2 id="defend-contain-comply-workflow"></h2>

## Defend, Contain, Comply Workflow

The workflow has three phases, each implemented as an AAP workflow template:

1. **Vulnerability Containment** (Defend)

   Splunk detects a CVE alert. EDA receives the event via the Ansible Add-on for Splunk and triggers a containment workflow that scans the host, locks down the service to internal-only access, and hardens the security posture -- all within seconds of detection.

2. **Policy-Gated Patching** (Contain)

   When a patch becomes available, Ansible gathers system facts and submits them to OPA for policy evaluation. Only if all gates pass (maintenance window, recent backup, sufficient disk space, healthy service) does the workflow proceed to a human approval node. After approval, the advisory is applied, the service is restarted, and post-patch verification confirms the CVE is resolved.

3. **Compliance and Hardening** (Comply)

   A compliance audit evaluates the host against OPA-defined controls (SELinux, firewall, SSH, kernel parameters, file permissions, services, CVE state). CIS-aligned hardening closes any gaps. A second audit produces before/after evidence. Finally, a hardened container image is built from UBI9-minimal, scanned for vulnerabilities, and pushed to a trusted registry.

### Operational Impact per Stage

| Stage | Operational Impact | Why |
|-------|-------------------|-----|
| **Scan System** | **None** | Read-only -- queries `yum updateinfo` and reports to Splunk HEC. No changes to the host. |
| **Contain Service** | **Medium** | Creates a firewall containment zone, restricts access to RFC 1918 ranges, disables httpd modules, adds security headers. Service remains running but externally unreachable. |
| **Harden Posture** | **Low** | Enforces SELinux booleans and installs AIDE. No service restart required. |
| **Pre-Patch Check** | **None** | Read-only -- gathers facts and queries OPA. Blocks if policy fails. |
| **Patch System** | **High** | Applies security advisory via `dnf`, restarts the patched service. Should go through an approval gate. |
| **Compliance Audit** | **None** | Read-only -- gathers system state and evaluates against OPA compliance controls. |
| **CIS Harden** | **Medium** | Modifies SSH config, sysctl parameters, file permissions, and disables unnecessary services. Restarts sshd. |
| **Build / Scan / Push** | **Low** | Builds a container image, runs a non-root assertion, and pushes to the registry. No changes to the host OS. |

### Workflow Architecture Diagram

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                        DEFEND (Event-Driven)                                │
│                                                                              │
│  Splunk Alert ──► EDA Rulebook ──► Vulnerability Containment Workflow        │
│                                    ┌──────────┬──────────┬──────────┐        │
│                                    │ Scan     │ Contain  │ Harden   │        │
│                                    │ System   │ Service  │ Posture  │        │
│                                    └──────────┴──────────┴──────────┘        │
└──────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        CONTAIN (Policy-Gated)                                │
│                                                                              │
│  Policy-Gated Patching Workflow                                              │
│  ┌───────────┬──────────┬──────────┬───────────┬──────────┐                  │
│  │ Pre-Patch │ Approval │ Patch    │ Post-Patch│ Report   │                  │
│  │ OPA Check │ Gate     │ System   │ Verify    │ Evidence │                  │
│  └───────────┴──────────┴──────────┴───────────┴──────────┘                  │
└──────────────────────────────────────────────────────────────────────────────┘
                                         │
                                         ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        COMPLY (Audit + Deliver)                              │
│                                                                              │
│  Compliance and Hardening Workflow                                           │
│  ┌───────┬───────────┬───────┬────────┬───────┬──────┬──────┐               │
│  │ Audit │ CIS       │ Audit │ Report │ Build │ Scan │ Push │               │
│  │ (pre) │ Harden    │(post) │        │ Image │      │      │               │
│  └───────┴───────────┴───────┴────────┴───────┴──────┴──────┘               │
└──────────────────────────────────────────────────────────────────────────────┘
```

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

### 1. Event-Driven Vulnerability Containment (Defend)

**Operational Impact:** Medium

This phase closes the gap between CVE detection and initial response. Instead of waiting for an engineer to investigate a SIEM alert, triage the vulnerability, and manually apply firewall rules, Event-Driven Ansible triggers a containment workflow within seconds of detection.

The integration chain works as follows: a Splunk saved search runs on a schedule (e.g. every 5 minutes) and aggregates CVE detection events by host. When results match, the **Ansible Add-on for Splunk** fires a webhook to the EDA Controller's **Token Event Stream**. An EDA rulebook evaluates the event and triggers the **Vulnerability Containment** workflow, scoped to the affected host.

**EDA Rulebook -- Respond to Splunk CVE Alerts**

The rulebook uses `ansible.eda.pg_listener` as the event source (Token Event Stream) and matches on the Splunk saved search name. The `job_args.limit` dynamically scopes the workflow to the host reported in the alert payload:

```yaml
- name: Respond to Splunk CVE alerts
  hosts: all
  sources:
    - ansible.eda.pg_listener:
        token: "{{ EDA_WEBHOOK_TOKEN | default('') }}"

  rules:
    - name: CVE alert from Splunk - trigger containment
      condition: event.payload.search_name is search("CVE Alert")
      actions:
        - run_workflow_template:
            name: "Vulnerability Containment"
            organization: Default
            job_args:
              limit: "{{ event.payload.results.host }}"
            extra_vars:
              target_cve: "CVE-2024-38476"
              affected_host: "{{ event.payload.results.host }}"
              alert_source: "splunk"
```

> **Why `is search()` instead of `==`?**
>
> The `is search()` condition performs substring matching, which is more resilient than exact string comparison if the saved search name changes slightly. This is a best practice for EDA rulebooks consuming external event payloads.

**Vulnerability Containment Workflow**

The workflow runs three job templates in sequence: **Scan System**, **Contain Service**, and **Harden Posture**.

**Scan System** confirms the CVE is present by querying `yum updateinfo` and reports the finding to Splunk HEC:

```yaml
- name: Check if target CVE is present
  ansible.builtin.set_fact:
    cve_detected: "{{ target_cve in cve_list.stdout }}"

- name: Report CVE detection to Splunk via HEC
  ansible.builtin.uri:
    url: "{{ splunk_hec_url }}"
    method: POST
    headers:
      Authorization: "Splunk {{ splunk_hec_token }}"
    validate_certs: false
    body_format: json
    body:
      host: "{{ inventory_hostname }}"
      source: "/var/log/secure"
      sourcetype: "linux_secure"
      index: "main"
      event: >-
        vulnerability-scanner[{{ ansible_date_time.epoch }}]: CRITICAL:
        {{ target_cve }} confirmed on httpd service.
        Immediate action required. Host: {{ inventory_hostname }}

- name: Set scan result fact for downstream workflows
  ansible.builtin.set_stats:
    data:
      cve_detected: "{{ cve_detected }}"
      cve_id: "{{ target_cve }}"
      scan_host: "{{ inventory_hostname }}"
```

**Contain Service** creates a firewall containment zone that restricts the vulnerable service to internal networks only, disables unnecessary httpd modules, suppresses server version exposure, and adds security headers -- all while keeping the service running for internal consumers:

```yaml
- name: Restrict firewall access to internal networks only
  ansible.posix.firewalld:
    rich_rule: >-
      rule family=ipv4 source address={{ item }}
      service name={{ firewall_service }} accept
    permanent: true
    immediate: true
    state: enabled
    zone: "{{ containment_zone }}"
  loop: "{{ allowed_sources }}"

- name: Remove public access to the service
  ansible.posix.firewalld:
    service: "{{ firewall_service }}"
    permanent: true
    immediate: true
    state: disabled
    zone: public

- name: Move service interface to containment zone
  ansible.posix.firewalld:
    zone: "{{ containment_zone }}"
    interface: "{{ ansible_default_ipv4.interface }}"
    permanent: true
    immediate: true
    state: enabled
```

> **RBAC:** The containment playbook requires `become: true` for firewalld and httpd configuration changes. In AAP, use a machine credential with sudo privileges scoped to the `appservers` inventory group.

**Harden Posture** enforces SELinux booleans to restrict httpd capabilities and installs AIDE for file integrity monitoring:

```yaml
- name: Enforce SELinux booleans for httpd containment
  ansible.posix.seboolean:
    name: "{{ item.name }}"
    state: "{{ item.state }}"
    persistent: true
  loop:
    - { name: httpd_can_network_connect, state: false }
    - { name: httpd_can_sendmail, state: false }
    - { name: httpd_enable_cgi, state: false }
    - { name: httpd_use_nfs, state: false }

- name: Create AIDE check cron job
  ansible.builtin.cron:
    name: "AIDE integrity check"
    minute: "0"
    hour: "*/4"
    job: "/usr/sbin/aide --check | /usr/bin/logger -t aide-check"
    user: root
```

### 2. Policy-Gated Patching with OPA (Contain)

**Operational Impact:** High

Once a patch is available (in this scenario, RHSA-2024:5138 for httpd), the question is not *whether* to patch, but *when it is safe to do so*. Policy-gated patching replaces ad-hoc judgment with programmable, auditable gates.

**OPA Patch Policy (Rego)**

The OPA policy defines four automatable gates. All must pass before patching is allowed. A fifth gate -- human approval -- is implemented as an AAP workflow approval node:

```rego
package dcc.patch_policy

import rego.v1

default allow_patch := false

maintenance_window_ok if {
  hour := input.current_hour
  hour >= 6
  hour < 22
}

backup_current if {
  input.backup_age_hours < 24
}

disk_space_ok if {
  input.free_disk_gb > 2
}

service_healthy if {
  input.service_state == "active"
}

allow_patch if {
  count(failed_gates) == 0
}

result := {
  "allow_patch": allow_patch,
  "gates": gate_results,
  "failed_gates": failed_gates,
  "total_gates": count(gate_results),
  "passed_gates": count(gate_results) - count(failed_gates),
}
```

> **Why OPA instead of Ansible conditionals?**
>
> Rego policies are version-controlled separately from playbooks, evaluated externally (separation of concerns), and queryable via REST API. This means security teams can update policy without modifying automation code, and every decision is logged with the full input context.

**Pre-Patch Policy Check Playbook**

The playbook gathers system facts, packages them into an OPA-compatible input, and queries the policy endpoint. If any gate fails, the playbook fails and the workflow halts:

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
    return_content: true
  register: _opa_response

- name: Fail if policy gates not met
  ansible.builtin.fail:
    msg: >-
      POLICY VIOLATION: {{ _opa_response.json.result.failed_gates | join(', ') }}
      failed. Patching not permitted.
  when: not (_opa_response.json.result.allow_patch | bool)

- name: Record policy check pass
  ansible.builtin.set_stats:
    data:
      pre_patch_policy_passed: true
      policy_check_timestamp: "{{ ansible_date_time.iso8601 }}"
      policy_gates_passed: "{{ _opa_response.json.result.passed_gates }}"
```

**Policy-Gated Patching Workflow**

The AAP workflow chains five nodes in sequence, with the approval node acting as the fifth (human) gate:

1. **Pre-Patch Check** -- Queries OPA; fails the workflow if any gate is blocked
2. **Approve Patch Application** -- AAP approval node (900-second timeout); a human reviewer sees the policy check results and approves or denies
3. **Patch System** -- Applies the security advisory via `ansible.builtin.dnf` with `security: true` and `advisory: RHSA-2024:5138`
4. **Post-Patch Verify** -- Asserts the CVE is no longer in the advisory list, the service is active, and SELinux is enforcing
5. **Report Compliance** -- Generates a timestamped HTML compliance report as a workflow artifact

**Patch Application**

```yaml
- name: Apply security advisory patch
  ansible.builtin.dnf:
    name: "*"
    security: true
    advisory: "{{ target_advisory }}"
    state: latest
  register: _patch_result

- name: Restart patched service
  ansible.builtin.systemd:
    name: "{{ target_service }}"
    state: restarted
  when: _patch_result.changed

- name: Wait for service to stabilize
  ansible.builtin.wait_for:
    port: "{{ service_port | default(443) }}"
    delay: 5
    timeout: 60
```

**Post-Patch Verification**

```yaml
- name: Verify target CVE is no longer in advisory list
  ansible.builtin.command:
    cmd: yum updateinfo list cves --quiet
  register: _post_patch_cves
  changed_when: false

- name: Assert CVE has been resolved
  ansible.builtin.assert:
    that:
      - target_cve not in _post_patch_cves.stdout
    fail_msg: >-
      COMPLIANCE FAILURE: {{ target_cve }} still appears in security
      advisories after patching. Manual investigation required.
    success_msg: "{{ target_cve }} resolved - no longer in pending advisories."

- name: Record verification results
  ansible.builtin.set_stats:
    data:
      post_patch_verified: true
      cve_resolved: "{{ target_cve not in _post_patch_cves.stdout }}"
      service_healthy: "{{ _service_post.status.ActiveState == 'active' }}"
      selinux_enforcing: "{{ _selinux_status.stdout == 'Enforcing' }}"
```

### 3. Compliance Audit, CIS Hardening, and Container Delivery (Comply)

**Operational Impact:** Medium

The final phase proves the security posture, closes any remaining gaps, and delivers a hardened container image. This produces the evidence chain that auditors and compliance officers need: a before snapshot, a hardening action, an after snapshot, and a traceable container artifact.

**Compliance Audit via OPA**

The audit playbook gathers system state across 13 controls -- SELinux mode, firewall state, SSH configuration, kernel sysctl parameters, file permissions, service state, and open CVEs -- and submits the full payload to OPA for evaluation:

```yaml
- name: Build OPA input payload
  ansible.builtin.set_fact:
    opa_input:
      selinux_mode: "{{ _selinux.stdout }}"
      firewall_active: "{{ _firewall.rc == 0 }}"
      ssh_permit_root_login: "{{ ssh_permit_root_login }}"
      ssh_x11_forwarding: "{{ ssh_x11_forwarding }}"
      ssh_max_auth_tries: "{{ ssh_max_auth_tries | int }}"
      ssh_client_alive_interval: "{{ ssh_client_alive_interval | int }}"
      sysctl_accept_redirects: "{{ _sysctl_values.results[0].stdout | int }}"
      sysctl_send_redirects: "{{ _sysctl_values.results[1].stdout | int }}"
      sysctl_randomize_va_space: "{{ _sysctl_values.results[2].stdout | int }}"
      passwd_mode: "{{ _file_perms.results[0].stat.mode }}"
      shadow_mode: "{{ _file_perms.results[1].stat.mode }}"
      rpcbind_enabled: "{{ _rpcbind.stdout == 'enabled' }}"
      open_cves: "{{ [target_cve] if target_cve in _cve_list.stdout else [] }}"

- name: Query OPA compliance policy
  ansible.builtin.uri:
    url: "{{ opa_url }}/v1/data/dcc/compliance/result"
    method: POST
    body_format: json
    body:
      input: "{{ opa_input }}"
    return_content: true
  register: _opa_response

- name: Set audit stats for workflow
  ansible.builtin.set_stats:
    data:
      "{{ audit_phase }}_audit_compliant": "{{ _opa_response.json.result.compliant }}"
      "{{ audit_phase }}_audit_pass_count": "{{ _opa_response.json.result.passed }}"
      "{{ audit_phase }}_audit_total_count": "{{ _opa_response.json.result.total }}"
```

The audit runs twice -- once before hardening (`audit_phase: pre`) and once after (`audit_phase: post`). The before/after pass counts are captured as workflow `set_stats` artifacts, providing a quantitative compliance improvement metric.

**CIS Benchmark-Aligned Hardening**

The hardening playbook applies controls aligned with the CIS RHEL 9 benchmark across five domains:

```yaml
- name: Harden SSH configuration
  ansible.builtin.copy:
    content: |
      PermitRootLogin no
      X11Forwarding no
      MaxAuthTries 4
      ClientAliveInterval 300
      ClientAliveCountMax 0
      PermitEmptyPasswords no
      IgnoreRhosts yes
      HostbasedAuthentication no
      Banner /etc/issue.net
    dest: /etc/ssh/sshd_config.d/99-cis-hardening.conf
    mode: "0600"
    owner: root
    group: root
  notify: Restart sshd

- name: Apply kernel sysctl hardening
  ansible.posix.sysctl:
    name: "{{ item.key }}"
    value: "{{ item.value }}"
    sysctl_set: true
    reload: true
    state: present
  loop: "{{ sysctl_hardening | dict2items }}"

- name: Stop and disable unnecessary services
  ansible.builtin.systemd:
    name: "{{ item }}"
    state: stopped
    enabled: false
  loop: "{{ unnecessary_services }}"
  failed_when: false
```

The hardening covers:
- **SSH:** Root login disabled, X11 forwarding off, max auth tries 4, client alive interval 300s, empty passwords denied
- **File permissions:** `/etc/shadow` and `/etc/gshadow` set to `0000`, `/etc/ssh/sshd_config` to `0600`
- **Kernel:** ICMP redirects disabled, source routing blocked, martian logging enabled, ASLR enforced (`randomize_va_space: 2`)
- **Services:** `rpcbind` and `avahi-daemon` stopped and disabled
- **Login:** Restrictive umask (`027`), core dumps disabled, cron restricted to root

**Hardened Container Build and Delivery**

The final stage produces a hardened container image from UBI9-minimal with full advisory traceability:

```dockerfile
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

LABEL maintainer="platform-team@meridian.example.com" \
      description="Hardened httpd application - post-remediation" \
      version="latest" \
      security.remediated="true" \
      security.advisory="RHSA-2024:5138"

RUN microdnf install -y httpd mod_ssl && \
    microdnf clean all && \
    rm -rf /var/cache/yum

COPY httpd.conf /etc/httpd/conf/httpd.conf
COPY index.html /var/www/html/index.html

RUN chown -R apache:apache /var/www/html && \
    chown -R apache:apache /etc/httpd/logs && \
    chown -R apache:apache /run/httpd && \
    chmod -R 0755 /var/www/html

EXPOSE 8443

USER apache

CMD ["httpd", "-D", "FOREGROUND", "-f", "/etc/httpd/conf/httpd.conf"]
```

The image is built with Podman, scanned for vulnerabilities (including a non-root user assertion), and pushed to a trusted registry:

```yaml
- name: Build container image with Podman
  containers.podman.podman_image:
    name: "{{ registry_url }}/{{ container_name }}"
    tag: "{{ container_tag }}"
    path: "{{ build_context }}"
    build:
      file: Containerfile
      format: oci
  register: _build_result

- name: Verify image runs without root
  ansible.builtin.command:
    cmd: >-
      podman inspect --format
      '{{.Config.User}}'
      {{ registry_url }}/{{ container_name }}:{{ container_tag }}
  register: _image_user
  changed_when: false

- name: Assert container does not run as root
  ansible.builtin.assert:
    that:
      - _image_user.stdout | trim | length > 0
      - _image_user.stdout | trim != "root"
      - _image_user.stdout | trim != "0"
    fail_msg: "SECURITY: Container runs as root. Must use non-root user."
    success_msg: "Container user: {{ _image_user.stdout | trim }} (non-root)."

- name: Push image to registry
  containers.podman.podman_image:
    name: "{{ registry_url }}/{{ container_name }}"
    tag: "{{ container_tag }}"
    push: true
    push_args:
      dest: "{{ registry_url }}/{{ container_name }}:{{ container_tag }}"
```

> **RBAC:** Container build and push operations require access to Podman on the target host. In AAP, this runs as the `rhel` machine credential. Registry authentication (if required) should use an AAP credential type for container registries.

**Compliance and Hardening Workflow**

The full workflow chains seven nodes: Pre-Audit → CIS Harden → Post-Audit → Report → Build Container → Scan Image → Push to Registry. All nodes connect with "On Success" links, so a failure at any stage halts the pipeline.

<h2 id="validation"></h2>

## Validation

### Test

Launch the **Compliance and Hardening** workflow from AAP Controller against the target host group. This exercises the full comply phase end-to-end:

```bash
curl -sk -X POST \
  https://<aap-controller>/api/v2/workflow_job_templates/<workflow-id>/launch/ \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"limit": "appservers", "extra_vars": {"target_cve": "CVE-2024-38476", "audit_phase": "pre"}}'
```

Alternatively, launch from the AAP Controller UI: **Templates** → **Compliance and Hardening** → **Launch**.

### Expected Result

The workflow job completes with all nodes successful. The `set_stats` artifacts show:

```
pre_audit_pass_count: 7
post_audit_pass_count: 13
pre_audit_compliant: false
post_audit_compliant: true
hardening_controls_applied: 7
```

The container image is present in the registry:

```bash
$ curl -s http://registry:5000/v2/meridian-app/tags/list
{"name":"meridian-app","tags":["latest","2024-07-15"]}
```

The compliance report at `/tmp/compliance-reports/` contains timestamped HTML with control-level pass/fail details.

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| EDA rulebook activation shows "No events received" | Splunk Add-on not configured with the correct EDA webhook URL or token | Verify the Token Event Stream URL and API key in the Splunk Add-on's `DCC` environment configuration |
| Pre-patch check fails with "backup_current" gate blocked | Backup marker file missing or older than 24 hours | Create or refresh the backup marker: `touch /var/log/last-backup-timestamp` |
| OPA returns connection refused | OPA container not running on the central host | Verify with `podman ps` on the central host; restart with `podman start opa` |
| Container build fails with "Containerfile not found" | Template rendering step skipped or build context directory missing | Ensure the `Containerfile.j2` template exists in the expected path and the build context directory was created |
| Post-patch verify asserts CVE still present | Errata repository not configured or `dnf` cache stale | Verify the errata repo is accessible (`yum repolist`), then clear cache with `dnf clean all` and re-run |
| Push to registry fails with connection refused | Local registry container not running | Start with `podman start workshop-registry` and verify with `curl http://localhost:5000/v2/` |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Description |
|----------|-------------|
| **Crawl** | Run scan and containment playbooks manually from AAP job templates. Deploy OPA in audit mode (log decisions but don't block). Run compliance audits on demand and review reports manually. |
| **Walk** | Connect Splunk to EDA for automated containment on detection. Enforce OPA policy gates on patching with human approval nodes. Schedule compliance audits on a recurring basis. Build container images as part of the patching workflow. |
| **Run** | Full closed-loop pipeline: Splunk alert → EDA containment → policy-gated patch → compliance audit → CIS harden → container build → scan → push. Extend to fleet-wide scanning across all hosts. Integrate with ITSM (ServiceNow, Jira) for ticket creation and closure. Add OpenSCAP or SCAP Security Guide profiles for formal CIS/STIG compliance scanning. |

<h2 id="related-guides"></h2>

## Related Guides

- [AIOps automation with Ansible](README-AIOps.md) -- the broader EDA + AI self-healing pipeline, including AI-driven root cause analysis and Lightspeed playbook generation
- [AIOps with Splunk and Event-Driven Ansible](README-AIOps-Splunk-ITSI.md) -- deeper Splunk integration patterns including ITSI predictive analytics and ML-driven anomaly detection
- [Zero Trust Operations with Ansible](README-ZTA.md) -- OPA policy-as-code, SPIFFE workload identity, and short-lived credentials for zero-trust automation
- [Reducing Residual CVE Risk with Compensating Controls](README-CME.md) -- verify and score host mitigations (ASLR, SELinux, crypto policy) while the vendor patch is still in flight
- [Post-Quantum Cryptography Readiness for RHEL](README-PQC.md) -- fleet cryptographic inventory, CycloneDX CBOM, and staged PQC remediation on the same RHEL hosts

<h2 id="summary"></h2>

## Summary

This guide demonstrated how to automate the full vulnerability lifecycle using Ansible Automation Platform -- from Splunk detection through EDA-driven containment, OPA policy-gated patching, CIS-aligned hardening, and hardened container delivery. The key outcomes are:

- **Mean time to containment reduced from hours to seconds** via Event-Driven Ansible reacting to Splunk CVE alerts
- **Zero patches without policy approval** -- OPA gates enforce maintenance windows, backup recency, disk space, and service health before any change proceeds
- **Auditable compliance evidence** generated automatically at every stage, with before/after OPA control scoring and timestamped HTML reports
- **Supply chain trust** through hardened container images traceable to specific security advisories, scanned for non-root execution, and pushed to a trusted registry

## Sources

- <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">Red Hat Ansible Automation Platform</a>
- <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">Event-Driven Ansible</a>
- <a target="_blank" href="https://www.openpolicyagent.org/">Open Policy Agent</a>
- <a target="_blank" href="https://www.cisecurity.org/cis-benchmarks">CIS Benchmarks</a>
- <a target="_blank" href="https://www.splunk.com/">Splunk Enterprise</a>
- <a target="_blank" href="https://splunkbase.splunk.com/app/7868">Red Hat Event-Driven Ansible Add-on for Splunk</a>
- <a target="_blank" href="https://podman.io/">Podman</a>
- <a target="_blank" href="https://access.redhat.com/security/cve/CVE-2024-38476">CVE-2024-38476 -- access.redhat.com</a>
{% endraw %}
