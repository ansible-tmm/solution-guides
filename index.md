---
layout: default
title: AAP Guides
patternfly: true
---

<div class="cards-layout">
  <aside class="cards-sidebar">
    <div class="cards-sidebar__header">
      <span>Filter by</span>
      <button id="filter-clear" class="cards-sidebar__clear">Clear filters</button>
    </div>
    <div class="cards-sidebar__body">
    <div class="cards-sidebar__section">
      <h4 class="cards-sidebar__title">Browse</h4>
      <nav class="cards-sidebar__nav" aria-label="Guide sections">
        <a href="#solution-guides" class="cards-sidebar__jump">
          <i class="fas fa-chevron-right cards-sidebar__jump-icon" aria-hidden="true"></i>
          Solution Guides
        </a>
        <a href="#implementation-guides" class="cards-sidebar__jump">
          <i class="fas fa-chevron-right cards-sidebar__jump-icon" aria-hidden="true"></i>
          Implementation Guides
        </a>
      </nav>
      <p class="cards-sidebar__learn-more">
        <a href="{{ '/guide-types' | relative_url }}">About guide types</a>
      </p>
    </div>
    <div class="cards-sidebar__section">
      <h4 class="cards-sidebar__title">Categories</h4>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--track">
        <input type="checkbox" value="aiops"> AIOps
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--track">
        <input type="checkbox" value="network"> Network automation
      </label>
    </div>
    <div class="cards-sidebar__section">
      <h4 class="cards-sidebar__title">Partners</h4>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="aws"> AWS
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="azure"> Azure
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="cisco"> Cisco
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="cloudnativepg"> CloudNativePG
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="edb"> EDB PostgreSQL
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="instana"> IBM Instana
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="kafka"> Kafka
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="logicmonitor"> LogicMonitor
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="netbox"> NetBox
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="redhat-ai"> Red Hat AI
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="servicenow"> ServiceNow
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="splunk"> Splunk
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="windows"> Windows
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--partner">
        <input type="checkbox" value="gluware"> Gluware
      </label>
    </div>
    </div>
    <div class="cards-sidebar__section cards-sidebar__section--status">
      <h4 class="cards-sidebar__title">Status</h4>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--status">
        <input type="checkbox" value="published" checked> Published
      </label>
      <label class="cards-sidebar__checkbox cards-sidebar__checkbox--status">
        <input type="checkbox" value="wip" checked> Work in Progress
      </label>
    </div>
  </aside>

  <div class="cards-main">
    <p id="guide-search-count" class="cards-search__count"></p>

    <section id="solution-guides" class="cards-guide-section">
      <div class="cards-guide-section__heading cards-guide-section__heading--catalog-top">
        <div class="cards-guide-section__heading-group">
          <h2 class="cards-guide-section__title">Solution Guides</h2>
          <a href="{{ '/guide-types' | relative_url }}#solution-guides" class="guide-section__info" data-tooltip="Partner-focused guides that show how AAP solves business problems with integrated technologies." aria-label="Learn about Solution Guides">
            <i class="fas fa-info-circle" aria-hidden="true"></i>
          </a>
        </div>
        <div class="edit-link-wrap edit-link-wrap--catalog">
          <a href="https://github.com/ansible-tmm/solution-guides/edit/main/{{ page.path }}"
             target="_blank" class="edit-link">
            <i class="fas fa-pencil-alt" aria-hidden="true"></i>
            Edit on GitHub
          </a>
        </div>
      </div>

      <div id="aiops-solutions" class="cards-track-section">
        <div class="cards-track-section__heading">
          <h3 class="cards-track-section__title">AIOps Solutions</h3>
          <a href="{{ '/guide-types' | relative_url }}#aiops-solutions" class="guide-section__info" data-tooltip="Partner integrations where AI inference, Automation code assistant, or MCP augments detection, diagnosis, and remediation." aria-label="Learn about AIOps Solutions">
            <i class="fas fa-info-circle" aria-hidden="true"></i>
          </a>
        </div>
        <p class="cards-track-section__intro">Closed-loop automation with AI-assisted diagnosis and remediation across observability, ITSM, and cloud event sources. Start with the foundational guide below (Crawl/Walk/Run and six use cases live there), then explore partner integrations.</p>
        <a href="{{ '/README-AIOps' | relative_url }}" id="aiops-foundational-hero" class="card-link card-link--foundational-hero" data-tags="aiops,solution,published">
          <div class="pf-v6-c-card card-foundational card-foundational--hero">
            <div class="pf-v6-c-card__header card-header--labels">
              <span class="pf-v6-c-label pf-m-green">
                <span class="pf-v6-c-label__content">
                  <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                  Solution Guide
                </span>
              </span>
              <span class="pf-v6-c-label card-label-style card-label-style--foundational">
                <span class="pf-v6-c-label__content">Foundational</span>
              </span>
            </div>
            <div class="pf-v6-c-card__main card-foundational--hero__main">
              <div class="pf-v6-c-card__title">
                <h3 class="pf-v6-c-card__title-text">AIOps automation with Ansible</h3>
              </div>
              <div class="pf-v6-c-card__body">
                Foundational reference for Crawl/Walk/Run, six operational use cases, and governed automation with EDA and partner observability or ITSM. Start here before partner integrations below.
              </div>
            </div>
          </div>
        </a>
        <h4 class="cards-track-subsection__title">Partner integrations</h4>
        <div class="pf-v6-l-gallery pf-m-gutter cards-gallery" id="aiops-gallery">
      <a href="{{ '/README-Instana-AIOps' | relative_url }}" class="card-link" data-tags="instana,aiops,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Automated Incident Remediation with IBM Instana</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Closed-loop incident remediation integrating IBM Instana observability with Event-Driven Ansible for automatic detection, AI-driven job template routing, and self-healing infrastructure.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/instana-logo.png' | relative_url }}" alt="Instana" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/instana-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AIOps-ServiceNow' | relative_url }}" class="card-link" data-tags="servicenow,aiops,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Unlock AIOps with ServiceNow LEAP and Ansible MCP server</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Cut incident MTTR from hours to minutes: LEAP identifies remediation opportunities, the Ansible MCP server surfaces approved playbooks, and governed execution closes incidents with full audit trail.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/servicenow-logo.png' | relative_url }}" alt="ServiceNow" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/servicenow-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AIOps-Splunk-ITSI' | relative_url }}" class="card-link" data-tags="splunk,aiops,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">AIOps with Splunk and Event-Driven Ansible</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Three use cases for closed-loop AIOps: ITSI predictive anomaly detection with MLTK, RHEL server remediation with AI-enriched diagnostics, and network OSPF remediation with Automation code assistant-generated playbooks.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/splunk-logo.png' | relative_url }}" alt="Splunk" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/splunk-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AIOps-Windows-Cert-Rotation' | relative_url }}" class="card-link" data-tags="windows,aiops,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Windows Certificate Rotation with AI Risk Analysis</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Automate Windows certificate rotation end-to-end: Event-Driven Ansible detects expiring certs, AI evaluates risk and timing, Ansible performs the rotation, and ITSM documents the full audit trail.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/windows-logo.png' | relative_url }}" alt="Windows" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/windows-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-SQS' | relative_url }}" class="card-link" data-tags="aws,aiops,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">AIOps with AWS SQS and Event-Driven Ansible</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Connect Amazon SQS to Event-Driven Ansible so CloudWatch, EventBridge, and other AWS events trigger AI diagnosis and automated remediation without custom polling or Lambda glue code.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/aws-logo.png' | relative_url }}" alt="AWS" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/aws-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AIOps-Azure-Service-Bus' | relative_url }}" class="card-link" data-tags="azure,aiops,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Event-Driven Remediation with Azure Service Bus</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Connect Azure Service Bus Queues to Event-Driven Ansible for real-time event consumption, AI-driven diagnosis, and automated remediation across hybrid Azure infrastructure.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/azure-logo.png' | relative_url }}" alt="Azure" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/azure-logo-darkmode.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-Patching-RHEL' | relative_url }}" class="card-link" data-tags="redhat-ai,aiops,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">RHEL Patching with Red Hat Lightspeed and Ansible MCP Server</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Collapse CVE patching from days to minutes: Red Hat Lightspeed MCP identifies vulnerable RHEL VMs on OpenShift Virtualization, the AAP MCP server surfaces approved remediation, and governed execution patches the fleet with full audit trail.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--redhat-ai">
              <img src="{{ '/assets/images/logos/redhat-ai-logo.png' | relative_url }}" alt="Red Hat AI" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/redhat-ai-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-OpenShift-EDA-Kafka' | relative_url }}" class="card-link" data-tags="kafka,aiops,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Consuming OpenShift API Resources with EDA and Kafka</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Capture OpenShift Namespace lifecycle events via Knative APIServerSource, stream them through Kafka, and surface them in Event-Driven Ansible for logging and downstream automation.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/kafka_logo.webp' | relative_url }}" alt="Kafka" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/kafka_logo_dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AIOps-LogicMonitor' | relative_url }}" class="card-link" data-tags="logicmonitor,aiops,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--aiops">
              <span class="pf-v6-c-label__content">AIOps</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Closed-Loop Network Remediation with LogicMonitor and Edwin AI</h3>
          </div>
          <div class="pf-v6-c-card__body">
            A crawl-walk-run maturity model for closed-loop network remediation: LogicMonitor alerts trigger Event-Driven Ansible, progressing from a single BGP-reset job template, to Edwin AI-enriched branched workflows, to agentic remediation via the AAP MCP Server.
          </div>
        </div>
      </a>

      </div>
      </div>

      <div id="network-automation" class="cards-track-section">
        <div class="cards-track-section__heading">
          <h3 class="cards-track-section__title">Network automation</h3>
          <a href="{{ '/guide-types' | relative_url }}#network-automation" class="guide-section__info" data-tooltip="Partner integrations for network source of truth, configuration, and failover with Ansible Automation Platform." aria-label="Learn about Network automation">
            <i class="fas fa-info-circle" aria-hidden="true"></i>
          </a>
        </div>
        <p class="cards-track-section__intro">Network source of truth, configuration, and failover patterns -- NetBox as inventory and intent, with Event-Driven Ansible where state changes should trigger governed execution.</p>
        <div class="pf-v6-l-gallery pf-m-gutter cards-gallery" id="network-gallery">

      <a href="{{ '/README-NetBox-SoT-EDA-Config' | relative_url }}" class="card-link" data-tags="netbox,network,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--network">
              <span class="pf-v6-c-label__content">Network</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Event-Driven Network Source of Truth with NetBox and AAP</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Dynamic inventory from NetBox, event-driven NTP and banner configuration via config contexts and EDA webhooks, and zero-touch device provisioning workflows.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--netbox">
              <img src="{{ '/assets/images/logos/logo_netboxlabs_dark_teal-scaled.png' | relative_url }}" alt="NetBox Labs" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/logo_netboxlabs_dark_teal-scaled-darkmode.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-NetBox-WAN-EDA-Failover' | relative_url }}" class="card-link" data-tags="netbox,network,solution,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-green">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-check-circle pf-v6-c-label__icon"></i>
                Solution Guide
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--network">
              <span class="pf-v6-c-label__content">Network</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Event-Driven WAN Circuit Failover with NetBox and AAP</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Event-driven WAN circuit failover using NetBox as the network source of truth, EDA for automated trigger, dynamic backup discovery, router reconfiguration, and automated incident reporting.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--netbox">
              <img src="{{ '/assets/images/logos/logo_netboxlabs_dark_teal-scaled.png' | relative_url }}" alt="NetBox Labs" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/logo_netboxlabs_dark_teal-scaled-darkmode.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-Gluware-Network-Automation' | relative_url }}" class="card-link" data-tags="gluware,cisco,network,solution,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label card-label-track card-label-track--network">
              <span class="pf-v6-c-label__content">Network</span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Intelligent Network Automation with Gluware and Ansible</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Configuration compliance with closed-loop remediation, multi-vendor OS upgrades, and complex NAC deployments -- AAP as the orchestration plane, Gluware as the network intelligence layer.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/glueware-light.png' | relative_url }}" alt="Gluware" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/glueware-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>
      </div>
      </div>
    </section>

    <section id="implementation-guides" class="cards-guide-section">
      <div class="cards-guide-section__heading">
        <h2 class="cards-guide-section__title">Implementation Guides</h2>
        <a href="{{ '/guide-types' | relative_url }}#implementation-guides" class="guide-section__info" data-tooltip="How to deploy and configure AAP for reliability, performance, and production outcomes." aria-label="Learn about Implementation Guides">
          <i class="fas fa-info-circle" aria-hidden="true"></i>
        </a>
      </div>
      <div class="cards-track-section cards-track-section--flat">
      <div class="pf-v6-l-gallery pf-m-gutter cards-gallery" id="implementation-gallery">
      <a href="{{ '/README-EDB' | relative_url }}" class="card-link" data-tags="edb,implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">High-Availability AAP with EDB PostgreSQL DR</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Multi-datacenter Active-Passive disaster recovery for Ansible Automation Platform using EDB Postgres Advanced Server and EDB Failover Manager with sub-5-minute RTO.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set">
              <img src="{{ '/assets/images/logos/edb.png' | relative_url }}" alt="EDB" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/edb-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-ZTA' | relative_url }}" class="card-link" data-tags="implementation,netbox,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Zero Trust Architecture with Ansible Automation Platform</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Orchestrate identity, secrets, policy, and network controls with AAP as the central layer -- dynamic credentials, policy-as-code, SPIFFE workload identity, and event-driven security response.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--zero-trust">
              <img src="{{ '/assets/images/logos/zero-trust.png' | relative_url }}" alt="Zero Trust" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/zero-trust.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-IA' | relative_url }}" class="card-link" data-tags="redhat-ai,aiops,implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">AI Infrastructure automation with Ansible</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Provision and configure Red Hat AI infrastructure -- from GPU instances to serving models -- using the infra.ai and redhat.ai collections.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--redhat-ai">
              <img src="{{ '/assets/images/logos/redhat-ai-logo.png' | relative_url }}" alt="Red Hat AI" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/redhat-ai-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-Intelligent-Assistant-RHAIIS' | relative_url }}" class="card-link" data-tags="redhat-ai,aiops,implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Intelligent Assistant with Red Hat AI Inference Server</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Deploy and configure a self-hosted LLM using Red Hat AI Inference Server on RHEL with GPU acceleration to power the Automation intelligent assistant in AAP.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--redhat-ai">
              <img src="{{ '/assets/images/logos/redhat-ai-logo.png' | relative_url }}" alt="Red Hat AI" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/redhat-ai-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-Ansible-DevTools' | relative_url }}" class="card-link" data-tags="implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">AI-Assisted Ansible Developer Experience</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Standardize your automation developer experience across the organization using Ansible Development Tools, from individual uv/pip installs to enterprise-governed Dev Spaces with 5-minute onboarding.
          </div>
        </div>
      </a>

      <a href="{{ '/README-Ansible-DevSpaces' | relative_url }}" class="card-link" data-tags="implementation,wip">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header card-header--labels">
            <span class="pf-v6-c-label pf-m-orange">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-exclamation-triangle pf-v6-c-label__icon"></i>
                Work in Progress
              </span>
            </span>
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">Ansible Development Workspaces</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Tiered image layering strategy for Ansible Dev Spaces on OpenShift -- deliver governed, customizable development environments across multiple automation domains using standard BuildConfigs and ImageStreams.
          </div>
        </div>
      </a>

      <a href="{{ '/README-AAP-HA-DR-OpenShift' | relative_url }}" class="card-link" data-tags="cloudnativepg,implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">AAP HA/DR on OpenShift with CloudNativePG</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Two-site active-passive disaster recovery for Ansible Automation Platform 2.7 on OpenShift using CloudNativePG cross-cluster replication, shared secrets, and controlled switchover procedures.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--cloudnativepg">
              <img src="{{ '/assets/images/logos/cloud-native.png' | relative_url }}" alt="CloudNativePG" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/cloud-native-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>

      <a href="{{ '/README-AAP-PostgreSQL-Autovacuum-Tuning' | relative_url }}" class="card-link" data-tags="implementation,published">
        <div class="pf-v6-c-card">
          <div class="pf-v6-c-card__header">
            <span class="pf-v6-c-label pf-m-blue">
              <span class="pf-v6-c-label__content">
                <i class="fas fa-cogs pf-v6-c-label__icon"></i>
                Implementation Guide
              </span>
            </span>
          </div>
          <div class="pf-v6-c-card__title">
            <h3 class="pf-v6-c-card__title-text">PostgreSQL Autovacuum Tuning for AAP</h3>
          </div>
          <div class="pf-v6-c-card__body">
            Three targeted autovacuum parameter changes -- tested in order of impact -- to keep large AAP tables continuously clean at enterprise scale.
          </div>
          <div class="pf-v6-c-card__footer">
            <span class="card-partner-logo-set card-partner-logo-set--postgresql">
              <img src="{{ '/assets/images/logos/postgresSQL.png' | relative_url }}" alt="PostgreSQL" class="card-partner-logo card-partner-logo--light">
              <img src="{{ '/assets/images/logos/postgresSQL_dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
            </span>
          </div>
        </div>
      </a>
      </div>
      </div>
    </section>

    <div class="cards-contributing">
      <h2>Contributing</h2>
      <p>Writing a new guide? Start with the <a href="{{ '/best-practices/' | relative_url }}">Best Practices hub</a> -- choose the Solution Guide or Implementation Guide framework, scoring rubric, and starter template for your content type.</p>
    </div>

    <details class="legacy-guides">
      <summary>Legacy Solution Guides (Under Review)</summary>
      <div class="legacy-guides__body">
      <p class="legacy-guides__intro">These solution guides were published on access.redhat.com before this repository existed. They are being reviewed and will be migrated to the new format as full markdown guides.</p>
      <div class="pf-v6-l-gallery cards-gallery legacy-guides__gallery">
        <a href="{{ '/README-ServiceNow-ITSM' | relative_url }}" class="card-link" data-tags="servicenow,aiops,solution,published">
          <div class="pf-v6-c-card">
            <div class="pf-v6-c-card__title">
              <h3 class="pf-v6-c-card__title-text">ServiceNow ITSM Ticket Enrichment</h3>
            </div>
            <div class="pf-v6-c-card__body">
              Automate ServiceNow ticket creation and enrich incidents with CVE data from Red Hat Insights.
            </div>
            <div class="pf-v6-c-card__footer">
              <span class="card-partner-logo-set">
                <img src="{{ '/assets/images/logos/servicenow-logo.png' | relative_url }}" alt="ServiceNow" class="card-partner-logo card-partner-logo--light">
                <img src="{{ '/assets/images/logos/servicenow-logo-dark.png' | relative_url }}" alt="" class="card-partner-logo card-partner-logo--dark" aria-hidden="true">
              </span>
            </div>
          </div>
        </a>
        <a href="https://access.redhat.com/articles/7136720" class="card-link" target="_blank" data-tags="published">
          <div class="pf-v6-c-card">
            <div class="pf-v6-c-card__title">
              <h3 class="pf-v6-c-card__title-text">Get started with EDA (Ansible Rulebook)</h3>
            </div>
            <div class="pf-v6-c-card__body">
              Fundamentals of Event-Driven Ansible -- rulebooks, event sources, conditions, and actions.
            </div>
          </div>
        </a>
        <a href="https://access.redhat.com/articles/7123366" class="card-link" target="_blank" data-tags="cisco,network,published">
          <div class="pf-v6-c-card">
            <div class="pf-v6-c-card__title">
              <h3 class="pf-v6-c-card__title-text">Network Back Up and Configuration</h3>
            </div>
            <div class="pf-v6-c-card__body">
              Backup, configure, and restore network devices using the network.backup validated content collection.
            </div>
            <div class="pf-v6-c-card__footer">
              <span class="card-partner-tag">Cisco</span>
            </div>
          </div>
        </a>
        <a href="https://access.redhat.com/articles/7123361" class="card-link" target="_blank" data-tags="cisco,network,published">
          <div class="pf-v6-c-card">
            <div class="pf-v6-c-card__title">
              <h3 class="pf-v6-c-card__title-text">Network Fact Gathering & Reporting</h3>
            </div>
            <div class="pf-v6-c-card__body">
              Collect network device facts and export structured data for compliance reporting.
            </div>
            <div class="pf-v6-c-card__footer">
              <span class="card-partner-tag">Cisco</span>
            </div>
          </div>
        </a>
      </div>
      </div>
    </details>
  </div>
</div>

<script>
(function () {
  var headerInput = document.getElementById('header-search');
  var filterClearBtn = document.getElementById('filter-clear');
  var countEl = document.getElementById('guide-search-count');
  var allCards = document.querySelectorAll('.card-link');
  var legacyDetails = document.querySelector('details.legacy-guides');
  var statusCheckboxes = document.querySelectorAll('.cards-sidebar__checkbox--status input');
  var trackCheckboxes = document.querySelectorAll('.cards-sidebar__checkbox--track input');
  var partnerCheckboxes = document.querySelectorAll('.cards-sidebar__checkbox--partner input');
  var publishedCheckbox = document.querySelector('.cards-sidebar__checkbox--status input[value="published"]');
  var wipCheckbox = document.querySelector('.cards-sidebar__checkbox--status input[value="wip"]');
  var cardsMain = document.querySelector('.cards-main');
  var solutionGuidesSection = document.getElementById('solution-guides');
  var aiopsFoundationalHero = document.getElementById('aiops-foundational-hero');
  var sectionConfigs = [
    { section: document.getElementById('aiops-solutions'), gallery: document.getElementById('aiops-gallery'), hero: aiopsFoundationalHero },
    { section: document.getElementById('network-automation'), gallery: document.getElementById('network-gallery') },
    { section: document.getElementById('implementation-guides'), gallery: document.getElementById('implementation-gallery') }
  ];

  if (!headerInput) return;

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

  function getCardTags(card) {
    return (card.getAttribute('data-tags') || '').split(',').map(function (s) { return s.trim(); });
  }

  function getActiveStatus() {
    var active = [];
    statusCheckboxes.forEach(function (cb) {
      if (cb.checked) active.push(cb.value);
    });
    return active;
  }

  function getActivePartners() {
    var active = [];
    partnerCheckboxes.forEach(function (cb) {
      if (cb.checked) active.push(cb.value);
    });
    return active;
  }

  function getActiveTracks() {
    var active = [];
    trackCheckboxes.forEach(function (cb) {
      if (cb.checked) active.push(cb.value);
    });
    return active;
  }

  function isDefaultStatusFilter() {
    return publishedCheckbox && publishedCheckbox.checked && wipCheckbox && wipCheckbox.checked;
  }

  function hasActiveFilters(query, activePartners, activeTracks) {
    return query || activePartners.length || activeTracks.length || !isDefaultStatusFilter();
  }

  function countVisibleCards(container) {
    var count = 0;
    if (!container) return 0;
    container.querySelectorAll('.card-link').forEach(function (card) {
      if (card.style.display !== 'none') count++;
    });
    return count;
  }

  function updateSectionVisibility(filterContext) {
    var onlyPublishedDefault = filterContext && filterContext.onlyPublishedDefault;
    var hasOtherFilters = filterContext && filterContext.hasOtherFilters;

    sectionConfigs.forEach(function (cfg) {
      if (!cfg.section || !cfg.gallery) return;
      var visibleInGallery = countVisibleCards(cfg.gallery);
      var totalInGallery = cfg.gallery.querySelectorAll('.card-link').length;
      var heroVisible = cfg.hero && cfg.hero.style.display !== 'none' ? 1 : 0;
      var sectionVisible = visibleInGallery + heroVisible;

      if (cfg.emptyState) {
        var showEmpty = visibleInGallery === 0 && totalInGallery > 0 && onlyPublishedDefault && !hasOtherFilters;
        cfg.emptyState.hidden = !showEmpty;
        cfg.gallery.style.display = showEmpty ? 'none' : '';
        cfg.section.style.display = sectionVisible > 0 || showEmpty ? '' : 'none';
        return;
      }

      if (cfg.hero) {
        cfg.section.style.display = sectionVisible === 0 ? 'none' : '';
        return;
      }

      cfg.section.style.display = visibleInGallery === 0 ? 'none' : '';
    });

    if (solutionGuidesSection) {
      var aiopsSection = document.getElementById('aiops-solutions');
      var networkSection = document.getElementById('network-automation');
      var solutionVisible = (aiopsSection && aiopsSection.style.display !== 'none')
        || (networkSection && networkSection.style.display !== 'none');
      solutionGuidesSection.style.display = solutionVisible ? '' : 'none';
    }
  }

  function filterCards() {
    var query = headerInput.value.toLowerCase().trim();
    var activeStatus = getActiveStatus();
    var activePartners = getActivePartners();
    var activeTracks = getActiveTracks();
    var showClear = hasActiveFilters(query, activePartners, activeTracks);
    filterClearBtn.style.display = showClear ? 'inline' : 'none';

    var visible = 0;
    var legacyHasMatch = false;

    allCards.forEach(function (card) {
      var cardTags = getCardTags(card);
      var isSolutionGuide = cardTags.indexOf('solution') !== -1;
      var textMatch = !query || getCardText(card).indexOf(query) !== -1;
      var statusMatch = !activeStatus.length || activeStatus.some(function (s) { return cardTags.indexOf(s) !== -1; });
      var partnerMatch = !activePartners.length || activePartners.some(function (p) { return cardTags.indexOf(p) !== -1; });
      var trackMatch = !activeTracks.length || !isSolutionGuide || activeTracks.some(function (t) { return cardTags.indexOf(t) !== -1; });
      var show = textMatch && statusMatch && partnerMatch && trackMatch;
      card.style.display = show ? '' : 'none';
      if (show) {
        visible++;
        if (legacyDetails && legacyDetails.contains(card)) legacyHasMatch = true;
      }
    });

    updateSectionVisibility({
      onlyPublishedDefault: isDefaultStatusFilter(),
      hasOtherFilters: !!(query || activePartners.length || activeTracks.length)
    });

    if (legacyDetails) {
      var legacyVisible = 0;
      legacyDetails.querySelectorAll('.card-link').forEach(function (card) {
        if (card.style.display !== 'none') legacyVisible++;
      });
      legacyDetails.style.display = legacyVisible === 0 ? 'none' : '';
      if (legacyHasMatch) legacyDetails.setAttribute('open', '');
      else if (hasActiveFilters(query, activePartners, activeTracks)) legacyDetails.removeAttribute('open');
    }

    if (hasActiveFilters(query, activePartners, activeTracks)) {
      countEl.textContent = visible === 0
        ? 'No guides match your filters.'
        : visible + ' guide' + (visible !== 1 ? 's' : '') + ' found.';
    } else {
      countEl.textContent = '';
    }

    if (cardsMain) {
      cardsMain.classList.toggle('cards-main--partner-filter', activePartners.length > 0);
    }
  }

  headerInput.addEventListener('input', filterCards);

  statusCheckboxes.forEach(function (cb) {
    cb.addEventListener('change', filterCards);
  });

  trackCheckboxes.forEach(function (cb) {
    cb.addEventListener('change', filterCards);
  });

  partnerCheckboxes.forEach(function (cb) {
    cb.addEventListener('change', filterCards);
  });

  filterClearBtn.addEventListener('click', function () {
    trackCheckboxes.forEach(function (cb) { cb.checked = false; });
    partnerCheckboxes.forEach(function (cb) { cb.checked = false; });
    if (publishedCheckbox) publishedCheckbox.checked = true;
    if (wipCheckbox) wipCheckbox.checked = true;
    headerInput.value = '';
    filterCards();
  });

  filterClearBtn.style.display = 'none';
  filterCards();
})();
</script>
