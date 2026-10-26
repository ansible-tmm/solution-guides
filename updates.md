---
layout: default
title: What's New
permalink: /updates/
---

<div class="hub-intro-row">
  <p class="guide-types-lead">Automated release notes for this site -- new solution guides, notable guide updates, and site changes from the last 30 days. Regenerated weekly from git history.</p>
</div>

<!-- BEGIN:AUTO-UPDATES -->
*Rolling window: 2026-09-26 to 2026-10-26. Regenerated weekly from git history.*

### New guides

- [Automated vulnerability remediation with Lightwell and Ansible]({{ "/README-AAP-LightWell-AO" | relative_url }}) -- Publish LightWell as solution guide, BruteForce + CME fixes, add .md extensions
- [LogicMonitor + Ansible Automation Platform: AIOps Solution Guide]({{ "/README-AIOps-LogicMonitor" | relative_url }}) -- Add LogicMonitor AIOps solution guide (#59)
- [AI-driven CVE routing and remediation with Automation orchestrator]({{ "/README-AO-driven-CVE-routing" | relative_url }}) -- Rename README-AO-driven-CVE-routing to README-AO-driven-CVE-routing.md
- [Automated Brute-Force Remediation with Event-Driven Ansible]({{ "/README-BruteForce-AAP" | relative_url }}) -- Publish LightWell as solution guide, BruteForce + CME fixes, add .md extensions
- [Automated CVE response and compliance verification with CME]({{ "/README-CME" | relative_url }}) -- Publish LightWell as solution guide, BruteForce + CME fixes, add .md extensions
- [Automated CVE response with policy-gated patching and compliance evidence]({{ "/README-CVE-defend-contain-comply" | relative_url }}) -- Create README-CVE-defend-contain-comply.md
- [Enforcing Compliance and Network Governance]({{ "/README-Compliance-Governance-with-policy" | relative_url }}) -- Publish README-Compliance-Governance-with-policy as solution guide
- [Automated runtime mitigation for Linux OT hosts]({{ "/README-Falco-runtime-mitigation" | relative_url }}) -- feat: add Falco runtime mitigation solution guide and review
- [Intelligent Network Automation with Gluware and Ansible]({{ "/README-Gluware-Network-Automation" | relative_url }}) -- Add WIP Gluware network automation solution guide
- [Lightwell Neuromancer CVE Routing]({{ "/README-Lightwell-Neuromancer-CVE-Routing" | relative_url }}) -- Review and publish CVE-defend-contain-comply, AO-driven-CVE-routing, ZTA-with-AAP
- [PQC Discovery and Scoped Remediation]({{ "/README-PQC-Discovery" | relative_url }}) -- Add files via upload
- [RHEL 9 STIG and CIS compliance scanning with Ansible]({{ "/README-STIG-CIS-compliance" | relative_url }}) -- Publish README-STIG-CIS-compliance.md as implementation guide
- [Proactive Vulnerability Remediation with Satellite, Event-Driven Ansible, and Lightspeed On-Premises]({{ "/README-Satellite-CVE-Remediation" | relative_url }}) -- Add Satellite CVE remediation solution guide
- [Zero Trust Architecture infrastructure with Ansible Automation Platform]({{ "/README-ZTA-with-AAP" | relative_url }}) -- Review and publish CVE-defend-contain-comply, AO-driven-CVE-routing, ZTA-with-AAP

### Guide updates

- [High Availability and Disaster Recovery for AAP 2.7 on OpenShift]({{ "/README-AAP-HA-DR-OpenShift" | relative_url }}): docs: link public AAP HA DR example
- [PostgreSQL Autovacuum Tuning Guide for Ansible Automation Platform]({{ "/README-AAP-PostgreSQL-Autovacuum-Tuning" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Event-Driven Remediation with Azure Service Bus and Ansible]({{ "/README-AIOps-Azure-Service-Bus" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Unlock AIOps with ServiceNow LEAP and Ansible MCP server]({{ "/README-AIOps-ServiceNow" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [AIOps with Splunk and Event-Driven Ansible]({{ "/README-AIOps-Splunk-ITSI" | relative_url }}): Remove redundant section dividers on guide pages
- [Windows Certificate Rotation with AI Risk Analysis]({{ "/README-AIOps-Windows-Cert-Rotation" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [AIOps automation with Ansible]({{ "/README-AIOps" | relative_url }}): Clarify 'select from library' with concrete examples
- [Ansible Development Workspaces]({{ "/README-Ansible-DevSpaces" | relative_url }}): Label Dev Spaces and Content Tools icon marks
- [AI-Assisted Ansible Developer Experience]({{ "/README-Ansible-DevTools" | relative_url }}): Label Dev Spaces and Content Tools icon marks
- [High-Availability Ansible Automation Platform with EDB PostgreSQL Active-Passive DR]({{ "/README-EDB" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [AI Infrastructure Automation with Ansible]({{ "/README-IA" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Automated Incident Remediation with IBM Instana and Ansible Automation Platform]({{ "/README-Instana-AIOps" | relative_url }}): Hide markdown section HRs that sat above headings
- [Configuring Ansible Lightspeed intelligent assistant with Red Hat AI Inference Server on RHEL]({{ "/README-Intelligent-Assistant-RHAIIS" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Event-Driven Network Source of Truth with NetBox and Ansible Automation Platform]({{ "/README-NetBox-SoT-EDA-Config" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Event-Driven WAN Circuit Failover with NetBox and Ansible Automation Platform]({{ "/README-NetBox-WAN-EDA-Failover" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [Using Event-Driven Ansible to Consume OpenShift API Resources With Kafka]({{ "/README-OpenShift-EDA-Kafka" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [RHEL Patching with Red Hat Lightspeed and Ansible MCP Server]({{ "/README-Patching-RHEL" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [AIOps with AWS SQS and Event-Driven Ansible]({{ "/README-SQS" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [ServiceNow ITSM Ticket Enrichment Automation]({{ "/README-ServiceNow-ITSM" | relative_url }}): fix: size all partner logos for raw markdown rendering (#67)
- [ZTA]({{ "/README-ZTA" | relative_url }}): Remove redundant section dividers on guide pages

### Site and tooling

- Trim NetBox and Gluware from partner filters
- Trim CloudNativePG, EDB, and Kafka from partner filters
- Remove orphan catalog cards for deleted Neuromancer and ZTA guides
- End dual gallery posting; keep dual tags for filters
- Keep Falco under Security only; drop Partner integrations heading
- Retag PQC Discovery as a Security solution guide
- Hide markdown section HRs that sat above headings
- Increase h2 underline contrast on guide pages
- Restore single h2 section underlines on guides
- Remove redundant section dividers on guide pages
- Label Automation orchestrator icon mark
- Label Dev Spaces and Content Tools icon marks
- Label Zero Trust emblem with readable text
- Rewrite catalog blurbs without prose double dashes
- Size OPA light logo as a wordmark, not an icon

_…and 41 more site commits in this window._

<!-- END:AUTO-UPDATES -->

<p class="guide-types-lead" style="margin-top: 2rem;">Want to contribute a guide? Start with the <a href="{{ '/best-practices/' | relative_url }}">Best Practices hub</a>.</p>
