---
layout: default
title: Common security automation use cases
permalink: /security-use-cases/
inline_edit: true
---

<div class="hub-intro-row">
  <div>
    <h1>Common security automation use cases</h1>
    <p class="guide-types-lead">Security automation in the AI era -- Crawl / Walk / Run patterns for technical customer conversations after the initial security automation pitch.</p>
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
> Security Use Cases explain **when** compliance assessment, exposure reporting, patching, mitigation, hardening, Zero Trust deploy, orchestrated incident response, and orchestrated patching earn their place. They are **not** partner Solution Guides. Partner technologies may appear as examples; start with the [foundational Security automation Solution Guide](README-Security-Automation.md), then open partner integrations from the [Solution Guides catalog]({{ '/' | relative_url }}#security-automation).

## Crawl, Walk, Run

| Maturity | Focus | Use cases |
|----------|--------|-----------|
| **Crawl** | Assess, report, and patch with trust | [Compliance](README-Security-Use-Case-01-Compliance.md), [Exposure reporting](README-Security-Use-Case-02-Exposure-Reporting.md), [Patching](README-Security-Use-Case-03-Patching.md) |
| **Walk** | Mitigate, harden, enforce at deploy | [Mitigation before patching](README-Security-Use-Case-04-Mitigation-Before-Patching.md), [Establish hardening baselines](README-Security-Use-Case-05-Hardening-Baselines.md), [Application deployment with Zero Trust](README-Security-Use-Case-06-Zero-Trust-App-Deployment.md) |
| **Run** | Orchestrate response and end-to-end patch | [Orchestrated incident response](README-Security-Use-Case-07-Orchestrated-Incident-Response.md), [Orchestrated patching across infrastructure](README-Security-Use-Case-08-Orchestrated-Patching.md) |

## All eight use cases

<div class="cards-track-section cards-track-section--use-cases cards-track-section--use-cases-hub">
<nav class="use-case-strip" aria-label="Security automation use cases">
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-01-Compliance' | relative_url }}">
  <span class="use-case-strip__num">1</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Compliance</span>
    <span class="use-case-strip__question">How do we assess STIG/CIS posture and cryptographic exposure continuously?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-02-Exposure-Reporting' | relative_url }}">
  <span class="use-case-strip__num">2</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Exposure reporting</span>
    <span class="use-case-strip__question">How do we turn CVE notifications into SBOM-aware reports for ITSM?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-03-Patching' | relative_url }}">
  <span class="use-case-strip__num">3</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Patching</span>
    <span class="use-case-strip__question">How do we deploy trusted patches on RHEL and Windows with audit proof?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-04-Mitigation-Before-Patching' | relative_url }}">
  <span class="use-case-strip__num">4</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Mitigation before patching</span>
    <span class="use-case-strip__question">How do we lower exploitability while waiting for a patch window?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-05-Hardening-Baselines' | relative_url }}">
  <span class="use-case-strip__num">5</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Establish hardening baselines</span>
    <span class="use-case-strip__question">How do we enforce STIG/CIS hardening at scale from scan results?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-06-Zero-Trust-App-Deployment' | relative_url }}">
  <span class="use-case-strip__num">6</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Application deployment with Zero Trust</span>
    <span class="use-case-strip__question">How does AAP act as a policy enforcement point at deploy time?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-07-Orchestrated-Incident-Response' | relative_url }}">
  <span class="use-case-strip__num">7</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Orchestrated incident response</span>
    <span class="use-case-strip__question">How do SIEM events drive coordinated firewall, Vault, and infra changes?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-Security-Use-Case-08-Orchestrated-Patching' | relative_url }}">
  <span class="use-case-strip__num">8</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Orchestrated patching across infrastructure</span>
    <span class="use-case-strip__question">How do we correlate SBOM risk, mitigate, patch, and validate end to end?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
</nav>
</div>
