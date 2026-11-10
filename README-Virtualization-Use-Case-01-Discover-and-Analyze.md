{% raw %}
<div class="guide-header">

<h1>Discover and analyze</h1>

<span class="guide-type-badge guide-type-badge--use-case"><i class="fas fa-layer-group" aria-hidden="true"></i> Virtualization Use Case</span>

</div>

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

Inventory your VMware environment and supporting hardware with Ansible before migration waves. Pull configuration facts from VMware vCenter and, where useful, Dell iDRAC or Redfish-compatible BIOS so reusable facts drive planning -- not spreadsheets.

**Maturity:** Crawl (Migration). **Customer question:** How do we inventory VMware and hardware before migration waves?

Start from the [Common virtualization automation use cases hub](virtualization-use-cases.md) or the foundational [Virtualization automation with Ansible](README-Virtualization.md) guide.

## Background

This page is a scaffold aligned to the Ansible OpenShift Virtualization Automation (AVA 301) technical deck. Expand with workflow diagrams, validation commands, and collection deep links as the pattern hardens.

## Solution

- **Ansible Automation Platform** for governed discovery jobs and reusable facts
- **VMware and hardware collections** for vCenter and Redfish-style inventory
- **OpenShift Virtualization / MTV planning inputs** as downstream consumers of those facts

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **Migration Team** | Unknown estate size and config drift | Facts-driven inventories for wave planning |
| **Platform Architect** | Manual discovery that goes stale | Scheduled AAP discovery with audit history |
| **Leadership** | Unclear migration scope | Measurable inventory before commit |

## Prerequisites

- Ansible Automation Platform with VMware (and optional hardware) credentials
- Lab or pilot vSphere inventory for first runs

## Workflow

```mermaid
graph LR
  Trigger([Schedule or manual]) --> Discover[AAP discovery job]
  Discover --> Facts[(Reusable facts)]
  Facts --> Plan([Migration waves])
```

## Solution Walkthrough

> **Scaffold:** Add playbook examples from the AVA 301 deck in a follow-up pass.

### Step 1: Connect credentials for vSphere (and hardware APIs)

Document which facts you need for MTV mapping and wave design.

### Step 2: Publish an approved discovery job template

Expose inventory and fact collection in Controller with RBAC.

### Step 3: Validate on a pilot cluster or datacenter

Run against a non-production scope; review fact quality before production waves.

## Validation

### Test

```bash
ansible-inventory -i inventories/virt-lab.yml --graph
```

### Expected Result

```
Pilot inventory lists expected VMware hosts or VMs; discovery job completes with failed=0.
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Auth failures to vCenter | Credential or permission | Fix Controller credential and role |
| Empty facts | Wrong inventory plugin or filter | Align plugin options with namespaces or clusters |

## Maturity Path

| Maturity | For this use case |
|----------|-------------------|
| **Crawl** | One-time or scheduled discovery feeding migration plans |
| **Walk** | Facts also drive provisioning and CMDB sync |
| **Run** | Continuous estate awareness into day-2 automation |

## Summary

**Discover and analyze** is use case 1 in the Virtualization foundational set -- the Assess step of automate once, benefit always.

## Next Steps

1. Return to [Virtualization automation with Ansible](README-Virtualization.md).
2. Browse [all nine use cases](virtualization-use-cases.md).
3. Continue with [Pre-migration validation](README-Virtualization-Use-Case-02-Pre-Migration-Validation.md).
{% endraw %}
