{% raw %}
# Triggering Automated Remediation from Splunk Alerts with Event-Driven Ansible - Solution Guide <!-- omit in toc -->

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

Splunk is the system of record for security and operations visibility in many enterprises -- ingesting logs, metrics, and events from thousands of sources. But when a critical Splunk alert fires, the response is still manual: an analyst reads the alert, opens a terminal, gathers context, and starts troubleshooting. This gap between **detection** and **resolution** is where MTTR lives. Organizations with hundreds of Splunk-generated alerts per day cannot scale human response to match.

This guide demonstrates how to connect Splunk alerts directly to **Event-Driven Ansible (EDA)**, triggering an automated pipeline that enriches the alert with AI-driven analysis and remediates the issue -- closing the loop from detection to resolution without requiring a human to interpret every alert manually.

The guide covers **two concrete use cases** that demonstrate the pattern across different infrastructure domains:

- **RHEL Server Remediation** -- Detect service failures, gather diagnostics, analyze with AI, and remediate
- **Network AIOps (OSPF)** -- Detect Cisco OSPF neighbor failures, enrich with AI-driven root cause analysis, and remediate with Lightspeed-generated playbooks

> **This guide builds on the AIOps reference architecture.**
>
> For the full end-to-end AIOps pipeline -- including AI inference, Lightspeed playbook generation, and the Crawl/Walk/Run maturity model -- see [AIOps automation with Ansible](README-AIOps.md). This guide focuses specifically on using **Splunk** as the observability trigger.

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [Splunk-to-Ansible Workflow](#splunk-to-ansible-workflow)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Diagram](#workflow-diagram)
- [Use Case A: RHEL Server Remediation](#use-case-a-rhel-server-remediation)
  - [A1. Configure Splunk Alert Action (Webhook)](#a1-configure-splunk-alert-action-webhook)
  - [A2. EDA Rulebook for Splunk Events](#a2-eda-rulebook-for-splunk-events)
  - [A3. Enrichment Workflow -- Gather Context and Analyze with AI](#a3-enrichment-workflow--gather-context-and-analyze-with-ai)
  - [A4. Notify and Remediate](#a4-notify-and-remediate)
- [Use Case B: Network AIOps -- OSPF Remediation](#use-case-b-network-aiops--ospf-remediation)
  - [B1. Configure Splunk for Network Event Detection](#b1-configure-splunk-for-network-event-detection)
  - [B2. EDA Rulebook for OSPF Events](#b2-eda-rulebook-for-ospf-events)
  - [B3. AI-Driven Ticket Enrichment](#b3-ai-driven-ticket-enrichment)
  - [B4. Network AIOps Workflow -- Lightspeed Remediation](#b4-network-aiops-workflow--lightspeed-remediation)
  - [B5. Validation -- Three OSPF Failure Scenarios](#b5-validation--three-ospf-failure-scenarios)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**Splunk** is a data platform that collects, indexes, and correlates machine-generated data -- logs, metrics, traces, and events -- from virtually any source across an organization's IT environment. Its search processing language (SPL) lets teams build saved searches and alerts that fire when conditions match predefined thresholds or patterns.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.splunk.com/en_us/products/splunk-enterprise.html">Splunk Enterprise -- splunk.com</a>

In traditional operations, a Splunk alert fires and creates a ticket or sends an email. A human then investigates, determines root cause, and manually remediates. This model works at small scale but breaks down as alert volume grows. **Event-Driven Ansible** eliminates this bottleneck by consuming Splunk alerts programmatically and triggering automation workflows in real time.

This applies equally to **server infrastructure** (service outages, resource exhaustion, configuration drift) and **network infrastructure** (OSPF adjacency failures, interface errors, routing misconfigurations). The same Splunk-to-EDA-to-AAP pipeline works across both domains -- only the detection logic, diagnostics collection, and remediation tasks change.

The combination of Splunk's detection capabilities with Ansible's remediation capabilities creates a **closed-loop operations model**: Splunk detects, EDA responds, AI enriches, and Ansible fixes.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? -- redhat.com</a>

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f50d.png" width="20" style="vertical-align:text-bottom;"> **Splunk Enterprise or Splunk Cloud** for centralized log ingestion, alerting, and correlation <a target="_blank" href="https://www.splunk.com/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** to receive Splunk webhook alerts and trigger automation <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Red Hat AI** for AI-driven root cause analysis of the alert context <a target="_blank" href="https://www.redhat.com/en/products/ai">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** workflows for orchestrating enrichment and remediation <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2728.png" width="20" style="vertical-align:text-bottom;"> **Ansible Lightspeed** to generate remediation playbooks from AI-enriched context <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/ansible-lightspeed">[Link]</a>

> **EDA is part of Ansible Automation Platform.**
>
> EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event. Think of it simply as inputs and outputs. EDA is an automatic way for inputs into Ansible Automation Platform, where Automation controller is the output (running a job template or workflow).

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **IT Ops Engineer / SRE** | Spending most of their day triaging Splunk alerts manually -- reading logs, SSH-ing into servers, running diagnostic commands | Splunk alerts automatically trigger enrichment and remediation workflows -- the fix starts before the engineer opens a terminal |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f310.png" width="20" style="vertical-align:text-bottom;"> **Network Engineer** | Manually troubleshooting OSPF adjacency failures across dozens of routers -- checking interface states, network types, and timers one device at a time | AI-driven diagnostics identify root cause automatically; Lightspeed generates targeted remediation playbooks with check-mode validation before execution |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Automation Architect** | Connecting Splunk to Ansible requires custom scripting, webhook plumbing, and fragile integrations | A reference architecture with production-ready EDA rulebooks, Splunk webhook configs, and tested collection usage -- applicable to both server and network domains |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **IT Manager / Director** | Alert fatigue and growing MTTR despite investment in both Splunk and Ansible | Closed-loop automation that turns Splunk from a detection tool into a detection-and-resolution tool -- with measurable MTTR reduction |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> [Hands-On AIOps Workshop -- Part 2: Network Automation with Splunk](https://rhpds.github.io/ai-driven-automation-showroom/modules/index.html) covers Splunk integration with Cisco router remediation end-to-end

**Source Code:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4bb.png" width="20" style="vertical-align:text-bottom;"> [ansible-tmm/aiops-summitlab](https://github.com/ansible-tmm/aiops-summitlab) -- Rulebooks, playbooks, and workflow definitions used in the network AIOps use case

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** -- Required for enterprise Event-Driven Ansible (EDA Controller) support and webhook event sources.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | EDA event sources and filters (webhooks, Kafka, etc.) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/namespaces/splunk/">splunk.es</a> | Certified | Manage Splunk Enterprise Security resources -- correlation searches, adaptive response actions, and data inputs |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Automation Controller configuration as code (job templates, workflows, surveys) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/redhat/ai">redhat.ai</a> | Certified | AI model inference using the OpenAI-compatible API via InstructLab |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/scm/">ansible.scm</a> | Certified | Git operations (commit and push generated playbooks) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/cisco/ios/">cisco.ios</a> | Certified | Cisco IOS device management -- required for the network AIOps use case |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/servicenow/itsm/">servicenow.itsm</a> | Certified | ServiceNow ITSM incident creation and enrichment |

### External Systems

| System | Required For | Notes |
|--------|-------------|-------|
| Splunk Enterprise or Splunk Cloud | Both use cases | Must be configured with saved searches or alerts that support webhook actions |
| AI inference endpoint | Both use cases | Red Hat AI (RHEL AI + InstructLab) or any OpenAI-compatible API |
| Ansible Lightspeed | Network use case | For dynamic playbook generation at the **Run** maturity level |
| Git repository | Network use case | GitHub, GitLab, or Gitea for storing generated playbooks |
| Chat or ITSM tool | Recommended | Slack, Mattermost, or ServiceNow for human-in-the-loop notifications |
| Cisco routers with OSPF | Network use case | Two or more Cisco IOS/IOS-XE devices with OSPF configured (e.g., Cat8000v) |

<h2 id="splunk-to-ansible-workflow"></h2>

## Splunk-to-Ansible Workflow

The workflow has four stages, matching the [AIOps reference architecture](README-AIOps.md):

1. **Splunk Alert -> EDA** -- A saved search or alert in Splunk fires and sends a webhook payload to EDA Controller.
2. **Enrichment Workflow** -- AAP gathers additional context from the affected host or device, sends the enriched data to Red Hat AI for root cause analysis, and notifies the operations team.
3. **Remediation Workflow** -- Ansible Lightspeed generates a remediation playbook from the AI analysis, commits it to Git, and creates a Job Template.
4. **Execute Remediation** -- The generated playbook runs against the affected infrastructure, resolving the issue.

### Operational Impact per Stage

| Stage | Operational Impact | Why |
|-------|-------------------|-----|
| **1. Splunk Alert -> EDA** | **None** | Read-only -- Splunk fires a webhook, EDA receives it. No changes to systems. |
| **2. Enrichment Workflow** | **Low** | Collects logs/diagnostics and system info, calls an AI API, posts to chat/ITSM. No infrastructure changes. |
| **3. Remediation Workflow** | **Low** | Generates a playbook, commits to Git, creates a Job Template. Prepares the fix but does not touch production. |
| **4. Execute Remediation** | **High** | Modifies production infrastructure. Should go through a change window or approval gate. |

### Workflow Diagram

```
Splunk Alert -> Webhook -> EDA Rulebook -> Enrichment Workflow -> AI Analysis -> Remediation Workflow -> Execute Fix
```

<a target="_blank" href="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/overview_diagram.png"><img src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/overview_diagram.png"></a>

> **Splunk replaces the Kafka/Filebeat layer.**
>
> In the AIOps reference architecture, Filebeat and Kafka handle event collection and transport. When using Splunk, it handles both -- Splunk ingests the data and fires the alert directly to EDA via webhook, simplifying the architecture.

---

<h2 id="use-case-a-rhel-server-remediation"></h2>

## Use Case A: RHEL Server Remediation

This use case demonstrates the Splunk-to-EDA pipeline for detecting and remediating RHEL server issues -- such as a failed httpd service.

### A1. Configure Splunk Alert Action (Webhook)

**Operational Impact:** None

Splunk alerts can trigger a **webhook action** that sends an HTTP POST to any endpoint -- including the EDA Controller webhook receiver. This is the bridge between Splunk's detection and Ansible's automation.

In Splunk, navigate to **Settings -> Searches, reports, and alerts** and edit (or create) a saved search. Under **Trigger Actions**, add a webhook action pointing to your EDA Controller:

| Field | Value |
|-------|-------|
| **Trigger condition** | Number of results is greater than 0 |
| **Trigger action** | Webhook |
| **URL** | `https://<eda-controller-host>:5000/endpoint` |

The webhook payload Splunk sends includes the search name, results count, and a link to the results. A typical payload looks like:

```json
{
  "sid": "scheduler_admin_search_RMD567890",
  "search_name": "High CPU Alert - web servers",
  "app": "search",
  "owner": "admin",
  "results_link": "https://<splunk-host>/app/search/@go?sid=scheduler_admin_search_RMD567890",
  "result": {
    "host": "web01.prod.internal",
    "sourcetype": "cpu_metrics",
    "cpu_percent": "98.5",
    "_raw": "2025-02-18 14:32:01 host=web01 cpu_percent=98.5 process=java pid=12345"
  }
}
```

> **Splunk Enterprise Security customers.**
>
> If you use Splunk Enterprise Security (ES), you can use **Adaptive Response Actions** instead of basic webhook alerts. The `splunk.es` Ansible collection can also manage correlation searches and notable events programmatically.

### A2. EDA Rulebook for Splunk Events

**Operational Impact:** None

The EDA rulebook listens for incoming webhook events from Splunk and triggers the enrichment workflow. The `ansible.eda.webhook` source plugin exposes an HTTP endpoint that Splunk's webhook action posts to.

```yaml
---
- name: Splunk alert response
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000

  rules:
    - name: Splunk high severity alert detected
      condition: event.payload.search_name is defined
      action:
        run_workflow_template:
          organization: "Default"
          name: "Splunk Alert Enrichment Workflow"
          extra_vars:
            alert_name: "{{ event.payload.search_name }}"
            affected_host: "{{ event.payload.result.host }}"
            raw_event: "{{ event.payload.result._raw }}"
            results_link: "{{ event.payload.results_link }}"
```

The rulebook extracts key fields from the Splunk webhook payload -- the search name, affected host, raw event data, and a link back to the Splunk results -- and passes them as extra variables to the enrichment workflow.

> **Filtering by severity or search name.**
>
> In production, you will want more specific conditions to avoid triggering automation on every Splunk alert. Filter by search name patterns, severity fields, or custom fields that your Splunk alerts include.

### A3. Enrichment Workflow -- Gather Context and Analyze with AI

**Operational Impact:** Low

Once EDA triggers the enrichment workflow, Ansible gathers additional context from the affected host and sends everything to Red Hat AI for root cause analysis. This is the same pattern described in the [AIOps reference architecture -- Log Enrichment and Prompt Generation Workflow](README-AIOps.md#2-log-enrichment-and-prompt-generation-workflow).

**Step 3a: Gather additional context from the affected host**

```yaml
- name: Gather host context for Splunk alert
  hosts: "{{ affected_host }}"
  become: true
  tasks:
    - name: Get systemd service status
      ansible.builtin.command:
        cmd: "systemctl status {{ service_name | default('httpd') }}"
      register: service_status
      ignore_errors: true

    - name: Collect recent journal logs
      ansible.builtin.command:
        cmd: "journalctl -u {{ service_name | default('httpd') }} --since '1 hour ago' --no-pager"
      register: journal_logs

    - name: Gather system facts
      ansible.builtin.setup:
        filter:
          - ansible_memtotal_mb
          - ansible_processor_vcpus
          - ansible_distribution*
```

**Step 3b: Analyze with Red Hat AI**

```yaml
- name: Analyze Splunk alert with Red Hat AI
  hosts: localhost
  tasks:
    - name: Build diagnostic prompt from host data and Splunk alert
      ansible.builtin.set_fact:
        enriched_prompt: |
          A Splunk alert fired: {{ alert_name }}
          Affected host: {{ affected_host }}
          Raw event: {{ raw_event }}
          Service status: {{ hostvars[affected_host].service_status.stdout }}
          Recent logs: {{ hostvars[affected_host].journal_logs.stdout | truncate(2000) }}

          Diagnose the root cause and recommend a remediation step.

    - name: Send diagnostics to Red Hat AI for root cause analysis
      redhat.ai.completion:
        base_url: "http://{{ rhelai_server }}:{{ rhelai_port }}"
        token: "{{ rhelai_token }}"
        prompt: "{{ enriched_prompt }}"
        model_path: "/root/.cache/instructlab/models/granite-8b-lab-v1"
      delegate_to: localhost
      register: ai_response
```

The AI response includes a diagnosis and recommended remediation, which feeds into the next stage.

### A4. Notify and Remediate

**Operational Impact:** Low (notification) -> **High** (remediation execution)

The enrichment workflow posts the AI analysis to your team's communication channel and -- depending on your maturity level -- either queues a remediation playbook for human approval or executes it automatically.

```yaml
    - name: Create enriched incident in ServiceNow with AI diagnosis
      servicenow.itsm.incident:
        state: new
        short_description: "Service Alert -- {{ alert_name }} -- {{ affected_host }}"
        description: |
          Splunk alert: {{ alert_name }}
          Host: {{ affected_host }}

          AI Root Cause Analysis:
          {{ ai_response.choice_0_text }}

          Diagnostics collected automatically -- see work notes for service status and logs.
        urgency: high
        impact: high
        caller: "ansible-automation"

    - name: Notify operations channel with diagnosis
      ansible.builtin.uri:
        url: "{{ slack_webhook_url }}"
        method: POST
        body_format: json
        body:
          text: |
            *Splunk Alert:* {{ alert_name }}
            *Host:* {{ affected_host }}
            *AI Diagnosis:* {{ ai_response.choice_0_text }}
            *Splunk Results:* {{ results_link }}

    - name: Attach AI analysis to Splunk notable event
      ansible.builtin.uri:
        url: "https://{{ splunk_server }}:8089/services/notable_update"
        method: POST
        user: "{{ splunk_user }}"
        password: "{{ splunk_password }}"
        force_basic_auth: true
        validate_certs: false
        body_format: form-urlencoded
        body:
          ruleUIDs: "{{ event_id }}"
          comment: "AI Analysis: {{ ai_response.choice_0_text }}"
          status: "2"
          urgency: "high"
```

> **Closing the loop back to Splunk.**
>
> Updating the Splunk notable event with the AI analysis creates a full audit trail -- the detection, diagnosis, and remediation are all visible in Splunk's incident review dashboard.

From here, the remediation follows the same pattern as the [AIOps Remediation Workflow](README-AIOps.md#3-remediation-workflow) -- Lightspeed generates a playbook, it gets committed to Git, and a Job Template is created for execution.

---

<h2 id="use-case-b-network-aiops--ospf-remediation"></h2>

## Use Case B: Network AIOps -- OSPF Remediation

This use case demonstrates the Splunk-to-EDA pipeline for **network infrastructure**, using Cisco OSPF neighbor failure detection as the trigger. It adds AI-driven ticket enrichment and uses Ansible Lightspeed to generate remediation playbooks with a human approval gate.

The complete source code for this use case is available at [ansible-tmm/aiops-summitlab](https://github.com/ansible-tmm/aiops-summitlab).

### B1. Configure Splunk for Network Event Detection

**Operational Impact:** None

Cisco IOS devices send syslog messages when OSPF neighbor adjacencies change state. Splunk ingests these syslogs, and a saved search triggers a webhook to EDA when an OSPF neighbor goes down.

**Step 1: Configure a TCP data input for Cisco syslogs**

In Splunk, navigate to **Settings -> Data Inputs -> TCP -> New Local TCP** and configure:

| Setting | Value |
|---------|-------|
| **Port** | 5514 |
| **Source Type** | `cisco:ios` |
| **App Context** | Cisco Networks (cisco:ios) |
| **Host** | IP |

**Step 2: Configure routers to forward syslogs to Splunk**

Run the `Network-Router-Setup` job template in AAP to configure OSPF routing and syslog forwarding on the Cisco routers. This playbook configures the target routers to send all syslog messages to Splunk over TCP port 5514.

> **Tip:** The full router setup playbook is available at [network_router_setup.yml on GitHub](https://github.com/ansible-tmm/aiops-summitlab/blob/main/playbooks/network_router_setup.yml).

**Step 3: Create a Splunk saved search and alert**

After routers are configured, verify that OSPF events appear in Splunk's **Cisco Networks App -> Routing Dashboard**. Then create an alert:

1. Search for: `%OSPF-5-ADJCHG: Process 1, Nbr 192.168.2.2 on Tunnel0 from FULL to DOWN`
2. **Save as Alert** with the following settings:

| Setting | Value |
|---------|-------|
| **Title** | `ospf-neighbor` |
| **Permissions** | Shared in App |
| **Alert type** | Real-time |
| **Actions** | Add to Triggered Alerts, Webhook |
| **Webhook URL** | EDA Controller webhook endpoint |

The alert name `ospf-neighbor` is the key identifier that the EDA rulebook uses to match incoming events.

### B2. EDA Rulebook for OSPF Events

**Operational Impact:** None

The EDA Controller is configured with:
- **Project**: `ai-eda` -- syncs from [ansible-tmm/aiops-summitlab](https://github.com/ansible-tmm/aiops-summitlab)
- **Rulebook Activation**: `OSPF Neighbor` -- runs the `ospf.yml` rulebook
- **Webhook Listener**: Listening on port 5000 for Splunk alerts

The rulebook ([ospf.yml](https://github.com/ansible-tmm/aiops-summitlab/blob/main/rulebooks/ospf.yml)):

```yaml
---
- name: "Listen for OSPF neighbor events on a webhook"
  hosts: all

  sources:
    - name: "Webhook listener for OSPF events"
      ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000

  rules:
    - name: "Process OSPF neighbor event from webhook"
      condition: event.payload.search_name == 'ospf-neighbor'
      actions:
        - debug:
            msg: |
              OSPF Webhook Received!
              Search Name: {{ event.payload.search_name }}
              Triggering workflow...

        - run_workflow_template:
            name: "Network-AIOps-Workflow"
            organization: "Default"
            job_args:
              extra_vars:
                webhook_payload: "{{ event.payload }}"
```

The rulebook matches specifically on `search_name == 'ospf-neighbor'` -- the exact alert name configured in Splunk. When matched, it launches the `Network-AIOps-Workflow` and passes the entire webhook payload as extra variables, making the event data available for subsequent automation steps.

### B3. AI-Driven Ticket Enrichment

**Operational Impact:** Low

When an OSPF neighbor goes down, the first thing a network engineer does is check the ITSM queue. If the ticket just says "OSPF neighbor down on cisco-rtr1," they still need to SSH in, run diagnostic commands, and figure out the root cause before they can act. This enrichment step eliminates that manual triage -- by the time the engineer opens the ticket, it already contains the AI-analyzed root cause and a recommended fix.

This follows the same pattern as the [RHEL enrichment workflow](#a3-enrichment-workflow--gather-context-and-analyze-with-ai) but uses network-specific diagnostics (`show` commands via `cisco.ios`) instead of RHEL diagnostics (`systemctl`, `journalctl`).

**Step 3a: Capture network diagnostics from the affected router**

```yaml
- name: Collect OSPF diagnostics from affected router
  hosts: "{{ affected_router | default('cisco-rtr1') }}"
  gather_facts: false
  tasks:
    - name: Get OSPF neighbor adjacency state
      cisco.ios.ios_command:
        commands:
          - show ip ospf neighbor
      register: ospf_neighbor

    - name: Get Tunnel0 interface status and counters
      cisco.ios.ios_command:
        commands:
          - show interface Tunnel0
      register: interface_status

    - name: Get OSPF interface details -- network type, hello timer, cost
      cisco.ios.ios_command:
        commands:
          - show ip ospf interface Tunnel0
      register: ospf_interface
```

**Step 3b: Analyze root cause with Red Hat AI**

```yaml
- name: Analyze OSPF failure and generate root cause diagnosis
  hosts: localhost
  tasks:
    - name: Build diagnostic prompt from router output
      ansible.builtin.set_fact:
        enriched_prompt: |
          A Splunk alert detected an OSPF neighbor adjacency failure.
          Alert: {{ alert_name }}
          Router: {{ affected_router }}

          OSPF Neighbor State:
          {{ hostvars[affected_router].ospf_neighbor.stdout[0] }}

          Interface Status:
          {{ hostvars[affected_router].interface_status.stdout[0] }}

          OSPF Interface Details:
          {{ hostvars[affected_router].ospf_interface.stdout[0] }}

          Diagnose the root cause of the OSPF neighbor failure and recommend a specific remediation action.

    - name: Send diagnostics to Red Hat AI for root cause analysis
      redhat.ai.completion:
        base_url: "http://{{ rhelai_server }}:{{ rhelai_port }}"
        token: "{{ rhelai_token }}"
        prompt: "{{ enriched_prompt }}"
        model_path: "/root/.cache/instructlab/models/granite-8b-lab-v1"
      delegate_to: localhost
      register: ai_response
```

**Step 3c: Create enriched ITSM ticket and update Splunk**

The AI diagnosis is written back to both the ITSM system (so the engineer sees it immediately when they open the ticket) and the Splunk notable event (so the detection and diagnosis are linked in the same audit trail).

```yaml
    - name: Create enriched incident in ServiceNow
      servicenow.itsm.incident:
        state: new
        short_description: "OSPF Neighbor Down -- {{ affected_router }} -- Tunnel0"
        description: |
          Splunk alert: {{ alert_name }}
          Router: {{ affected_router }}

          AI Root Cause Analysis:
          {{ ai_response.choice_0_text }}

          Diagnostics collected automatically -- see work notes for full output.
        urgency: high
        impact: high
        caller: "ansible-automation"
      register: snow_incident

    - name: Attach Splunk alert link to Splunk notable event
      ansible.builtin.uri:
        url: "https://{{ splunk_server }}:8089/services/notable_update"
        method: POST
        user: "{{ splunk_user }}"
        password: "{{ splunk_password }}"
        force_basic_auth: true
        validate_certs: false
        body_format: form-urlencoded
        body:
          ruleUIDs: "{{ event_id }}"
          comment: "AI Root Cause Analysis: {{ ai_response.choice_0_text }} | Incident: {{ snow_incident.record.number }}"
          status: "2"
          urgency: "high"

    - name: Notify operations channel with diagnosis and ticket link
      ansible.builtin.uri:
        url: "{{ chat_webhook_url }}"
        method: POST
        body_format: json
        body:
          text: |
            *OSPF Neighbor Down -- {{ affected_router }}*
            *AI Diagnosis:* {{ ai_response.choice_0_text }}
            *Incident:* {{ snow_incident.record.number }}
            *Action:* Remediation workflow pending approval in AAP.
```

> **Why enrich before remediating?**
>
> By the time the network engineer sees the ServiceNow ticket, it already contains the AI-analyzed root cause, the collected diagnostics, and a link to the pending remediation workflow. Instead of spending 20 minutes SSH-ing into routers and running `show` commands, they can review the diagnosis and approve the fix in AAP -- or escalate if the AI analysis doesn't look right. The Splunk notable event also gets the diagnosis, creating a full audit trail from detection through resolution.

### B4. Network AIOps Workflow -- Lightspeed Remediation

**Operational Impact:** Low (generation) -> **High** (execution)

The `Network-AIOps-Workflow` orchestrates the full remediation pipeline. After the enrichment step, the workflow uses Ansible Lightspeed to generate a remediation playbook, validates it in check mode, and waits for human approval before applying the fix.

**Workflow steps:**

```
Create Playbook AI -> Sync Project -> Playbook-Check-Mode -> [Human Approval] -> Playbook-Run-Mode
```

**Step 4a: Generate remediation playbook with Lightspeed**

The `Create Playbook AI` job template calls the Lightspeed API with a natural language prompt written by the network engineer. Here is the prompt for Scenario 1 (interface shutdown) -- the simplest case:

```yaml
---
- name: Generate OSPF remediation playbook via Lightspeed
  hosts: localhost
  gather_facts: false
  vars:
    lightspeed_prompt: |
     "Create a playbook and name it 'OSPF Fix'
     host ==  cisco-rtr1
     create a task that shows the status of Tunnel0 and register the output
     run a new task that administratively enables interface for parent interface tunnel0
     when stdout contains 'administratively down'"
```

For Scenarios 2 and 3, the prompt grows incrementally -- adding conditional checks for OSPF network type and hello timer mismatches. The full cumulative prompt covering all three scenarios is in the [network_aiops.yml playbook on GitHub](https://github.com/ansible-tmm/aiops-summitlab/blob/main/playbooks/network_aiops.yml).

Lightspeed generates the YAML playbook, which is saved to the Gitea repository and made available for the next workflow steps:

```yaml
    - name: Call Lightspeed API to generate remediation playbook
      ansible.builtin.uri:
        url: "https://c.ai.ansible.redhat.com/api/v0/ai/generations/"
        method: POST
        headers:
          Content-Type: "application/json"
          Authorization: "Bearer {{ lightspeed_token }}"
        body_format: json
        body:
          text: "{{ lightspeed_prompt }}"
      register: response

    - name: Save Lightspeed-generated playbook to repository
      ansible.builtin.copy:
        content: "{{ response.json.playbook | from_yaml | to_nice_yaml(sort_keys=False) }}"
        dest: "{{ repository['path'] }}/playbooks/lightspeed-response.yml"
        mode: '0644'

    - name: Commit and push generated playbook to Gitea
      ansible.scm.git_publish:
        path: "{{ repository['path'] }}"
        user:
          name: lab-user
          email: lab-user@example.org
      delegate_to: localhost
```

**Step 4b: Check mode validation**

The `Playbook-Check-Mode` job template runs the generated playbook with `--check` flag. This shows what changes *would* be made without actually modifying the router configuration. The operator reviews the proposed changes in the AAP Workflow Visualizer.

**Step 4c: Human approval gate**

The workflow pauses at an approval node. The operator reviews the check-mode output and either:
- **Approves** -- the workflow continues to run mode
- **Denies** -- the workflow stops without modifying the router

**Step 4d: Run mode execution**

The `Playbook-Run-Mode` job template applies the fix to the router. After execution, the operator verifies the OSPF neighbor has returned to FULL adjacency in both the router CLI and the Splunk Cisco Networks dashboard.

### B5. Validation -- Three OSPF Failure Scenarios

Each scenario demonstrates a progressively more complex OSPF failure, requiring a more detailed Lightspeed prompt. This mirrors the Crawl/Walk/Run maturity path.

#### Scenario 1: Interface Shutdown

| | Details |
|---|--------|
| **Trigger** | SSH to cisco-rtr1: `config t` -> `int tu 0` -> `shut` |
| **Detection** | Splunk search matches `%OSPF-5-ADJCHG: ... from FULL to DOWN` |
| **AI Diagnosis** | "Tunnel0 is administratively down" |
| **Lightspeed Fix** | Check interface status; if administratively down, run `no shutdown` |
| **Verification** | `show ip ospf neighbor` shows `FULL` state; Splunk routing dashboard shows adjacency restored |

#### Scenario 2: Incorrect OSPF Network Type

| | Details |
|---|--------|
| **Trigger** | SSH to cisco-rtr1: `config t` -> `int tu 0` -> `ip ospf network non-broadcast` -> `end` |
| **Detection** | Interface stays up but OSPF neighbor goes down -- Splunk fires alert |
| **AI Diagnosis** | "OSPF network type mismatch -- configured as non-broadcast, expected point-to-point" |
| **Lightspeed Fix** | Check interface is up; check OSPF network type; if not `POINT_TO_POINT`, configure `ip ospf network type point_to_point` |
| **Verification** | `show ip ospf neighbor` shows `FULL`; `show ip ospf int tu0` shows `Network Type POINT_TO_POINT` |

#### Scenario 3: Hello Timer Mismatch

| | Details |
|---|--------|
| **Trigger** | SSH to cisco-rtr1: `config t` -> `int tu 0` -> `ip ospf hello-interval 30` -> `end` |
| **Detection** | Interface up, correct network type, but OSPF neighbor down after dead timer expires |
| **AI Diagnosis** | "OSPF hello timer mismatch -- configured as 30s, peer expects 10s" |
| **Lightspeed Fix** | Check interface is up; check network type is correct; check hello timer; if not `Hello 10`, configure `ip ospf hello-interval 10` |
| **Verification** | `show ip ospf neighbor` shows `FULL`; `show ip ospf int tu0` shows `Hello 10` |

> **Progressive prompt complexity.**
>
> Each scenario adds conditions to the Lightspeed prompt. Scenario 1 has one condition, Scenario 2 has two, and Scenario 3 has three. This demonstrates how a network engineer can iteratively refine their prompt to handle more failure modes in a single playbook.

---

<h2 id="validation"></h2>

## Validation

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| **1. Splunk Alert -> EDA** | Webhook fires and EDA receives the event | EDA Controller shows the rulebook activation as **Running**; event log shows the Splunk payload |
| **2. Enrichment Workflow** | AI analyzed the alert and notifications were sent | Workflow Visualizer shows all nodes green; Slack/ITSM received the AI diagnosis |
| **3. Remediation Workflow** | Playbook was generated and committed (network) or service was restarted (RHEL) | New playbook file exists in the Git repository; Job Template was created |
| **4. Execute Remediation** | The fix was applied | Service returns to steady state; Splunk stops firing the alert; OSPF neighbor shows FULL adjacency |

**Quick validation test** -- Send a test webhook to EDA to simulate a Splunk alert:

```bash
# Test RHEL use case
curl -H "Content-Type: application/json" \
  -d '{
    "search_name": "Test High CPU Alert",
    "result": {
      "host": "web01.prod.internal",
      "sourcetype": "cpu_metrics",
      "cpu_percent": "95",
      "_raw": "host=web01 cpu_percent=95 process=java"
    },
    "results_link": "https://<splunk-host>/app/search/test"
  }' \
  https://<eda-controller-host>:5000/endpoint

# Test Network use case
curl -H "Content-Type: application/json" \
  -d '{
    "search_name": "ospf-neighbor",
    "result": {
      "host": "cisco-rtr1",
      "sourcetype": "cisco:ios",
      "_raw": "%OSPF-5-ADJCHG: Process 1, Nbr 192.168.2.2 on Tunnel0 from FULL to DOWN"
    },
    "results_link": "https://<splunk-host>/app/search/test"
  }' \
  https://<eda-controller-host>:5000/endpoint
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Splunk alert fires but EDA doesn't trigger | Webhook URL is wrong or EDA port is blocked by firewall | Verify the EDA webhook endpoint is reachable from the Splunk server; check `eda-server` logs |
| EDA receives event but condition doesn't match | Splunk payload structure doesn't match rulebook condition | Use `debug` action in the rulebook to print `event.payload` and compare against your conditions |
| EDA matches but `search_name` is wrong | Splunk alert title doesn't match the condition (e.g., `ospf-neighbor` vs `OSPF-Neighbor`) | Ensure the Splunk alert title matches the rulebook condition exactly -- matching is case-sensitive |
| Enrichment workflow runs but AI response is empty | Prompt is too vague or AI endpoint is unreachable | Verify the Red Hat AI server is running; test with a simple prompt first |
| Network diagnostics fail -- "unable to connect" | SSH/NETCONF credentials missing or router unreachable | Verify the Cisco IOS credential in AAP; test connectivity with `ansible -m ping` against the router inventory |
| Splunk notable event not updated | Incorrect Splunk API credentials or endpoint URL | Verify Splunk REST API access at `https://splunk:8089/services`; check credentials |
| Lightspeed-generated playbook doesn't fix the issue | AI prompt doesn't cover the failure scenario | Review and extend the Lightspeed prompt to include additional conditional checks for the failure mode |
| Check mode shows no changes | Generated playbook conditions don't match the actual router state | Review the `show` command output in the check-mode job log; adjust the prompt's conditional language |
| Remediation playbook doesn't fix the issue (RHEL) | AI diagnosis was inaccurate or Lightspeed prompt was too generic | Review the AI prompt -- ensure host logs and service status were included in the context |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | RHEL Track | Network Track | AI Role |
|----------|-----------|---------------|---------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Splunk alert -> EDA -> AI diagnoses -> enriched context posted to Slack/ITSM -> **human investigates and remediates** | Splunk detects OSPF failure -> EDA triggers -> AI enriches Splunk event with root cause -> **human reviews and acts** | Read-only: AI interprets, humans act |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | AI **selects a pre-approved playbook** -> human approves -> playbook executes | AI generates remediation playbook -> **check mode validates** -> human approves -> playbook executes | AI selects or generates with human approval gate |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Lightspeed **generates a remediation playbook** -> policy engine validates -> playbook executes | Multi-condition Lightspeed playbook handles cascading failure scenarios -> policy engine validates -> auto-executes | AI generates new automation within policy boundaries |

> **Start with Crawl.**
>
> Deploy the EDA rulebook and enrichment workflow first. Let your team see AI-enriched Splunk alerts in Slack for a few weeks before adding automated remediation. This builds confidence in the AI analysis and catches edge cases early.

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **AIOps reference architecture:** See [AIOps automation with Ansible](README-AIOps.md) for the full end-to-end pipeline, including Lightspeed playbook generation, policy enforcement, and the broader AIOps maturity journey.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Need to deploy the AI backend?** See [AI Infrastructure automation with Ansible](README-IA.md) for automating Red Hat AI provisioning with the `infra.ai` and `redhat.ai` collections.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **New to Event-Driven Ansible?** See [Get started with EDA (Ansible Rulebook)](https://access.redhat.com/articles/7136720) for the fundamentals of rulebooks, event sources, and actions.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> **Looking for ServiceNow integration?** See [Reducing MTTR with Automated ServiceNow Ticket Enrichment](README-AIOps-ServiceNow.md) for ticket enrichment and ITSM-driven remediation.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> **Want to try this hands-on?** The [Hands-On AIOps Workshop -- Part 2](https://rhpds.github.io/ai-driven-automation-showroom/modules/index.html) walks through Splunk integration with Cisco router remediation in a live lab.

---

## Summary

With Splunk alerts connected to Event-Driven Ansible, your operations team no longer needs to manually triage every alert. Whether the alert is a failed httpd service on a RHEL server or an OSPF neighbor down on a Cisco router, the same pipeline applies: Splunk detects the issue, EDA triggers the response, Red Hat AI diagnoses the root cause, and Ansible remediates -- reducing MTTR from hours of manual investigation to minutes of automated resolution.

The network AIOps use case adds AI-driven ticket enrichment and Lightspeed playbook generation with check-mode validation and human approval gates -- demonstrating how the same Splunk investment can power closed-loop automation across both server and network infrastructure.

---

<img width="400" src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/aap_logo.png">
{% endraw %}
