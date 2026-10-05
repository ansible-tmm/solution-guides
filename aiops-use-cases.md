---
layout: default
title: Common AIOps Use Cases
permalink: /aiops-use-cases/
inline_edit: true
---

<div class="hub-intro-row">
  <div>
    <h1>Common AIOps Use Cases</h1>
    <p class="guide-types-lead">Vendor-neutral adoption patterns for technical customer conversations after the initial AIOps pitch. AI identifies opportunities; automation delivers outcomes.</p>
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
> AIOps Use Cases explain **when** Event-Driven Ansible, AI enrichment, and Automation orchestrator earn their place for a given operational pattern. They are **not** partner Solution Guides. Partner technologies may appear as examples; start with the [foundational AIOps Solution Guide](README-AIOps.md) for the reference architecture, then open partner integrations from each use case's Related Guides section.

## Crawl, Walk, Run

| Maturity | Focus | Use cases |
|----------|--------|-----------|
| **Crawl** | Build visibility and enrich insights | [Incident and Ticket Enrichment](README-AIOps-Use-Case-01-Incident-Ticket-Enrichment.md), [Cost and Resource Optimization](README-AIOps-Use-Case-02-Cost-Resource-Optimization.md) |
| **Walk** | Orchestrate and automate with intelligence | [Intelligent Capacity Orchestration](README-AIOps-Use-Case-03-Intelligent-Capacity-Orchestration.md), [Curated Automation Remediation](README-AIOps-Use-Case-04-Curated-Automation-Remediation.md) |
| **Run** | Autonomous operations and continuous enforcement | [System-Level Drift and Policy Enforcement](README-AIOps-Use-Case-05-System-Drift-Policy-Enforcement.md), [Self-healing infrastructure](README-AIOps-Use-Case-06-Self-Healing-Infrastructure.md) |

The two **Run** links above are separate conversation topics (prevent drift vs close the break-fix loop), not a mandatory sequence.

**Self-healing (use case 6)** models curated Run execution from an approved library; the optional multi-LLM workshop appendix on that page is for lab and policy-governed exceptions only.

## How work starts

Workflows can begin from a human request, an observability event, an ITSM ticket, or a scheduled review. The use case describes the **pattern**; the entry point depends on the customer environment.

<img src="{{ '/assets/images/how-work-starts.png' | relative_url }}" alt="How work starts: human, event, ticket, and scheduled paths converge on Ansible Automation Platform execution" class="guide-how-work-starts">

## All six use cases

<div class="cards-track-section cards-track-section--use-cases cards-track-section--use-cases-hub">
<nav class="use-case-strip" aria-label="AIOps use cases">
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-01-Incident-Ticket-Enrichment' | relative_url }}">
  <span class="use-case-strip__num">1</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Incident and Ticket Enrichment</span>
    <span class="use-case-strip__question">How do we stop wasting time just figuring out what happened?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-02-Cost-Resource-Optimization' | relative_url }}">
  <span class="use-case-strip__num">2</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Cost and Resource Optimization</span>
    <span class="use-case-strip__question">How do we identify wasted capacity before it becomes an operational problem?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--crawl">Crawl</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-03-Intelligent-Capacity-Orchestration' | relative_url }}">
  <span class="use-case-strip__num">3</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Intelligent Capacity Orchestration</span>
    <span class="use-case-strip__question">How do we anticipate capacity needs across hybrid environments?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-04-Curated-Automation-Remediation' | relative_url }}">
  <span class="use-case-strip__num">4</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Curated Automation Remediation</span>
    <span class="use-case-strip__question">How do we remediate faster using automation teams already trust?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--walk">Walk</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-05-System-Drift-Policy-Enforcement' | relative_url }}">
  <span class="use-case-strip__num">5</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">System-Level Drift and Policy Enforcement</span>
    <span class="use-case-strip__question">How do we prevent slow failure and risk accumulation in the first place?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
<a class="use-case-strip__item" href="{{ '/README-AIOps-Use-Case-06-Self-Healing-Infrastructure' | relative_url }}">
  <span class="use-case-strip__num">6</span>
  <span class="use-case-strip__body">
    <span class="use-case-strip__title">Self-healing infrastructure</span>
    <span class="use-case-strip__question">What do we do when something breaks, end to end?</span>
  </span>
  <span class="use-case-maturity-chip use-case-maturity-chip--run">Run</span>
</a>
</nav>
</div>

## How this relates to Solution Guides

1. Read [AIOps automation with Ansible](README-AIOps.md) for the end-to-end reference architecture (EDA, inference, MCP, governed execution).
2. Pick the **use case** that matches the customer's operational question (table above).
3. Follow **Related Guides** on that use case page for partner-specific depth (Splunk, ServiceNow, Azure, AWS, Instana, and others).

Solution Guides answer "how does AAP plus a partner solve X?" Use cases answer "which pattern are we selling, and when does each platform layer matter?"

## Browse the catalog

Return to the [Solution Guides catalog]({{ '/' | relative_url }}#aiops-solutions) for partner integrations, or filter by partner on the homepage.
