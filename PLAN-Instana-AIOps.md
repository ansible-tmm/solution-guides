# Plan: Instana + AAP AIOps Solution Guide (v2 — Research-Corrected)

## Context

Create a new solution guide for **IBM Instana + Ansible Automation Platform (AAP)** as an AIOps solution. It must match the gold standard of `README-AIOps.md` and follow the 9-step framework in `README-best-practices.md`.

Two integration entry points:
- **Path A**: Instana Webhook Alert Channel → Event-Driven Ansible (EDA) → AAP Job Templates (production-ready, GA)
- **Path B**: Instana Action Framework → EDA via action sensor script → AAP Job Templates (Open Beta — manual trigger only as of Nov 2024)

Three use cases: Service latency spike recovery, Database performance degradation, Bad deployment auto-rollback.

AI layer: Instana's built-in Causal AI is primary, with an optional external LLM step.

---

## Research Corrections (from v1)

These are critical errors in the v1 plan that deep research uncovered:

### 1. Webhook Payload Structure Was Wrong

**v1 assumed** flat fields like `event.payload.title`, `event.payload.severity`, `event.payload.entityName`.

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

### 2. Custom Payload Template Placeholders Are UNVERIFIED

**v1 used** `${event.id}`, `${entity.label}`, etc. as custom payload template syntax.

**Actual**: IBM docs describe custom payloads via **tag-based key-value pairs** with `custom:` prefix, not `${event.xxx}` placeholders. The placeholder syntax was found only in third-party integration docs and may not be official. The guide should show the **default payload** and custom tag-based payloads, not assumed placeholders.

### 3. Severity Is Numeric, Not String

**v1 used** `event.payload.severity == "10"` (string comparison).

**Actual**: Severity is an integer: `-1` = Change/Info, `5` = Warning, `10` = Critical. Correct condition: `event.payload.issue.severity == 10`.

### 4. The `ibm.instana` Collection Has Its Own Source Plugin

**v1 used** `ansible.eda.webhook` as the source plugin.

**Actual**: The `ibm.instana` collection includes a dedicated `instana_webhook` source plugin. The official example from the GitHub repo uses:

```yaml
sources:
  - instana_webhook:
      host: 0.0.0.0
      port: 5000
```

**However**, the two paths produce different payload structures:
- **Via Instana Webhook Alert Channel** → uses default `issue` payload → access via `event.payload.issue.*`
- **Via Instana Action Framework** → uses `${INSTANA_EVENT}` variable → access via `event.payload.problem.problemText` etc.

The guide should document both payload formats explicitly.

### 5. Action Framework Is Still Open Beta (Manual Trigger Only)

**v1 presented** Path B as a production-ready alternative where Instana "directly executes AAP job templates."

**Actual**: The Action Framework is in **Open Beta** (announced Nov 2024). Currently supports **manual triggering only** — auto-trigger is a planned feature. The Ansible-specific action sensor (auto-import of job templates) is also in development.

The guide must clearly label Path B as "(Open Beta)" and note current limitations. Path A (webhook → EDA) should be positioned as the **production-ready** path.

### 6. Instana Annotations API Was Wrong

**v1 used** `POST {{ instana_base_url }}/api/v1/events` with `apiToken` header.

**Actual**: There are two correct approaches:
- **Local agent SDK** (recommended): `POST http://localhost:42699/com.instana.plugin.generic.event` — no auth needed, agent-local endpoint
- **Backend API** for deployment markers: `POST /api/releases` with `authorization: apiToken <token>` header

The agent SDK approach is simpler and doesn't require network access to the Instana backend.

### 7. Smart Alerts Are the Recommended Approach

**v1 didn't distinguish** between Smart Alerts, Built-in Events, and Custom Events.

**Actual**: Built-in events and custom events for app/service/endpoint entities are **deprecated** in favor of Smart Alerts. The guide should recommend Smart Alerts as the alerting mechanism.

### 8. Instana's Unique Positioning

**v1 didn't cover** competitive positioning.

**Key differentiator**: IBM owns both Instana and Red Hat (Ansible). This means:
- Same corporate family → tighter roadmap alignment
- `ibm.instana` collection available on both Galaxy and Red Hat Automation Hub
- Instana's Intelligent Remediation uses watsonx to generate Ansible playbooks (see `instana/intelligent-remediation-ansible` GitHub repo)
- Instana monitors Ansible natively (via callback plugin in `instana/instana-ansible`)

Dynatrace actually has a **more mature** EDA integration (certified collection, bidirectional workflows). The guide should position Instana's strengths honestly without overpromising on beta features.

### 9. Key GitHub Repos to Reference

| Repository | Purpose |
|-----------|---------|
| [instana/ibm-instana-ansible](https://github.com/instana/ibm-instana-ansible) | EDA collection with `instana_webhook` source plugin |
| [instana/intelligent-remediation-ansible](https://github.com/instana/intelligent-remediation-ansible) | WatsonX-generated remediation playbooks for Instana events |
| [instana/instana-ansible](https://github.com/instana/instana-ansible) | Callback plugin to send playbook events TO Instana |

### 10. Instana Webhook Compatibility Warning

IBM docs explicitly state: "The Instana Webhook format is not compatible with third-party tools expecting Incoming Webhooks in their format." This means custom adapters or EDA rulebook parsing is necessary — which is exactly what the guide demonstrates.

---

## Critical Files

- **Gold standard to match**: `README-AIOps.md`
- **Framework to follow**: `README-best-practices.md`
- **Output file**: `README-Instana-AIOps.md` (new)
- **Main index**: `README.md` (update with link)

---

## Guide Structure (9-Step Framework)

### File: `README-Instana-AIOps.md`

---

### 1. Title

`Automated Incident Remediation with IBM Instana and Ansible Automation Platform - Solution Guide`

---

### 2. Overview

**Problem statement**: IBM Instana monitors 300+ technologies with 1-second granularity and uses Causal AI to identify root causes automatically. Yet most organizations still route Instana alerts to human on-call engineers for manual triage and remediation — creating alert fatigue, inconsistent responses, and MTTR measured in hours. This guide demonstrates how to close the loop: Instana detects and diagnoses, Ansible Automation Platform remediates, fully automated and governed.

Include:
- Hero image (placeholder or reference to a custom Instana+AAP architecture diagram)
- Linked table of contents

---

### 3. Background

What makes Instana different from other observability tools:
- **Zero-config auto-discovery** of 300+ technologies (vs. manual agent configuration)
- **1-second data granularity** with no sampling on distributed traces (vs. typical 1-minute polling or sampled traces)
- **Causal AI** for root cause analysis — understands dependency topology and uses differential observability, not just threshold breaches
- **Smart Alerts** with dynamic baselines — learns daily/weekly seasonality patterns automatically
- **Three event types**: Changes (deployments, config), Issues (health signature breaches), Incidents (correlated groups of issues affecting service KPIs)

Why Instana + AAP (positioning the IBM family angle):
- IBM owns both Instana and Red Hat — tighter roadmap alignment than third-party integrations
- `ibm.instana` collection available on Red Hat Automation Hub (certified) and Ansible Galaxy
- Instana's Intelligent Remediation roadmap includes watsonx-generated Ansible playbooks
- Instana already monitors Ansible natively via a callback plugin — creating a bidirectional feedback loop

---

### 4. Solution

**Components:**
- **IBM Instana** — Auto-discovery, Smart Alerts, Causal AI root cause analysis
- **Event-Driven Ansible (EDA)** — Webhook listener, event parsing, rulebook logic
- **Instana Action Framework** (Open Beta) — In-product action catalog with AI-powered recommendations
- **Ansible Automation Platform (AAP)** — Governed job template execution, audit trail, RBAC
- **`ibm.instana` Ansible Collection** — Dedicated `instana_webhook` EDA source plugin
- **AI Inference Endpoint** (optional) — Red Hat AI or OpenAI-compatible API for enriched recommendations

**Persona table:**

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| IT Ops Engineer / SRE | Alert fatigue: Instana fires hundreds of alerts daily, each requiring manual investigation and response | Automated first-response: high-signal Instana incidents trigger targeted, tested remediation without manual triage |
| Automation Architect | Connecting Instana's event model to AAP requires understanding webhook payloads, EDA rulebook syntax, and credential flows | Two documented integration patterns (EDA webhook + Action Framework) with verified YAML, correct payload accessors, and credential types |
| IT Manager / Director | MTTR measured in hours; difficult to show ROI on observability investment when it only produces dashboards | Instana investment becomes an active remediation trigger; MTTR drops to minutes; only unresolvable incidents escalate to humans |

**Demos/Labs**: Placeholder links
- [Red Hat TV: From Observability to Action with EDA and IBM Instana](https://tv.redhat.com/en/detail/6365958260112/from-observability-to-action-with-event-driven-ansible-and-ibm-instana)
- [IBM Developer: Automation-Powered AIOps using Instana and Red Hat Ansible](https://developer.ibm.com/articles/automation-powered-aiops/)

---

### 5. Prerequisites

**AAP Version:** 2.5+ (EDA Controller GA, `ansible.eda` collection included)

**Featured Ansible Content Collections:**

| Collection | Source | Purpose |
|-----------|--------|---------|
| [`ibm.instana`](https://catalog.redhat.com/en/software/collection/ibm/instana) | Red Hat Automation Hub / Ansible Galaxy | Dedicated `instana_webhook` EDA source plugin |
| [`ansible.eda`](https://console.redhat.com/ansible/automation-hub/repo/published/ansible/eda/) | Certified (bundled with EDA Controller) | Fallback webhook source, event filters |
| [`community.mysql`](https://galaxy.ansible.com/ui/repo/published/community/mysql/) | Community | Database remediation tasks (Use Case 2) |
| [`kubernetes.core`](https://console.redhat.com/ansible/automation-hub/repo/published/kubernetes/core/) | Certified | Kubernetes rollback tasks (Use Case 3) |

**External Systems:**

| System | Required | Notes |
|--------|----------|-------|
| IBM Instana (SaaS or on-prem) | Yes | API token with "Configuration of alert channels" permission |
| Red Hat AAP Controller | Yes | Job template execute permissions for EDA service account |
| EDA Controller | Yes (Path A) | Reachable from Instana SaaS for webhook delivery |
| AI inference endpoint | Optional | For LLM enrichment step only |

**Requirements:**
- Python >= 3.9
- Ansible Core >= 2.15.0
- aiohttp >= 3.8.4 (for `ibm.instana` collection)

**Operational Impact:** Medium — remediation playbooks modify production services. Test in non-prod first. Per-step impact ratings provided in the walkthrough.

---

### 6. Workflow and Architecture

**Path A: EDA Webhook Path (Production-Ready)**
```
Instana Smart Alert fires
  → Instana Webhook Alert Channel sends HTTP POST to EDA
  → EDA receives event via instana_webhook source (or ansible.eda.webhook)
  → EDA rulebook condition matches on event.payload.issue.severity, .text, .type
  → EDA triggers AAP Job Template via run_job_template action
  → AAP executes remediation playbook on target host(s)
  → Playbook posts annotation back to Instana via agent SDK
  → Instana timeline shows remediation event alongside incident
```

**Path B: Action Framework Path (Open Beta)**
```
Instana detects anomaly and creates incident
  → Operator views incident in Instana UI
  → Instana AI recommends an action from the action catalog (confidence score)
  → Operator triggers action manually (auto-trigger planned)
  → Action sensor executes bash script that POSTs to EDA webhook
  → EDA processes ${INSTANA_EVENT} payload and triggers AAP
  → AAP executes remediation
  → Action output displayed in Instana incident timeline
```

**When to use which path:**

| Consideration | Path A: EDA Webhook | Path B: Action Framework |
|--------------|---------------------|--------------------------|
| Maturity | GA (production-ready) | Open Beta (manual trigger only) |
| Trigger type | Automatic (event-driven) | Manual (operator initiates) |
| Automation governance | EDA rulebook conditions + AAP RBAC | Instana action catalog + AAP RBAC |
| AI enrichment | Easy (inline in workflow before job launch) | Built-in (Instana AI recommends actions) |
| Rule complexity | Multi-condition logic, pattern matching | 1 event → 1 action mapping |
| Payload format | `event.payload.issue.*` (default webhook) | `event.payload.problem.*` (INSTANA_EVENT) |
| Best for | Fully automated closed-loop remediation | Operator-assisted remediation with AI guidance |

---

### 7. Solution Walkthrough

#### Part 1: Shared Setup

**Step 1: Create an Instana API Token**
- Navigate to Settings > Team Settings > API Tokens
- Required permission: "Configuration of alert channels"
- For posting remediation annotations: "Configuration of releases" (optional)

**Step 2: Create AAP Custom Credential Type for Instana**

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

**Step 3: Configure Instana Webhook Alert Channel**

Navigate to **Settings > Events & Alerts > Alert Channels > Add Alert Channel > Generic Webhook**

| Field | Value |
|-------|-------|
| **Name** | `EDA Webhook - Remediation` |
| **Webhook URL** | `https://eda.example.com:5000/instana` |
| **Custom HTTP Headers** | (optional: `X-EDA-Token: <bearer-token>` for auth) |

> **Note**: Instana states "The Instana Webhook format is not compatible with third-party tools expecting Incoming Webhooks in their format." This is expected — the EDA rulebook handles parsing.

Use the **Test Channel** button to verify delivery.

**Step 3b: Create an Alert Configuration**
1. Navigate to **Settings > Events & Alerts > Alerts > New Alert**
2. Select **Alert on Event(s)**
3. Add events by filtering on Entity Type (e.g., Application, Service, Host)
4. Under **Alerting**, attach the `EDA Webhook - Remediation` channel
5. Set scope to the appropriate Application Perspective or infrastructure zone

**Default payload sent by Instana** (this is what EDA receives):

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

**Step 4: Create EDA Rulebook**

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

**EDA Rulebook Activation config table:**

| Field | Value |
|-------|-------|
| **Name** | `Instana Incident Remediation` |
| **Project** | `Instana AIOps` (Git repo with rulebooks) |
| **Rulebook** | `instana_remediation.yml` |
| **Decision Environment** | Custom DE with `ibm.instana` collection installed |
| **Credential** | AAP Controller credential (for `run_job_template`) |
| **Restart Policy** | `Always` |

---

#### Part 3: Path B — Instana Action Framework (Open Beta)

> **Note**: The Action Framework is in Open Beta (announced November 2024). Currently only **manual triggering** is supported. Auto-trigger is a planned feature.

**Step 5: Create an Action in Instana**

1. Navigate to **Automation > Action Catalog > Create Action**
2. Select action type: **Script**
3. Configure the script to POST event data to the EDA webhook:

```bash
#!/bin/bash
# Instana Action: Forward event to Event-Driven Ansible
if [ -z "${INSTANA_EVENT}" ]; then
  # Test mode - send sample event
  curl -s -H 'Content-Type: application/json' \
    -d '{"message": "Test event from Instana Action Framework"}' \
    @@eda_server@@/instana
else
  # Production - forward actual event
  curl -s -H 'Content-Type: application/json' \
    -d "${INSTANA_EVENT}" \
    @@eda_server@@/instana
fi
```

4. Add parameter `eda_server` with value `https://eda.example.com:5000`
5. Associate the action with relevant event types
6. Instana shows a **Confidence score** for each action-event association based on text-similarity matching

**Step 6: Associate Action with Alert Policies**

- Select alert rules in **Settings > Events & Alerts > Alerts**
- Attach the action to trigger when matching events occur
- Currently: operator manually clicks "Run Action" from the incident view
- Future: auto-trigger will execute the action automatically

---

#### Part 4: Use Case Walkthroughs

**Use Case 1: Service Latency Spike Recovery**

**Operational Impact:** Medium

Instana detects response time exceeding the dynamic baseline on a microservice. Smart Alerts fire based on seasonality-adjusted latency thresholds (not static values). The EDA rulebook matches on `event.payload.issue.text` containing "Slow" or "latency" and triggers the remediation job template.

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

- name: Post remediation annotation to Instana agent
  ansible.builtin.uri:
    url: "http://localhost:42699/com.instana.plugin.generic.event"
    method: POST
    body_format: json
    body:
      title: "AAP Remediation: {{ service_name }} restarted"
      text: "Service restarted by AAP job {{ tower_job_id }} due to latency spike. Health check passed."
      severity: -1
      duration: 30000
```

Job Template configuration:

| Field | Value |
|-------|-------|
| **Name** | `Instana - Service Latency Remediation` |
| **Inventory** | `Application Servers` |
| **Project** | `Instana AIOps Playbooks` |
| **Playbook** | `remediate_service_latency.yml` |
| **Credentials** | `Machine Credential`, `Instana API Token` |
| **Extra Variables** | `target_host` (prompt on launch), `service_name`, `service_port` |
| **Limit** | `{{ target_host }}` (dynamic from EDA) |

---

**Use Case 2: Database Performance Degradation**

**Operational Impact:** Medium

Instana detects slow query execution times or connection pool exhaustion on a monitored MySQL database. The entity type in the alert matches database-related patterns. AAP clears the query cache and recycles connections.

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

- name: Post remediation annotation to Instana agent
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

Instana detects a spike in erroneous call rate correlated with a recent deployment change event. Causal AI identifies the deployment as the probable root cause. AAP triggers a Kubernetes rollback.

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

- name: Post rollback annotation to Instana agent
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

For teams that want richer remediation recommendations beyond Instana's built-in Causal AI — e.g., using an LLM to analyze the incident context and recommend which remediation playbook to run.

This is a **workflow job template** pattern: EDA triggers a workflow that first calls AI for analysis, then conditionally runs the appropriate remediation job template.

```yaml
- name: Enrich incident with AI analysis
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
            You are an SRE assistant. Given an Instana incident, recommend exactly ONE
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
| Instana webhook channel | Channel is configured and reachable | **Test Channel** button in Instana returns success |
| Instana alert rule | Alert is bound to webhook channel | Settings > Alerts shows the channel under the rule |
| EDA activation | Rulebook activation running | EDA Controller shows activation status **Running** |
| Webhook delivery | Instana event reaches EDA | EDA activation log shows received event JSON |
| Rulebook condition match | Correct rule fires for test event | EDA activation log shows matched rule name |
| AAP job launch | Job template triggered by EDA | AAP Job History shows new job from EDA |
| Remediation | Service/DB/deployment recovers | Target system returns to healthy state |
| Instana annotation | Remediation event visible in Instana | Instana timeline shows change event with AAP remediation details |

**Test command** — send a synthetic Instana-format event to EDA:

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

**Expected result** (AAP job output):

```
PLAY [Remediate service latency] ************************************************

TASK [Gather service state before restart] **************************************
ok: [app-server-01.example.com]

TASK [Restart service to clear thread pool exhaustion] **************************
changed: [app-server-01.example.com]

TASK [Wait for service health check to pass] ************************************
ok: [app-server-01.example.com]

TASK [Post remediation annotation to Instana agent] *****************************
ok: [app-server-01.example.com]

PLAY RECAP *********************************************************************
app-server-01.example.com : ok=4    changed=1    unreachable=0    failed=0
```

**Troubleshooting table:**

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| EDA activation fails to start | `ibm.instana` collection not in Decision Environment | Build custom DE image with `ibm.instana` and `aiohttp>=3.8.4` installed |
| Webhook events received but no rule fires | Condition field paths don't match actual payload | Add a catch-all debug rule (shown in rulebook above) to log raw payload and verify field paths |
| EDA rule fires but AAP job fails to launch | Job template name mismatch or missing EDA → Controller credential | Verify exact template name and organization; check EDA credential type is "Red Hat Ansible Automation Platform" |
| Instana Test Channel returns error | EDA host not reachable from Instana SaaS | Verify firewall rules allow inbound HTTPS from Instana SaaS IPs to EDA port |
| Remediation playbook runs but Instana still shows incident | Instana event auto-closes based on metric recovery, not playbook completion | Wait for Instana's next evaluation cycle (seconds to minutes); verify the root metric actually recovered |
| Annotation POST returns connection refused | Instana agent not running on target host, or agent REST API disabled | Verify agent is running: `systemctl status instana-agent`; check agent config for `com.instana.plugin.generic.event` |
| Action Framework script fails | `${INSTANA_EVENT}` variable empty in test mode | Use the `if [ -z "${INSTANA_EVENT}" ]` guard pattern shown in Step 5 |

---

### 9. Maturity Path and Related Guides

**Crawl / Walk / Run:**

| Maturity | Description | What to Build |
|----------|-------------|---------------|
| **Crawl** | Instana alerts forwarded to EDA, which enriches and routes notifications (Slack, email, ITSM ticket) — no remediation, human decides | Configure Instana webhook → EDA → `run_job_template` that sends a Slack notification with incident context and Instana link |
| **Walk** | EDA triggers AAP job templates with human approval gate before execution | Add `ask_variables_on_launch: true` on job templates; use AAP approval workflow nodes; operator reviews before remediation runs |
| **Run** | Fully automated closed-loop: Instana detects → EDA triggers → AAP remediates → Instana confirms resolution, no human in loop | Remove approval gates for well-understood failure patterns; add policy guardrails (e.g., max 3 auto-remediations per hour per service, business-hours-only for critical services) |

**Related Guides:**
- [AIOps automation with Ansible](README-AIOps.md) — tool-agnostic AIOps pattern (the generic foundation this guide builds on)
- [AI Infrastructure automation with Ansible](README-IA.md) — deploy the AI inference backend if using the optional LLM enrichment step
- [Get started with EDA](https://access.redhat.com/articles/7136720) — EDA fundamentals for teams new to event-driven automation

**ROI Recap:**
- Instana observability investment shifts from passive monitoring to active remediation engine
- MTTR drops from hours (manual triage) to minutes (automated response) — IBM claims up to 70% MTTR reduction
- Alert fatigue reduction: only truly novel or unresolvable incidents escalate to humans
- Single-vendor advantage: IBM owns both Instana and Red Hat, enabling tighter integration roadmap

---

## Sources (for reference during implementation)

| Source | URL |
|--------|-----|
| IBM Docs — Webhook Alert Channel | https://www.ibm.com/docs/en/instana-observability/current?topic=alerting-webhooks |
| IBM Docs — Custom Payloads | https://www.ibm.com/docs/en/instana-observability/current?topic=alerts-configuring-custom-payloads |
| IBM Docs — Event Types | https://www.ibm.com/docs/en/instana-observability/current?topic=references-event-types |
| IBM Docs — Smart Alerts | https://www.ibm.com/docs/en/instana-observability/current?topic=applications-smart-alerts |
| IBM Docs — Host Agent REST API | https://www.ibm.com/docs/en/instana-observability/current?topic=apis-host-agent-rest-api |
| IBM Blog — Action Framework Open Beta | https://www.ibm.com/blog/announcement/open-beta-instana-action-framework/ |
| IBM Developer — Automation-Powered AIOps | https://developer.ibm.com/articles/automation-powered-aiops/ |
| GitHub — ibm.instana EDA Collection | https://github.com/instana/ibm-instana-ansible |
| GitHub — Intelligent Remediation Playbooks | https://github.com/instana/intelligent-remediation-ansible |
| GitHub — Instana Ansible Callback Plugin | https://github.com/instana/instana-ansible |
| Red Hat Automation Hub — ibm.instana | https://catalog.redhat.com/en/software/collection/ibm/instana |
| Red Hat TV — EDA + Instana Demo | https://tv.redhat.com/en/detail/6365958260112/ |
| AlertOps — Instana Webhook Payload Reference | https://docs.alertops.com/docs/instana |
| Callgoose — Instana Integration Reference | https://docs.callgoose.com/sqibs-integration/ibm_instana |
| IBM — Instana Supported Technologies | https://www.ibm.com/products/instana/supported-technologies |

---

## Implementation Steps

1. Create `README-Instana-AIOps.md` using the structure above
2. Write all 9 sections with full prose content (target 2,500-3,500 words)
3. Include 7+ YAML code blocks: credential type (input + injector), EDA rulebook, 3 remediation playbooks, AI inference task, Instana action script
4. Include 2 workflow diagrams (ASCII) — one for each path
5. Add all required tables: persona (3-col), collections, external systems, alert channel config, job template config, validation checklist, troubleshooting
6. Update `README.md` to add a link to the new guide
7. Ensure all EDA rulebook conditions use correct `event.payload.issue.*` accessors
8. Ensure Instana annotation POST uses the local agent SDK endpoint (port 42699), not a fabricated API endpoint

## Verification After Implementation

- All 9 framework sections present
- YAML blocks: minimum 6, target 8+
- Tables: minimum 7
- Word count: 2,500-3,500
- All `event.payload.issue.*` accessors match the documented Instana webhook payload
- Instana annotation API uses `http://localhost:42699/com.instana.plugin.generic.event`
- Action Framework clearly labeled as "(Open Beta)"
- Severity values are integers (10, 5, -1), not strings
- No fabricated URLs or unverified API endpoints
- Score against quality rubric: target 9+/10
