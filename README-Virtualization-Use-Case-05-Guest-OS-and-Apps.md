{% raw %}
<div class="guide-header">

<h1>Guest OS and application configuration</h1>

<span class="guide-type-badge guide-type-badge--use-case"><i class="fas fa-layer-group" aria-hidden="true"></i> Virtualization Use Case</span>

</div>

<style>
  div#toc {
    display: none;
  }
</style>

## Overview

After the VM exists on OpenShift Virtualization, use Ansible to optimize the guest (tools, OS settings) and install applications with native Linux or Windows modules. Network, DNS, load balancers, firewalls, and ITSM updates can ride the same workflow so day-1 state matches intent.

**Maturity:** Walk (Initial Deployment). **Customer question:** How do we configure guests and deploy apps without day-1 drift?

Start from the [Common virtualization automation use cases hub](virtualization-use-cases.md) or the foundational [Virtualization automation with Ansible](README-Virtualization.md) guide.

## Background

AVA 301 separates OpenShift Virtualization automation (provision) from guest and infra automation (optimize / install application / orchestration). This use case covers guest and application day-1 configuration.

## Solution

- **Ansible Automation Platform** with guest credentials (SSH/WinRM)
- **Dynamic inventory** from OpenShift Virtualization / kubevirt
- **Linux and Windows modules** plus optional ITSM / DNS / firewall jobs

### Who Benefits

| Persona | Challenge | What They Gain |
|---------|-----------|----------------|
| **App owners** | Golden image drift after create | Repeatable guest and app playbooks |
| **Virt admins** | Manual guest tooling | Automated optimize step after provision |
| **Ops** | Infra and CMDB out of sync | Orchestrated ITSM and network follow-ons |

## Prerequisites

- Reachable guests from the execution environment
- Inventory source for OpenShift Virtualization VMs

## Workflow

```mermaid
graph LR
  VM([VM Running]) --> Guest[Guest config job]
  Guest --> App[Application deploy]
  App --> Infra([DNS / ITSM / firewall])
```

## Solution Walkthrough

### Step 1: Build dynamic inventory from kubevirt

Target only the VMs in the wave or namespace you just provisioned or migrated.

### Step 2: Apply guest optimize and baseline config

Tools, hardening baselines, and OS settings as code.

### Step 3: Deploy applications and notify dependent systems

Install services; update DNS, load balancers, or ITSM as required.

## Validation

### Test

```bash
ansible -i inventories/virt-lab.yml all -m ping
```

### Expected Result

```
Guest ping succeeds; configure/app job completes with failed=0 and desired packages or services present.
```

### Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Unreachable guest | Network policy or credential | Fix inventory vars and SSH/WinRM |
| Partial app install | Missing repos or EE packages | Align content and proxy settings |

## Maturity Path

| Maturity | For this use case |
|----------|-------------------|
| **Crawl** | Manual guest playbooks after create |
| **Walk** | Provision workflow chains guest + app |
| **Run** | Same content used for drift repair day-2 |

## Summary

**Guest OS and application configuration** is use case 5 -- day-1 intent enforced with the same Ansible skills used for migration.

## Next Steps

1. Return to [Virtualization automation with Ansible](README-Virtualization.md).
2. Browse [all nine use cases](virtualization-use-cases.md).
3. Continue with [Snapshot and backup management](README-Virtualization-Use-Case-06-Snapshot-and-Backup.md).
{% endraw %}
