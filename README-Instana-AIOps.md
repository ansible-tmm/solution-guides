# Automated Incident Remediation with IBM Instana and Ansible Automation Platform - Solution Guide <!-- omit in toc -->

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

Observability tools like IBM Instana detect thousands of infrastructure and application anomalies daily — but detection alone does not fix the problem. Most organizations still route alerts to human on-call engineers for manual triage and remediation, creating alert fatigue, inconsistent responses, and mean time to resolution (MTTR) measured in hours instead of minutes.

Red Hat Ansible Automation Platform bridges this gap as a **trusted, governed automation layer** that turns observability signals into consistent, auditable remediation actions. This guide demonstrates how to connect IBM Instana Observability to Ansible Automation Platform so that every high-signal Incident triggers the right remediation — automatically, with full RBAC control and audit trail.

**Business value:** Reduced MTTR from hours (manual triage and remediation) to minutes (automated response). Reduced alert fatigue through automated triage — only novel or unresolvable Incidents escalate to humans. Compliance-ready audit trail for every remediation action: who triggered it, what changed, pass or fail.

**Technical value:** Governed remediation with RBAC-scoped job templates — only authorized teams can trigger remediation within their scope. Credential isolation — secrets stored in automation controller and injected at runtime, never exposed in playbooks or logs. Bidirectional observability-automation feedback loop via Host Agent REST API annotations, linking remediation actions to Incidents on the Instana timeline.

- [Background](#background)
- [Solution](#solution)
- [Prerequisites](#prerequisites)
- [Integration Architecture](#integration-architecture)
- [Solution Walkthrough](#solution-walkthrough)
  - [Part 1: Shared Setup](#part-1-shared-setup)
  - [Part 2: Path A — Event-Driven Ansible Integration](#part-2-path-a--event-driven-ansible-integration)
  - [Part 3: Path B — Instana Automation Framework](#part-3-path-b--instana-automation-framework)
  - [Part 4: Use Case Walkthroughs](#part-4-use-case-walkthroughs)
  - [Part 5: Optional AI Inference Enhancement](#part-5-optional-ai-inference-enhancement)
- [Validation](#validation)
- [Maturity Path](#maturity-path)
- [Related Guides](#related-guides)
- [ROI Recap](#roi-recap)

---

## Background

### The AIOps Gap: Detection Without Remediation

Modern observability platforms excel at detecting anomalies, identifying root causes, and correlating events. But without an automation layer to act on those signals, organizations are left with dashboards and alert noise. The value of observability is only realized when it connects to remediation — and that remediation must be governed, auditable, and consistent across teams and shifts.

### Ansible Automation Platform: The Trusted Automation Layer

Red Hat Ansible Automation Platform provides the capabilities that turn observability signals into safe, governed action:

- **Automation controller** — centralized execution of job templates with full RBAC, ensuring only authorized teams can trigger remediation within their scope
- **Event-Driven Ansible** — real-time event processing via rulebooks that match observability events to the correct remediation job template, eliminating manual triage
- **Audit trail** — every job execution is logged with who triggered it, what changed, and whether it succeeded, satisfying compliance and change management requirements
- **Approval workflows** — workflow job templates can include approval nodes so that high-impact remediations require human sign-off before execution
- **Credential management** — secrets are stored in automation controller and injected at runtime, never exposed in playbooks or logs
- **Execution environments** — containerized, reproducible runtime environments ensure remediation playbooks run identically in dev, staging, and production

### IBM Instana: The Detection Layer

[IBM Instana Observability](https://www.ibm.com/products/instana) is a full-stack observability platform that provides the intelligent detection feeding AAP's automation layer:

- **Zero-config auto-discovery** of [300+ technologies](https://www.ibm.com/products/instana/supported-technologies) — application runtimes, databases, messaging systems, Kubernetes clusters, and infrastructure — without manual agent configuration
- **[Probable Root Cause](https://www.ibm.com/blog/probable-root-cause-accelerating-incident-remediation-with-causal-ai/)** — uses causal AI and differential observability to identify *why* something broke, not just *that* it broke, giving AAP the context needed to choose the right remediation
- **[Smart Alerts](https://www.ibm.com/docs/en/instana-observability/current?topic=applications-smart-alerts)** with [adaptive thresholds](https://www.ibm.com/docs/en/instana-observability/1.0.313?topic=instana-adaptive-thresholds-in-smart-alerts) — learns daily and weekly seasonality patterns to reduce false positives without manual threshold tuning
- Three event types (**Change**, **Issue**, **Incident**) that map cleanly to EDA rulebook conditions

IBM owns both Instana and Red Hat, which means tighter integration than third-party observability tools. The [`ibm.instana`](https://catalog.redhat.com/en/software/collection/ibm/instana) Ansible Content Collection is available on Red Hat automation hub, and Instana's [Intelligent Remediation](https://www.ibm.com/new/announcements/achieving-operational-efficiency-through-instanas-intelligent-remediation) uses watsonx to generate curated Ansible playbooks published in the [`instana/intelligent-remediation-ansible`](https://github.com/instana/intelligent-remediation-ansible) GitHub repository.

---

## Solution

### Components

**Ansible Automation Platform — the automation layer:**

- **[Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)** — governed job template execution with RBAC, audit trail, approval workflows, and credential management via automation controller
- **[Event-Driven Ansible](https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible)** — real-time event processing: webhook listener, rulebook conditions, and automated job template triggering (Path A)
- **[`ibm.instana`](https://catalog.redhat.com/en/software/collection/ibm/instana) Ansible Content Collection** — dedicated `instana_webhook` EDA source plugin for parsing Instana webhook payloads

**IBM Instana — the detection layer:**

- **[IBM Instana Observability](https://www.ibm.com/products/instana)** — auto-discovery, Smart Alerts with adaptive thresholds, Probable Root Cause (causal AI)
- **Instana automation framework** — in-product action catalog with AI-powered action recommendations and auto-trigger via automation policies (Path B)

**Optional:**

- **AI inference endpoint** — Red Hat AI or any OpenAI-compatible API for enriched remediation recommendations

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| **IT Ops Engineer / SRE** | Alert fatigue from observability tools; manual triage and inconsistent remediation across shifts | AAP provides consistent, tested remediation via governed job templates — Instana Incidents trigger the right fix automatically, every time |
| **Automation Architect** | Need to connect observability signals to AAP with proper RBAC, credential management, and approval workflows | Two production-ready integration patterns with verified YAML, correct payload accessors, and automation controller configuration tables |
| **IT Manager / Director** | MTTR measured in hours; no audit trail for incident response; difficult to justify observability spend | AAP's audit trail satisfies compliance; MTTR drops to minutes; observability investment becomes an active remediation trigger, not just dashboards |

### Demos and Labs

- [Red Hat TV: From Observability to Action with Event-Driven Ansible and IBM Instana](https://tv.redhat.com/en/detail/6365958260112/from-observability-to-action-with-event-driven-ansible-and-ibm-instana)
- [IBM Developer: Automation-Powered AIOps using Instana and Red Hat Ansible](https://developer.ibm.com/articles/automation-powered-aiops/)

---

## Prerequisites

### Red Hat Ansible Automation Platform

**Ansible Automation Platform 2.5+** — required for Event-Driven Ansible controller (GA) and the `ansible.eda` collection.

### Featured Ansible Content Collections

| Collection | Source | Purpose |
|-----------|--------|---------|
| [`ibm.instana`](https://catalog.redhat.com/en/software/collection/ibm/instana) | Red Hat automation hub / Ansible Galaxy | Dedicated `instana_webhook` EDA source plugin |
| [`ansible.eda`](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/) | Ansible Certified Content (bundled) | Fallback webhook source, event filters |
| [`community.mysql`](https://galaxy.ansible.com/ui/repo/published/community/mysql/) | Community | Database remediation tasks (Use Case 2) |
| [`kubernetes.core`](https://console.redhat.com/ansible/automation-hub/repo/published/kubernetes/core/) | Ansible Certified Content | Kubernetes rollback tasks (Use Case 3) |

### External Systems

| System | Required | Notes |
|--------|----------|-------|
| IBM Instana (SaaS or self-hosted) | Yes | API token with "Configuration of alert channels" permission |
| Automation controller | Yes | Job template execute permissions for EDA service account |
| Event-Driven Ansible controller | Yes (Path A) | Must be reachable from Instana SaaS for webhook delivery |
| AI inference endpoint | Optional | For LLM enrichment step only |

### Technical Requirements

- Python >= 3.9
- Ansible Core >= 2.15.0
- aiohttp >= 3.8.4 (dependency for `ibm.instana` collection)

**Operational Impact:** Medium — remediation playbooks modify production services. Validate all automation in a non-production environment before enabling auto-trigger.

### Cost and Resource Notes

- No GPU required unless using the optional AI inference endpoint
- **Instana licensing**: SaaS or self-hosted; automation framework capability requires Standard or Enterprise edition
- **Event-Driven Ansible controller**: included in AAP subscription, sized per standard [AAP planning guidance](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/planning_your_installation/)
- **AI inference endpoint** (optional): see [AI Infrastructure automation with Ansible](README-IA.md) for GPU and model serving requirements

---

## Integration Architecture

This guide covers two production-ready integration paths. Both are GA and can be used independently or together.

When an Instana Smart Alert fires — for example, a service latency spike detected by adaptive thresholds — the alert triggers one of two paths into Ansible Automation Platform. In Path A, Instana sends a webhook to Event-Driven Ansible, where a rulebook evaluates the event payload (severity, entity type, alert text) and triggers the matching remediation job template on automation controller. In Path B, Instana's automation framework evaluates the event against automation policies and triggers an action from the action catalog directly on automation controller via the Automation Action Ansible sensor. In both paths, automation controller executes the remediation playbook with full RBAC scoping and credential injection. The playbook performs the fix (restart a service, recycle database connections, roll back a deployment) and posts an annotation back to Instana via the Host Agent REST API. Instana displays this annotation as a Change event on the Incident timeline, closing the feedback loop so operators can see exactly what automation did and when.

### Operational Impact per Stage

| Stage | Impact | Why |
|-------|--------|-----|
| **Shared setup** (API token, credential type) | None | Configuration only — no changes to running systems |
| **Path A setup** (webhook channel, alert config, rulebook) | Low | Configures event routing — no production changes |
| **Path B setup** (sensor config, automation policy) | Low | Configures event routing — no production changes |
| **Use Case 1: Service restart** | Medium | Restarts a running service; validated by health check |
| **Use Case 2: DB connection recycle** | Medium | Kills idle database connections; validated by connection count |
| **Use Case 3: Deployment rollback** | High | Reverts production code; use approval gates until validated |
| **AI enrichment** (optional) | Low | Read-only API call to inference endpoint; no infrastructure changes |

### Path A: Event-Driven Ansible

```
Instana Smart Alert fires
  -> Instana webhook alert channel sends HTTP POST
  -> Event-Driven Ansible controller receives event via ibm.instana.instana_webhook source
  -> Rulebook condition matches on event.payload.issue.severity, .text, .type
  -> run_job_template action triggers automation controller job template
  -> Automation controller executes remediation playbook (RBAC-scoped, credential-injected)
  -> Playbook posts annotation back to Instana via Host Agent REST API
  -> Instana timeline shows remediation Change event alongside the Incident
```

### Path B: Instana Automation Framework

```
Instana Smart Alert or event fires
  -> Instana automation policy evaluates trigger conditions
  -> Policy triggers action automatically (or operator triggers manually)
  -> Instana AI recommends best action from action catalog (confidence score)
  -> Automation Action Ansible sensor connects to automation controller
  -> Automation controller executes remediation job template (same RBAC, same audit trail)
  -> Action output reported back to Instana Incident timeline
```

### When to Use Which Path

| Consideration | Path A: Event-Driven Ansible | Path B: Automation framework |
|--------------|------------------------------|------------------------------|
| Trigger type | Automatic (webhook-driven) | Automatic (automation policy) or manual |
| Governance model | EDA rulebook conditions + automation controller RBAC | Instana automation policies + automation controller RBAC |
| AI enrichment | Add custom LLM step in EDA workflow | Built-in (Instana AI recommends actions with confidence score) |
| Rule complexity | Multi-condition logic, regex matching, multi-source correlation | Policy-based: event definition, Smart Alert, or schedule |
| Infrastructure | Requires Event-Driven Ansible controller | Uses Instana host agent's Automation Action Ansible sensor (no extra infra) |
| Best for | Complex multi-step orchestration, custom logic | Direct Instana-to-AAP remediation, AI-guided actions, minimal setup |

> **Tip:** Both paths converge on automation controller for execution. The RBAC policies, credential types, audit trail, and approval workflows are identical regardless of which path triggers the job template.

---

## Solution Walkthrough

### Part 1: Shared Setup

#### Step 1: Create an Instana API Token

**Operational Impact:** None

1. In Instana, navigate to **Settings > Team Settings > API Tokens**
2. Create a new token with the permission **Configuration of alert channels** (required for webhook setup)
3. Store the token securely — it will be needed for Path B (Automation Action Ansible sensor configuration)

#### Step 2 (Optional): Create a custom credential type in automation controller

**Operational Impact:** None

> Only needed if your playbooks call the Instana backend API (e.g., `POST /api/releases` for deployment markers). The remediation playbooks in this guide use the [Host Agent REST API](https://www.ibm.com/docs/en/instana-observability/current?topic=apis-host-agent-rest-api) on `localhost:42699`, which requires no authentication.

Input configuration:

```yaml
fields:
  - id: instana_api_token
    type: string
    label: Instana API Token
    secret: true
  - id: instana_base_url
    type: string
    label: Instana Base URL
required:
  - instana_api_token
  - instana_base_url
```

Injector configuration:

```yaml
extra_vars:
  instana_api_token: !unsafe "{{ instana_api_token }}"
  instana_base_url: !unsafe "{{ instana_base_url }}"
```

---

### Part 2: Path A — Event-Driven Ansible Integration

#### Step 3: Configure an Instana webhook alert channel

**Operational Impact:** None

Navigate to **Settings > Events & Alerts > Alert Channels > Add Alert Channel > Generic Webhook** in Instana.

| Field | Value |
|-------|-------|
| **Name** | `EDA Webhook - Remediation` |
| **Webhook URL** | `https://eda.example.com:5000/instana` |
| **Custom HTTP Headers** | (optional: `X-EDA-Token: <bearer-token>` for auth) |

> **Note:** Instana states "The Instana Webhook format is not compatible with third-party tools expecting Incoming Webhooks in their format." This is expected — the `ibm.instana.instana_webhook` source plugin handles parsing.

Use the **Test Channel** button to verify delivery before proceeding.

#### Step 3b: Create an alert configuration in Instana

1. Navigate to **Settings > Events & Alerts > Alerts > New Alert**
2. Select **Alert on Event(s)**
3. Add events by filtering on entity type (e.g., Application, Service, Host)
4. Under **Alerting**, attach the `EDA Webhook - Remediation` alert channel
5. Set scope to the appropriate Application Perspective or infrastructure zone

When the alert fires, Instana sends an HTTP POST with the following default payload:

```json
{
  "issue": {
    "id": "abc123-def456",
    "type": "issue",
    "state": "OPEN",
    "start": 1709500000000,
    "severity": 10,
    "text": "Erroneous call rate is too high",
    "suggestion": "Check application logs for errors",
    "link": "https://instana.example.com/#/?snapshotId=abc123",
    "zone": "production",
    "fqdn": "app-server-01.example.com",
    "entity": "jvm",
    "entityLabel": "checkout-service",
    "container": "checkout-pod-7b8f9"
  }
}
```

Key fields for EDA rulebook conditions:

| Payload Field | EDA Accessor | Description |
|--------------|-------------|-------------|
| `issue.severity` | `event.payload.issue.severity` | `5` = Warning, `10` = Critical |
| `issue.text` | `event.payload.issue.text` | Alert title (used for pattern matching in rulebook conditions) |
| `issue.state` | `event.payload.issue.state` | `OPEN` or `CLOSED` |
| `issue.entity` | `event.payload.issue.entity` | Entity type (`jvm`, `Host`, `mysql`, etc.) |
| `issue.fqdn` | `event.payload.issue.fqdn` | Target host FQDN (passed as `limit` to the job template) |
| `issue.suggestion` | `event.payload.issue.suggestion` | Instana's remediation suggestion |
| `issue.link` | `event.payload.issue.link` | Direct link to the Incident in Instana UI |

#### Step 4: Create an EDA rulebook and rulebook activation

**Operational Impact:** Low

The following rulebook uses the dedicated `ibm.instana.instana_webhook` source plugin and handles all three use cases covered in this guide. Each rule matches on specific Instana event patterns and triggers the corresponding automation controller job template via the `run_job_template` action.

```yaml
---
- name: Instana Incident Remediation
  hosts: all
  sources:
    - ibm.instana.instana_webhook:
        host: 0.0.0.0
        port: 5000

  rules:
    - name: Service Latency - restart affected service
      condition: >
        event.payload.issue.severity == 10 and
        event.payload.issue.text is match(".*Slow.*|.*latency.*|.*response time.*", ignorecase=true) and
        event.payload.issue.state == "OPEN"
      action:
        run_job_template:
          name: "Instana - Service Latency Remediation"
          organization: "Default"
          job_args:
            extra_vars:
              target_host: "{{ event.payload.issue.fqdn }}"
              entity_label: "{{ event.payload.issue.entityLabel }}"
              instana_link: "{{ event.payload.issue.link }}"
              instana_suggestion: "{{ event.payload.issue.suggestion }}"

    - name: Database Performance - clear cache and recycle connections
      condition: >
        event.payload.issue.severity >= 5 and
        event.payload.issue.entity is match(".*sql.*|.*db.*|.*database.*|.*mysql.*|.*postgres.*", ignorecase=true) and
        event.payload.issue.state == "OPEN"
      action:
        run_job_template:
          name: "Instana - Database Performance Remediation"
          organization: "Default"
          job_args:
            extra_vars:
              target_host: "{{ event.payload.issue.fqdn }}"
              entity_label: "{{ event.payload.issue.entityLabel }}"

    - name: Deployment Error Spike - trigger rollback
      condition: >
        event.payload.issue.severity == 10 and
        event.payload.issue.text is match(".*error rate.*|.*erroneous call.*", ignorecase=true) and
        event.payload.issue.state == "OPEN"
      action:
        run_job_template:
          name: "Instana - Deployment Rollback"
          organization: "Default"
          job_args:
            extra_vars:
              target_host: "{{ event.payload.issue.fqdn }}"
              entity_label: "{{ event.payload.issue.entityLabel }}"
              instana_link: "{{ event.payload.issue.link }}"

    - name: Log all unmatched events for debugging
      condition: event.payload.issue is defined
      action:
        debug:
          msg: >
            Unmatched Instana event: {{ event.payload.issue.text }}
            (severity={{ event.payload.issue.severity }})
```

Create a rulebook activation in the Event-Driven Ansible controller:

| Field | Value |
|-------|-------|
| **Name** | `Instana Incident Remediation` |
| **Project** | `Instana AIOps` (Git repo containing rulebooks) |
| **Rulebook** | `instana_remediation.yml` |
| **Decision environment** | Custom image with `ibm.instana` and `aiohttp>=3.8.4` installed |
| **Credential** | Automation controller credential (for `run_job_template`) |
| **Restart policy** | `Always` |

---

### Part 3: Path B — Instana Automation Framework

#### Step 5: Configure the Automation Action Ansible sensor

**Operational Impact:** Low

The [Automation Action Ansible sensor](https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-automation-action-ansible) runs on the Instana host agent and connects to automation controller via the Ansible automation connector.

Add the following to the Instana agent configuration file:

```yaml
com.instana.plugin.action.ansible:
  enabled: true
  url: https://aap-controller.example.com
  token: <aap_api_token>
  apiPath: /api/v2          # optional, default
  maxConcurrentActions: 10  # optional, default
  defaultTimeout: 300       # optional, seconds
```

Key capabilities:
- **Auto-import**: Automatically imports all job templates and workflow job templates from automation controller into the Instana action catalog (since sensor 1.0.74, July 2025). No manual action creation required.
- **Concurrent execution**: Supports up to 10 concurrent actions (configurable).
- **No container runtime required**: Works without Docker or Podman (since sensor 1.0.58).
- **Workflow output**: Retrieves comprehensive workflow job template outputs (since sensor 1.0.78).

#### Step 6: Verify auto-imported job templates

**Operational Impact:** None

1. Navigate to **Automation > Action Catalog** in Instana
2. Verify that automation controller job templates appear as Ansible actions
3. Instana displays a **confidence score** for each action-event association based on text-similarity matching between the action metadata and event context

#### Step 7: Create an automation policy for auto-trigger

**Operational Impact:** Medium

1. Navigate to **Automation > Automation Policies > Create Policy** in Instana
2. Configure the trigger: event definition, Smart Alert, or schedule
3. Set execution mode: **automatic**, manual, or both
4. Associate with one or more actions from the action catalog
5. When the trigger fires, Instana automatically executes the associated Ansible action on automation controller — the same RBAC, credential management, and audit trail apply as with Path A

> **Alternative: Route through Event-Driven Ansible**
>
> If you prefer EDA for complex multi-step orchestration, create a **Script** action in Instana that forwards event data to the EDA webhook:
>
> ```bash
> #!/bin/bash
> if [ -z "${INSTANA_EVENT}" ]; then
>   curl -s -H 'Content-Type: application/json' \
>     -d '{"message": "Test event from Instana automation framework"}' \
>     @@eda_server@@/instana
> else
>   curl -s -H 'Content-Type: application/json' \
>     -d "${INSTANA_EVENT}" \
>     @@eda_server@@/instana
> fi
> ```

---

### Part 4: Use Case Walkthroughs

#### Use Case 1: Service Latency Spike Recovery

**Operational Impact:** Medium

Instana detects response time exceeding the adaptive threshold on a microservice. A Smart Alert fires based on seasonality-adjusted latency thresholds. The EDA rulebook matches on `event.payload.issue.text` containing latency-related patterns and triggers the remediation job template on automation controller.

**Remediation playbook — featured tasks:**

```yaml
- name: Gather service state before restart
  ansible.builtin.systemd:
    name: "{{ service_name }}"
  register: service_state

- name: Restart service to clear thread pool exhaustion
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: restarted
  when: service_state.status.ActiveState == "active"

- name: Wait for service health check to pass
  ansible.builtin.uri:
    url: "http://{{ inventory_hostname }}:{{ service_port }}/health"
    status_code: 200
  retries: 10
  delay: 6
  register: health_check
  until: health_check.status == 200

- name: Post remediation annotation to Instana via Host Agent REST API
  ansible.builtin.uri:
    url: "http://localhost:42699/com.instana.plugin.generic.event"
    method: POST
    body_format: json
    body:
      title: "AAP Remediation: {{ service_name }} restarted"
      text: >
        Service restarted by automation controller job {{ tower_job_id }}
        due to latency spike. Health check passed.
      severity: -1
      duration: 30000
```

**Job template configuration in automation controller:**

| Field | Value |
|-------|-------|
| **Name** | `Instana - Service Latency Remediation` |
| **Inventory** | `Application Servers` |
| **Project** | `Instana AIOps Playbooks` |
| **Playbook** | `remediate_service_latency.yml` |
| **Credentials** | Machine credential |
| **Extra variables** | `target_host` (prompt on launch), `service_name`, `service_port` |
| **Limit** | `{{ target_host }}` (dynamic, passed from Event-Driven Ansible) |

The Host Agent REST API annotation (severity `-1` = Change) creates a visible marker on the Instana timeline, linking the remediation action to the original Incident for post-incident review.

---

#### Use Case 2: Database Performance Degradation

**Operational Impact:** Medium

Instana detects slow query execution times or connection pool exhaustion on a monitored MySQL database. The `entity` field in the webhook payload matches database-related patterns. Automation controller runs a job template that identifies and kills idle connections.

**Remediation playbook — featured tasks:**

```yaml
- name: Check current connection count
  community.mysql.mysql_query:
    login_host: "{{ db_host }}"
    login_user: "{{ db_admin_user }}"
    login_password: "{{ db_admin_password }}"
    query: "SHOW STATUS WHERE Variable_name = 'Threads_connected'"
  register: db_connections

- name: Kill idle connections exceeding threshold
  community.mysql.mysql_query:
    login_host: "{{ db_host }}"
    login_user: "{{ db_admin_user }}"
    login_password: "{{ db_admin_password }}"
    query: >
      SELECT CONCAT('KILL ', id, ';') FROM information_schema.processlist
      WHERE command = 'Sleep' AND time > 300
  register: idle_connections
  when: db_connections.query_result[0][0].Value | int > connection_threshold

- name: Post remediation annotation to Instana via Host Agent REST API
  ansible.builtin.uri:
    url: "http://localhost:42699/com.instana.plugin.generic.event"
    method: POST
    body_format: json
    body:
      title: "AAP Remediation: DB connections recycled on {{ db_host }}"
      text: >
        Idle connections killed. Previous count:
        {{ db_connections.query_result[0][0].Value }}
      severity: -1
      duration: 60000
```

> **Tip:** Store database credentials in an automation controller credential type — never hardcode `db_admin_user` or `db_admin_password` in playbook variables. Use injectors to pass them as extra variables or environment variables at runtime.

---

#### Use Case 3: Bad Deployment Auto-Rollback

**Operational Impact:** High

Instana detects a spike in erroneous call rate correlated with a recent deployment Change event. Probable Root Cause identifies the deployment as the likely cause. Automation controller runs a job template that triggers a Kubernetes rollback.

> **Warning:** This use case has **high** operational impact — a rollback reverts production code. Use automation controller approval workflow nodes (see [Maturity Path](#maturity-path)) until this pattern is validated in your environment.

**Remediation playbook — featured tasks:**

```yaml
- name: Get deployment rollout history
  kubernetes.core.k8s_info:
    kind: Deployment
    name: "{{ app_name }}"
    namespace: "{{ app_namespace }}"
  register: current_deploy

- name: Roll back to previous revision
  ansible.builtin.command:
    cmd: >
      kubectl rollout undo deployment/{{ app_name }}
      -n {{ app_namespace }}
  register: rollback_result

- name: Wait for rollout to complete
  ansible.builtin.command:
    cmd: >
      kubectl rollout status deployment/{{ app_name }}
      -n {{ app_namespace }} --timeout=120s
  register: rollout_status

- name: Post rollback annotation to Instana via Host Agent REST API
  ansible.builtin.uri:
    url: "http://localhost:42699/com.instana.plugin.generic.event"
    method: POST
    body_format: json
    body:
      title: "AAP Remediation: {{ app_name }} rolled back"
      text: >
        Deployment rolled back due to error rate spike.
        {{ rollback_result.stdout }}
      severity: -1
      duration: 120000
```

> **Tip:** For Kubernetes remediation, store the `kubeconfig` in an automation controller credential of type "OpenShift or Kubernetes API Bearer Token" and ensure the execution environment includes the `kubernetes.core` Ansible Certified Content Collection.

---

### Part 5: Optional AI Inference Enhancement

For teams that want richer remediation recommendations beyond Instana's built-in Probable Root Cause — for example, using an LLM to analyze the Incident context and recommend which remediation job template to run.

This uses a **workflow job template** pattern in automation controller: Event-Driven Ansible triggers a workflow that first calls an AI inference endpoint, then conditionally runs the appropriate remediation job template based on the AI response.

```yaml
- name: Enrich Incident with AI analysis
  ansible.builtin.uri:
    url: "{{ ai_inference_url }}/v1/chat/completions"
    method: POST
    headers:
      Authorization: "Bearer {{ ai_api_token }}"
      Content-Type: "application/json"
    body_format: json
    body:
      model: "{{ ai_model }}"
      messages:
        - role: system
          content: >
            You are an SRE assistant. Given an Instana Incident, recommend
            exactly ONE remediation action from this list: restart_service,
            recycle_db_connections, rollback_deployment, scale_out, do_nothing.
            Respond with only the action name.
        - role: user
          content: |
            Incident: {{ instana_issue_text }}
            Entity: {{ instana_entity_label }}
            Entity Type: {{ instana_entity_type }}
            Severity: {{ instana_severity }}
            Instana Suggestion: {{ instana_suggestion }}
  register: ai_response

- name: Set recommended action
  ansible.builtin.set_fact:
    recommended_action: "{{ ai_response.json.choices[0].message.content | trim }}"
```

**When to use AI enrichment vs. direct remediation:**

| Scenario | Approach |
|----------|----------|
| Well-understood, recurring failure with a single correct response | Direct remediation — no AI needed |
| Novel failure mode, ambiguous root cause, or multiple possible remediations | AI enrichment — LLM recommends the action |
| Instana Probable Root Cause provides a clear suggestion | Direct remediation using the `suggestion` field |

> **Tip:** The generic [AIOps automation with Ansible](README-AIOps.md) guide covers the AI inference pattern in depth, including how to use Red Hat AI, OpenAI, or any OpenAI-compatible endpoint.

---

## Validation

### Per-Stage Checklist

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| Instana API token | Token has correct permissions | Settings > API Tokens shows token with alert channel scope |
| Webhook alert channel | Channel is configured and reachable | **Test Channel** button returns success |
| Alert rule | Alert is bound to webhook alert channel | Settings > Alerts shows the channel under the rule |
| Rulebook activation | Activation is running | Event-Driven Ansible controller shows status **Running** |
| Webhook delivery | Instana event reaches Event-Driven Ansible | Rulebook activation log shows received event JSON |
| Condition match | Correct rule fires for test event | Activation log shows matched rule name |
| Job template launch | Job template triggered by Event-Driven Ansible | Automation controller job history shows new job |
| Remediation | Service/DB/deployment recovers | Target system returns to healthy state |
| Instana annotation | Remediation visible in Instana | Timeline shows Change event with AAP remediation details |

### Test

Send a synthetic Instana-format event to the Event-Driven Ansible controller to validate the end-to-end flow without waiting for a real Incident:

```bash
curl -X POST https://eda.example.com:5000/instana \
  -H "Content-Type: application/json" \
  -d '{
    "issue": {
      "id": "test-001",
      "type": "issue",
      "state": "OPEN",
      "start": 1709500000000,
      "severity": 10,
      "text": "Slow response time detected on checkout-service",
      "suggestion": "Check thread pool configuration",
      "link": "https://instana.example.com/#/?snapshotId=test",
      "fqdn": "app-server-01.example.com",
      "entity": "jvm",
      "entityLabel": "checkout-service",
      "zone": "production"
    }
  }'
```

### Expected Result

The automation controller job output should show:

```
PLAY [Remediate service latency] ************************************************

TASK [Gather service state before restart] **************************************
ok: [app-server-01.example.com]

TASK [Restart service to clear thread pool exhaustion] **************************
changed: [app-server-01.example.com]

TASK [Wait for service health check to pass] ************************************
ok: [app-server-01.example.com]

TASK [Post remediation annotation to Instana via Host Agent REST API] ***********
ok: [app-server-01.example.com]

PLAY RECAP *********************************************************************
app-server-01.example.com : ok=4    changed=1    unreachable=0    failed=0
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Rulebook activation fails to start | `ibm.instana` collection not in decision environment | Build a custom decision environment image with `ibm.instana` and `aiohttp>=3.8.4` |
| Webhook events received but no rule fires | Condition field paths don't match payload | Add the catch-all debug rule (included in the rulebook) to log raw payload and verify field paths |
| Rule fires but job template fails to launch | Job template name mismatch or missing credential | Verify the exact job template name and organization in automation controller; check credential type is "Red Hat Ansible Automation Platform" |
| Instana Test Channel returns error | Event-Driven Ansible controller not reachable | Verify firewall rules allow inbound HTTPS from Instana SaaS IPs to the EDA port |
| Remediation runs but Instana still shows Incident | Instana auto-closes Issues based on metric recovery | Wait for Instana's evaluation cycle; verify the root metric recovered |
| Annotation POST returns connection refused | Instana host agent not running on target | Verify agent status: `systemctl status instana-agent` |
| Automation Action Ansible sensor can't reach automation controller | Ansible automation connector misconfigured | Verify the URL and API token in the Instana host agent configuration |

---

## Maturity Path

| Maturity | Description | What to Build |
|----------|-------------|---------------|
| **Crawl** | Instana alerts forwarded to Event-Driven Ansible, which enriches and routes notifications — no remediation, human decides | Instana webhook -> EDA rulebook -> `run_job_template` that sends a Slack or email notification with Incident context and Instana link |
| **Walk** | Event-Driven Ansible triggers automation controller job templates with a human approval gate before execution | Enable `ask_variables_on_launch` on job templates; use automation controller approval workflow nodes; operator reviews before remediation runs |
| **Run** | Fully automated closed-loop: Instana detects -> Event-Driven Ansible triggers -> automation controller remediates -> Instana confirms resolution | Remove approval gates for well-understood failure patterns; add policy guardrails (e.g., max 3 auto-remediations per hour per service, business-hours-only for critical services) |

---

## Related Guides

- [AIOps automation with Ansible](README-AIOps.md) — the tool-agnostic AIOps pattern that this guide builds on
- [AI Infrastructure automation with Ansible](README-IA.md) — deploy the AI inference backend if using the optional LLM enrichment step
- [Get started with EDA](https://access.redhat.com/articles/7136720) — Event-Driven Ansible fundamentals for teams new to event-driven automation

---

## ROI Recap

By connecting IBM Instana to Ansible Automation Platform, you have built a governed, automated incident remediation pipeline:

- **MTTR reduction**: Automated response drops mean time to resolution from hours (manual triage, handoff, remediation) to minutes (detect, trigger, fix, verify)
- **Consistent remediation**: Every Incident triggers the same tested, RBAC-scoped job template — regardless of which engineer is on call or what shift it is
- **Alert fatigue reduction**: Event-Driven Ansible filters and routes events so only truly novel or unresolvable Incidents escalate to human operators
- **Observability ROI**: Instana shifts from passive monitoring (dashboards and alerts) to an active remediation engine, with AAP providing the trusted execution layer
- **Compliance and audit**: Every remediation is logged in automation controller — who triggered it, what changed, which hosts were affected, and whether it succeeded — satisfying change management and compliance requirements

---

## Sources

- [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)
- [Red Hat — Event-Driven Ansible](https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible)
- [Red Hat Automation Hub — ibm.instana](https://catalog.redhat.com/en/software/collection/ibm/instana)
- [IBM Instana Observability](https://www.ibm.com/products/instana)
- [IBM Docs — Webhook Alert Channel](https://www.ibm.com/docs/en/instana-observability/current?topic=alerting-webhooks)
- [IBM Docs — Smart Alerts](https://www.ibm.com/docs/en/instana-observability/current?topic=applications-smart-alerts)
- [IBM Docs — Adaptive Thresholds](https://www.ibm.com/docs/en/instana-observability/1.0.313?topic=instana-adaptive-thresholds-in-smart-alerts)
- [IBM Docs — Event Types](https://www.ibm.com/docs/en/instana-observability/current?topic=references-event-types)
- [IBM Docs — Host Agent REST API](https://www.ibm.com/docs/en/instana-observability/current?topic=apis-host-agent-rest-api)
- [IBM Docs — Automation Action Ansible Sensor](https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-automation-action-ansible)
- [IBM Docs — Managing Actions](https://www.ibm.com/docs/en/instana-observability/1.0.312?topic=instana-managing-actions)
- [IBM — Probable Root Cause with Causal AI](https://www.ibm.com/blog/probable-root-cause-accelerating-incident-remediation-with-causal-ai/)
- [IBM — Intelligent Remediation](https://www.ibm.com/new/announcements/achieving-operational-efficiency-through-instanas-intelligent-remediation)
- [IBM — Intelligent Incident Investigation](https://www.ibm.com/new/announcements/use-agentic-ai-to-resolve-incidents-faster-with-ibm-instana-intelligent-incident-investigation)
- [GitHub — ibm.instana EDA Collection](https://github.com/instana/ibm-instana-ansible)
- [GitHub — Intelligent Remediation Playbooks](https://github.com/instana/intelligent-remediation-ansible)
- [GitHub — Instana Ansible Callback Plugin](https://github.com/instana/instana-ansible)
