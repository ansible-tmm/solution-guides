
# Best Practices for Writing Solution Guides <!-- omit in toc -->

A framework for creating enterprise-grade solution guides for Ansible Automation Platform.

> **Quick start:** Jump to the [Starter Template](#appendix-starter-template).
>
> Copy the ready-made skeleton, fill in the placeholders, and score your draft against the [Quality Scoring Rubric](#quality-scoring-rubric) before publishing.

- [0. Title Standard (Non-Negotiable)](#0-title-standard-non-negotiable)
- [1. The Executive Hook (Strategic Framing)](#1-the-executive-hook-strategic-framing)
  - [1.1 The Problem Statement (2-4 sentences max)](#11-the-problem-statement-2-4-sentences-max)
  - [1.2 Who Benefits (Persona Mapping)](#12-who-benefits-persona-mapping)
- [2. Scope and Production Considerations (Expectation Setting)](#2-scope-and-production-considerations-expectation-setting)
  - [2.1 Impact Rating](#21-impact-rating)
  - [2.2 Prerequisites](#22-prerequisites)
  - [2.3 Cost and Resource Notes](#23-cost-and-resource-notes)
  - [2.4 KB Article Metadata](#24-kb-article-metadata)
- [3. Architecture and Workflow (The "Aha" Layer)](#3-architecture-and-workflow-the-aha-layer)
  - [3.1 Workflow Diagram](#31-workflow-diagram)
  - [3.2 Narrative Walkthrough](#32-narrative-walkthrough)
  - [3.3 Visual Design Patterns](#33-visual-design-patterns)
- [4. Technical Core (The Executable Proof)](#4-technical-core-the-executable-proof)
  - [4.1 Foundation Setup](#41-foundation-setup)
  - [4.2 Featured Code (Critical Section)](#42-featured-code-critical-section)
  - [4.3 AAP Integration](#43-aap-integration)
- [5. Validation and Sanity Check](#5-validation-and-sanity-check)
  - [5.1 The Test](#51-the-test)
  - [5.2 Expected Result](#52-expected-result)
  - [5.3 Troubleshooting Common Failures](#53-troubleshooting-common-failures)
- [6. Business Reinforcement and Maturity Path](#6-business-reinforcement-and-maturity-path)
  - [6.1 ROI Recap](#61-roi-recap)
  - [6.2 Crawl, Walk, Run](#62-crawl-walk-run)
  - [6.3 Next Steps and Cross-Linking](#63-next-steps-and-cross-linking)
- [Quality Scoring Rubric](#quality-scoring-rubric)
- [Common Failure Modes (What to Ban)](#common-failure-modes-what-to-ban)
- [What Makes a Guide "Elite"](#what-makes-a-guide-elite)
- [Appendix: Starter Template](#appendix-starter-template)

---

## 0. Title Standard (Non-Negotiable)

**Rule:** Titles must describe an operational outcome, not a product feature.

Solution guides published on access.redhat.com follow the convention `[Topic] - Solution Guide`. Within that convention, the topic portion should still be outcome-oriented whenever possible.

**Bad:**

- "Using the ServiceNow Collection"
- "Ansible EDA Overview"

**Good (KB title format):**

- "ServiceNow ITSM Ticket Enrichment Automation - Solution Guide"
- "AIOps automation with Ansible - Solution Guide"

**Better (outcome-oriented):**

- "Reducing MTTR with Automated ServiceNow Ticket Enrichment - Solution Guide"
- "Triggering Automated Remediation from Splunk Alerts with Event-Driven Ansible - Solution Guide"

> **Tip:** When in doubt, use the standard format.
>
> Use `[Topic] - Solution Guide` for the KB article title, but lead the guide itself with an outcome-oriented subtitle or problem statement in the opening section.

**Solution vs. Tutorial:** A solution guide must solve an operational problem, not teach how to use a tool. If your guide could be titled "Getting started with X" or "How to use Y," it is a tutorial, not a solution. Reframe it around the outcome: what real-world problem does this automation solve?

| Type | Example Title | Verdict |
|------|--------------|---------|
| Tutorial | "Get started with EDA (Ansible Rulebook)" | Not a solution guide -- teaches a tool |
| Solution | "Responding to Infrastructure Alerts with Event-Driven Ansible" | Solves a real operational problem |

**Litmus test:** Would a VP of IT understand the value from the title alone, without knowing Ansible?

---

## 1. The Executive Hook (Strategic Framing)

This section must be readable by a decision maker.

### 1.1 The Problem Statement (2-4 sentences max)

- Define the operational pain.
- Quantify if possible (time, cost, risk, compliance).

**Example format:**

> **Example problem statement:**
>
> Organizations spend X hours manually performing Y, leading to Z risk. This guide demonstrates how to automate this workflow using AAP to reduce effort by X% and improve consistency.

### 1.2 Who Benefits (Persona Mapping)

| Persona | What They Gain |
|---------|---------------|
| IT Ops Admin | Eliminates manual triage |
| Architect | Reference workflow design |
| Manager | Reduced MTTR and measurable ROI |

---

## 2. Scope and Production Considerations (Expectation Setting)

This is where many solution guides fail.

### 2.1 Impact Rating

- **Low** — safe, read-only
- **Medium** — config change, reversible
- **High** — production mutation, requires CAB

### 2.2 Prerequisites

- AAP version
- Collections
- OS requirements
- External systems (ServiceNow, Splunk, AWS, etc.)

### 2.3 Cost and Resource Notes

- GPU required?
- Cloud instance sizing?
- API limits?
- Licensing assumptions?

Ensure the required infrastructure is realistic for the target audience and that security or RBAC implications are called out.

### 2.4 KB Article Metadata

Published solution guides on access.redhat.com follow a structured metadata pattern. Include these fields near the top of each guide, directly after the overview:

- **Operational Impact** -- State the impact level per step if it varies, not just per guide (None / Low / Medium / High).
- **Business Value Drivers** -- 2-3 bullet points framing the business outcome (e.g., reduced downtime, improved compliance posture).
- **Technical Value Drivers** -- 2-3 bullet points framing the technical outcome (e.g., simplified compliance reporting, enforced configuration policies).
- **Recommended Demos and Self-Paced Labs** -- Link to interactive demos, YouTube videos, and Instruqt labs where available.
- **Featured Ansible Content Collections** -- List every collection used with a direct link to its [Automation Hub](https://console.redhat.com/ansible/automation-hub/) page.

For reference, the impact levels:

| Impact | Meaning |
|--------|---------|
| **None** | Read-only, no changes to systems |
| **Low** | Safe, reversible changes |
| **Medium** | Configuration changes, test first |
| **High** | Production mutation, requires change advisory board (CAB) |

---

## 3. Architecture and Workflow (The "Aha" Layer)

This must show causality.

### 3.1 Workflow Diagram

Simple. Clean. 3-6 blocks max. Every guide must have at least one diagram. Choose the pattern that matches your guide type:

**Event-driven (EDA) pattern:**

```
Alert → EDA Rulebook → Job Template → API Call → Resolution
```

**Provisioning / Day 1 pattern:**

```
Request → Survey/Vars → Workflow Template → Provision → Validate → Notify
```

**Day 2 operations pattern:**

```
Schedule/Trigger → Fact Gather → Analyze/Compare → Remediate → Report
```

**Integration pattern:**

```
External Event (ITSM/Webhook) → Controller API → Playbook → Update Source System
```

> **Tip:** Draw your own if needed.
>
> If your guide doesn't fit any of these patterns, draw your own -- but if you can't draw it in 3-6 blocks, the workflow may be too complex for a single guide. Consider splitting.

### 3.2 Narrative Walkthrough

Explain the logic in 5-8 sentences:

- What triggers it
- What decision logic runs
- What automation executes
- What outcome is produced

**Litmus test:** Could someone redraw the workflow after reading your narrative alone?

### 3.3 Visual Design Patterns

Use the right visual format for the right purpose:

| Format | When to Use | Example |
|--------|-------------|---------|
| **Workflow diagram** | Show end-to-end causality (3-6 blocks) | Event -> EDA -> Playbook -> Result |
| **Architecture diagram** | Show system components and connections | AAP <-> Kafka <-> Observability tool |
| **Tables** | Compare options, map events to responses | Event / Source / Response tables |
| **Code blocks (YAML)** | Show the actual automation logic | Featured tasks, rulebooks, API calls |
| **Screenshots** | Show AAP UI configuration (Job Templates, Workflows) | Workflow Visualizer, Survey setup |
| **Callout boxes** | Highlight tips, warnings, and context | Blockquotes with tip/warning prefix |

**Callout conventions:**

Use blockquotes for tips, warnings, and contextual notes. Keep a consistent style across all guides:

> **Tip:** Use for helpful context, shortcuts, or "did you know" information.

> **Why [tool]?** Use for explaining tool choices and alternatives.

> **Warning:** Use for production-impact notes or common mistakes.

**Inline logos and branding:**

When referencing third-party tools (Kafka, Splunk, ServiceNow, etc.), include their logo image inline where it aids scannability. Keep logos to a consistent width (e.g., 200px) and link to the relevant Automation Hub page.

---

## 4. Technical Core (The Executable Proof)

This is where credibility is built.

### 4.1 Foundation Setup

Only include:

- Secrets/tokens
- API connectivity
- Required collections

**Automation Hub linking rule:** Every Ansible collection referenced in the guide **must** include a direct link to its page on [Automation Hub](https://console.redhat.com/ansible/automation-hub/). This serves as both a credibility signal and a convenience for the reader.

**Example:**

- **Certified Collection**: [redhat.ai](https://console.redhat.com/ansible/automation-hub/repo/published/redhat/ai) -- Configures and serves an AI model using InstructLab.
- **Validated Collection**: [infra.ai](https://console.redhat.com/ansible/automation-hub/repo/validated/infra/ai) -- Provisions RHEL AI infrastructure.

No fluff.

### 4.2 Featured Code (Critical Section)

Do **NOT** dump the full repo. Show:

- The key task
- The logic block
- The rulebook trigger
- The API call

**Example:**

```yaml
- name: Update ServiceNow ticket with enriched data
  servicenow.itsm.incident:
    number: "{{ incident_number }}"
    state: "In Progress"
    work_notes: "{{ ai_summary }}"
```

Then link to the full source:

> Full source available at: `github.com/your-org/solution-guide-x`

### 4.3 AAP Integration

Show:

- Job Template setup
- Rulebook activation
- Credentials mapping
- RBAC notes

No vague instructions like "Create a job template." Be explicit. Here is the minimum level of detail expected:

**Example -- Job Template configuration:**

| Field | Value |
|-------|-------|
| **Name** | `ServiceNow Ticket Enrichment` |
| **Inventory** | `ServiceNow Hosts` |
| **Project** | `ITSM Automation` |
| **Playbook** | `enrich_ticket.yml` |
| **Credentials** | `ServiceNow API Token`, `Machine Credential` |
| **Extra Variables** | `incident_number` (prompt on launch) |
| **Verbosity** | 1 (Verbose) |

**Example -- Credential mapping:**

> **Custom Credential Types** for API tokens.
>
> Inject tokens as extra variables or environment variables -- never hardcode secrets in playbooks. See [Creating Custom Credential Types](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/) in the AAP documentation.

**Example -- RBAC note:**

> **RBAC:** Scope roles tightly per team.
>
> Assign the `Execute` role on this Job Template to the `ops-tier1` team. The `Admin` role should be limited to the automation architect team to prevent accidental template modification.

---

## 5. Validation and Sanity Check

This is mandatory. Validation was the most inconsistent section across existing guides -- many omit it entirely. A guide without a validation step is a guide that cannot be trusted.

### 5.1 The Test

Define a concrete, repeatable test. Not a vague suggestion -- an actual command or action the reader can execute.

**Good example (API test):**

```bash
curl -sk https://controller.example.com/api/v2/job_templates/42/launch/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"extra_vars": {"incident_number": "INC0012345"}}' | jq .status
```

**Good example (EDA test):**

> Send a test event to the webhook endpoint:
>
> ```bash
> curl -H "Content-Type: application/json" \
>   -d '{"alert": "high_cpu", "host": "web01.example.com"}' \
>   http://eda.example.com:5000/endpoint
> ```

**Good example (manual trigger):**

> **Manual trigger** via the AAP UI.
>
> Navigate to **Resources → Templates → [Template Name]** in the AAP Controller UI. Click **Launch** and provide the survey values when prompted.

### 5.2 Expected Result

Show the actual output the reader should expect. Do not describe it in prose -- show it.

**Good example (console output):**

```
PLAY RECAP *********************************************************************
servicenow_host : ok=4    changed=2    unreachable=0    failed=0    skipped=0
```

**Good example (state change):**

> After the playbook completes, the ServiceNow incident should show:
> - **State:** In Progress
> - **Work Notes:** Contains the AI-generated summary
> - **Assignment Group:** Updated to the correct tier

### 5.3 Troubleshooting Common Failures

Include at least 2-3 common failure scenarios and how to diagnose them:

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| `401 Unauthorized` | Expired or invalid API token | Regenerate the token and update the credential in AAP |
| Playbook hangs at "Gathering Facts" | Target host unreachable | Verify network connectivity and SSH/WinRM access |
| EDA rulebook doesn't fire | Event payload doesn't match condition | Check rulebook condition syntax against the actual event JSON |

---

## 6. Business Reinforcement and Maturity Path

This prevents it from being "just a lab."

### 6.1 ROI Recap

> You now have automated X, reducing manual effort and improving consistency.

### 6.2 Crawl, Walk, Run

| Maturity | Description |
|----------|-------------|
| **Crawl** | Read-only enrichment |
| **Walk** | Automated ticket updates |
| **Run** | Fully automated remediation |

### 6.3 Next Steps and Cross-Linking

Every guide exists within a broader ecosystem. Authors must identify and link to related guides so readers understand the full journey.

- Link to the **next logical guide** (e.g., Network Fact Gathering links to Network Backup and Configuration)
- Link to **prerequisite guides** (e.g., AIOps guide references the AI Infrastructure guide for deploying the AI backend)
- Link to **ISV or partner integrations** where applicable
- Link to **advanced architecture expansions** for readers ready to go deeper

**Example cross-links:**

> **Related guides:**
> - Need to deploy the AI infrastructure first? See [AI Infrastructure automation with Ansible](README-IA.md)
> - Ready to add event-driven triggers? See [Get started with EDA](https://access.redhat.com/articles/7136720)

---

## Quality Scoring Rubric

Grade guides against this rubric before publishing:

| Category | Weight |
|----------|--------|
| Outcome Clarity | 20% |
| Architecture Clarity | 20% |
| Technical Executability | 25% |
| Validation/Testability | 15% |
| Production Readiness Info | 10% |
| Business Framing | 10% |

Score each 1-5. Anything below 3 in any category — revise before publish.

---

## Common Failure Modes (What to Ban)

- "Overview Only" guides with no code
- Screenshot-heavy, YAML-light content
- No validation step
- No versioning
- No production impact warning
- No persona/value framing
- No GitHub repo

---

## What Makes a Guide "Elite"

A truly excellent solution guide:

- Has a deterministic workflow
- Shows real automation logic
- Can be executed in < 60 minutes
- Has clear operational outcome
- Maps to maturity progression
- Could be used by a field seller as enablement

### Minimum Depth Standard

A guide that covers every section can still fail in practice if it lacks depth. Use this rule of thumb:

| Indicator | Minimum | Ideal |
|-----------|---------|-------|
| Solution walkthrough steps | 3 | 5-8 |
| YAML code blocks | 2 | 4-6 |
| Total guide length | ~800 words | 1500-2500 words |
| Diagrams | 1 | 2-3 |
| Validation scenarios | 1 | 2-3 (including failure cases) |

> **Warning:** Your guide may be too thin.
>
> If it has fewer than 3 walkthrough steps or fewer than 2 code blocks, either expand the scope or merge it with a related guide. The Network Fact Gathering guide is an example that would benefit from merging with its companion due to insufficient standalone depth.

---

## Appendix: Starter Template

Copy this skeleton when creating a new solution guide. Replace all placeholder text.

````markdown
# [Topic] - Solution Guide

> **Knowledge Base Article**: [https://access.redhat.com/articles/XXXXXXX](https://access.redhat.com/articles/XXXXXXX)

## Overview

<!-- 2-4 sentence problem statement. Define the operational pain and quantify if possible. -->

Organizations spend X hours manually performing Y, leading to Z risk. This guide demonstrates how to automate this workflow using Ansible Automation Platform.

**Operational Impact:** Low | Medium | High

**Business Value Drivers:**
- [Value 1]
- [Value 2]

**Technical Value Drivers:**
- [Value 1]
- [Value 2]

**Recommended Demos and Self-Paced Labs:**
- [Demo or lab name](https://link)

**Featured Ansible Content Collections:**
- [collection.name](https://console.redhat.com/ansible/automation-hub/repo/published/namespace/name/)

### Who Benefits

| Persona | What They Gain |
|---------|---------------|
| IT Ops Admin | [Benefit] |
| Architect | [Benefit] |
| Manager | [Benefit] |

## Prerequisites

- Ansible Automation Platform version X.X
- Collections: `namespace.collection` vX.X
- OS: RHEL X
- External systems: [ServiceNow, AWS, etc.]

## Architecture

<!-- Include a workflow diagram: 3-6 blocks showing the end-to-end flow. -->

```
[Trigger] → [Step 1] → [Step 2] → [Result]
```

<!-- 5-8 sentence narrative explaining what triggers the workflow, what logic runs, and what outcome is produced. -->

## Solution Walkthrough

### Step 1: [Name]

**Operational Impact:** Low

<!-- Explanation of what this step does. -->

```yaml
- name: Example task
  namespace.collection.module:
    parameter: "{{ variable }}"
```

### Step 2: [Name]

**Operational Impact:** Medium

<!-- Continue with additional steps. -->

## Validation

### Test

<!-- Provide a concrete, executable test -- an actual command or UI action, not just "run the playbook." -->

```bash
# Example: curl, ansible-playbook CLI, or AAP API call
```

### Expected Result

<!-- Show the actual expected output verbatim. -->

```
PLAY RECAP *********************************************************************
target_host : ok=X    changed=X    unreachable=0    failed=0    skipped=0
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| [Error message or behavior] | [Root cause] | [Resolution steps] |
| [Error message or behavior] | [Root cause] | [Resolution steps] |

## Business Reinforcement

### ROI Recap

> You now have automated [X], reducing manual effort by [Y] and improving [Z].

### Maturity Path

| Maturity | Description |
|----------|-------------|
| **Crawl** | [Starting point] |
| **Walk** | [Intermediate] |
| **Run** | [Fully automated] |

### Related Guides

- [Related guide 1](link)
- [Related guide 2](link)

## Sources

- [Red Hat Ansible Automation Platform](https://www.redhat.com/en/technologies/management/ansible)
- [Additional source](link)
````
