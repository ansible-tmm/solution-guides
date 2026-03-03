# Plan: Instana + AAP AIOps Solution Guide

## Context

The user wants to create a new solution guide for **IBM Instana + Ansible Automation Platform (AAP)** as an AIOps solution. It must match the gold standard of the existing `README-AIOps.md` guide in this repo and follow the 9-step framework in `README-best-practices.md`.

The guide covers two integration entry points:
- **Path A**: Instana → Webhook → Event-Driven Ansible (EDA) → AAP Job Templates
- **Path B**: Instana Action Framework → AAP Job Templates (direct, native integration)

Three use cases: Service latency spike recovery, Database performance degradation, Bad deployment auto-rollback.

AI layer: Instana's built-in Causal AI is primary, with an optional external LLM step (same pattern as the generic AIOps guide).

A reference GitHub repo will be created/linked for the sample code.

---

## Critical Files

- **Gold standard to match**: `README-AIOps.md` (the existing generic AIOps guide, 854 lines)
- **Framework to follow**: `README-best-practices.md` (9-step structure, quality rubric)
- **Output file**: `README-Instana-AIOps.md` (new file to create)
- **Main index**: `README.md` (to be updated with a link to the new guide)

---

## Guide Structure (9-Step Framework)

### File: `README-Instana-AIOps.md`

---

### 1. Title

**Working title**: `Automated Incident Remediation with IBM Instana and Ansible Automation Platform - Solution Guide`

The Overview subtitle should anchor the pain: organizations already running Instana have rich observability data but still rely on manual triage and response when alerts fire.

---

### 2. Overview

**Problem statement** (2-4 sentences):
- IBM Instana detects thousands of infrastructure and application anomalies per day with millisecond precision, but most organizations still route these alerts to human on-call engineers for manual triage and remediation.
- This creates alert fatigue, inconsistent responses, and MTTR measured in hours instead of minutes.
- This guide shows how to close the loop: from Instana detecting an incident to AAP executing the remediation, fully automated and governed.

Include:
- Hero image (reference existing AIOps image or note placeholder)
- Linked table of contents

---

### 3. Background (1-3 paragraphs)

What Instana is and what makes it different:
- 300+ auto-discovered technology integrations (no manual agent config)
- 1-second data granularity (vs. typical 1-minute polling)
- Built-in Causal AI: not threshold-based, but dynamic baseline + root cause analysis (~90% accuracy in fault localization)
- Monitors the full stack: infrastructure, databases, microservices, Kubernetes/OpenShift, messaging systems

Why Instana + AAP is a natural pairing:
- Instana is best at *detecting* — with causal AI that understands why something went wrong, not just that it's wrong
- AAP is best at *fixing* — with governed, auditable, idempotent automation across any infrastructure
- Together they form the full Observe → Infer → Execute loop

Brief explanation of the two integration paths (framed as options, not requiring a choice upfront).

---

### 4. Solution

**Components:**
- **IBM Instana** — Observability, auto-discovery, dynamic baselining, Causal AI for root cause analysis
- **Event-Driven Ansible (EDA)** — Webhook listener, event parsing, rulebook logic (Path A)
- **Instana Action Framework** — Native AAP integration for direct job template execution from Instana (Path B)
- **Ansible Automation Platform (AAP)** — Governed job template execution, audit trail, RBAC
- **AI Inference Endpoint** (optional) — Red Hat AI or any OpenAI-compatible API for enriched remediation recommendations
- **`ibm.instana` Ansible Collection** — EDA event source plugin for Instana webhooks

**Persona table** (3 columns: Persona, Challenge, What They Gain):

| Persona | Challenge | What They Gain |
|---------|-----------|---------------|
| IT Ops Engineer / SRE | Alert fatigue: Instana fires hundreds of alerts, each requiring manual investigation | Automated first-response: high-signal Instana incidents trigger targeted remediation without manual triage |
| Automation Architect | Connecting Instana's event model to AAP requires custom integration code | Two documented, production-ready integration patterns (EDA and Action Framework) with sample YAML |
| IT Manager / Director | MTTR is measured in hours due to human-in-the-loop triage; difficult to show ROI of observability spend | Demonstrable reduction in MTTR; Instana's observability investment becomes an active remediation trigger, not just a monitoring dashboard |

**Demos/Labs**: placeholder for links (note to add Instruqt/YouTube links when available)

---

### 5. Prerequisites

**AAP Version:** 2.4+ (EDA Controller GA, required for Path A)

**Featured Ansible Content Collections:**

| Collection | Type | Purpose |
|-----------|------|---------|
| `ibm.instana` | Community (GitHub: instana/ibm-instana-ansible) | EDA event source plugin for Instana webhook events |
| `ansible.eda` | Certified | EDA rulebook event sources and filters |
| `redhat.ai` (optional) | Certified | AI inference endpoint calls for enriched remediation |

**External Systems:**

| System | Required | Notes |
|--------|----------|-------|
| IBM Instana (SaaS or on-prem) | Yes | API token with alert management scope |
| Red Hat AAP Controller | Yes | API access for Action Framework (Path B) |
| AI inference endpoint | Optional | For LLM enrichment step only |

**Operational Impact:** Medium (remediating services is a production-impacting operation; test in non-prod first)

**Instana-specific setup:**
- Instana API token scopes needed (alert channels, webhooks, action framework)
- Network connectivity: EDA host must be reachable from Instana SaaS (for webhook delivery)
- AAP API URL must be reachable from Instana (for Action Framework path)

---

### 6. Workflow and Architecture

**Two integration patterns** — include a side-by-side comparison:

**Path A: Event-Driven Ansible Path**
```
Instana Detects Anomaly
    → Instana Smart Alert fires
    → Instana Webhook → EDA Rulebook Activation
    → EDA parses event, matches rule
    → EDA triggers AAP Job Template
    → AAP executes remediation playbook
    → (Optional) LLM enrichment before remediation
    → Instana confirms resolution (metric returns to baseline)
```

**Path B: Instana Action Framework Path**
```
Instana Detects Anomaly
    → Instana Causal AI identifies root cause
    → Instana suggests Action (AI-recommended or manual)
    → Action Framework calls AAP API directly
    → AAP executes job template
    → Status reported back to Instana incident timeline
```

**When to use which path (table):**

| Consideration | Path A: EDA | Path B: Action Framework |
|--------------|-------------|--------------------------|
| Response latency | Seconds (event-driven) | Seconds (API-driven) |
| Automation governance | AAP + EDA rulebook | AAP (Action Framework bypasses EDA) |
| AI enrichment option | Easy (inline in rulebook) | Requires custom webhook step |
| Rule complexity | Supports complex multi-condition logic | Simple: 1 alert → 1 action mapping |
| Instana version | Any (webhooks are standard) | Requires Action Framework (check version) |
| Best for | Complex orchestration, multi-step workflows | Quick actions, tightly Instana-integrated workflows |

**Narrative walkthrough:** 5-8 sentences covering both paths end-to-end.

---

### 7. Solution Walkthrough

#### Part 1: Shared Setup

**Step 1: Create an Instana API Token**
- Required scopes: Alert channels, Webhook configuration
- Credential storage in AAP (custom credential type for Instana API token)

**Step 2: Create AAP Custom Credential Type for Instana**
- YAML for custom credential type definition (injectors pattern)

```yaml
# Custom credential type input schema
fields:
  - id: instana_api_token
    type: string
    label: Instana API Token
    secret: true
  - id: instana_base_url
    type: string
    label: Instana Base URL
injectors:
  extra_vars:
    instana_api_token: "{{ instana_api_token }}"
    instana_base_url: "{{ instana_base_url }}"
```

---

#### Part 2: Path A — Event-Driven Ansible Integration

**Step 3: Configure Instana Webhook Alert Channel**
- Show Instana UI steps (with table of field values)
- Webhook payload format Instana sends

```json
{
  "id": "{{ event.id }}",
  "title": "{{ event.title }}",
  "type": "{{ event.type }}",
  "severity": "{{ event.severity }}",
  "entityName": "{{ entity.label }}",
  "entityType": "{{ entity.type }}",
  "state": "{{ event.state }}",
  "startTime": "{{ event.startTime }}",
  "link": "{{ event.consoleLink }}"
}
```

**Step 4: Create EDA Rulebook Activation**

Show a generic rulebook that handles all three use cases via conditions:

```yaml
---
- name: Instana Event Processing
  hosts: all
  sources:
    - ansible.eda.webhook:
        host: 0.0.0.0
        port: 5000

  rules:
    - name: Service Latency Spike — restart service
      condition: >
        event.payload.title contains "Slow response time" and
        event.payload.severity == "10"
      action:
        run_job_template:
          name: "Instana | Service Latency Remediation"
          organization: "Default"
          job_args:
            extra_vars:
              entity_name: "{{ event.payload.entityName }}"
              instana_link: "{{ event.payload.link }}"

    - name: Database Performance Degradation — remediate
      condition: >
        event.payload.title contains "database" and
        event.payload.severity == "10"
      action:
        run_job_template:
          name: "Instana | Database Performance Remediation"
          organization: "Default"
          job_args:
            extra_vars:
              entity_name: "{{ event.payload.entityName }}"

    - name: Deployment Correlated with Errors — rollback
      condition: >
        event.payload.type == "DEPLOYMENT_CHANGE" and
        event.payload.title contains "error rate"
      action:
        run_job_template:
          name: "Instana | Deployment Rollback"
          organization: "Default"
          job_args:
            extra_vars:
              entity_name: "{{ event.payload.entityName }}"
```

**EDA Rulebook Activation configuration table** (Name, Project, Rulebook, Decision Env, etc.)

---

#### Part 3: Path B — Instana Action Framework

**Step 5: Connect Instana Action Framework to AAP**
- Instana UI steps to configure AAP as an action provider
- Required AAP API credentials in Instana

**Step 6: Import and Map AAP Job Templates in Instana**
- How Instana syncs job templates from AAP
- Associating job templates with alert policies in Instana
- Screenshot description of the Action Framework UI

---

#### Part 4: Use Case Walkthroughs

**Use Case 1: Service Latency Spike Recovery**

Context: Instana detects response time exceeding dynamic baseline across a microservice. Causal AI identifies the root cause (e.g., thread pool exhaustion). AAP restarts the affected service.

EDA trigger condition (already in rulebook above).

Remediation playbook key tasks:

```yaml
- name: Gather service state before restart
  ansible.builtin.systemd:
    name: "{{ service_name }}"
  register: service_state

- name: Restart service to recover from thread pool exhaustion
  ansible.builtin.systemd:
    name: "{{ service_name }}"
    state: restarted
  when: service_state.status.ActiveState == "active"

- name: Wait for service health check
  ansible.builtin.uri:
    url: "http://{{ inventory_hostname }}:{{ service_port }}/health"
    status_code: 200
  retries: 10
  delay: 6
```

AAP Job Template config table (Name, Inventory, Project, Playbook, Credentials, Survey fields)

---

**Use Case 2: Database Performance Degradation**

Context: Instana detects slow query execution times (exceeding baseline) or connection pool exhaustion on a monitored database. AAP clears caches and recycles the connection pool.

```yaml
- name: Check database connection count
  community.mysql.mysql_query:
    login_host: "{{ db_host }}"
    query: "SHOW STATUS WHERE variable_name = 'Threads_connected'"
  register: db_connections

- name: Clear query cache if supported
  community.mysql.mysql_query:
    login_host: "{{ db_host }}"
    query: "RESET QUERY CACHE"
  when: db_connections.query_result[0][0].Value | int > connection_threshold

- name: Notify via Instana API that remediation applied
  ansible.builtin.uri:
    url: "{{ instana_base_url }}/api/v1/events"
    method: POST
    headers:
      Authorization: "apiToken {{ instana_api_token }}"
    body_format: json
    body:
      title: "AAP Remediation: Database cache cleared"
      text: "Connection pool recycled on {{ inventory_hostname }}"
      type: "ANNOTATION"
```

---

**Use Case 3: Bad Deployment Auto-Rollback**

Context: Instana detects a spike in error rates or latency correlated with a recent deployment (change event). Causal AI identifies the deployment as probable root cause. AAP triggers rollback.

```yaml
- name: Identify current deployment version
  kubernetes.core.k8s_info:
    kind: Deployment
    name: "{{ app_name }}"
    namespace: "{{ app_namespace }}"
  register: current_deploy

- name: Roll back to previous version
  kubernetes.core.k8s:
    kind: Deployment
    name: "{{ app_name }}"
    namespace: "{{ app_namespace }}"
    definition:
      spec:
        template:
          spec:
            containers:
              - name: "{{ app_name }}"
                image: "{{ rollback_image }}"

- name: Wait for rollout to complete
  kubernetes.core.k8s_info:
    kind: Deployment
    name: "{{ app_name }}"
    namespace: "{{ app_namespace }}"
    wait: true
    wait_condition:
      type: Progressing
      status: "True"
```

---

#### Part 5: Optional AI Inference Enhancement

For teams that want richer remediation recommendations beyond Instana's built-in Causal AI — e.g., using an LLM to analyze logs or generate a runbook summary.

Insert between EDA trigger and AAP job template execution:

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
          content: "You are an SRE. Analyze this Instana incident and recommend the specific remediation action."
        - role: user
          content: |
            Incident: {{ event.payload.title }}
            Entity: {{ event.payload.entityName }}
            Severity: {{ event.payload.severity }}
            Instana Root Cause: {{ event.payload.description }}
            Recommend ONE specific remediation action.
  register: ai_response
```

Explain when to use this (novel/unknown failure modes) vs. when Instana's built-in Causal AI is sufficient (well-understood, recurring failures).

---

### 8. Validation

**Per-stage validation checklist** (table format):

| Stage | What to Verify | Success Indicator |
|-------|---------------|-------------------|
| Instana webhook | Alert channel is active | Instana shows channel as "Active" in alert settings |
| EDA activation | Rulebook activation running | EDA Controller shows activation **Running** |
| EDA → AAP connection | Credentials valid | EDA activation log shows no auth errors |
| Test event | Webhook delivers to EDA | EDA activation log shows received event |
| Job template | AAP triggered successfully | AAP job history shows new job for the template |
| Remediation | Service/DB/deployment recovered | Instana metric returns to baseline (green) |

**Test command** — send a synthetic Instana-format event to EDA:

```bash
curl -X POST http://eda.example.com:5000 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Slow response time detected",
    "severity": "10",
    "entityName": "checkout-service",
    "entityType": "APPLICATION",
    "state": "OPEN",
    "type": "SLOWDOWN"
  }'
```

**Expected result** (AAP job output):

```
PLAY RECAP *********************************************************************
app-server-01  : ok=4    changed=1    unreachable=0    failed=0
```

**Troubleshooting table:**

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| EDA rulebook activation fails to start | Missing `ibm.instana` collection in decision environment | Add collection to custom EE image |
| Webhook events received but no rule fires | Condition field names don't match actual payload keys | Log the raw event payload: add `ansible.eda.noop` rule with `debug` to inspect |
| AAP job template not found by EDA | Template name mismatch or org scope | Verify exact template name and organization in EDA rulebook |
| Action Framework can't connect to AAP | Network/firewall blocking Instana SaaS → AAP controller | Confirm AAP controller URL is reachable from Instana's egress IPs |
| Rollback playbook fails on Kubernetes | `kubeconfig` not available in AAP execution environment | Add `kubernetes.core` credential and kubeconfig to job template |

---

### 9. Maturity Path and Related Guides

**Crawl / Walk / Run:**

| Maturity | Description | What to Build |
|----------|-------------|---------------|
| **Crawl** | Instana alerts enrich a dashboard or ITSM ticket — no automation, human decides | Configure Instana webhook → EDA → ServiceNow/Slack notification with Causal AI context |
| **Walk** | EDA triggers AAP job templates, but with human approval via AAP Survey before execution | Add `ask_variables_on_launch: true` to job templates; human confirms remediation details |
| **Run** | Fully automated: Instana detects → Causal AI confirms → EDA triggers → AAP executes, no human in loop | Remove survey requirement; add policy-based guardrails (only auto-remediate patterns with >95% historical success) |

**Related Guides:**
- Generic AIOps guide: `README-AIOps.md` (for the tool-agnostic AIOps pattern)
- AI Infrastructure guide: `README-IA.md` (for deploying AI inference backend if using optional LLM step)
- EDA getting started: link to access.redhat.com EDA guide (for EDA fundamentals)

**ROI Recap:**
- Instana's observability investment shifts from passive monitoring to active remediation
- MTTR reduction: from hours (manual triage) to minutes (automated response)
- Alert fatigue reduction: only unresolvable incidents escalate to humans

---

## Implementation Steps

1. Create `README-Instana-AIOps.md` using the structure above
2. Write all 9 sections with full content (2,000-3,000 words target)
3. Include 5-7 YAML code blocks (rulebook, credential type, 3 remediation playbooks, AI inference task)
4. Include 3 workflow diagrams (ASCII) — one for each path and one comparing both
5. Add all required tables (persona, collections, external systems, troubleshooting, validation)
6. Update `README.md` to add a link to the new guide
7. Add placeholder image reference (same pattern as `README-AIOps.md`)

## Verification After Implementation

- Count sections: all 9 must be present
- Count YAML blocks: minimum 4, target 6+
- Count tables: minimum 5 (persona, collections, systems, troubleshooting, validation)
- Word count: target 2,000-2,500 words
- Score against quality rubric from `README-best-practices.md`: target 8+/10
  - Outcome Clarity: strong problem statement ✓
  - Architecture Clarity: two paths diagrammed ✓
  - Technical Executability: concrete YAML + test commands ✓
  - Validation/Testability: checklist + curl test + troubleshooting table ✓
  - Production Readiness: operational impact ratings, credential patterns ✓
  - Business Framing: persona table + ROI recap ✓
