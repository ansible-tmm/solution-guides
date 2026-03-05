# Plan: Document Splunk AIOps Use Cases (RHEL + Network)

## Status: Implemented

## Context

The [`README-AIOps-Splunk.md`](https://github.com/ansible-tmm/solution-guides/blob/main/README-AIOps-Splunk.md) was a conceptual guide using a RHEL server-based use case (httpd service remediation) with placeholder URLs and example domains. A **working, tested** Splunk use case exists in the [ai-driven-automation-showroom](https://github.com/rhpds/ai-driven-automation-showroom) repo — a network automation AIOps pipeline that detects Cisco OSPF failures via Splunk, triggers EDA, generates remediation with Lightspeed, and applies fixes through an approval-gated workflow.

The guide was enhanced to cover **both use cases** — keeping the RHEL server scenario and adding the network AIOps scenario — while meeting the [best practices framework](https://github.com/ansible-tmm/solution-guides/blob/main/README-best-practices.md).

## What Was Done

### Shared Sections

- **Overview** updated to introduce both use cases (RHEL + Network)
- **Background** expanded with paragraph on network ops gap
- **Persona table** expanded with Network Engineer role
- **Prerequisites** updated: added `cisco.ios` and `servicenow.itsm` collections; external systems table split by use case
- **Architecture** notes that the same Splunk -> EDA -> AAP pattern works across both domains

### Track A: RHEL Server Remediation (improved)

- Replaced `example.com` placeholders with descriptive `<eda-controller-host>` and `<splunk-host>` patterns
- Added ServiceNow ticket creation (`servicenow.itsm.incident`) to match the network track's enrichment pattern
- Fixed generic task names (e.g., `Send to Red Hat AI for analysis` -> `Send diagnostics to Red Hat AI for root cause analysis`)

### Track B: Network AIOps (new)

1. **B1: Splunk network event detection** — TCP data input config (port 5514, `cisco:ios`), saved search for OSPF neighbor down, alert with webhook
2. **B2: EDA rulebook** — Full `ospf.yml` from [ansible-tmm/aiops-summitlab](https://github.com/ansible-tmm/aiops-summitlab) with `search_name == 'ospf-neighbor'` condition
3. **B3: AI-driven ticket enrichment** — Collects router diagnostics via `cisco.ios.ios_command` (`show ip ospf neighbor`, `show interface Tunnel0`, `show ip ospf interface Tunnel0`), analyzes with `redhat.ai.completion`, creates enriched ServiceNow incident, updates Splunk notable event with AI diagnosis and incident number, notifies ops channel
4. **B4: Lightspeed remediation workflow** — Shows Scenario 1 prompt only (simplest case), links to full playbook on GitHub for Scenarios 2-3; describes check mode, human approval gate, and run mode execution
5. **B5: Three OSPF failure scenarios** — Interface shutdown, wrong network type, hello timer mismatch — each with trigger, detection, AI diagnosis, fix, and verification

### Shared Closing Sections

- **Troubleshooting** table expanded with network-specific entries (credential issues, check-mode no changes, case-sensitive search_name matching)
- **Maturity path** maps both tracks to Crawl/Walk/Run
- **Validation** includes curl tests for both RHEL and network use cases

## Key Design Decisions

- **ServiceNow in both tracks**: Both RHEL and network enrichment steps create ServiceNow incidents, making the pattern consistent — the engineer sees an AI-enriched ticket regardless of infrastructure domain
- **Lightspeed prompt simplified**: Only Scenario 1 prompt shown inline; full cumulative prompt linked to GitHub to avoid overwhelming the reader
- **Descriptive task names**: All `ansible.builtin.*` tasks use names that describe what they do, not generic labels like "Send request to AI API"

## Key Content Sources

| Content | Source |
|---------|--------|
| RHEL use case | Existing [`README-AIOps-Splunk.md`](https://github.com/ansible-tmm/solution-guides/blob/main/README-AIOps-Splunk.md) (improved) |
| Network use case YAML | [ansible-tmm/aiops-summitlab](https://github.com/ansible-tmm/aiops-summitlab) (`rulebooks/ospf.yml`, `playbooks/network_aiops.yml`) |
| Network walkthrough | [showroom modules 02-04](https://github.com/rhpds/ai-driven-automation-showroom/tree/main/content/modules/ROOT/pages) |
| Ticket enrichment pattern | [AIOps guide enrichment workflow](https://github.com/ansible-tmm/solution-guides/blob/main/README-AIOps.md) |
| Best practices structure | [`README-best-practices.md`](https://github.com/ansible-tmm/solution-guides/blob/main/README-best-practices.md) |
