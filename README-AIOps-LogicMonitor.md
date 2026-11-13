# LogicMonitor + Ansible Automation Platform: AIOps Solution Guide

> **Work in Progress** -- this guide is actively being developed.

**From Alert Noise to Governed Remediation**

Organizations invest heavily in observability, yet most still rely on humans to translate monitoring insights into remediation actions. LogicMonitor and Edwin AI provide the intelligence to detect, analyze, and recommend. Ansible Automation Platform provides the trust layer to govern, execute, and report. Together, they deliver closed-loop AIOps that is safe enough for 3 AM and auditable enough for Monday morning.

This guide follows a crawl-walk-run maturity progression for BGP network remediation. Crawl uses Envision for static mappings and manual execution; Walk adds Edwin correlation and maps approved automation to Insights for manual initiation; Run adds root-cause-informed Rules and Actions that trigger approved automation through Event-Driven Ansible (EDA). Edwin AI chat complements these stages. The same pattern applies to any infrastructure domain that LogicMonitor monitors -- servers, storage, cloud, and hybrid IT environments.

|  |  |
| :---- | :---- |
| **Operational Impact** | Clear operator guidance and repeatable manual execution (Crawl), faster operator decisions through correlated Insights and mapped automation (Walk), and reduced response time through root-cause-informed, rule-triggered automation with human approval for writes (Run) |
| **Business Value Drivers** | Reduced MTTR, lower on-call escalation volume, faster incident resolution without increasing headcount |
| **Technical Value Drivers** | Envision static mappings, Edwin correlation and Insight action mappings, root-cause-informed EDA triggers, governed execution with RBAC, approvals, and audit trails |

---

## Contents

* [Background](#background)  
* [Solution](#solution)  
* [Prerequisites](#prerequisites)  
* [Integration Architecture](#integration-architecture)  
* [Stage 1 -- Crawl: Envision Playbook Mapping and Manual Execution](#stage-1----crawl-envision-playbook-mapping-and-manual-execution)  
* [Stage 2 -- Walk: AI Correlated Insights and Operator-Initiated Automation](#stage-2----walk-ai-correlated-insights-and-operator-initiated-automation)
* [Stage 3 -- Run: Root-Cause-Informed, Rule-Triggered Automation](#stage-3----run-root-cause-informed-rule-triggered-automation)
* [Going Further -- Conversational Investigation with Edwin AI](#going-further----conversational-investigation-with-edwin-ai)  
* [Operational Considerations](#operational-considerations)  
* [Validation and Troubleshooting](#validation-and-troubleshooting)  
* [Maturity Path Summary](#maturity-path-summary)  
* [ROI Recap](#roi-recap)  
* [Extending to Hybrid IT](#extending-to-hybrid-it)  
* [Sources and Next Steps](#sources-and-next-steps)

---

## Background

### The AIOps Gap: Detection Without Action

Alert fatigue is the symptom. The root cause is a gap between intelligence and execution.

Monitoring platforms excel at detecting problems. AI layers excel at correlating signals and recommending fixes. But without a governed execution layer, those recommendations become Slack messages, tickets, and pages to an on-call engineer who may or may not act on them in time.

The fundamental question is this: **if your AI makes a recommendation at 3 AM, what prevents a bad recommendation from reaching production?**

Manual review does not scale. Blind automation introduces unacceptable risk. The answer lies in combining AI intelligence with governed automation.

### LogicMonitor and Edwin AI: The Intelligence Layer

LogicMonitor is a hosted full-stack infrastructure monitoring platform with particular strength in network monitoring. It provides agentless discovery, anomaly detection, and comprehensive alerting across hybrid infrastructure.

Edwin AI is LogicMonitor's AI-powered ITOps layer. It goes beyond simple threshold-based alerting to proactively detect, diagnose, and recommend remediation actions through:

* **Alert correlation** -- grouping related alerts to reduce noise and reveal root causes  
* **Event analysis** -- connecting configuration changes, deployments, and infrastructure events to alert patterns  
* **Intelligent recommendations** -- suggesting specific remediation actions based on historical patterns and current context

### Ansible Automation Platform: The Trust Layer

Red Hat Ansible Automation Platform provides the governance framework that makes AI-recommended automation safe for production:

* **RBAC** -- controlling who can create, modify, and execute automation  
* **Policy as Code** -- defining what automation is allowed to do and under what conditions  
* **Approval workflows** -- requiring human sign-off for high-risk actions  
* **Audit trails** -- recording every action, every parameter, and every outcome  
* **Deterministic execution** -- ensuring the same automation produces the same result every time  
* **Event-Driven Ansible** -- reacting to external events in real time with governed rule evaluation

LogicMonitor and Edwin AI provide the intelligence. AAP provides the trust layer. Neither platform can deliver closed-loop AIOps alone.

---

## Solution

### Components

| Component | Role | Details |
| :---- | :---- | :---- |
| **LogicMonitor** | Detection and monitoring | Full-stack infrastructure monitoring, webhook-based alerting |
| **Edwin AI** | Analysis and recommendation | Alert correlation, root cause analysis, remediation recommendations |
| **AAP Automation Controller** | Governed execution | Job templates, workflow templates, RBAC, audit logging |
| **AAP EDA Controller** | Event-driven automation | Rulebook activations, event stream processing, webhook ingestion |
| **MCP (Model Context Protocol) integration** | Agentic AI interface | Connects Edwin AI to AAP APIs for approved automation discovery and execution within configured authorization and approval boundaries. |
| **Network infrastructure** | Target infrastructure | Network devices monitored by LogicMonitor (examples in this guide use Arista EOS) |

### Personas

| Persona | Challenge | What They Gain |
| :---- | :---- | :---- |
| **Network Operations** | Manual triage of BGP alerts; slow MTTR; alert fatigue from repetitive incidents | Known issues resolve in seconds. Ambiguous failures are triaged by AI. On-call engineers handle only truly novel problems. |
| **Platform Engineering** | Remediation logic lives in tribal knowledge; no governed way to encode decision trees | Every action runs through pre-tested job templates with RBAC. Workflow templates encode decision logic. Patterns promote from ad-hoc to governed. |
| **Security and Compliance** | No audit trail for manual remediation; AI actions bypass governance | Every alert, decision, and action is logged. Policy as Code enforces boundaries. Human approval gates at any point in the chain. |

---

## Prerequisites

| Requirement | Version / Details |
| :---- | :---- |
| Ansible Automation Platform | 2.6 or later |
| LogicMonitor | Active account with API access and webhook configuration |
| Edwin AI | Portal with API credentials (`access_id`, `access_key`) |
| MCP integration | Connects Edwin AI to AAP APIs through MCP; configure the AAP connection and authorization controls. |
| Network devices | Devices monitored by LogicMonitor with BGP peering (examples use Arista EOS) |

> **Note:** AAP 2.6 is the minimum supported version for this guide. Validation against AAP 2.7 is in progress; this section will be updated once that testing is complete.

### Collections

| Collection | Purpose |
| :---- | :---- |
| `logicmonitor.integration` | LM device management (devices, collectors, alert rules, device groups) |
| `logicmonitor.edwin_ai` | Edwin AI query API for alert correlation and insights |
| `arista.eos` | Network device automation (substitute your platform's collection as needed) |
| `ansible.eda` | Event-Driven Ansible webhook source plugin, Event Stream management |

---

## Integration Architecture

### AIOps Value Chain

The integration maps cleanly across the AIOps value chain, with LogicMonitor and Edwin AI owning the left side (intelligence) and AAP owning the right side (execution):

```
  LogicMonitor / Edwin AI                 AAP
  +------------------------------+  +------------------------------+
  | DETECT -> ANALYZE -> RECOMMEND |  | GOVERN -> EXECUTE -> REPORT  |
  |                                |  |                              |
  | LM monitors infrastructure    |  | RBAC, Policy as Code         |
  | Edwin AI correlates alerts     |  | Pre-tested job templates     |
  | Edwin AI recommends actions    |  | Workflow orchestration       |
  |                                |  | Audit trails                 |
  +------------------------------+  +------------------------------+
```

### Overall Architecture

```
+---------------------------------------------------------------------+
|                        LOGICMONITOR                                   |
|  +----------+    +----------+    +------------------------------+    |
|  | Detection |-->| Analysis |-->| Edwin AI (Recommendations)    |    |
|  | Engine    |   | (AI/ML)  |   |                                |   |
|  +----------+    +----------+    +------+--------------+---------+   |
|                                         |              |             |
+-----------------------------------------|--------------|-------------+
                                          |              |
                        Webhook (alerts)  |              | MCP (chat and agentic)
                                          |              |
+-----------------------------------------|--------------|-------------+
|                  ANSIBLE AUTOMATION PLATFORM                         |
|                                         |              |             |
|  +------------------+    +--------------v--+   +-------v--------+   |
|  | EDA Controller   |    | Automation      |   | MCP integration |   |
|  |                  |    | Controller      |   |                |   |
|  | Event Streams    |--->| Job Templates   |<--| AAP API access |   |
|  | Rulebook         |    | Workflows       |   | Authorization and approvals  |   |
|  | Activations      |    | RBAC / PaC      |   | Human approval |   |
|  +------------------+    | Audit Logging   |   +----------------+   |
|                          +--------+--------+                        |
|                                   |                                 |
|                    +--------------v--------------+                  |
|                    | Content Collections          |                  |
|                    | logicmonitor.integration     |                  |
|                    | logicmonitor.edwin_ai        |                  |
|                    | arista.eos                   |                  |
|                    +--------------+--------------+                  |
|                                   |                                 |
+-----------------------------------|---------------------------------+
                                    |
                    +---------------v---------------+
                    |    TARGET INFRASTRUCTURE       |
                    |  Network devices monitored     |
                    |  by LogicMonitor                |
                    +-------------------------------+
```

### Integration Surfaces

The following surfaces support the maturity stages and complementary chat experience:

| Surface | Component | Stage | Role |
| :---- | :---- | :---- | :---- |
| **EDA Event Stream** | AAP Event Streams (AAP 2.6+) | Run | Configured endpoint that receives events and routes them to rulebook activations. |
| **EDA webhook source** | `ansible.eda.webhook` source plugin | Run | EDA rulebook activation that evaluates events received through the configured Event Stream. |
| **LM device management** | `logicmonitor.integration` collection | All | Manages LM devices, collectors, alert rules, device groups |
| **Edwin AI query** | `logicmonitor.edwin_ai.query_api` module | Optional enrichment | Queries Edwin AI for correlated alerts, events, insights |
| **MCP integration** | `MCP connection to AAP APIs` | Complementary chat | Connects Edwin AI to AAP APIs for approved automation discovery and execution. |

### Integration Patterns

Each maturity stage uses a different integration pattern with AAP. The patterns differ in how they are triggered, how tightly they couple the partner platform to AAP, and how governance is enforced:

|  | Envision (Crawl) | Correlated Insights (Walk) | Rule-Triggered Automation (Run) |
| :---- | :---- | :---- | :---- |
| **Trigger** | Operator-selected mapped playbooks | Operator triggers recommended playbooks | Configured Rules and Actions route correlated Insight and root-cause context to EDA |
| **Coupling** | Guided (operator-led, mapped) | Guided (operator-led, correlation-informed) | Rule-based (root-cause-informed, event-driven) |
| **Primary user** | NOC / platform operators | Operations and platform teams | Operations and platform teams |
| **Governance** | RBAC, approval, and audit controls | RBAC, approval, and audit controls | Rulebook conditions, service accounts, AAP policy, and human approval before writes |
| **Response model** | Human-initiated and auditable | Human-initiated, with Edwin discovery, mapping, and recommendations | Event-driven, with approval gates for write-based remediation |

> **Roadmap note:** Today, Edwin AI reaches AAP through a custom LogicMonitor MCP service. Native integration with the Ansible AAP MCP Server -- including its OAuth-based authorization -- is in development. Throughout this guide, "MCP" refers to that custom LogicMonitor MCP; once AAP MCP Server support ships, the specifics of this integration surface will change.

---

## Stage 1 -- Crawl: Envision Playbook Mapping and Manual Execution

* Integration surface: LogicMonitor Envision and AAP job templates  
* Operational impact: Foundational -- mapped playbooks, operator-led execution, and governed learning  
* Story: A known operational condition is mapped to an approved playbook; the operator reviews context and starts the run manually.


Crawl establishes the shared operational vocabulary before automation is delegated to events or agents. LogicMonitor Envision statically maps monitored conditions and recommended actions to approved AAP job templates. Operators use that mapping to review the alert context, select the appropriate playbook, and execute it manually through LogicMonitor Envision with AAP RBAC, approvals, and auditability.

### Flow

LogicMonitor detects a condition and surfaces its context in Envision  
  -> LogicMonitor presents the mapped, approved AAP job template  
    -> Operator reviews the diagnostic context and available actions  
      -> Operator manually executes the AAP job from the LogicMonitor Envision UI  
        -> AAP enforces access controls and any required approval  
          -> Results are recorded and used to identify candidates for Walk-stage Insight mappings

### Setup

* Configure Ansible Actions in LogicMonitor: in Settings > Integrations, add an Ansible Actions integration, provide the AAP HTTPS endpoint and a write-scoped AAP personal access token.  
* Validate playbook discovery and resource mapping: LogicMonitor retrieves AAP job-template metadata only. Confirm the AAP host name matches the LogicMonitor resource hostname, IP address, or display name before making the action available to the appropriate resources.  
* Run and review from the resource: authorized operators use the resource Actions tab to launch a mapped playbook, monitor execution status, and review output and run history. 

## Stage 2 -- Walk: AI Correlated Insights and Operator-Initiated Automation

* Integration surface: LogicMonitor alerts, Edwin AI Insights, and mapped AAP job and workflow templates
* Operational impact: Medium -- Corellated Insight map to recommended AAP playbooks and manually initiate diagnostics or approved remediation
* Story: Edwin AI correlates related alerts into an Insight and recommends relevant approved automation to it. The operator reviews the Insight and manually triggers the selected action.

Walk adds correlated incident context to the static mappings established in Crawl. Edwin groups related LogicMonitor alerts into an Insight and maps relevant approved AAP job templates or workflows to that Insight, and reccomends the best option for this issue. The operator reviews the context, chooses an available diagnostic or remediation action, and explicitly starts execution. Correlation and action mapping do not themselves launch automation in this stage. AAP authorization and any required approval gates govern execution.

### Flow

```
LogicMonitor detects related alerts
  -> Edwin AI correlates the alerts into an Insight
  -> Relevant approved AAP templates are mapped to the Insight
  -> Edwin AI recommends the best plabook for this Insight
  -> Operator reviews the Insight and manually triggers an action
  -> AAP enforces authorization and required approvals, then executes
  -> Edwin receives execution status and output for operator review
```

### Setup

1. **Connect Edwin AI to AAP.** In the Edwin AI integration, configure the AAP Base URL, OAuth token, AAP API path prefix, and AAP EDA API path prefix. Use a Relay Agent only when direct HTTPS/API connectivity is unavailable.
   ![][image1]

2. **Confirm the LogicMonitor signal path.** Ensure the relevant alerts, device metrics, logs, and topology context are available to Edwin AI. Verify that related alerts are correlated into an Insight.

3. **Verify automation discovery and recommendations.** Edwin discovers available AAP job templates, maps relevant automation to correlated Insights, and recommends the most appropriate playbook to run. Operators review the recommendation and manually initiate execution; they do not configure the Insight-to-automation mappings.

4. **Define safe execution boundaries.** Use approved AAP templates, appropriately scoped credentials and permissions, and human approval gates before write-based remediation. Limit the integration credential or service account to the required AAP resources and actions. Verify that automation starts only when an operator manually initiates it, and that execution status and output return to Edwin for review.

5. **Create the job template.** Create the "Reset BGP Session" job template using the configuration below. Once the template is available, verify that Edwin discovers it and recommends the appropriate approved action for the correlated Insight.

| Field | Value |
| :---- | :---- |
| Name | Reset BGP Session |
| Job Type | Run |
| Organization | Network Ops |
| Project | LM AIOps Solution Guide |
| Playbook | `playbooks/reset_bgp_session.yml` |
| Inventory | Network Inventory |
| Credentials | Machine Credential |
| Ask Variables on Launch | Yes |
| Extra Variables | `{"affected_host":"<host>","alert_id":"<alert_id>"} (valid JSON supplied by the Edwin action payload)` |

### Use Case: BGP Peer Down -- Review the Insight and Launch an Action

A BGP peer relationship drops on a router, generating a peer-down alert and related reachability alerts in LogicMonitor. Edwin correlates these alerts into an Insight and recommends the automation associated with the "Reset BGP Session" job template configured above.

The operator reviews the Insight and Edwin's recommendation, supplies any required device and peer inputs, and manually initiates the approved remediation workflow. AAP enforces authorization before launching the "Reset BGP Session" job template.

The job template runs `playbooks/reset_bgp_session.yml` against the affected device. The playbook resets only the affected BGP peer session, waits for it to re-establish, and validates recovery.


### Validation

Generate a test BGP peer failure and verify that related alerts appear in a correlated Insight with the mapped actions. Manually trigger the diagnostic or approved remediation workflow, then verify the target, execution ID, status, and output.

**Expected behavior:**

```
Correlated Insight: related BGP and reachability alerts
Mapped actions: approved diagnostic and remediation templates
Before operator initiation: no job or workflow launched
After operator initiation: selected AAP job or workflow created
Completed execution: status and output available for review
```

### Components

| Component | Details |
| :---- | :---- |
| LogicMonitor | Detects alerts and supplies operational context |
| Edwin AI Insights | Correlates related alerts and surfaces mapped automation |
| Mapped AAP actions | Associate relevant approved job or workflow templates with the Insight |
| Operator | Reviews the Insight and manually initiates the selected action |
| AAP | Applies authorization, approval gates, execution, and audit logging |
| Execution results | Execution ID, status, and output returned to Edwin |

---

## Stage 3 -- Run: Root-Cause-Informed, Rule-Triggered Automation

* Integration surface: LogicMonitor alerts, Edwin AI Rules and Actions, Event-Driven Ansible, and Ansible Automation Platform  
* Operational impact: High -- AI correlation and root cause analysis drive automated execution of diagnostic and remediation job templates
* Story: LogicMonitor detects an alert; Edwin AI identifies its likely root cause and uses configured Rules and Actions to execute the correct AAP job template or workflow for execution.

The Run stage combines LogicMonitor detection with Edwin AI correlation and rule-based action mapping. Edwin identifies the likely root cause, then configured Rules and Actions select an approved AAP job template and send the relevant payload to Event-Driven Ansible for governed AAP execution. This creates a repeatable, root-cause-informed path from alert to action. Configured rules initiate the workflow without an operator manually launching each run. Read-only diagnostics may execute automatically where permitted; write-capable branches can pause for human approval before changing a device.

### Flow

```
LogicMonitor detects a BGP alert on a network device
  -> LogicMonitor sends alert context to Edwin AI
    -> Edwin AI correlates signals and identifies the likely root cause
      -> Edwin Rules and Actions select the mapped AAP job template
        -> Edwin uses Post Ansible EDA Event to send the mapped payload to the configured Event Stream URL
          -> The EDA rulebook evaluates the payload and invokes the approved AAP job template
            -> AAP runs permitted diagnostics and remediations
              -> AAP executes approved remediation and validates the outcome
              -> Edwin checks status using the execution ID and receives the result and output
```

### Setup

1. **Connect Edwin AI to AAP.** In the Edwin AI integration, configure the AAP Base URL, OAuth token, AAP API path prefix, and AAP EDA API path prefix. Use a Relay Agent only when direct HTTPS/API connectivity is unavailable. Verify that Edwin can retrieve the approved AAP job templates and workflows that will be available as actions.  
   ![][image1]  
2. **Confirm the LogicMonitor signal path.** Ensure the relevant alerts, device metrics, logs, and topology context are available to Edwin AI so it can correlate the event and identify the likely root cause.  
     
3. **Configure Edwin Rules and Actions.** For direct execution, map a condition to an approved AAP job or workflow template ID. For EDA, use Post Ansible EDA Event with the configured Event Stream URL. Map the affected resource and incident context into valid JSON extra variables expected by the target template.
   ![][image2]

4. **Define safe execution boundaries.** Use approved AAP templates, appropriate credentials and permissions, and approval gates for write-based remediation where policy requires. Rule-based actions run only within the configured integration credential or service-account and AAP RBAC boundaries. Capture the execution ID, check status after launch, and review output in Edwin; synchronize to ITSM only when configured.
   ![][image3]

5. **Reuse the existing BGP remediation template.** Use the "Reset BGP Session" job template created in Stage 2, retaining its playbook, inventory, credentials, and required inputs. Configure the EDA rule to launch this job template for the validated scenario.

### Use Case: Correlated BGP Peer Failure -- Approved Remediation

LogicMonitor detects a BGP peer failure and related reachability alerts. Edwin correlates the alerts into an Insight and identifies the likely root cause. A configured rule matches the validated scenario and routes the affected device and peer context to approved automation. An unresolved or unmatched cause remains available for operator investigation rather than triggering an arbitrary remediation.

Edwin uses Post Ansible EDA Event to send the mapped payload to the configured Event Stream URL, where an EDA rulebook evaluates it and launches the existing "Reset BGP Session" job template. This illustrative rule assumes the payload has already been mapped by the configured Edwin action:

```
# --- RUN: Configured response following Edwin correlation and root-cause analysis ---
- name: BGP peer down - reset session
  condition: event.payload.type == "bgp_peer_down"
  action:
    run_workflow_template:
      name: "Reset BGP Session (Approved)"
      organization: "Network Ops"
      job_args:
        extra_vars:
          affected_host: "{{ event.payload.host }}"
          alert_id: "{{ event.payload.id }}"
```

The "Reset BGP Session" job template (`playbooks/reset_bgp_session.yml`) targets the affected device, resets the affected BGP peer session, waits for it to re-establish, and validates the recovery.

> **Note:** Scope BGP reset carefully.
>
> In production, scope the reset to the specific affected peer session rather than clearing all BGP sessions on the device. Clearing all sessions disrupts working peers and can cause broader network impact.

AAP records the workflow execution status and job output, including the recovery validation results. Operators can review these results in AAP to confirm the outcome or continue investigating if recovery fails.

### Validation

Once configured, trigger a real or test BGP peer down alert in LogicMonitor. Verify that Edwin creates the correlated Insight and the matching rule posts the event without a manual launch. In AAP, verify that "Reset BGP Session (Approved)" targets the correct host, and runs the remediation only after approval. Denial or timeout must leave the device unchanged.

**Illustrative job output after approval:**

```
PLAY [Reset BGP session on affected device] ************************************

TASK [Assert BGP peers are established] ****************************************
ok: [affected-device] => {
    "changed": false,
    "msg": "BGP peers successfully re-established"
}

PLAY RECAP *********************************************************************
affected-device            : ok=6    changed=0    unreachable=0    failed=0
```

### Components

| Component | Details |
| :---- | :---- |
| LogicMonitor | Detects alerts and sends operational context to Edwin AI |
| Edwin AI | `Correlates signals and identifies the likely root cause` |
| Edwin Rules and Actions | Matches configured conditions against the correlated Insight and root-cause context; builds and routes the execution payload |
| Event Stream | Configured Event Stream URL that receives the mapped payload from Edwin's Post Ansible EDA Event action |
| EDA source | `EDA rulebook activation configured for the Event Stream` |
| Rulebook | `Evaluates the mapped payload, conditions, and guardrails; invokes the selected approved job template` |
| AAP workflow | "Reset BGP Session (Approved)" -- approval gate followed by the remediation job template |
| Playbook | `playbooks/reset_bgp_session.yml` |
| Collections | `arista.eos, ansible.eda` |

---

## Going Further -- Conversational Investigation with Edwin AI

Edwin AI chat complements the maturity stages by giving operators a conversational way to investigate Insights, review recommendations, and initiate approved AAP automation. Chat is useful when the available context needs exploration or the appropriate response is not covered by an established rule.

### Flow

```
Operator opens an Edwin Insight in chat
  -> Edwin explains correlated alerts, likely cause, and recommendations
  -> Operator investigates and selects an eligible AAP action
  -> Edwin communicates with AAP via MCP
  -> AAP enforces authorization and approval controls, then executes
  -> Status and output return to the conversation
```

Configure the AAP connection and expose only eligible, validated job and workflow templates. Permit autonomous read-only diagnostics only within the configured authorization boundaries; retain human approval for write-based remediation.

### Example: Investigating BGP Flapping

Edwin correlates BGP flapping with other operational signals. The operator uses chat to explore the Insight and review diagnostic or remediation options. The following are illustrative investigation paths, not automatic conclusions from a single metric:

| Correlated context | Possible cause to investigate | Potential approved action |
| :---- | :---- | :---- |
| Interface errors alongside BGP flapping | Link or interface fault | Gather interface diagnostics; consider an approved interface action after review |
| High CPU alongside BGP flapping | Resource exhaustion | Gather process and routing diagnostics before deciding on remediation |
| Recent configuration change alongside BGP flapping | Configuration regression | Compare configuration; consider an approved rollback after review |
| No clear supporting signals | Undetermined | Gather additional read-only diagnostics |

Validate the chat path by opening an Insight, reviewing eligible templates, initiating an approved action, and confirming that execution status and output return to the same conversation. Chat actions remain subject to the configured AAP authorization and approval controls.

---

## Operational Considerations

The following best practices apply across all maturity stages and should be addressed before deploying to production.

### Credential Management

Multiple credential types are in play across the integration: LogicMonitor API tokens, Edwin AI `access_id` and `access_key`, AAP OAuth tokens, network device credentials, and MCP authentication. Store all secrets using AAP credential types or an external vault (such as HashiCorp Vault or CyberArk). Define a rotation policy for each credential type. Apply least-privilege scoping to ensure service accounts and integration credentials have only the permissions required for their specific function.

### Event Stream Security

When Edwin posts payloads to an EDA Event Stream URL, protect the endpoint:

* **Authentication:** Require token-based authentication or mTLS on the Event Stream endpoint. Edwin's "Post Ansible EDA Event" action is a distinct integration point from LogicMonitor's Custom HTTP Delivery; use Token authentication (or mTLS) for this action rather than an HMAC signature.
* **Payload validation:** Validate the payload schema in the EDA rulebook before processing. Reject unexpected or malformed events.
* **Network segmentation:** Restrict network access to the Event Stream URL to known sources (Edwin AI, internal monitoring infrastructure).

### Defining "Read-Only" Automation

Run and the complementary chat experience may use autonomous read-only diagnostics. In practice, "read-only" is an operational contract, not a platform-level toggle. Enforce it through:

* **Template design:** Ensure diagnostic playbooks only run gather-facts, show commands, or other non-mutating operations.
* **Credential scoping:** Use read-only credentials for diagnostic service accounts on target devices.
* **RBAC boundaries:** Limit the integration service account to diagnostic job templates only.

### Write-Approval Gates

Every write-based job or workflow template reachable from Crawl, Walk, Run, or chat should sit behind an explicit approval step, not just RBAC. In AAP, add an **Approval** node before the remediation node(s) in the workflow template:

```
Edwin / EDA trigger
  -> Workflow Template: "Bounce Interface (Approved)"
       Node 1: Approval -- "Approve interface bounce on {{ affected_host }}"
         (timeout, approved-by audit trail, denial path)
       Node 2 (on approval): Job Template -- "Bounce Interface"
       Node 2 (on denial/timeout): Job Template -- "Notify on-call" (no device change)
```

For the Crawl Walk, and Run stages, pair this with a read-only diagnostic template (`check_mode: true` or a dry-run playbook) that Edwin or the operator can run first to preview the change before approving the write-capable template. This keeps the "read-only by default, human-approved for writes" posture consistent across all three stages, not just Run.

### Idempotency and Rate Limiting

* Ensure all remediation playbooks are idempotent so that repeated execution does not cause unintended side effects.
* Protect against alert storms: implement rate limiting or deduplication logic in EDA rulebook conditions to prevent dozens of simultaneous remediations from a burst of correlated alerts.
* Respect change windows: consider whether EDA rules should check for active maintenance windows before triggering remediation.

---

## Validation and Troubleshooting

### Per-Stage Validation Checklist

| Stage | Validation step | Expected result |
| :---- | :---- | :---- |
| **Crawl** | Configure Ansible Actions integration in LogicMonitor | AAP endpoint connects and retrieves job template metadata |
| **Crawl** | Map an approved playbook to a monitored resource in Envision | Mapped action appears in the resource Actions tab |
| **Crawl** | Operator launches mapped playbook from Envision | AAP job executes with RBAC enforcement; output and run history visible in LogicMonitor |
| **Walk** | Generate related BGP and reachability alerts | Edwin creates a correlated Insight with mapped approved actions |
| **Walk** | Review the Insight before selecting an action | No automation launches solely because the Insight appears |
| **Walk** | Manually trigger the mapped action | AAP launches the selected template or approval workflow; results return to Edwin |
| **Run** | Generate a correlated scenario matching a configured rule | Edwin identifies the likely root cause and posts the mapped EDA event without a manual launch |
| **Run** | EDA evaluates the payload | Approved workflow starts with the correct target and inputs |
| **Run** | Check execution result and audit log | Status, output, approval decision, and execution are recorded |
| **Chat (optional)** | Investigate an Insight and start an eligible action via MCP | Execution status and output return to the conversation |


### Common Issues

| Issue | Cause | Resolution |
| :---- | :---- | :---- |
| EDA event not reaching the configured Event Stream | Network reachability, incorrect Event Stream URL, invalid action configuration, or activation not running | Verify the Event Stream URL and activation in EDA Controller; validate the Edwin action configuration and network reachability. |
| BGP not re-establishing after reset | Hold timer not expired, or underlying link still down | Increase wait timeout in `playbooks/reset_bgp_session.yml`; verify link connectivity on affected device |
| Run rule does not match | Correlated context or mapped root-cause fields do not meet the configured conditions | Compare the actual Insight and event payload with the Edwin action mapping and EDA conditions. |
| MCP connection to AAP APIs cannot reach the configured AAP instance | Invalid AAP Base URL, OAuth token, API path prefix, or unavailable Relay Agent | Verify the AAP connection settings and OAuth token; confirm API paths and Relay Agent reachability when used |
| Run rule fires for a scenario that should be handled differently | Rulebook rule ordering issue | Review rule conditions and ordering; ensure only proven repeatable scenarios are routed through Run rules. |

---

## Maturity Path Summary

### Progression

```
CRAWL                         WALK                          RUN
Static mappings               Correlated Insights           Correlation + likely root cause
Operator initiates            Operator initiates            Configured rules initiate
Envision -> AAP                Edwin action -> AAP           Edwin -> EDA -> AAP

Human approval before writes applies at every stage.
Chat complements the stages for investigation and operator-initiated execution.
```

### When to Advance

From Crawl to Walk: Add correlated Insights when operators need related alerts and operational context together to choose an action. Verify that Edwin discovers the available AAP automation, maps relevant templates to Insights, and recommends the appropriate playbook. Operators review the recommendation and manually initiate execution.

From Walk to Run: Promote a validated procedure when the root-cause conditions, target mapping, inputs, approval requirements, and recovery checks can be expressed as repeatable rules. Configure Edwin Rules and Actions and EDA to initiate the workflow; retain human approval before writes.

### The Promotion Pattern

The crawl-walk-run framework is not just an adoption path -- it is an ongoing operational pattern. As operators validate Edwin's recommendations and observe which responses consistently resolve incidents:

1. A recurring Walk recommendation that produces a repeatable, approved outcome can be promoted to a Run rule with explicit root-cause conditions, input mappings, and approval gates.

2. A proven Run response can remain available for manual initiation through a Walk Insight or a Crawl mapping when the situation requires operator judgment or falls outside the configured rule conditions.

3. Execution outcomes inform ongoing refinement of recommendations and Run rules. Expand automated triggering as confidence grows; return unreliable or ambiguous scenarios to operator-led investigation until their conditions and safeguards are understood.

---



## ROI Recap

### MTTR Reduction

- Crawl: Teams reduce time-to-action by mapping common conditions to approved playbooks in Envision, while retaining operator judgment and traceable manual execution.  
- Walk: Correlated Insights and mapped automation reduce alert-by-alert investigation and help operators choose and manually initiate an appropriate response.  
- Run: Root-cause-informed rules initiate approved automation through EDA, reducing manual launch effort and response time; write-based remediation remains human-approved.

### Alert Noise Reduction

Edwin AI's alert correlation reduces the volume of events that reach the on-call team. Combined with EDA's event-driven processing, most alerts are handled without human intervention. The team's attention is focused on high-value work rather than repetitive remediation.

### Governance and Audit Readiness

Every remediation action -- whether launched from a Crawl mapping or Walk Insight, triggered by a Run rule, or initiated through complementary chat via MCP -- flows through AAP's governance framework. This means:

- Complete audit trails for every action taken  
- RBAC enforcement on all automation, including AI-initiated actions  
- Policy as Code ensuring automation stays within approved boundaries  
- Approval workflows for high-risk operations

### Suggested Metrics

Track these metrics to quantify the value of each stage:

| Metric | What it measures | Target |
| :---- | :---- | :---- |
| MTTR by stage | Time from static mapping to manual execution (Crawl), Insight to operator action (Walk), and matched cause to workflow initiation and approved execution (Run) | Set a baseline for Crawl; target a measurable reduction for Walk; track diagnostic and approval time for Run |
| Remediation success rate | Percentage of automated remediations that resolve the issue | Track operator-validated Crawl outcomes and success rate for Run rules |
| On-call escalation reduction | Change in pages to on-call engineers | Illustrative targets: 30-50% reduction after Walk, 50-70% after Run (establish baselines to validate) |
| Alert noise reduction | Volume of alerts reaching human operators | Measurable decrease as Run rules expand without sacrificing approval controls |
| Pattern promotion rate | Number of validated Walk procedures promoted to Run rules per quarter | Indicates system maturity growth |

---

## Extending to Hybrid IT

This guide uses BGP network remediation as the reference scenario because network alerts are concrete, easy to simulate, and immediately relatable to operations teams. However, the crawl-walk-run pattern and every integration surface described here apply to any infrastructure domain that LogicMonitor monitors.

| Domain | Crawl example | Walk example | Run example |
| :---- | :---- | :---- | :---- |
| **Server / OS** | Disk alert -> static mapping, manually launched | Related memory alerts -> correlated Insight with mapped diagnostics, manually launched | Validated resource-exhaustion cause -> rule-triggered approved automation |
| **Cloud** | Budget alert -> static mapping, manually launched | Latency and deployment alerts -> correlated Insight with mapped actions, manually launched | Validated deployment-related cause -> rule-triggered approved workflow |
| **Storage** | Array health alert -> static mapping, manually launched | Related I/O and firmware events -> correlated Insight with mapped diagnostics, manually launched | Validated storage cause -> rule-triggered approved workflow |


The architecture remains the same: LogicMonitor detects, Edwin AI analyzes, and AAP governs execution. Only the content collections and remediation playbooks change per domain. Teams that start with network can expand to additional domains by adding new rulebook rules, job templates, and the appropriate content collections.

---

## Sources and Next Steps

### Resources

| Resource | Link |
| :---- | :---- |
| `logicmonitor.integration` collection | [Automation Hub](https://console.redhat.com/ansible/automation-hub/collections/published/logicmonitor/integration) |
| `logicmonitor.edwin_ai` collection | [Automation Hub](https://console.redhat.com/ansible/automation-hub/collections/published/logicmonitor/edwin_ai) |
| MCP integration | [Deploying the Ansible MCP Server (AAP 2.7)](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.7/extend-assembly_deploying_ansible_mcp_server) |
| Optional LogicMonitor API integration | Available separately |
| Solution Guides | [ansible-tmm.github.io/solution-guides](https://ansible-tmm.github.io/solution-guides/) |

### Next Steps

1. Start with Crawl. In LogicMonitor Envision, map a small set of well-understood network conditions to tested AAP job templates. Have operators review context and launch the mapped automation manually, using RBAC and approvals to establish confidence and collect outcomes.  
     
2. Expand to Walk. Verify that Edwin correlates related alerts into Insights, discovers relevant AAP automation, and recommends the appropriate playbook. Have operators review each recommendation, manually initiate the selected action, and validate the results.

3. Explore Run. Promote proven Walk procedures into configured Rules and Actions that route root-cause context to EDA. Start with permitted read-only diagnostics and retain human approval before every write-based remediation.

4. Add conversational investigation where useful. Use Edwin AI chat to explore Insights, review recommendations, and initiate approved automation via MCP.


The crawl-walk-run progression is designed to meet teams where they are. Each stage delivers immediate value while building the foundation for the next.  


[image1]: <data:image/png;base64,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zaUcFblL83eaeVsDAIQLQoKzU8CVGsaH/ilMAICzclEL6exfjAWzxMXFxcTE4CEAKAwu2LXssrOzjV/LDiEBABQfYuOSNkWc/vqHcWRYGVzjPPviqt8s/D5QKmEX0dupU6fOLqSWLVtK/dprr+3atWvNmjWW63o/A2wmTZo0btw4dxeHlStXelM227dvP3nypOeaQzfeeKN7EwAAiibipLS0tIMHD+7evXvXebN3797jx4+f/fYTzsVVRUiaETE6QnrooYfyG1ojRoy47rrrVqxYoRe4E66//npxlQSjRo3SjzIPHTr0pptOXymnUqVK999//xNPPCFxlSpV6tevb9lCOnHiBFoCACj6iD+ys7MzTZCVlSVD6f8yggnJubiqCOlSG8u1QurYsaPTsly5cpbruqsvvfSSlb+6Gj16tJhmyZIlTz31lGVfUEBXSB73yGbnzp2Tkv67KgQAgKJMnjmcMQsUkvviqs4KSTc16Nu376BBg/QtO73LkQhM1nGyBJs2bZpoTFdLDz744JgxYzIyMrp3726dvt7oXLeQZP2k793JZuPGjd2PDAAAShQFCik89BYVwpEjR87c44/ngq3x8fHuTQAAKDkYFhIAAEB4ICQAACgSICQAACgSICQAACgSICQoFLyf6wSAs+GdRSUPhASFQlZWljcFAAUjUwYnISQwT05OjjcFAGcjI+P327aWTBASmEe/Ug0A58Svv/7qTZUwggmpWbNw7iAnq85JkyZdeumlu3btCvGLrqNGjfKm4GLG831nAAgFhHQWIXXq1KlJkyZHjx79+9///uGHH86YMeOrr75SUX355ZelSpWSQJI333xz3759H3zwQdl85JFHLNcVhnr27Jmenj5mzBgZ5+67705JOX07d+nbqFEjy75sq/QtW7as9oXiAUICCAOEdBYhNW7c2Mq3yzvvvPPpp59a9nVeZ8+evXXrVolff/11TTqkpqY6XZR77rlH6ttvv92yrwKenJzs9BXPWayQih0ICSAMENI5CKl58+biHlno1KtXLzMzs2LFirGxsaIWt5B27typgXSR+NChQzNnzly+fPnPP/8smcTExEqVKsle6durVy/pW61aNQshFTsQEkAYIKRgQgrEsxg6J6pXr+5NQTEFIQGEAUI6NyGdz/2KoqKivCkopiAkgDBASOcmJIBQCCKk++67r7RN1apV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T19Zed26dV27dtVeMviMGTM6dOggjaXW5Keffir1oEGDnDYHDx7cu3evbgJcFCAkhATmKUhIsnZZa6ObIqT27dtL0Lx58/Xr1+/bt08c07t3b8lIG8l89tln2rJly5bOvfiysrK0QbNmzaz8Y7mF1Ldv388//1wCt5D0uABFAc8bAw4ICSGBeXyFtDbfQw66Qlq+fHl0dHS7du0se4UkiyFZIWljWeVIvWvXLm3fr1+/zp07T5482bJHk8aW63052Txw4IDGGzdulHxTG80AFCkCp4OFkBASFAYhCgmgxOI7HRASQgLzICSA4PhOB4SEkMA8CAkgOL7TASEhJDAPQgIIju90QEgICcyDkACC4zsdEBJCAvMgJIDg+E4HhISQwDwICSA4vtMBISEkME+IQipdurQTjxkzxgrtFhVRUVFay1HuvPPOnJwc2czOznYa5OXl5ebmejYFCSZOnJhnI5uZmZnaV5BYau0le52+IeJ+Ir50795dA33wBTFu3LjVq1fHxcW5kxs2bHBvKg0bNvSm4KIicDpYCAkhQWEQupCaNGkip2CJH3roITkd16xZs3379qKNF154oV69epY9RWvUqCGB1sLmzZsT84mOjtYgyUaCI0eOOHvlzJ6RkaHxsGHDjh8/7jReuHCh08xBjnXixIlWrVrt3LlTj7VgwYK77rpLjqiblSpVmj179k8//bRq1arGjRtLpm3bto8++qgK6aWXXqpTp06XLl20seD0rV+/vmbKlSsn9aJFi6T7m2++eezYMXXw+++/L22qVq0qr0ZERMSTTz6p7eUJancd4ZlnnnnjjTesfCFJL8t+ZfQ7wtLmgQceULVDESdwOlgICSFBYRC6kKx807hXSAMGDNAGBw4cEDnNmDHD6dK5c+fU1FSvSQomOTlZajnvS33q1CmpHS1pLOM7mw7O4b755hup5YiW/WhHjhzZsWNHiWfNmuW00V1O/Oyzz7qTKSkpTiwPXurIyMh58+ZZtpwOHTr0448/SiwCtvJXSNJA4g8//NCyDaSjCc7rINIVIZUpU0bi9957b6SNlX8UtxGhyBI4HSyEhJCgMDgnIenf/r5CEoXIckEWNJMmTdJMgwYNsrKyVBuymkm0NaO+uf/+++XsL3tjYmLS09MHDx4syW+//Vbio0ePShwVFbVlyxZRlDySnJyc2NhYiSWjAzqikvaOYFQ/06dPl7ps2bJS68VepYGsb6z8q4xre32vzxGSLoamTZvmNJAHb9nXOtJhJXny5MmhQ4fKg9H1lvstu+7du3fr1k2HUrZu3apBbm6uCElMJkfs06eP00CP0q9fPycDRZbA6WAhJIQEhUGIQioIEZKco51B9D89utSw8s/7zntxishJ37JLdKnFCaSvBom2bxLtd+10U0YL7Gjl/z/Jyr+enqK3t/AgVtNAurj/lSXIAsi96cs5/cvKM76SkJDgTUGRx3c6ICSEBOY5fyF5UwHI2kLl4cb9dpwQb+POhIj3YACm8Z0OCAkhgXnOU0ghoh+Ny7aRVZSz1HA+d6cZDWT54uSlo9SnTp3Svpa9TMnKynI+dAdQ2PhOB4SEkMA8F0ZIABcvvtMBISEkMA9CAgiO73RASAgJzIOQAILjOx0QEkIC8yAkgOD4TgeEhJDAPAgJIDi+0wEhISQwD0ICCI7vdEBICAnM4yskYffu3WsBSjwyEbxzwwYhISQwT0FCAoAgICSEBOZBSABhgJAQEpgHIQGEAUJCSGAehAQQBggJIYF5EBJAGCAkhATmQUgAYYCQEBKYByEBhAFCQkhgHoQEEAYICSGBeXxvbAoAwXFui1xiQUhgnry8vKNHj86ePXs6AITAjBkzZMqU8FtEzp8/HyFBoZCbmyvrpN8AIARkssiU8c6iksSPP/7Ytm3b/w+1PExEITzB1gAAAABJRU5ErkJggg==>

[image2]: <data:image/png;base64,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>

[image3]: <data:image/png;base64,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>
