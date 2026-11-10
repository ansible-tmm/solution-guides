{% raw %}
<div class="guide-header">

<h1>MTV migration orchestration</h1>

<span class="guide-type-badge guide-type-badge--use-case"><i class="fas fa-layer-group" aria-hidden="true"></i> Virtualization Use Case</span>

</div>

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

Orchestrate Migration Toolkit for Virtualization (MTV) plans with Ansible Automation Platform: create plans via API, apply the same plan across clusters, batch waves with dependency ordering, run automated cutover, and hook change management (for example ServiceNow approvals).

**Maturity:** Crawl (Migration). **Customer question:** How do we run the same migration plan across clusters without UI mistakes?

Start from the [Common virtualization automation use cases hub](virtualization-use-cases.md) or the foundational [Virtualization automation with Ansible](README-Virtualization.md) guide.

**Related content:** Migration collections such as `infra.openshift_virtualization_migration` in AVA labs and Hub.

## Background

MTV moves the data. AAP ensures the same migration plan runs identically across environments, pre-flight has passed, and post-migration validation happens automatically. This page scaffolds the AVA 301 migration automation story.

## Solution

- **Ansible Automation Platform** for multi-cluster orchestration and audit
- **MTV** for the migration data plane
- **ITSM** optional for approvals before execute

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **Migration Team** | UI clicking does not scale to 50+ clusters | Codified, reviewable plans in Git and AAP |
| **Automation Architect** | One-off scripts per wave | Shared workflows with surveys and RBAC |
| **Leadership** | Migration risk and headcount | Scale waves without proportional headcount |

## Prerequisites

- AAP, MTV, and target OpenShift Virtualization
- Successful [pre-migration validation](README-Virtualization-Use-Case-02-Pre-Migration-Validation.md) pattern

## Workflow

```mermaid
graph LR
  Wave([Migration wave]) --> AAP[AAP MTV workflow]
  AAP --> MTV[MTV plan execute]
  MTV --> Validate[Post-migration checks]
  Validate --> Evidence([Job + ITSM])
```

## Solution Walkthrough

### Step 1: Create MTV plans via API from AAP

Eliminate UI-only plan creation for production waves.

### Step 2: Orchestrate dependency-ordered batches

Migrate related VMs as waves with clear go/no-go gates.

### Step 3: Validate and record

Post-migration checks and AAP job history as the audit trail.

## Validation

### Test

```bash
# Confirm MTV and OpenShift access from the EE used by the migration job
oc get migration -A
```

### Expected Result

```
Lab MTV plan created and completed via AAP with failed=0; plan definition matches Git or survey inputs.
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Plan creation fails | Mapping or permission | Re-run pre-flight; fix RBAC |
| Wave stuck | Dependency or storage | Inspect MTV plan status; adjust ordering |

## Maturity Path

| Maturity | For this use case |
|----------|-------------------|
| **Crawl** | Single-cluster lab MTV via AAP |
| **Walk** | Multi-wave with ITSM approval |
| **Run** | Same plan pattern across many clusters |

## Summary

**MTV migration orchestration** is use case 3 -- streamlining migration so the same Ansible skills continue into production.

## Next Steps

1. Return to [Virtualization automation with Ansible](README-Virtualization.md).
2. Browse [all nine use cases](virtualization-use-cases.md).
3. Continue with [VM provisioning workflows](README-Virtualization-Use-Case-04-VM-Provisioning.md).
{% endraw %}
