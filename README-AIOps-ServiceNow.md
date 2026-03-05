{% raw %}
# Reducing MTTR with Automated ServiceNow Ticket Enrichment - Solution Guide <!-- omit in toc -->

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

When a ServiceNow incident is created — whether by a monitoring tool, a user report, or an automated process — it typically contains a title and a short description. The Tier 1 engineer assigned to it must then spend time gathering context: checking logs, verifying system health, identifying recent changes, and determining root cause. This manual triage process is **the largest contributor to mean time to resolution (MTTR)** in most enterprises.

Organizations handling hundreds or thousands of ServiceNow incidents per month cannot scale this human investigation process. The result is longer resolution times, escalation bottlenecks, and inconsistent diagnostic quality across shifts and teams.

This guide demonstrates how to **automatically enrich ServiceNow incidents** using Ansible Automation Platform and AI inference. When an incident is created, Ansible gathers diagnostic context from the affected systems, sends it to Red Hat AI for root cause analysis, and writes the enriched diagnosis directly back into the ServiceNow ticket — before a human engineer even opens it.

> **This is the Crawl stage of AIOps.**
>
> Ticket enrichment is the lowest-risk, highest-value entry point for AIOps adoption. No production systems are modified — AI adds context to tickets, and humans still decide what to do. For the full self-healing pipeline (Crawl → Walk → Run), see [AIOps automation with Ansible](README-AIOps.md).

- [Overview](#overview)
- [Background](#background)
- [Solution](#solution)
  - [Who Benefits](#who-benefits)
- [Prerequisites](#prerequisites)
  - [Ansible Automation Platform](#ansible-automation-platform)
  - [Featured Ansible Content Collections](#featured-ansible-content-collections)
  - [External Systems](#external-systems)
- [ServiceNow Enrichment Workflow](#servicenow-enrichment-workflow)
  - [Operational Impact per Stage](#operational-impact-per-stage)
  - [Workflow Diagram](#workflow-diagram)
- [Solution Walkthrough](#solution-walkthrough)
  - [1. ServiceNow Outbound Webhook (Business Rule)](#1-servicenow-outbound-webhook-business-rule)
  - [2. EDA Rulebook for ServiceNow Events](#2-eda-rulebook-for-servicenow-events)
  - [3. Gather Diagnostic Context from Affected Host](#3-gather-diagnostic-context-from-affected-host)
  - [4. Analyze with Red Hat AI](#4-analyze-with-red-hat-ai)
  - [5. Enrich the ServiceNow Ticket](#5-enrich-the-servicenow-ticket)
- [Validation](#validation)
  - [Troubleshooting](#troubleshooting)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [Summary](#summary)

<h2 id="background"></h2>

## Background

**ServiceNow** is the enterprise standard for IT Service Management (ITSM). It serves as the system of record for incidents, problems, changes, and service requests across most large organizations. When something goes wrong in IT infrastructure, the resolution process almost always flows through ServiceNow — whether the ticket was created automatically by a monitoring tool or manually by an end user.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.servicenow.com/products/itsm.html">ServiceNow ITSM — servicenow.com</a>

The challenge is not ticket creation — most organizations have automated that. The challenge is **ticket context**. A newly created incident might say "web server down" but doesn't include which process failed, what the logs show, when the last change was made, or what similar incidents looked like. Engineers spend the first 15-30 minutes of every incident gathering this context manually.

**Ticket enrichment** closes this gap by automatically attaching diagnostic context to incidents at creation time. AI inference takes it a step further — instead of just dumping raw logs into a ticket, an AI model analyzes the data and provides a human-readable root cause analysis and recommended next steps.

<img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4d6.png" width="20" style="vertical-align:text-bottom;"> <a target="_blank" href="https://www.redhat.com/en/topics/ai/what-is-aiops">What is AIOps? — redhat.com</a>

<h2 id="solution"></h2>

## Solution

What makes up the solution?

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **ServiceNow** as the ITSM system of record for incidents <a target="_blank" href="https://www.servicenow.com/">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **Event-Driven Ansible (EDA)** to receive ServiceNow webhook events and trigger automation <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Red Hat AI** for AI-driven root cause analysis of the incident context <a target="_blank" href="https://www.redhat.com/en/products/ai">[Link]</a>
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f501.png" width="20" style="vertical-align:text-bottom;"> **Ansible Automation Platform (AAP)** workflows for orchestrating the enrichment pipeline <a target="_blank" href="https://www.redhat.com/en/technologies/management/ansible">[Link]</a>

> **EDA is part of Ansible Automation Platform.**
>
> EDA uses rulebooks to monitor events, then executes specified job templates or workflows based on the event. Think of it simply as inputs and outputs. EDA is an automatic way for inputs into Ansible Automation Platform, where Automation controller is the output (running a job template or workflow).

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6e0.png" width="20" style="vertical-align:text-bottom;"> **IT Ops Engineer / SRE** | Spending 15-30 minutes per incident manually gathering logs, checking system health, and identifying root cause before even starting remediation | Incidents arrive pre-enriched with diagnostic context, AI-generated root cause analysis, and recommended next steps — engineers start fixing instead of investigating |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f5fa.png" width="20" style="vertical-align:text-bottom;"> **Automation Architect** | Integrating ServiceNow with Ansible requires understanding business rules, webhooks, the REST API, and credential management | A reference architecture with production-ready EDA rulebooks, ServiceNow business rule examples, and tested `servicenow.itsm` collection usage |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4ca.png" width="20" style="vertical-align:text-bottom;"> **IT Manager / Director** | MTTR is high despite staffing investments; escalation rates are growing; diagnostic quality varies by shift | Consistent, AI-driven enrichment on every incident — measurable MTTR reduction, fewer escalations, and a foundation for further AIOps maturity |

**Recommended Demos and Self-Paced Labs:**

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3a5.png" width="20" style="vertical-align:text-bottom;"> [YouTube: Ansible + ServiceNow Demo (~3 min)](https://www.youtube.com/watch?v=2R5_Mw8D2U0)

<h2 id="prerequisites"></h2>

## Prerequisites

### Ansible Automation Platform

- **Ansible Automation Platform 2.5+** — Required for enterprise Event-Driven Ansible (EDA Controller) support and webhook event sources.

### Featured Ansible Content Collections

| Collection | Type | Purpose |
|-----------|------|---------|
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/servicenow/itsm/">servicenow.itsm</a> | Certified | Create, update, and query ServiceNow incidents, problems, changes, and CMDB records |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/">ansible.eda</a> | Certified | EDA event sources and filters (webhooks, Kafka, etc.) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/ansible/controller/">ansible.controller</a> | Certified | Automation Controller configuration as code (job templates, workflows, surveys) |
| <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/redhat/ai">redhat.ai</a> | Certified | AI model inference using the OpenAI-compatible API via InstructLab |

> **The servicenow.itsm collection is key.**
>
> This certified collection provides native Ansible modules for ServiceNow — no raw REST API calls needed. It supports incidents, problems, changes, configuration items, and more. Install it from <a target="_blank" href="https://console.redhat.com/ansible/automation-hub/repo/published/servicenow/itsm/">Automation Hub</a>.

### External Systems

| System | Required | Notes |
|--------|----------|-------|
| ServiceNow instance | Yes | Developer instance (free) or enterprise instance; must support Business Rules and REST API |
| AI inference endpoint | Yes | Red Hat AI (RHEL AI + InstructLab) or any OpenAI-compatible API |
| Chat platform | Recommended | Slack, Mattermost, or Microsoft Teams for real-time notifications alongside ticket updates |

> **ServiceNow Developer Instances are free.**
>
> If you don't have a ServiceNow enterprise instance, you can get a free developer instance at <a target="_blank" href="https://developer.servicenow.com/">developer.servicenow.com</a> for testing and development.

<h2 id="servicenow-enrichment-workflow"></h2>

## ServiceNow Enrichment Workflow

The enrichment workflow has five stages:

1. **ServiceNow Incident → EDA** — A new incident is created in ServiceNow. A Business Rule fires and sends a webhook to EDA Controller.
2. **Gather Diagnostic Context** — Ansible connects to the affected host and collects logs, system status, and configuration data.
3. **AI Analysis** — The gathered context is sent to Red Hat AI, which provides a root cause analysis and recommended next steps.
4. **Enrich the Ticket** — Ansible writes the AI analysis, diagnostic data, and recommendations back into the ServiceNow incident as work notes.
5. **Notify the Team** — The enriched incident is flagged in Slack/Mattermost so the assigned engineer knows it's ready for action.

### Operational Impact per Stage

| Stage | Operational Impact | Why |
|-------|-------------------|-----|
| **1. ServiceNow → EDA** | **None** | Read-only — ServiceNow fires a webhook, EDA receives it. No changes to systems. |
| **2. Gather Context** | **None** | Read-only — Ansible collects logs and facts from the affected host. No modifications. |
| **3. AI Analysis** | **None** | Read-only — data is sent to an AI API and a response is received. No infrastructure changes. |
| **4. Enrich Ticket** | **Low** | Writes work notes to the ServiceNow incident. No infrastructure changes. |
| **5. Notify Team** | **Low** | Posts a message to Slack/Mattermost. No infrastructure changes. |

> **This entire workflow is read-only on infrastructure.**
>
> Unlike the full AIOps self-healing pipeline, ticket enrichment never modifies production systems. The only writes are to ServiceNow (work notes) and chat (notifications). This makes it safe to deploy immediately in any environment.

### Workflow Diagram

```
ServiceNow Incident → Webhook → EDA Rulebook → Gather Context → AI Analysis → Update Ticket → Notify Team
```

<h2 id="solution-walkthrough"></h2>

## Solution Walkthrough

### 1. ServiceNow Outbound Webhook (Business Rule)

**Operational Impact:** None (ServiceNow configuration only)

ServiceNow **Business Rules** execute server-side logic when records are inserted, updated, or deleted. To trigger EDA when a new incident is created, configure an outbound REST message from a Business Rule.

In ServiceNow, navigate to **System Definition → Business Rules** and create a new rule:

| Field | Value |
|-------|-------|
| **Name** | `Trigger Ansible EDA on Incident Create` |
| **Table** | `incident` |
| **When** | After |
| **Insert** | true |
| **Filter Conditions** | Priority = 1 (Critical) OR Priority = 2 (High) |

The Business Rule script sends a webhook to EDA with the incident details:

```javascript
(function executeRule(current, previous) {
    var request = new sn_ws.RESTMessageV2();
    request.setEndpoint('https://eda.example.com:5000/endpoint');
    request.setHttpMethod('POST');
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestBody(JSON.stringify({
        incident_number: current.number.toString(),
        short_description: current.short_description.toString(),
        priority: current.priority.toString(),
        affected_ci: current.cmdb_ci.name.toString(),
        assigned_to: current.assigned_to.name.toString(),
        caller: current.caller_id.name.toString()
    }));
    var response = request.execute();
})(current, previous);
```

> **Filter by priority.**
>
> Don't trigger automation on every incident. Start with Priority 1 (Critical) and Priority 2 (High) incidents only. As confidence grows, expand to lower priorities.

### 2. EDA Rulebook for ServiceNow Events

**Operational Impact:** None

The EDA rulebook listens for incoming webhook events from ServiceNow and triggers the enrichment workflow.

```yaml
---
- name: ServiceNow incident enrichment
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000

  rules:
    - name: New high-priority ServiceNow incident
      condition: event.payload.incident_number is defined and event.payload.priority in ["1", "2"]
      action:
        run_workflow_template:
          organization: "Default"
          name: "ServiceNow Incident Enrichment"
          extra_vars:
            incident_number: "{{ event.payload.incident_number }}"
            short_description: "{{ event.payload.short_description }}"
            affected_ci: "{{ event.payload.affected_ci }}"
            priority: "{{ event.payload.priority }}"
```

The rulebook extracts the incident number, description, affected configuration item (CI), and priority from the ServiceNow webhook payload, then passes them to the enrichment workflow.

### 3. Gather Diagnostic Context from Affected Host

**Operational Impact:** None (read-only)

The first job in the enrichment workflow connects to the affected host and gathers diagnostic data. The host is identified from the ServiceNow CI (Configuration Item) field.

```yaml
- name: Gather diagnostic context for ServiceNow incident
  hosts: "{{ affected_ci }}"
  become: true
  tasks:
    - name: Get systemd service status for common services
      ansible.builtin.shell:
        cmd: "systemctl list-units --state=failed --no-pager"
      register: failed_services

    - name: Collect recent syslog entries
      ansible.builtin.command:
        cmd: "journalctl --since '2 hours ago' --priority=err --no-pager"
      register: recent_errors

    - name: Check disk usage
      ansible.builtin.command:
        cmd: "df -h"
      register: disk_usage

    - name: Check memory usage
      ansible.builtin.command:
        cmd: "free -m"
      register: memory_usage

    - name: Gather Ansible facts
      ansible.builtin.setup:
        filter:
          - ansible_distribution*
          - ansible_memtotal_mb
          - ansible_processor_vcpus
          - ansible_uptime_seconds
```

> **Adapt the diagnostic checks to your environment.**
>
> The tasks above are examples for Linux hosts. For network devices, use `ansible.netcommon` fact gathering. For Windows, use `win_shell` and `win_service`. The key principle is: gather enough context that the AI model can make an informed diagnosis.

### 4. Analyze with Red Hat AI

**Operational Impact:** None (API call only)

With diagnostic data collected, the next job sends everything to Red Hat AI for analysis.

```yaml
- name: Analyze incident with Red Hat AI
  hosts: localhost
  tasks:
    - name: Build context-rich prompt
      ansible.builtin.set_fact:
        analysis_prompt: |
          ServiceNow Incident: {{ incident_number }}
          Description: {{ short_description }}
          Priority: {{ priority }}
          Affected System: {{ affected_ci }}

          Failed services: {{ hostvars[affected_ci].failed_services.stdout }}
          Recent errors: {{ hostvars[affected_ci].recent_errors.stdout | truncate(2000) }}
          Disk usage: {{ hostvars[affected_ci].disk_usage.stdout }}
          Memory: {{ hostvars[affected_ci].memory_usage.stdout }}

          Based on the above diagnostic data, provide:
          1. Root cause analysis
          2. Recommended remediation steps
          3. Risk assessment (Low/Medium/High)

    - name: Send to Red Hat AI for analysis
      redhat.ai.completion:
        base_url: "http://{{ rhelai_server }}:{{ rhelai_port }}"
        token: "{{ rhelai_token }}"
        prompt: "{{ analysis_prompt }}"
        model_path: "/root/.cache/instructlab/models/granite-8b-lab-v1"
      delegate_to: localhost
      register: ai_analysis
```

### 5. Enrich the ServiceNow Ticket

**Operational Impact:** Low (writes to ServiceNow only)

The final step writes the AI analysis and diagnostic data back into the ServiceNow incident using the `servicenow.itsm` collection.

```yaml
- name: Enrich ServiceNow incident with AI analysis
  hosts: localhost
  tasks:
    - name: Update incident with AI-driven work notes
      servicenow.itsm.incident:
        instance:
          host: "{{ snow_instance }}"
          username: "{{ snow_username }}"
          password: "{{ snow_password }}"
        number: "{{ incident_number }}"
        state: in_progress
        other:
          work_notes: |
            [AI-Enriched Diagnostic Report]
            ================================
            Analysis performed by: Red Hat AI (Granite 8B)
            Timestamp: {{ ansible_date_time.iso8601 }}

            ROOT CAUSE ANALYSIS:
            {{ ai_analysis.choice_0_text }}

            DIAGNOSTIC DATA COLLECTED:
            - Failed services: {{ hostvars[affected_ci].failed_services.stdout | truncate(500) }}
            - Recent errors: {{ hostvars[affected_ci].recent_errors.stdout | truncate(500) }}
            - Disk usage: {{ hostvars[affected_ci].disk_usage.stdout }}
            - Memory: {{ hostvars[affected_ci].memory_usage.stdout }}

            [End AI-Enriched Report]

    - name: Notify team on Slack
      ansible.builtin.uri:
        url: "{{ slack_webhook_url }}"
        method: POST
        body_format: json
        body:
          text: |
            :white_check_mark: *Incident {{ incident_number }} enriched*
            *Description:* {{ short_description }}
            *AI Analysis:* {{ ai_analysis.choice_0_text | truncate(500) }}
            View in ServiceNow: https://{{ snow_instance }}/nav_to.do?uri=incident.do?sysparm_query=number={{ incident_number }}
```

After this workflow completes, the engineer opening the ServiceNow incident sees a detailed diagnostic report in the work notes — including AI-generated root cause analysis, failed services, recent errors, disk and memory status — all gathered and analyzed automatically.

> **RBAC:** Scope the ServiceNow credential tightly.
>
> The Ansible credential for ServiceNow should have write access only to the `work_notes` field on incidents. Use a dedicated ServiceNow integration user with the `itil` role scoped to incident updates only.

<h2 id="validation"></h2>

## Validation

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| **1. ServiceNow → EDA** | Business Rule fires and EDA receives the webhook | EDA Controller shows the rulebook activation as **Running**; event log shows the ServiceNow payload |
| **2. Gather Context** | Diagnostic data was collected from the affected host | First job in the workflow completes green in Workflow Visualizer |
| **3. AI Analysis** | Red Hat AI returned a root cause analysis | AI analysis job completes green; check job output for `ai_analysis.choice_0_text` |
| **4. Enrich Ticket** | Work notes were written to the ServiceNow incident | Open the incident in ServiceNow; **Work Notes** tab shows the AI-enriched diagnostic report |
| **5. Notify Team** | Slack/Mattermost message was sent | Check the channel for the enrichment notification |

**Quick validation test** — Create a test incident in ServiceNow and verify the enrichment:

```bash
curl -s "https://your-instance.service-now.com/api/now/table/incident" \
  -H "Content-Type: application/json" \
  -H "Authorization: Basic $(echo -n 'admin:password' | base64)" \
  -d '{
    "short_description": "Test: web server unresponsive",
    "priority": "2",
    "cmdb_ci": "web01.example.com",
    "description": "Web server web01 is not responding to health checks."
  }' | jq '.result.number'
```

After creating the incident, verify in ServiceNow that work notes have been populated with the AI-enriched diagnostic report within 2-3 minutes.

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Incident created but EDA doesn't trigger | Business Rule is not active, or webhook URL is incorrect | Verify the Business Rule is active and set to fire on Insert; check the EDA endpoint URL |
| EDA triggers but workflow fails at "Gather Context" | Affected CI hostname doesn't match Ansible inventory | Ensure the ServiceNow CI `name` field maps to a host in your AAP inventory |
| AI analysis returns generic or unhelpful results | Diagnostic data is too sparse or prompt is missing context | Verify the diagnostic playbook collected data; check that `hostvars` are being passed correctly between jobs |
| ServiceNow ticket not updated | Credential error or incorrect instance URL | Verify the ServiceNow credential in AAP; test with `servicenow.itsm.incident_info` first |
| Work notes show raw Jinja2 instead of resolved values | Variable not passed between workflow jobs | Use `set_stats` or workflow extra vars to pass data between jobs in the workflow |

<h2 id="maturity-path"></h2>

## Maturity Path

| Maturity | Approach | How It Works | AI Role |
|----------|----------|-------------|---------|
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f6b6.png" width="20" style="vertical-align:text-bottom;"> **Crawl** | Ticket Enrichment | Incident created → EDA → gather context → AI analyzes → enriched work notes added → **human remediates** | Read-only: AI enriches tickets, humans act |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c3.png" width="20" style="vertical-align:text-bottom;"> **Walk** | Enrichment + Curated Remediation | Incident created → EDA → enrich ticket → AI **recommends a pre-approved playbook** → human approves via ServiceNow → playbook executes | AI selects from existing automation; ServiceNow approval gates execution |
| <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f680.png" width="20" style="vertical-align:text-bottom;"> **Run** | Enrichment + Auto-Remediation | Incident created → EDA → enrich ticket → AI **generates remediation playbook** → policy engine validates → playbook executes → ticket auto-resolved | AI generates and executes automation within policy boundaries |

> **Crawl is the starting point for most organizations.**
>
> Ticket enrichment delivers immediate value with zero production risk. Let your Tier 1 team experience AI-enriched tickets for 30-60 days before moving to Walk, where AI begins recommending remediation actions.

<h2 id="related-guides"></h2>

## Related Guides

- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4cb.png" width="20" style="vertical-align:text-bottom;"> **AIOps reference architecture:** See [AIOps automation with Ansible](README-AIOps.md) for the full self-healing pipeline (Crawl → Walk → Run), including Lightspeed playbook generation and policy enforcement.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f50d.png" width="20" style="vertical-align:text-bottom;"> **Using Splunk as the trigger?** See [Triggering Automated Remediation from Splunk Alerts](README-AIOps-Splunk.md) for connecting Splunk alerts to the same AIOps pipeline.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f9e0.png" width="20" style="vertical-align:text-bottom;"> **Need to deploy the AI backend?** See [AI Infrastructure automation with Ansible](README-IA.md) for automating Red Hat AI provisioning with the `infra.ai` and `redhat.ai` collections.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4e1.png" width="20" style="vertical-align:text-bottom;"> **New to Event-Driven Ansible?** See [Get started with EDA (Ansible Rulebook)](https://access.redhat.com/articles/7136720) for the fundamentals of rulebooks, event sources, and actions.
- <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4a1.png" width="20" style="vertical-align:text-bottom;"> **Existing ServiceNow enrichment guide:** See [ServiceNow ITSM Ticket Enrichment Automation](https://access.redhat.com/articles/7127603) on access.redhat.com for the legacy KB article on this topic.

---

## Summary

With automated ticket enrichment in place, your Tier 1 engineers no longer spend the first 15-30 minutes of every incident gathering context. ServiceNow incidents arrive pre-enriched with diagnostic data, AI-generated root cause analysis, and recommended next steps. This reduces MTTR, improves diagnostic consistency across shifts, and creates the foundation for further AIOps maturity — from enrichment (Crawl) to curated remediation (Walk) to full self-healing (Run).

---

<img width="400" src="https://raw.githubusercontent.com/rhpds/showroom-lb2961-ai-driven-ansible-automation/refs/heads/main/solution_images/aap_logo.png">
{% endraw %}
