---
layout: default
title: Common network automation use cases
permalink: /network-use-cases/
inline_edit: true
---

<div class="hub-intro-row">
  <div>
    <h1>Common network automation use cases</h1>
    <p class="guide-types-lead">NetOps as Code patterns for technical customer conversations after the initial network automation pitch. Start small, think big -- Opportunistic to Institutionalized, mapped to Crawl / Walk / Run.</p>
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
> Network Use Cases explain **when** backup, facts, hygiene, SoT, compliance, health checks, upgrades, Event-Driven Ansible troubleshooting, and device lifecycle earn their place. They are **not** partner Solution Guides. Partner technologies may appear as examples; start with the [foundational Network automation Solution Guide](README-Network-Automation.md), then open partner integrations from the [Solution Guides catalog]({{ '/' | relative_url }}#network-automation).

## Crawl, Walk, Run

| Maturity | Journey stage | Focus | Use cases |
|----------|---------------|--------|-----------|
| **Crawl** | Opportunistic | Simplify a task or set of tasks | [Configuration backup and restore](README-Network-Use-Case-01-Config-Backup-Restore.md), [Inventory audits and reports](README-Network-Use-Case-02-Inventory-Audits-Reports.md), [Configuration hygiene](README-Network-Use-Case-03-Configuration-Hygiene.md) |
| **Walk** | Systematic | Centralize processes | [Network compliance and drift](README-Network-Use-Case-04-Compliance-Drift.md), [Apply sources of truth](README-Network-Use-Case-05-Sources-of-Truth.md), [Network health checks](README-Network-Use-Case-06-Network-Health-Checks.md) |
| **Run** | Institutionalized | Orchestrate processes | [Network OS upgrades](README-Network-Use-Case-07-Network-OS-Upgrades.md), [Event-driven troubleshooting](README-Network-Use-Case-08-Event-Driven-Troubleshooting.md), [Provisioning, retirement, and migration](README-Network-Use-Case-09-Provisioning-Retirement-Migration.md) |

## Network automation journey

<img src="{{ '/assets/images/network-automation-journey.png' | relative_url }}" alt="Network automation journey: Opportunistic, Systematic, and Institutionalized -- start small, think big" class="guide-how-work-starts">

## All nine use cases

<div class="cards-track-section cards-track-section--use-cases cards-track-section--use-cases-hub">
<nav class="use-case-strip" aria-label="Network automation use cases">
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-01-Config-Backup-Restore' | relative_url }}">
  <span class="use-case-strip__num">1</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Configuration backup and restore</span>
    <span class="use-case-strip__question">How do we recover network steady state without CLI heroics?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-02-Inventory-Audits-Reports' | relative_url }}">
  <span class="use-case-strip__num">2</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Inventory audits and reports</span>
    <span class="use-case-strip__question">How do we know what is actually on the network?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-03-Configuration-Hygiene' | relative_url }}">
  <span class="use-case-strip__num">3</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Configuration hygiene</span>
    <span class="use-case-strip__question">How do we standardize VLANs, ACLs, and SNMP without a big-bang rewrite?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-04-Compliance-Drift' | relative_url }}">
  <span class="use-case-strip__num">4</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Network compliance and drift</span>
    <span class="use-case-strip__question">How do we enforce security and config policy consistently?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-05-Sources-of-Truth' | relative_url }}">
  <span class="use-case-strip__num">5</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Apply sources of truth</span>
    <span class="use-case-strip__question">How do we make NetOps data-centric with GitOps and IPAM?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-06-Network-Health-Checks' | relative_url }}">
  <span class="use-case-strip__num">6</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Network health checks</span>
    <span class="use-case-strip__question">How do we validate operational state beyond the running config?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-07-Network-OS-Upgrades' | relative_url }}">
  <span class="use-case-strip__num">7</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Network OS upgrades</span>
    <span class="use-case-strip__question">How do we upgrade NOS fleets consistently with pre and post checks?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-08-Event-Driven-Troubleshooting' | relative_url }}">
  <span class="use-case-strip__num">8</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Event-driven troubleshooting</span>
    <span class="use-case-strip__question">How do we troubleshoot from monitoring events in near real time?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Network-Use-Case-09-Provisioning-Retirement-Migration' | relative_url }}">
  <span class="use-case-strip__num">9</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Provisioning, retirement, and migration</span>
    <span class="use-case-strip__question">How do we automate device lifecycle instead of one-off cutovers?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
</nav>
</div>
