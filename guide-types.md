---
layout: default
title: Guide Types
permalink: /guide-types/
inline_edit: true
---

<div class="hub-intro-row">
  <p class="guide-types-lead">AAP Guides are organized into two types. Each answers a different question for IT leaders and practitioners evaluating or deploying Ansible Automation Platform.</p>
  <div class="edit-link-wrap edit-link-wrap--catalog">
    <a href="https://github.com/ansible-tmm/solution-guides/edit/main/{{ page.path }}"
       target="_blank" class="edit-link">
      <i class="fas fa-pencil-alt" aria-hidden="true"></i>
      Edit on GitHub
    </a>
  </div>
</div>
<div class="guide-types-grid">
<section class="guide-type-panel guide-type-panel--solution">
  <div class="guide-type-panel__header">
    <span class="guide-type-badge guide-type-badge--solution"><i class="fas fa-check-circle" aria-hidden="true"></i> Solution Guide</span>
    <h2 id="solution-guides" class="guide-type-panel__title">Solution Guides</h2>
  </div>

  <p class="guide-type-panel__summary">Show <strong>AAP plus a partner</strong> solving a specific operational problem -- integrated reference architectures, not platform setup alone.</p>

  <dl class="guide-type-facts">
    <div class="guide-type-fact">
      <dt>Who they are for</dt>
      <dd>IT directors, operations leaders, and architects evaluating how Ansible fits a specific business problem.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What they cover</dt>
      <dd>Partner-focused reference architectures that show how Ansible Automation Platform solves a measurable operational challenge -- often alongside Splunk, ServiceNow, IBM Instana, Azure, or other technologies your organization already runs.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What you get</dt>
      <dd>A clear problem statement, business outcomes (such as lower MTTR or less manual triage), architecture diagrams, and a path from pilot to production.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>Examples</dt>
      <dd><a href="{{ '/README-AIOps' | relative_url }}">AIOps automation with Ansible</a>, <a href="{{ '/README-Instana-AIOps' | relative_url }}">automated incident remediation with IBM Instana</a>, <a href="{{ '/README-AIOps-Splunk-ITSI' | relative_url }}">AIOps with Splunk and Event-Driven Ansible</a>.</dd>
    </div>
  </dl>

  <a href="{{ '/' | relative_url }}" class="guide-type-panel__cta">Browse Solution Guides</a>
</section>

<section class="guide-type-panel guide-type-panel--implementation">
  <div class="guide-type-panel__header">
    <span class="guide-type-badge guide-type-badge--implementation"><i class="fas fa-cogs" aria-hidden="true"></i> Implementation Guide</span>
    <h2 id="implementation-guides" class="guide-type-panel__title">Implementation Guides</h2>
  </div>

  <p class="guide-type-panel__summary">Show <strong>how</strong> -- the platform configuration that makes those outcomes reliable in production.</p>

  <dl class="guide-type-facts">
    <div class="guide-type-fact">
      <dt>Who they are for</dt>
      <dd>Platform owners, infrastructure leads, and senior automation engineers responsible for deploying and operating AAP in production.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What they cover</dt>
      <dd>How to configure Ansible Automation Platform for reliability, performance, and scale -- high availability, disaster recovery, database tuning, developer tooling, and platform hardening patterns that apply regardless of which integrations you adopt later.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What you get</dt>
      <dd>Architecture decisions, prerequisites, step-by-step walkthroughs, validation tests, and troubleshooting guidance you can hand to an implementation team.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>Examples</dt>
      <dd><a href="{{ '/README-AAP-HA-DR-OpenShift' | relative_url }}">AAP HA/DR on OpenShift with CloudNativePG</a>, <a href="{{ '/README-AAP-PostgreSQL-Autovacuum-Tuning' | relative_url }}">PostgreSQL autovacuum tuning</a>, <a href="{{ '/README-IA' | relative_url }}">AI infrastructure automation with Ansible</a>.</dd>
    </div>
  </dl>

  <a href="{{ '/' | relative_url }}#implementation-guides" class="guide-type-panel__cta">Browse Implementation Guides</a>
</section>
</div>
<section class="guide-types-tracks">
  <h2 id="solution-guide-categories" class="guide-types-tracks__title">Solution Guide categories</h2>
  <p class="guide-type-panel__tracks-intro">Solution Guides are grouped into <strong>categories</strong> by domain: AIOps and Network automation. All categories use the same guide framework, validation expectations, and maturity path structure. Within a category, one guide may carry a <strong>Foundational</strong> badge -- start there before partner integrations (today: <a href="{{ '/README-AIOps' | relative_url }}">AIOps automation with Ansible</a>, including <a href="{{ '/README-AIOps' | relative_url }}#common-aiops-use-cases">six operational use cases</a> and Crawl/Walk/Run).</p>

  <div class="guide-type-tracks">
    <article class="guide-type-track guide-type-track--aiops">
      <div class="guide-type-track__header">
        <span class="guide-type-track__badge">AIOps</span>
        <h3 id="aiops-solutions" class="guide-type-track__title"><a href="{{ '/' | relative_url }}#aiops-solutions">AIOps Solutions</a></h3>
      </div>
      <p class="guide-type-track__body">Partner integrations where <strong>AI inference, Automation code assistant, or MCP</strong> augments detection, diagnosis, and remediation. Use these when the outcome depends on intelligent triage, enrichment, or governed playbook selection.</p>
      <div class="guide-type-track__examples">
        <span class="guide-type-track__examples-label">Examples</span>
        <div class="guide-type-track__pills">
          <a href="{{ '/README-AIOps' | relative_url }}" class="guide-type-example-pill">AIOps automation with Ansible</a>
          <a href="{{ '/README-AIOps-Splunk-ITSI' | relative_url }}" class="guide-type-example-pill">AIOps with Splunk and Event-Driven Ansible</a>
          <a href="{{ '/README-AIOps-ServiceNow' | relative_url }}" class="guide-type-example-pill">Unlock AIOps with ServiceNow LEAP and Ansible MCP server</a>
        </div>
      </div>
    </article>

    <article class="guide-type-track guide-type-track--network">
      <div class="guide-type-track__header">
        <span class="guide-type-track__badge">Network</span>
        <h3 id="network-automation" class="guide-type-track__title"><a href="{{ '/' | relative_url }}#network-automation">Network automation</a></h3>
      </div>
      <p class="guide-type-track__body">Partner integrations for <strong>network source of truth, configuration, and failover</strong> with Ansible Automation Platform. Use these when NetBox (or similar) inventory and intent should drive device config, provisioning, or circuit recovery -- with Event-Driven Ansible when state changes should trigger governed execution.</p>
      <div class="guide-type-track__examples">
        <span class="guide-type-track__examples-label">Examples</span>
        <div class="guide-type-track__pills">
          <a href="{{ '/README-NetBox-WAN-EDA-Failover' | relative_url }}" class="guide-type-example-pill">Event-driven WAN circuit failover with NetBox and AAP</a>
          <a href="{{ '/README-NetBox-SoT-EDA-Config' | relative_url }}" class="guide-type-example-pill">Event-driven network source of truth with NetBox and AAP</a>
        </div>
      </div>
    </article>
  </div>
</section>
