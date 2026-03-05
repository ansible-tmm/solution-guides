---
layout: default
title: Solution Guides
patternfly: true
---

<div class="cards-hero">
  <h1>Solution Guides</h1>
  <p>Enterprise solution guides for AI-driven automation with Ansible Automation Platform.</p>
</div>

<div class="cards-search">
  <div class="cards-search__input-wrapper">
    <i class="fas fa-search cards-search__icon"></i>
    <input type="text" id="guide-search" class="cards-search__input" placeholder="Filter guides — try &quot;Splunk&quot;, &quot;ServiceNow&quot;, &quot;EDA&quot;, &quot;network&quot;..." autocomplete="off">
    <button id="guide-search-clear" class="cards-search__clear" aria-label="Clear search">&times;</button>
  </div>
  <p id="guide-search-count" class="cards-search__count"></p>
</div>

<div class="pf-v6-l-gallery pf-m-gutter cards-gallery" id="main-gallery">

  <a href="{{ '/README-AIOps' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-green">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
            Solution Guide
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">AIOps automation with Ansible</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Self-healing infrastructure using Event-Driven Ansible, Red Hat AI inference, and Ansible Lightspeed to detect, diagnose, and remediate incidents automatically.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">AIOps</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">EDA</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Red Hat AI</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Lightspeed</span></span>
      </div>
    </div>
  </a>

  <a href="{{ '/README-Instana-AIOps' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-orange">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
            Work in Progress
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">Automated Incident Remediation with IBM Instana</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Closed-loop incident remediation integrating IBM Instana observability with Event-Driven Ansible for automatic detection, AI-driven job template routing, and self-healing infrastructure.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">AIOps</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Instana</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">EDA</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">IBM</span></span>
      </div>
    </div>
  </a>

  <a href="{{ '/README-AIOps-Splunk' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-green">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
            Solution Guide
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">Triggering Automated Remediation from Splunk Alerts</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Connect Splunk alerts to Event-Driven Ansible for closed-loop detection and remediation — from webhook configuration to AI-enriched response.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">AIOps</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Splunk</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">EDA</span></span>
      </div>
    </div>
  </a>

  <a href="{{ '/README-AIOps-ServiceNow' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-green">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
            Solution Guide
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">Reducing MTTR with ServiceNow Ticket Enrichment</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Automatically enrich ServiceNow incidents with diagnostic data and AI-driven root cause analysis — the lowest-risk entry point for AIOps.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">AIOps</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">ServiceNow</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">ITSM</span></span>
      </div>
    </div>
  </a>

  <a href="{{ '/README-IA' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-green">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
            Solution Guide
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">AI Infrastructure automation with Ansible</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Provision and configure Red Hat AI infrastructure — from GPU instances to serving models — using the infra.ai and redhat.ai collections.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Red Hat AI</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">InstructLab</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">GPU</span></span>
      </div>
    </div>
  </a>

  <a href="{{ '/README-Intelligent-Assistant-RHAIIS' | relative_url }}" class="card-link">
    <div class="pf-v6-c-card">
      <div class="pf-v6-c-card__header">
        <span class="pf-v6-c-label pf-m-green">
          <span class="pf-v6-c-label__content">
            <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
            Solution Guide
          </span>
        </span>
      </div>
      <div class="pf-v6-c-card__title">
        <h3 class="pf-v6-c-card__title-text">Intelligent Assistant with Red Hat AI Inference Server</h3>
      </div>
      <div class="pf-v6-c-card__body">
        Deploy and configure a self-hosted LLM using Red Hat AI Inference Server on RHEL with GPU acceleration to power the Ansible Lightspeed intelligent assistant in AAP.
      </div>
      <div class="pf-v6-c-card__footer">
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Lightspeed</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">RHAIIS</span></span>
        <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">GPU</span></span>
      </div>
    </div>
  </a>

</div>

<div class="cards-contributing">
  <h2>Contributing</h2>
  <p>Writing a new solution guide? Start with the <a href="{{ '/README-best-practices' | relative_url }}">Best Practices for Writing Solution Guides</a> — it includes the framework, quality scoring rubric, and a starter template.</p>
</div>

<details class="legacy-guides">
  <summary>Legacy Solution Guides (Under Review)</summary>
  <p>These solution guides were published on access.redhat.com before this repository existed. They are being reviewed and will be migrated to the new format as full markdown guides.</p>
  <div class="pf-v6-l-gallery pf-m-gutter cards-gallery">

    <a href="https://access.redhat.com/articles/7136383" class="card-link" target="_blank">
      <div class="pf-v6-c-card">
        <div class="pf-v6-c-card__title">
          <h3 class="pf-v6-c-card__title-text">Automation Dashboard and Analytics</h3>
        </div>
        <div class="pf-v6-c-card__body">
          Visualize automation ROI and operational metrics with the AAP Dashboard and Automation Analytics.
        </div>
        <div class="pf-v6-c-card__footer">
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Analytics</span></span>
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Dashboard</span></span>
        </div>
      </div>
    </a>

    <a href="https://access.redhat.com/articles/7127603" class="card-link" target="_blank">
      <div class="pf-v6-c-card">
        <div class="pf-v6-c-card__title">
          <h3 class="pf-v6-c-card__title-text">ServiceNow ITSM Ticket Enrichment</h3>
        </div>
        <div class="pf-v6-c-card__body">
          Automate ServiceNow ticket creation and enrich incidents with CVE data from Red Hat Insights.
        </div>
        <div class="pf-v6-c-card__footer">
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">ServiceNow</span></span>
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">ITSM</span></span>
        </div>
      </div>
    </a>

    <a href="https://access.redhat.com/articles/7136720" class="card-link" target="_blank">
      <div class="pf-v6-c-card">
        <div class="pf-v6-c-card__title">
          <h3 class="pf-v6-c-card__title-text">Get started with EDA (Ansible Rulebook)</h3>
        </div>
        <div class="pf-v6-c-card__body">
          Fundamentals of Event-Driven Ansible — rulebooks, event sources, conditions, and actions.
        </div>
        <div class="pf-v6-c-card__footer">
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">EDA</span></span>
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Kafka</span></span>
        </div>
      </div>
    </a>

    <a href="https://access.redhat.com/articles/7123366" class="card-link" target="_blank">
      <div class="pf-v6-c-card">
        <div class="pf-v6-c-card__title">
          <h3 class="pf-v6-c-card__title-text">Network Back Up and Configuration</h3>
        </div>
        <div class="pf-v6-c-card__body">
          Backup, configure, and restore network devices using the network.backup validated content collection.
        </div>
        <div class="pf-v6-c-card__footer">
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Network</span></span>
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Cisco IOS</span></span>
        </div>
      </div>
    </a>

    <a href="https://access.redhat.com/articles/7123361" class="card-link" target="_blank">
      <div class="pf-v6-c-card">
        <div class="pf-v6-c-card__title">
          <h3 class="pf-v6-c-card__title-text">Network Fact Gathering & Reporting</h3>
        </div>
        <div class="pf-v6-c-card__body">
          Collect network device facts and export structured data for compliance reporting.
        </div>
        <div class="pf-v6-c-card__footer">
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Network</span></span>
          <span class="pf-v6-c-label pf-m-outline pf-m-compact"><span class="pf-v6-c-label__content">Reporting</span></span>
        </div>
      </div>
    </a>

  </div>
</details>

<script>
(function () {
  var input = document.getElementById('guide-search');
  var clearBtn = document.getElementById('guide-search-clear');
  var countEl = document.getElementById('guide-search-count');
  var allCards = document.querySelectorAll('.card-link');
  var legacyDetails = document.querySelector('details.legacy-guides');

  function getCardText(card) {
    var title = card.querySelector('.pf-v6-c-card__title-text');
    var body = card.querySelector('.pf-v6-c-card__body');
    var labels = card.querySelectorAll('.pf-v6-c-label__content');
    var text = '';
    if (title) text += ' ' + title.textContent;
    if (body) text += ' ' + body.textContent;
    labels.forEach(function (l) { text += ' ' + l.textContent; });
    return text.toLowerCase();
  }

  function filterCards() {
    var query = input.value.toLowerCase().trim();
    clearBtn.style.display = query ? 'block' : 'none';

    if (!query) {
      allCards.forEach(function (c) { c.style.display = ''; });
      countEl.textContent = '';
      if (legacyDetails) legacyDetails.removeAttribute('open');
      return;
    }

    var visible = 0;
    var legacyHasMatch = false;

    allCards.forEach(function (card) {
      var match = getCardText(card).indexOf(query) !== -1;
      card.style.display = match ? '' : 'none';
      if (match) {
        visible++;
        if (legacyDetails && legacyDetails.contains(card)) legacyHasMatch = true;
      }
    });

    if (legacyDetails) {
      if (legacyHasMatch) legacyDetails.setAttribute('open', '');
      else legacyDetails.removeAttribute('open');
    }

    countEl.textContent = visible === 0
      ? 'No guides match your search.'
      : visible + ' guide' + (visible !== 1 ? 's' : '') + ' found.';
  }

  input.addEventListener('input', filterCards);
  clearBtn.addEventListener('click', function () {
    input.value = '';
    filterCards();
    input.focus();
  });
})();
</script>
