# Plan: Instana + AAP AIOps Solution Guide (v3 — Terminology-Corrected)

## Context

Create a new solution guide for **IBM Instana Observability + Red Hat Ansible Automation Platform** as an AIOps solution. It must match the gold standard of `README-AIOps.md` and follow the 9-step framework in `README-best-practices.md`.

Two integration entry points (both GA):
- **Path A**: Instana webhook alert channel → Event-Driven Ansible → automation controller job templates
- **Path B**: Instana automation framework (GA) → Automation Action Ansible sensor → automation controller job templates (with auto-trigger via automation policies)

Three use cases: Service latency spike recovery, Database performance degradation, Bad deployment auto-rollback.

AI layer: Instana's built-in Probable Root Cause (causal AI) is primary, with an optional external LLM step.

---

## Terminology Reference

### Red Hat Ansible Automation Platform (AAP)

| Official Term | Capitalization | Avoid |
|--------------|----------------|-------|
| Red Hat Ansible Automation Platform | Title case (first mention) | "Ansible Platform" |
| Ansible Automation Platform / AAP | Subsequent mentions | |
| automation controller | **lowercase** | "Automation Controller", "AAP Controller" |
| Event-Driven Ansible | Title case, hyphenated | "EDA Controller" as standalone |
| Event-Driven Ansible controller | lowercase "controller" | |
| job template | **lowercase** | "Job Template" |
| workflow job template | **lowercase** | "Workflow Job Template" |
| rulebook activation | **lowercase** | "Rulebook Activation" |
| decision environment | **lowercase** | "Decision Environment" |
| execution environment | **lowercase** | "Execution Environment" |
| credential / credential type | **lowercase** | |
| project / organization / survey | **lowercase** | |
| Ansible Content Collections | Title case | "collections" alone |
| Ansible Certified Content | Title case "Certified" | |
| Ansible validated content | lowercase "validated" | |
| automation mesh | **lowercase** | "Automation Mesh" |
| private automation hub | **lowercase** | "Private Automation Hub" |

### IBM Instana Observability

| Official Term | Capitalization | Avoid |
|--------------|----------------|-------|
| IBM Instana Observability | Full name (first mention) | "IBM Instana APM" |
| IBM Instana / Instana | Subsequent mentions | |
| automation framework | **lowercase** (the capability) | "Action Framework" (old tech preview name) |
| action catalog | **lowercase** in body text | "Action Catalog" only in UI references |
| automation policy | **lowercase** | "Action Policy" |
| Smart Alerts | Title case, two words | "SmartAlerts" (one word) |
| Automation Action Ansible sensor | Full official name (first mention) | "Ansible sensor", "Ansible action sensor" |
| Ansible automation connector | lowercase | "Automation Connector" (generic) |
| alert channel | **lowercase** | "notification channel" |
| Application Perspective | Title case | |
| Probable Root Cause | Feature name (title case) | "Causal AI" as a feature name |
| causal AI | **lowercase** (technique description) | |
| adaptive thresholds | **lowercase** | "dynamic baseline" |
| Intelligent Remediation | Title case | |
| Intelligent Incident Investigation | Title case | |
| Host Agent REST API | Official name for localhost:42699 | "Agent SDK" |
| host agent / Instana agent | lowercase | |
| Change, Issue, Incident | Capitalize as event types | |
| Warning (5), Critical (10) | Severity level names | "High", "Medium", "Low" |

---

## Research Corrections (from v1)

### 1. Webhook Payload Structure Was Wrong

**v1 assumed** flat fields like `event.payload.title`, `event.payload.severity`.

**Actual**: Instana's default webhook wraps everything in an `issue` object:

```json
{
  "issue": {
    "id": "unique-identifier",
    "type": "issue|change|presence|monitoringIssue",
    "state": "OPEN|CLOSED",
    "start": 1460537793322,
    "end": 1460538393322,
    "severity": 5,
    "text": "Alert title",
    "suggestion": "Remediation guidance",
    "link": "https://instance/#/?snapshotId=...",
    "zone": "prod",
    "fqdn": "host1.demo.com",
    "entity": "jvm|Host|Process",
    "entityLabel": "Entity name",
    "tags": "comma-separated values",
    "container": "container-name"
  }
}
```

**Correct EDA accessors**: `event.payload.issue.state`, `event.payload.issue.severity`, `event.payload.issue.text`, `event.payload.issue.entityLabel`, `event.payload.issue.fqdn`

### 2. Severity Is Numeric, Not String

Severity is an integer: `-1` = Change/Info, `5` = Warning, `10` = Critical. Correct condition: `event.payload.issue.severity == 10`.

### 3. The `ibm.instana` Collection Has Its Own Source Plugin

The `ibm.instana` collection includes a dedicated `instana_webhook` source plugin:

```yaml
sources:
  - ibm.instana.instana_webhook:
      host: 0.0.0.0
      port: 5000
```

### 4. Automation Framework Is Now GA (Updated March 2026)

The Instana automation framework has graduated to GA. Key updates:
- **Auto-trigger is GA** — automation policies can trigger actions automatically based on event definitions, Smart Alerts, or schedules
- **Automation Action Ansible sensor is GA** — connects to automation controller via the Ansible automation connector, supports up to 10 concurrent actions
- **Auto-import of job templates shipped in sensor 1.0.74 (July 2025)** — the sensor auto-imports job templates and workflow job templates from automation controller whenever enabled or reconfigured
- **Intelligent Incident Investigation launched GA Dec 2025** — agentic AI that generates Bash or Ansible scripts

Sources:
- [Managing actions (v1.0.312, no beta label)](https://www.ibm.com/docs/en/instana-observability/1.0.312?topic=instana-managing-actions)
- [Automation Action Ansible sensor (v1.0.309)](https://www.ibm.com/docs/en/instana-observability/1.0.309?topic=technologies-automation-action-ansible)

### 5. Instana Host Agent REST API Was Wrong

**v1 used** `POST {{ instana_base_url }}/api/v1/events`.

**Actual**: Two correct approaches:
- **Host Agent REST API** (recommended): `POST http://localhost:42699/com.instana.plugin.generic.event` — no auth needed, agent-local endpoint
- **Backend API** for deployment markers: `POST /api/releases` with `authorization: apiToken <token>` header

### 6. Smart Alerts with Adaptive Thresholds Are the Recommended Approach

Built-in events and custom events for app/service/endpoint entities are **deprecated** in favor of Smart Alerts. Smart Alerts use **adaptive thresholds** (not "dynamic baselines") that learn daily/weekly seasonality patterns.

---

## Critical Files

- **Gold standard to match**: `README-AIOps.md`
- **Framework to follow**: `README-best-practices.md`
- **Output file**: `README-Instana-AIOps.md` (new)
- **Main index**: `README.md` (update with link)

---

## Guide Structure (9-Step Framework)

### 1. Title

`Automated Incident Remediation with IBM Instana and Ansible Automation Platform - Solution Guide`

---

### 2. Overview

**Problem statement**: IBM Instana Observability monitors 300+ technologies with 1-second granularity and uses causal AI to identify root causes automatically. Yet most organizations still route Instana alerts to human on-call engineers for manual triage and remediation — creating alert fatigue, inconsistent responses, and MTTR measured in hours. This guide demonstrates how to close the loop: Instana detects and diagnoses, Red Hat Ansible Automation Platform remediates — fully automated and governed.

Include:
- Hero image placeholder
- Linked table of contents

---

### 3. Background

What makes Instana different from other observability tools:
- **Zero-config auto-discovery** of 300+ technologies (vs. manual agent configuration)
- **1-second data granularity** with no sampling on distributed traces
- **Probable Root Cause** — uses causal AI and differential observability to analyze traces and topology, identifying unhealthy entities (not just threshold breaches)
- **Smart Alerts** with adaptive thresholds — learns daily/weekly seasonality patterns automatically
- **Three event types**: Changes (deployments, config), Issues (health signature breaches), Incidents (correlated groups of Issues affecting service KPIs)

Why Instana + Ansible Automation Platform (positioning the IBM family angle):
- IBM owns both Instana and Red Hat — tighter roadmap alignment than third-party integrations
- `ibm.instana` Ansible Content Collection available on Red Hat automation hub and Ansible Galaxy
- Instana's Intelligent Remediation uses watsonx to generate Ansible playbooks (see `instana/intelligent-remediation-ansible` GitHub repo)
- Instana monitors Ansible natively via a callback plugin — creating a bidirectional feedback loop

---

### 4. Solution

**Components:**
- **IBM Instana Observability** — Auto-discovery, Smart Alerts, Probable Root Cause (causal AI)
- **Event-Driven Ansible** — Webhook listener, event parsing, rulebook logic (Path A)
- **Instana automation framework** (GA) — In-product action catalog with AI-powered recommendations, auto-trigger via automation policies (Path B)
- **Red Hat Ansible Automation Platform** — Governed job template execution, audit trail, RBAC via automation controller
- **`ibm.instana` Ansible Content Collection** — Dedicated `instana_webhook` EDA source plugin
- **AI inference endpoint** (optional) — Red Hat AI or OpenAI-compatible API for enriched recommendations

**Persona table:**

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| IT Ops Engineer / SRE | Alert fatigue: Instana fires hundreds of alerts daily, each requiring manual investigation and response | Automated first-response: high-signal Instana Incidents trigger targeted, tested remediation via automation controller job templates without manual triage |
| Automation Architect | Connecting Instana's event model to automation controller requires understanding webhook payloads, EDA rulebook syntax, and credential flows | Two documented integration patterns (EDA webhook + automation framework) with verified YAML, correct payload accessors, and credential types |
| IT Manager / Director | MTTR measured in hours; difficult to show ROI on observability investment when it only produces dashboards | Instana investment becomes an active remediation trigger; MTTR drops to minutes; only unresolvable Incidents escalate to humans |

**Demos/Labs:**
- [Red Hat TV: From Observability to Action with Event-Driven Ansible and IBM Instana](https://tv.redhat.com/en/detail/6365958260112/from-observability-to-action-with-event-driven-ansible-and-ibm-instana)
- [IBM Developer: Automation-Powered AIOps using Instana and Red Hat Ansible](https://developer.ibm.com/articles/automation-powered-aiops/)

---

### 5. Prerequisites

**AAP Version:** Red Hat Ansible Automation Platform 2.5+ (Event-Driven Ansible controller GA, `ansible.eda` collection included)

**Featured Ansible Content Collections:**

| Collection | Source | Purpose |
|-----------|--------|---------|
| [`ibm.instana`](https://catalog.redhat.com/en/software/collection/ibm/instana) | Red Hat automation hub / Ansible Galaxy | Dedicated `instana_webhook` EDA source plugin |
| [`ansible.eda`](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/) | Ansible Certified Content (bundled with Event-Driven Ansible controller) | Fallback webhook source, event filters |
| [`community.mysql`](https://galaxy.ansible.com/ui/repo/published/community/mysql/) | Community | Database remediation tasks (Use Case 2) |
| [`kubernetes.core`](https://console.redhat.com/ansible/automation-hub/repo/published/kubernetes/core/) | Ansible Certified Content | Kubernetes rollback tasks (Use Case 3) |

**External Systems:**

| System | Required | Notes |
|--------|----------|-------|
| IBM Instana (SaaS or self-hosted) | Yes | API token with "Configuration of alert channels" permission |
| Automation controller | Yes | Job template execute permissions for EDA service account |
| Event-Driven Ansible controller | Yes (Path A) | Reachable from Instana SaaS for webhook delivery |
| AI inference endpoint | Optional | For LLM enrichment step only |

**Requirements:**
- Python >= 3.9
- Ansible Core >= 2.15.0
- aiohttp >= 3.8.4 (for `ibm.instana` collection)

**Operational Impact:** Medium — remediation playbooks modify production services. Test in non-prod first. Per-step impact ratings provided in the walkthrough.

---

### 6. Workflow and Architecture

**Path A: Event-Driven Ansible Path (GA)**
```
Instana Smart Alert fires
  -> Instana webhook alert channel sends HTTP POST to Event-Driven Ansible controller
  -> Event-Driven Ansible receives event via ibm.instana.instana_webhook source
  -> Rulebook condition matches on event.payload.issue.severity, .text, .type
  -> Rulebook triggers automation controller job template via run_job_template action
  -> Automation controller executes remediation playbook on target host(s)
  -> Playbook posts annotation back to Instana via Host Agent REST API
  -> Instana timeline shows remediation Change event alongside Incident
```

**Path B: Instana Automation Framework Path (GA)**
```
Instana Smart Alert or event fires
  -> Automation policy evaluates trigger conditions
  -> Policy triggers action automatically (or operator triggers manually from Incident view)
  -> Instana AI recommends best action from action catalog (confidence score)
  -> Automation Action Ansible sensor connects to automation controller via Ansible automation connector
  -> Automation controller executes remediation job template
  -> Action output and status reported back to Instana Incident timeline
```

**When to use which path:**

| Consideration | Path A: Event-Driven Ansible | Path B: Instana automation framework |
|--------------|------------------------------|--------------------------------------|
| Maturity | GA | GA |
| Trigger type | Automatic (webhook-driven) | Automatic (automation policy) or manual (operator) |
| Automation governance | EDA rulebook conditions + automation controller RBAC | Instana automation policies + automation controller RBAC |
| AI enrichment | Add custom LLM step in EDA workflow | Built-in (Instana AI recommends actions with confidence score) |
| Rule complexity | Multi-condition logic, regex matching, multi-source correlation | Policy-based: event definition, Smart Alert, or schedule triggers |
| Infrastructure | Requires Event-Driven Ansible controller deployment | Uses Instana host agent's Automation Action Ansible sensor (no extra infra) |
| Payload format | `event.payload.issue.*` (default webhook) | Instana passes event context to Automation Action Ansible sensor directly |
| Best for | Complex multi-step orchestration, custom logic, multi-source events | Direct Instana-to-AAP remediation, AI-guided actions, minimal setup |

---

### 7. Solution Walkthrough

#### Part 1: Shared Setup

**Step 1: Create an Instana API Token**
- Navigate to Settings > Team Settings > API Tokens
- Required permission: "Configuration of alert channels"
- For posting remediation annotations: "Configuration of releases" (optional)

**Step 2 (Optional): Create a custom credential type in automation controller for Instana backend API**

> Only needed if your playbooks call the Instana backend API (e.g., `POST /api/releases` for deployment markers). The remediation playbooks in this guide use the Host Agent REST API (`localhost:42699`) which requires no authentication.

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

#### Part 2: Path A — Event-Driven Ansible Integration

**Step 3: Configure Instana webhook alert channel**

Navigate to **Settings > Events & Alerts > Alert Channels > Add Alert Channel > Generic Webhook**

| Field | Value |
|-------|-------|
| **Name** | `EDA Webhook - Remediation` |
| **Webhook URL** | `https://eda.example.com:5000/instana` |
| **Custom HTTP Headers** | (optional: `X-EDA-Token: <bearer-token>` for auth) |

> **Note**: Instana states "The Instana Webhook format is not compatible with third-party tools expecting Incoming Webhooks in their format." This is expected — the EDA rulebook handles parsing.

Use the **Test Channel** button to verify delivery.

**Step 3b: Create an alert configuration in Instana**
1. Navigate to **Settings > Events & Alerts > Alerts > New Alert**
2. Select **Alert on Event(s)**
3. Add events by filtering on entity type (e.g., Application, Service, Host)
4. Under **Alerting**, attach the `EDA Webhook - Remediation` alert channel
5. Set scope to the appropriate Application Perspective or infrastructure zone

**Default payload sent by Instana** (this is what Event-Driven Ansible receives):

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

**Step 4: Create EDA rulebook**

Using the dedicated `ibm.instana.instana_webhook` source plugin:

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
          msg: "Unmatched Instana event: {{ event.payload.issue.text }} (severity={{ event.payload.issue.severity }})"
```

**Rulebook activation configuration in Event-Driven Ansible controller:**

| Field | Value |
|-------|-------|
| **Name** | `Instana Incident Remediation` |
| **Project** | `Instana AIOps` (Git repo containing rulebooks) |
| **Rulebook** | `instana_remediation.yml` |
| **Decision environment** | Custom image with `ibm.instana` collection installed |
| **Credential** | Automation controller credential (for `run_job_template` action) |
| **Restart policy** | `Always` |

---

#### Part 3: Path B — Instana Automation Framework (GA)

**Step 5: Configure the Automation Action Ansible sensor on the Instana host agent**

The Automation Action Ansible sensor runs on the Instana host agent and connects to automation controller via the Ansible automation connector.

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

Key sensor capabilities (GA):
- Auto-imports all job templates and workflow job templates from automation controller into the Instana action catalog (since sensor 1.0.74, July 2025)
- Supports up to 10 concurrent actions
- Works without Docker/Podman (since sensor 1.0.58, Dec 2024)
- Retrieves comprehensive workflow job outputs (since sensor 1.0.78, Feb 2026)

**Step 6: Verify auto-imported job templates**

Once the sensor is enabled, it automatically imports all job templates and workflow job templates from automation controller into the Instana action catalog:

1. Navigate to **Automation > Action Catalog** in Instana
2. Verify job templates appear as Ansible actions (auto-imported by sensor 1.0.74+)
3. No manual action creation needed — templates sync automatically on sensor enable/reconfigure
4. Instana shows a **confidence score** for each action-event association based on text-similarity matching

**Step 7: Create an automation policy for auto-trigger**

1. Navigate to **Automation > Automation Policies > Create Policy** in Instana
2. Configure trigger: event definition, Smart Alert, or schedule
3. Set execution mode: **automatic**, manual, or both
4. Associate with one or more actions from the action catalog
5. When the trigger fires, Instana automatically executes the associated Ansible action on automation controller

> **Alternative: Script-based action for Event-Driven Ansible integration**
>
> If you prefer to route through Event-Driven Ansible (for complex multi-step orchestration), create a **Script** action that POSTs event data to the EDA webhook:
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

#### Part 4: Use Case Walkthroughs

**Use Case 1: Service Latency Spike Recovery**

**Operational Impact:** Medium

Instana detects response time exceeding the adaptive threshold on a microservice. A Smart Alert fires based on seasonality-adjusted latency thresholds (not static values). The EDA rulebook matches on `event.payload.issue.text` containing "Slow" or "latency" and triggers the remediation job template on automation controller.

Remediation playbook — key tasks:

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
      text: "Service restarted by automation controller job {{ tower_job_id }} due to latency spike. Health check passed."
      severity: -1
      duration: 30000
```

Job template configuration in automation controller:

| Field | Value |
|-------|-------|
| **Name** | `Instana - Service Latency Remediation` |
| **Inventory** | `Application Servers` |
| **Project** | `Instana AIOps Playbooks` |
| **Playbook** | `remediate_service_latency.yml` |
| **Credentials** | Machine credential |
| **Extra variables** | `target_host` (prompt on launch), `service_name`, `service_port` |
| **Limit** | `{{ target_host }}` (dynamic from Event-Driven Ansible) |

---

**Use Case 2: Database Performance Degradation**

**Operational Impact:** Medium

Instana detects slow query execution times or connection pool exhaustion on a monitored MySQL database. The entity type in the alert matches database-related patterns. Automation controller runs a job template that clears the query cache and recycles connections.

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
      text: "Idle connections killed. Previous count: {{ db_connections.query_result[0][0].Value }}"
      severity: -1
      duration: 60000
```

---

**Use Case 3: Bad Deployment Auto-Rollback**

**Operational Impact:** High

Instana detects a spike in erroneous call rate correlated with a recent deployment Change event. Probable Root Cause identifies the deployment as the likely cause. Automation controller runs a job template that triggers a Kubernetes rollback.

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
      text: "Deployment rolled back due to error rate spike. {{ rollback_result.stdout }}"
      severity: -1
      duration: 120000
```

---

#### Part 5: Optional AI Inference Enhancement

For teams that want richer remediation recommendations beyond Instana's built-in Probable Root Cause — e.g., using an LLM to analyze the Incident context and recommend which remediation job template to run.

This is a **workflow job template** pattern in automation controller: Event-Driven Ansible triggers a workflow that first calls AI for analysis, then conditionally runs the appropriate remediation job template.

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
            You are an SRE assistant. Given an Instana Incident, recommend exactly ONE
            remediation action from this list: restart_service, recycle_db_connections,
            rollback_deployment, scale_out, do_nothing. Respond with only the action name.
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
- **Direct remediation** (no AI): Well-understood, recurring failures with a single correct response (e.g., service restart for thread pool exhaustion)
- **AI enrichment**: Novel failure modes, ambiguous root causes, or when the correct remediation depends on context that requires reasoning

---

### 8. Validation

**Per-stage validation checklist:**

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| Instana API token | Token has correct permissions | Settings > API Tokens shows token with alert channel config scope |
| Instana webhook alert channel | Channel is configured and reachable | **Test Channel** button in Instana returns success |
| Instana alert rule | Alert is bound to webhook alert channel | Settings > Alerts shows the channel under the rule |
| EDA rulebook activation | Rulebook activation running | Event-Driven Ansible controller shows activation status **Running** |
| Webhook delivery | Instana event reaches Event-Driven Ansible | Rulebook activation log shows received event JSON |
| Rulebook condition match | Correct rule fires for test event | Rulebook activation log shows matched rule name |
| Job template launch | Job template triggered by Event-Driven Ansible | Automation controller job history shows new job from EDA |
| Remediation | Service/DB/deployment recovers | Target system returns to healthy state |
| Instana annotation | Remediation event visible in Instana | Instana timeline shows Change event with AAP remediation details |

**Test command** — send a synthetic Instana-format event to Event-Driven Ansible:

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

**Expected result** (automation controller job output):

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

**Troubleshooting table:**

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Rulebook activation fails to start | `ibm.instana` collection not in decision environment | Build custom decision environment image with `ibm.instana` and `aiohttp>=3.8.4` installed |
| Webhook events received but no rule fires | Condition field paths don't match actual payload | Add a catch-all debug rule (shown in rulebook above) to log raw payload and verify field paths |
| EDA rule fires but job template fails to launch | Job template name mismatch or missing credential | Verify exact job template name and organization in automation controller; check EDA credential type is "Red Hat Ansible Automation Platform" |
| Instana Test Channel returns error | Event-Driven Ansible controller not reachable from Instana SaaS | Verify firewall rules allow inbound HTTPS from Instana SaaS IPs to EDA port |
| Remediation runs but Instana still shows Incident | Instana auto-closes Issues based on metric recovery, not playbook completion | Wait for Instana's next evaluation cycle (seconds to minutes); verify the root metric actually recovered |
| Annotation POST returns connection refused | Instana host agent not running on target host, or Host Agent REST API disabled | Verify agent is running: `systemctl status instana-agent` |
| Automation framework script fails | `${INSTANA_EVENT}` variable empty in test mode | Use the `if [ -z "${INSTANA_EVENT}" ]` guard pattern shown in Step 7 |
| Automation Action Ansible sensor can't reach automation controller | Ansible automation connector misconfigured or URL unreachable | Verify automation controller URL and API token in the Instana host agent configuration |

---

### 9. Maturity Path and Related Guides

**Crawl / Walk / Run:**

| Maturity | Description | What to Build |
|----------|-------------|---------------|
| **Crawl** | Instana alerts forwarded to Event-Driven Ansible, which enriches and routes notifications (Slack, email, ITSM ticket) — no remediation, human decides | Configure Instana webhook → EDA rulebook → `run_job_template` that sends a Slack notification with Incident context and Instana link |
| **Walk** | Event-Driven Ansible triggers automation controller job templates with human approval gate before execution | Add `ask_variables_on_launch: true` on job templates; use automation controller approval workflow nodes; operator reviews before remediation runs |
| **Run** | Fully automated closed-loop: Instana detects → Event-Driven Ansible triggers → automation controller remediates → Instana confirms resolution, no human in loop | Remove approval gates for well-understood failure patterns; add policy guardrails (e.g., max 3 auto-remediations per hour per service, business-hours-only for critical services) |

**Related Guides:**
- [AIOps automation with Ansible](README-AIOps.md) — tool-agnostic AIOps pattern (the generic foundation this guide builds on)
- [AI Infrastructure automation with Ansible](README-IA.md) — deploy the AI inference backend if using the optional LLM enrichment step
- [Get started with EDA](https://access.redhat.com/articles/7136720) — EDA fundamentals for teams new to Event-Driven Ansible

**ROI Recap:**
- Instana observability investment shifts from passive monitoring to active remediation engine
- MTTR drops from hours (manual triage) to minutes (automated response) — IBM claims up to 70% MTTR reduction
- Alert fatigue reduction: only truly novel or unresolvable Incidents escalate to humans
- Single-vendor advantage: IBM owns both Instana and Red Hat, enabling tighter integration roadmap

---

## Sources (for reference during implementation)

| Source | URL |
|--------|-----|
| IBM Docs — Webhook alert channel | https://www.ibm.com/docs/en/instana-observability/current?topic=alerting-webhooks |
| IBM Docs — Event types | https://www.ibm.com/docs/en/instana-observability/current?topic=references-event-types |
| IBM Docs — Smart Alerts | https://www.ibm.com/docs/en/instana-observability/current?topic=applications-smart-alerts |
| IBM Docs — Adaptive thresholds | https://www.ibm.com/docs/en/instana-observability/1.0.313?topic=instana-adaptive-thresholds-in-smart-alerts |
| IBM Docs — Host Agent REST API | https://www.ibm.com/docs/en/instana-observability/current?topic=apis-host-agent-rest-api |
| IBM Docs — Automation Action Ansible sensor | https://www.ibm.com/docs/en/instana-observability/current?topic=technologies-automation-action-ansible |
| IBM Docs — Managing actions (v1.0.312) | https://www.ibm.com/docs/en/instana-observability/1.0.312?topic=instana-managing-actions |
| IBM Docs — Probable Root Cause | https://www.ibm.com/new/announcements/introducing-probable-root-cause-enhancing-instanas-observability |
| IBM Developer — Automation-Powered AIOps | https://developer.ibm.com/articles/automation-powered-aiops/ |
| GitHub — ibm.instana EDA Collection | https://github.com/instana/ibm-instana-ansible |
| GitHub — Intelligent Remediation Playbooks | https://github.com/instana/intelligent-remediation-ansible |
| GitHub — Instana Ansible Callback Plugin | https://github.com/instana/instana-ansible |
| Red Hat automation hub — ibm.instana | https://catalog.redhat.com/en/software/collection/ibm/instana |
| Red Hat TV — EDA + Instana Demo | https://tv.redhat.com/en/detail/6365958260112/ |
| Red Hat — Event-Driven Ansible | https://www.redhat.com/en/technologies/management/ansible/event-driven-ansible |
| Red Hat Docs — AAP 2.5 components | https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.5/html/planning_your_installation/ref-aap-components |

---

## Implementation Steps

1. Create `README-Instana-AIOps.md` using the structure above
2. Write all 9 sections with full prose content (target 2,500-3,500 words)
3. Include 7+ YAML code blocks: credential type (input + injector), sensor config, EDA rulebook, 3 remediation playbooks, AI inference task
4. Include 2 workflow diagrams (ASCII) — one for each path
5. Add all required tables: persona (3-col), collections, external systems, alert channel config, job template config, rulebook activation config, validation checklist, troubleshooting
6. Update `README.md` to add a link to the new guide
7. Ensure all terminology matches the reference tables above
8. Ensure all EDA rulebook conditions use correct `event.payload.issue.*` accessors
9. Ensure Instana annotation POST uses the Host Agent REST API (`localhost:42699`)

## Verification After Implementation

- All 9 framework sections present
- YAML blocks: minimum 6, target 8+
- Tables: minimum 8
- Word count: 2,500-3,500
- Terminology audit: all terms match the reference tables (lowercase automation controller, lowercase job template, etc.)
- All `event.payload.issue.*` accessors match the documented Instana webhook payload
- Instana annotation API uses `http://localhost:42699/com.instana.plugin.generic.event`
- Automation framework documented as GA with auto-trigger via automation policies
- Severity values are integers (10, 5, -1), not strings
- No fabricated URLs or unverified API endpoints
- Score against quality rubric: target 9+/10
