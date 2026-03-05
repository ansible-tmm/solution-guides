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

Splunk is the system of record for security and operations visibility in many enterprises — ingesting logs, metrics, and events from thousands of sources. But when a critical Splunk alert fires, the response is still manual: an analyst reads the alert, opens a terminal, gathers context, and starts troubleshooting. This gap between **detection** and **resolution** is where MTTR lives. Organizations with hundreds of Splunk-generated alerts per day cannot scale human response to match.

This guide demonstrates how to connect Splunk alerts directly to **Event-Driven Ansible (EDA)**, triggering an automated pipeline that enriches the alert with AI-driven analysis and remediates the issue — closing the loop from detection to resolution without requiring a human to interpret every alert manually.

> **This guide builds on the AIOps reference architecture.**
>
> For the full end-to-end AIOps pipeline — including AI inference, Lightspeed playbook generation, and the Crawl/Walk/Run maturity model — see [AIOps automation with Ansible](README-AIOps.md). This guide focuses specifically on using **Splunk** as the observability trigger.

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
- [Solution Walkthrough](#solution-walkthrough)
  - [1. Configure Splunk Alert Action (Webhook)](#1-configure-splunk-alert-action-webhook)
  - [2. EDA Rulebook for Splunk Events](#2-eda-rulebook-for-splunk-events)
  - [3. Enrichment Workflow — Gather Context and Analyze with AI](#3-enrichment-workflow--gather-context-and-analyze-with-ai)
  - [4. Notify and Remediate](#4-notify-and-remediate)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**Splunk** is a data platform that collects, indexes, and correlates machine-generated data — logs, metrics, traces, and events — from virtually any source across an organization's IT environment. Its search processing language (SPL) lets teams build saved searches and alerts that fire when conditions match predefined thresholds or patterns.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.splunk.com/en_us/products/splunk-enterprise.html">Splunk Enterprise — splunk.com</a>

In traditional operations, a Splunk alert fires and creates a ticket or sends an email. A human then investigates, determines root cause, and manually remediates. This model works at small scale but breaks down as alert volume grows. **Event-Driven Ansible** eliminates this bottleneck by consuming Splunk alerts programmatically and triggering automation workflows in real time.

The combination of Splunk's detection capabilities with Ansible's remediation capabilities creates a **closed-loop operations model**: Splunk detects, EDA responds, AI enriches, and Ansible fixes.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? — redhat.com</a>

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
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **IT Ops Engineer / SRE** | Spending most of their day triaging Splunk alerts manually — reading logs, SSH-ing into servers, running diagnostic commands | Splunk alerts automatically trigger enrichment and remediation workflows — the fix starts before the engineer opens a terminal |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Automation Architect** | Connecting Splunk to Ansible requires custom scripting, webhook plumbing, and fragile integrations | A reference architecture with production-ready EDA rulebooks, Splunk webhook configs, and tested collection usage |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **IT Manager / Director** | Alert fatigue and growing MTTR despite investment in both Splunk and Ansible | Closed-loop automation that turns Splunk from a detection tool into a detection-and-resolution tool — with measurable MTTR reduction |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> [Hands-On AIOps Workshop — Part 2: Network Automation with Splunk](https://rhpds.github.io/ai-driven-automation-showroom/modules/index.html) covers Splunk integration with Cisco router remediation end-to-end

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** — Required for enterprise Event-Driven Ansible (EDA Controller) support and webhook event sources.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | EDA event sources and filters (webhooks, Kafka, etc.) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/namespaces/splunk/">splunk.es</a> | Certified | Manage Splunk Enterprise Security resources — correlation searches, adaptive response actions, and data inputs |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Automation Controller configuration as code (job templates, workflows, surveys) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/redhat/ai">redhat.ai</a> | Certified | AI model inference using the OpenAI-compatible API via InstructLab |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/scm/">ansible.scm</a> | Certified | Git operations (commit and push generated playbooks) |

### External Systems

| System | Required | Notes |
|--------|----------|-------|
| Splunk Enterprise or Splunk Cloud | Yes | Must be configured with saved searches or alerts that support webhook actions |
| AI inference endpoint | Yes | Red Hat AI (RHEL AI + InstructLab) or any OpenAI-compatible API |
| Ansible Lightspeed | Recommended | For dynamic playbook generation at the **Run** maturity level |
| Git repository | Yes | GitHub, GitLab, or Gitea for storing generated playbooks |
| Chat or ITSM tool | Recommended | Slack, Mattermost, or ServiceNow for human-in-the-loop notifications |

<h2 id="splunk-to-ansible-workflow"></h2>

## Splunk-to-Ansible Workflow

The workflow has four stages, matching the [AIOps reference architecture](README-AIOps.md):

1. **Splunk Alert → EDA** — A saved search or alert in Splunk fires and sends a webhook payload to EDA Controller.
2. **Enrichment Workflow** — AAP gathers additional context from the affected host, sends the enriched data to Red Hat AI for root cause analysis, and notifies the operations team.
3. **Remediation Workflow** — Ansible Lightspeed generates a remediation playbook from the AI analysis, commits it to Git, and creates a Job Template.
4. **Execute Remediation** — The generated playbook runs against the affected infrastructure, resolving the issue.

### Operational Impact per Stage

| Stage | Operational Impact | Why |
|-------|-------------------|-----|
| **1. Splunk Alert → EDA** | **None** | Read-only — Splunk fires a webhook, EDA receives it. No changes to systems. |
| **2. Enrichment Workflow** | **Low** | Collects logs and system info, calls an AI API, posts to chat/ITSM. No infrastructure changes. |
| **3. Remediation Workflow** | **Low** | Generates a playbook, commits to Git, creates a Job Template. Prepares the fix but does not touch production. |
| **4. Execute Remediation** | **High** | Modifies production infrastructure. Should go through a change window or approval gate. |

### Workflow Diagram

```
Splunk Alert → Webhook → EDA Rulebook → Enrichment Workflow → AI Analysis → Remediation Workflow → Execute Fix
```

<a target="_blank" href="https://github.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/blob/main/solution_images/overview_diagram.png"><img src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/overview_diagram.png"></a>

> **Splunk replaces the Kafka/Filebeat layer.**
>
> In the AIOps reference architecture, Filebeat and Kafka handle event collection and transport. When using Splunk, it handles both — Splunk ingests the data and fires the alert directly to EDA via webhook, simplifying the architecture.

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

### 1. Configure Splunk Alert Action (Webhook)

**Operational Impact:** None

Splunk alerts can trigger a **webhook action** that sends an HTTP POST to any endpoint — including the EDA Controller webhook receiver. This is the bridge between Splunk's detection and Ansible's automation.

In Splunk, navigate to **Settings → Searches, reports, and alerts** and edit (or create) a saved search. Under **Trigger Actions**, add a webhook action pointing to your EDA Controller:

| Field | Value |
|-------|-------|
| **Trigger condition** | Number of results is greater than 0 |
| **Trigger action** | Webhook |
| **URL** | `https://eda.example.com:5000/endpoint` |

The webhook payload Splunk sends includes the search name, results count, and a link to the results. A typical payload looks like:

```json
{
  "sid": "scheduler_admin_search_RMD567890",
  "search_name": "High CPU Alert - web servers",
  "app": "search",
  "owner": "admin",
  "results_link": "https://splunk.example.com/app/search/@go?sid=scheduler_admin_search_RMD567890",
  "result": {
    "host": "web01.example.com",
    "sourcetype": "cpu_metrics",
    "cpu_percent": "98.5",
    "_raw": "2025-02-18 14:32:01 host=web01 cpu_percent=98.5 process=java pid=12345"
  }
}
```

> **Splunk Enterprise Security customers.**
>
> If you use Splunk Enterprise Security (ES), you can use **Adaptive Response Actions** instead of basic webhook alerts. The `splunk.es` Ansible collection can also manage correlation searches and notable events programmatically.

Alternatively, you can configure the webhook in Splunk using the `splunk.es` collection:

```yaml
- name: Configure Splunk saved search with webhook alert
  splunk.es.splunk_data_inputs_monitor:
    name: "/var/log/httpd/error_log"
    state: present
  delegate_to: localhost
```

### 2. EDA Rulebook for Splunk Events

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

The rulebook extracts key fields from the Splunk webhook payload — the search name, affected host, raw event data, and a link back to the Splunk results — and passes them as extra variables to the enrichment workflow.

> **Filtering by severity or search name.**
>
> In production, you will want more specific conditions to avoid triggering automation on every Splunk alert. Filter by search name patterns, severity fields, or custom fields that your Splunk alerts include.

### 3. Enrichment Workflow — Gather Context and Analyze with AI

**Operational Impact:** Low

Once EDA triggers the enrichment workflow, Ansible gathers additional context from the affected host and sends everything to Red Hat AI for root cause analysis. This is the same pattern described in the [AIOps reference architecture — Log Enrichment and Prompt Generation Workflow](README-AIOps.md#2-log-enrichment-and-prompt-generation-workflow).

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
    - name: Build enriched prompt
      ansible.builtin.set_fact:
        enriched_prompt: |
          A Splunk alert fired: {{ alert_name }}
          Affected host: {{ affected_host }}
          Raw event: {{ raw_event }}
          Service status: {{ hostvars[affected_host].service_status.stdout }}
          Recent logs: {{ hostvars[affected_host].journal_logs.stdout | truncate(2000) }}

          Diagnose the root cause and recommend a remediation step.

    - name: Send to Red Hat AI for analysis
      redhat.ai.completion:
        base_url: "http://{{ rhelai_server }}:{{ rhelai_port }}"
        token: "{{ rhelai_token }}"
        prompt: "{{ enriched_prompt }}"
        model_path: "/root/.cache/instructlab/models/granite-8b-lab-v1"
      delegate_to: localhost
      register: ai_response
```

The AI response includes a diagnosis and recommended remediation, which feeds into the next stage.

### 4. Notify and Remediate

**Operational Impact:** Low (notification) → **High** (remediation execution)

The enrichment workflow posts the AI analysis to your team's communication channel and — depending on your maturity level — either queues a remediation playbook for human approval or executes it automatically.

```yaml
    - name: Post AI diagnosis to Slack
      ansible.builtin.uri:
        url: "{{ slack_webhook_url }}"
        method: POST
        body_format: json
        body:
          text: |
            :rotating_light: *Splunk Alert:* {{ alert_name }}
            *Host:* {{ affected_host }}
            *AI Diagnosis:* {{ ai_response.choice_0_text }}
            *Splunk Results:* {{ results_link }}

    - name: Update Splunk notable event with AI analysis
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
> Updating the Splunk notable event with the AI analysis creates a full audit trail — the detection, diagnosis, and remediation are all visible in Splunk's incident review dashboard.

From here, the remediation follows the same pattern as the [AIOps Remediation Workflow](README-AIOps.md#3-remediation-workflow) — Lightspeed generates a playbook, it gets committed to Git, and a Job Template is created for execution.

<h2 id="validation"></h2>

## Validation

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| **1. Splunk Alert → EDA** | Webhook fires and EDA receives the event | EDA Controller shows the rulebook activation as **Running**; event log shows the Splunk payload |
| **2. Enrichment Workflow** | AI analyzed the alert and notifications were sent | Workflow Visualizer shows all nodes green; Slack/ITSM received the AI diagnosis |
| **3. Remediation Workflow** | Playbook was generated and committed | New playbook file exists in the Git repository; Job Template was created |
| **4. Execute Remediation** | The fix was applied | Service returns to steady state; Splunk stops firing the alert |

**Quick validation test** — Send a test webhook to EDA to simulate a Splunk alert:

```bash
curl -H "Content-Type: application/json" \
  -d '{
    "search_name": "Test High CPU Alert",
    "result": {
      "host": "web01.example.com",
      "sourcetype": "cpu_metrics",
      "cpu_percent": "95",
      "_raw": "host=web01 cpu_percent=95 process=java"
    },
    "results_link": "https://splunk.example.com/app/search/test"
  }' \
  https://eda.example.com:5000/endpoint
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Splunk alert fires but EDA doesn't trigger | Webhook URL is wrong or EDA port is blocked by firewall | Verify the EDA webhook endpoint is reachable from the Splunk server; check `eda-server` logs |
| EDA receives event but condition doesn't match | Splunk payload structure doesn't match rulebook condition | Use `debug` action in the rulebook to print `event.payload` and compare against your conditions |
| Enrichment workflow runs but AI response is empty | Prompt is too vague or AI endpoint is unreachable | Verify the Red Hat AI server is running; test with a simple prompt first |
| Splunk notable event not updated | Incorrect Splunk API credentials or endpoint URL | Verify Splunk REST API access at `https://splunk:8089/services`; check credentials |
| Remediation playbook doesn't fix the issue | AI diagnosis was inaccurate or Lightspeed prompt was too generic | Review the AI prompt — ensure host logs and service status were included in the context |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Approach | How It Works | AI Role |
|----------|----------|-------------|---------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Alert Enrichment | Splunk alert → EDA → AI diagnoses → enriched context posted to Slack/ITSM → **human investigates and remediates** | Read-only: AI interprets, humans act |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | Curated Remediation | Splunk alert → EDA → AI diagnoses → AI **selects a pre-approved playbook** → human approves → playbook executes | AI selects from existing automation |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Auto-Remediation | Splunk alert → EDA → AI diagnoses → Lightspeed **generates a remediation playbook** → policy engine validates → playbook executes | AI generates new automation within policy boundaries |

> **Start with Crawl.**
>
> Deploy the EDA rulebook and enrichment workflow first. Let your team see AI-enriched Splunk alerts in Slack for a few weeks before adding automated remediation. This builds confidence in the AI analysis and catches edge cases early.

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **AIOps reference architecture:** See [AIOps automation with Ansible](README-AIOps.md) for the full end-to-end pipeline, including Lightspeed playbook generation, policy enforcement, and the broader AIOps maturity journey.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Need to deploy the AI backend?** See [AI Infrastructure automation with Ansible](README-IA.md) for automating Red Hat AI provisioning with the `infra.ai` and `redhat.ai` collections.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **New to Event-Driven Ansible?** See [Get started with EDA (Ansible Rulebook)](https://access.redhat.com/articles/7136720) for the fundamentals of rulebooks, event sources, and actions.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> **Looking for ServiceNow integration?** See [Reducing MTTR with Automated ServiceNow Ticket Enrichment](README-AIOps-ServiceNow.md) for ticket enrichment and ITSM-driven remediation.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> **Want to try this hands-on?** The [Hands-On AIOps Workshop — Part 2](https://rhpds.github.io/ai-driven-automation-showroom/modules/index.html) walks through Splunk integration with Cisco router remediation in a live lab.

---

## Summary

With Splunk alerts connected to Event-Driven Ansible, your operations team no longer needs to manually triage every alert. Splunk detects the issue, EDA triggers the response, Red Hat AI diagnoses the root cause, and Ansible remediates — reducing MTTR from hours of manual investigation to minutes of automated resolution. The same Splunk investment you already have becomes the trigger for a closed-loop AIOps pipeline.

---

<img width="400" src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/aap_logo.png">
{% endraw %}
