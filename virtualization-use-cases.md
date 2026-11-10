---
layout: default
title: Common virtualization automation use cases
permalink: /virtualization-use-cases/
inline_edit: true
---

<div class="hub-intro-row">
  <div>
    <h1>Common virtualization automation use cases</h1>
    <p class="guide-types-lead">Ansible Automation Platform for OpenShift Virtualization -- Migration / Initial Deployment / Day-2 patterns for technical customer conversations after the initial virtualization automation pitch.</p>
  </div>
  <div class="edit-link-wrap edit-link-wrap--catalog">
    <a href="https://github.com/ansible-tmm/solution-guides/edit/main/{{ page.path }}"
       target="_blank" class="edit-link">
      <i class="fas fa-pencil-alt" aria-hidden="true"></i>
      Edit on GitHub
    </a>
  </div>
</div>

> **What these pages are for.**
>
> Virtualization Use Cases explain **when** discovery, MTV orchestration, provisioning, guest configuration, snapshots, patching, lifecycle, and event-driven remediation earn their place. They are **not** partner Solution Guides. Start with the [foundational Virtualization automation Solution Guide](README-Virtualization.md), then open deeper guides such as [Self-healing VMs on OpenShift](README-Self-Healing-VMs-OpenShift.md) from the [Solution Guides catalog]({{ '/' | relative_url }}#virtualization).

## Crawl, Walk, Run

| Maturity | Lifecycle phase | Focus | Use cases |
|----------|-----------------|--------|-----------|
| **Crawl** | Migration | Discover, validate, orchestrate MTV | [Discover and analyze](README-Virtualization-Use-Case-01-Discover-and-Analyze.md), [Pre-migration validation](README-Virtualization-Use-Case-02-Pre-Migration-Validation.md), [MTV migration orchestration](README-Virtualization-Use-Case-03-MTV-Migration-Orchestration.md) |
| **Walk** | Initial Deployment | Provision and configure without drift | [VM provisioning workflows](README-Virtualization-Use-Case-04-VM-Provisioning.md), [Guest OS and application configuration](README-Virtualization-Use-Case-05-Guest-OS-and-Apps.md), [Snapshot and backup management](README-Virtualization-Use-Case-06-Snapshot-and-Backup.md) |
| **Run** | Day-2 Operations | Patch, lifecycle, event-driven healing | [Patch and package management](README-Virtualization-Use-Case-07-Patch-and-Package-Management.md), [Lifecycle management](README-Virtualization-Use-Case-08-Lifecycle-Management.md), [Event-driven remediation](README-Virtualization-Use-Case-09-Event-Driven-Remediation.md) |

## All nine use cases

<div class="cards-track-section cards-track-section--use-cases cards-track-section--use-cases-hub">
<nav class="use-case-strip" aria-label="Virtualization automation use cases">
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-01-Discover-and-Analyze' | relative_url }}">
  <span class="use-case-strip__num">1</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Discover and analyze</span>
    <span class="use-case-strip__question">How do we inventory VMware and hardware before migration waves?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-02-Pre-Migration-Validation' | relative_url }}">
  <span class="use-case-strip__num">2</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Pre-migration validation</span>
    <span class="use-case-strip__question">How do we prove target readiness and MTV prerequisites before cutover?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-03-MTV-Migration-Orchestration' | relative_url }}">
  <span class="use-case-strip__num">3</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">MTV migration orchestration</span>
    <span class="use-case-strip__question">How do we run the same migration plan across clusters without UI mistakes?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-04-VM-Provisioning' | relative_url }}">
  <span class="use-case-strip__num">4</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">VM provisioning workflows</span>
    <span class="use-case-strip__question">How do we self-service create VMs on OpenShift Virtualization with approvals?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-05-Guest-OS-and-Apps' | relative_url }}">
  <span class="use-case-strip__num">5</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Guest OS and application configuration</span>
    <span class="use-case-strip__question">How do we configure guests and deploy apps without day-1 drift?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-06-Snapshot-and-Backup' | relative_url }}">
  <span class="use-case-strip__num">6</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Snapshot and backup management</span>
    <span class="use-case-strip__question">How do we create, manage, and restore VM snapshots consistently?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-07-Patch-and-Package-Management' | relative_url }}">
  <span class="use-case-strip__num">7</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Patch and package management</span>
    <span class="use-case-strip__question">How do we patch guest VMs inside maintenance windows with audit proof?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-08-Lifecycle-Management' | relative_url }}">
  <span class="use-case-strip__num">8</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Lifecycle management</span>
    <span class="use-case-strip__question">How do we power, scale, and reconfigure NICs and storage on running VMs?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Virtualization-Use-Case-09-Event-Driven-Remediation' | relative_url }}">
  <span class="use-case-strip__num">9</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Event-driven remediation</span>
    <span class="use-case-strip__question">How do platform and monitoring events drive governed VM auto-remediation?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
</nav>
</div>
