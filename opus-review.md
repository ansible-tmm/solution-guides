
# Review: Published Solution Guides

*Reviewed: July 22, 2026*

## Scorecard

| Rank | Solution Guide | Score | Verdict |
|------|---------------|-------|---------|
| 1 | [AAP HA/DR on OpenShift](#1-high-availability-and-disaster-recovery-for-aap-on-openshift) | 9.8/10 | Reference-grade implementation guide with validated test scenarios, observed SLAs, and production-hardened failover runbooks |
| 2 | [Windows Certificate Rotation with AI Risk Analysis](#2-windows-certificate-rotation-with-ai-risk-analysis) | 9.5/10 | Elite AIOps guide: three decision paths, three test scenarios with verbatim output, arcade demo, video, graceful fallback, and success metrics |
| 3 | [AI-Assisted Ansible Developer Experience](#3-ai-assisted-ansible-developer-experience) | 9.5/10 | Comprehensive DevTools guide with four installation methods, MCP integration, and enterprise maturity model from individual to governed |
| 4 | [OpenShift EDA + Kafka Event Pipeline](#4-openshift-eda--kafka-event-pipeline) | 9.2/10 | Deep integration guide: full Kafka/Serverless/EDA pipeline with custom credential types, alternative architectures, and strong validation |
| 5 | [AIOps with Splunk and EDA](#5-aiops-with-splunk-and-event-driven-ansible) | 8.9/10 | Deepest multi-use-case guide; three integration patterns with strong validation and troubleshooting |
| 6 | [Automated Incident Remediation with IBM Instana](#6-automated-incident-remediation-with-ibm-instana) | 8.9/10 | Dual-path architecture (EDA vs native); per-use-case operational impact and unusually complete validation |
| 7 | [High-Availability AAP with EDB PostgreSQL DR](#7-high-availability-aap-with-edb-postgresql-dr) | 8.7/10 | Reference-grade VM-based DR architecture with diagrams, runbooks, and failback procedures |
| 8 | [Unlock AIOps with ServiceNow LEAP and Ansible MCP server](#8-unlock-aiops-with-servicenow-leap-and-ansible-mcp-server) | 8.7/10 | Strong LEAP/MCP governance story with MTTR focus, customer evidence, multi-agent visibility |
| 9 | [AIOps automation with Ansible](#9-aiops-automation-with-ansible) | 8.5/10 | Strong foundational reference architecture; best systems narrative, observability catalog, and playbook source mapping |
| 10 | [AI Infrastructure automation with Ansible](#10-ai-infrastructure-automation-with-ansible) | 7.3/10 | Clear two-collection story (infra.ai + redhat.ai); needs framework alignment and deeper validation |
| 11 | [Intelligent Assistant with Red Hat AI Inference Server](#11-intelligent-assistant-with-red-hat-ai-inference-server) | 6.9/10 | Strong hands-on RHAIIS + Lightspeed hookup; weakest framework alignment of published guides |

---

## How This Was Scored

Each guide was evaluated against the quality scoring model from the [Best Practices for Writing Solution Guides](README-best-practices.md):

| Category | Weight |
|----------|--------|
| Outcome Clarity | 20% |
| Architecture Clarity | 20% |
| Technical Executability | 25% |
| Validation/Testability | 15% |
| Production Readiness Info | 10% |
| Business Framing | 10% |

Score each category 1-5. Multiply by weight. Final score out of 10. Any category below 3 means revise before publishing.

---

## Guide Reviews

---

### 1. High Availability and Disaster Recovery for AAP on OpenShift

**File:** [README-AAP-HA-DR-OpenShift.md](README-AAP-HA-DR-OpenShift.md)
**Score: 9.8 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 5 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 5 |
| Business Framing (10%) | 4 |

**Stats:** ~8,500 words | 12+ YAML blocks | 1 clickable architecture image + 1 Mermaid diagram | 6 major sections with appendix | Validated test scenarios table

**Strengths:**
- Extraordinary depth: full operator Subscriptions, CNPG Cluster CRs with production-tuned PostgreSQL parameters, complete AAP CR with node scheduling
- Validated test scenarios with **observed SLAs** -- pod recovery (6-59s), DB failover (33-44s), node failure (~7min), full region DR (11-79s)
- Two failover procedures (controlled switchover vs emergency) with exact `oc patch` commands and step-by-step token flow
- Day 2 operations section: backup/restore, DB maintenance, certificate rotation, monitoring stack with key metrics and alert thresholds
- Known Issues section documents real bugs with workarounds (metrics service, stale OAuth2 secret, ODF RGW pg_num)
- Planning section on physical placement, distance, and external dependencies is unusually thoughtful for a technical guide
- Appendix A provides full ODF RGW multisite bootstrap with `radosgw-admin` commands and upstream bug references

**Weaknesses:**
- No demos, videos, or interactive walkthroughs
- Business framing is present (persona table, maturity path) but lacks quantified cost/MTTR savings
- The guide is extremely long -- may benefit from being split into "Architecture + Planning" and "Implementation" documents
- Missing KB blockquote under the title

**Suggestions:**
1. Add a brief executive summary or "Quick Start" at the top for architects who need the architecture without the full implementation
2. Consider a companion reference card (one-pager) with the validated SLA table and failover cheat sheet
3. Add a cost/resource estimate section (node count, storage, operator overhead)

---

### 2. Windows Certificate Rotation with AI Risk Analysis

**File:** [README-AIOps-Windows-Cert-Rotation.md](README-AIOps-Windows-Cert-Rotation.md)
**Score: 9.5 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 5 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 5 |
| Business Framing (10%) | 4.5 |

**Stats:** ~4,200 words | 7 YAML blocks | 1 hero image + 1 Mermaid diagram + 6 screenshots | Arcade embed + YouTube video | 4 walkthrough steps (with 3a/3b branching) | 3 validation test paths

**Strengths:**
- Three-path AI decision routing (PROCEED, SCHEDULE, ESCALATE) is the most sophisticated workflow logic in any guide -- demonstrates real-world AI judgment, not just "ask AI and do what it says"
- Three complete validation test paths with curl commands, each producing different AI decisions with verbatim expected output
- Graceful fallback: rescue block escalates when AI is unavailable, rotation job remains available for manual launch
- "Measuring Success" table with 6 quantifiable metrics and where to find them -- sets the standard for ROI evidence
- Arcade interactive demo AND YouTube video -- both available inline
- Per-stage operational impact table with clear "why" column
- Cost notes (under $0.01/call) address a real concern about AI API usage

**Weaknesses:**
- Mermaid diagram uses inline `style F fill:#f9f,stroke:#333` which conflicts with the mermaid conventions (no inline styles)
- No link to a source repo with the full playbooks -- readers must assemble from excerpts
- Missing KB blockquote under the title
- Twemoji images add visual polish but increase HTML noise significantly

**Suggestions:**
1. Remove the inline `style` directive from the mermaid diagram; rely on the default theme
2. Add a link to a GitHub repo with the complete playbook set (or note one is coming)
3. Add a "Before You Begin" timing note: capture baseline MTTR metrics before enabling automation

---

### 3. AI-Assisted Ansible Developer Experience

**File:** [README-Ansible-DevTools.md](README-Ansible-DevTools.md)
**Score: 9.5 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4.5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 5 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 5 |
| Business Framing (10%) | 5 |

**Stats:** ~4,800 words | 3 Mermaid diagrams + multiple code blocks (bash, JSON, YAML) | 4 installation methods with step-by-step | MCP server configuration section | Comprehensive comparison table

**Strengths:**
- Four installation methods (uv/pip, RPM, Dev Container, Dev Spaces) with clear "best for" guidance and honest tradeoffs
- Three Mermaid diagrams: delivery method progression, tool lifecycle (Create/Test/Deploy), and MCP architecture
- MCP section covers both Ansible Devtools MCP server and AAP MCP server with configuration examples for Claude Code, VS Code, and `.mcp.json`
- End-to-end development workflow showing scaffold -> lint -> inventory check -> run on AAP -> troubleshoot loop
- Comparison table across 11 dimensions is immediately actionable for decision-makers
- Maturity path goes to four levels (Crawl through "Fly") -- first guide to do so, appropriate for the topic
- Both upstream (community) and downstream (Red Hat supported) paths documented side by side

**Weaknesses:**
- Borderline solution vs. tutorial -- the framing around "enterprise developer experience" saves it, but the guide could be read as "how to install ADT"
- Validation is relatively simple (`adt --version` + smoke test) compared to the complexity of what's being set up
- No screenshots of the Dev Container or Dev Spaces experience in action
- Missing KB blockquote under the title

**Suggestions:**
1. Add a screenshot or two showing the dev container experience (VS Code with Ansible extension running inside the container)
2. Strengthen the validation section with a more meaningful test (e.g., scaffold a role, lint it, run molecule)
3. Add a "Common questions from leadership" FAQ addressing cost justification for Dev Spaces infrastructure

---

### 4. OpenShift EDA + Kafka Event Pipeline

**File:** [README-OpenShift-EDA-Kafka.md](README-OpenShift-EDA-Kafka.md)
**Score: 9.2 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 5 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 4 |
| Business Framing (10%) | 4 |

**Stats:** ~5,200 words | 15+ YAML/shell blocks | 1 Mermaid diagram | 7 numbered walkthrough steps | Per-stage validation table + 7-row troubleshooting table

**Strengths:**
- Complete pipeline from Kubernetes API to EDA: APIServerSource -> KafkaSink -> Kafka -> EDA -> AAP job template, all with deployable CRs
- Custom credential type for Kafka with field definitions and injector configuration -- uncommonly detailed
- Alternative architecture comparison (direct KafkaSink vs KafkaChannel + Subscription) with strengths/limitations table
- CloudEvents table documenting the three event types captured with their triggers and payloads
- Full EDA rulebook with three condition rules and a catch-all debug rule
- Honest scoping: "This guide builds the foundational event pipeline" with Maturity Path showing the path to automated governance

**Weaknesses:**
- The immediate outcome is "log namespace events" -- deliberately basic, but a reader might feel underwhelmed after deploying Kafka + Serverless + EDA
- No demos, videos, or interactive walkthroughs
- No quantified business value (time savings, audit compliance improvement)
- Missing KB blockquote under the title

**Suggestions:**
1. Add a "What you can build on this" section with 2-3 concrete examples (e.g., auto-apply network policies to new namespaces, alert on label violations)
2. Consider adding a simple governance action in a "bonus step" to show immediate value beyond logging
3. Add cost/resource notes for the Kafka + Serverless stack (storage, operator overhead)

---

### 5. AIOps with Splunk and Event-Driven Ansible

**File:** [README-AIOps-Splunk-ITSI.md](README-AIOps-Splunk-ITSI.md)
**Score: 8.9 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 5 |
| Architecture Clarity (20%) | 4 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 4 |
| Business Framing (10%) | 5 |

**Stats:** ~6,800 words | 15 YAML blocks | 1 hero image + 1 architecture image | 17 walkthrough subsections

**Strengths:**
- Three integration patterns (ITSI/MLTK, generic webhook, network OSPF) in a single guide with a repeatable story
- Deep Splunk operational detail -- MLTK adaptive-interval behavior, aggregation policy pitfalls, ITSI source field nuances
- Unusually thorough validation: per-stage checklists, scripted webhook injection, OSPF scenario matrix, and a wide troubleshooting sheet
- Closed-loop completeness from detect through correlate, enrich, remediate, and episode closure
- Strong business framing with retail KPI severity scenario and persona table anchored to measurable pain

**Weaknesses:**
- TOC includes "Incident Response Timeline" with no matching section (dead anchor)
- Same `aiops_splunk_predict.png` reused for the webhook pipeline section -- risks confusing readers
- Phase 1 of the ITSI remediation playbook is placeholder text; not all referenced collections appear in Prerequisites
- Missing KB blockquote under the title per repo convention

**Suggestions:**
1. Fix or remove the dead "Incident Response Timeline" TOC entry
2. Provide a distinct diagram (or clear caption) separating predictive ITSI topology from generic webhook flow
3. Unify Prerequisites with every module used in excerpts (add `f5networks.f5_modules`, `amazon.aws`)

---

### 6. Automated Incident Remediation with IBM Instana

**File:** [README-Instana-AIOps.md](README-Instana-AIOps.md)
**Score: 8.9 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 4 |
| Business Framing (10%) | 5 |

**Stats:** ~4,300 words | 8 YAML blocks | 1 hero image + 2 architecture diagrams | 8 numbered steps + 3 use cases + optional AI section

**Strengths:**
- Two integration patterns (EDA webhook vs Instana native automation framework) with "when to use which" comparison table
- Concrete integration surface: webhook URL/payload field table, full rulebook, Host Agent REST annotation loop
- Per-stage and per-use-case operational impact levels, rollback warnings, and approval-gate maturity guidance
- Strong validation: checklist-by-stage verification, deterministic synthetic POST test, and troubleshooting grid
- Business + engineering alignment: personas, demos, ROI recap, and measurable success metric table

**Weaknesses:**
- "Integration Architecture" section name deviates from the framework's standard "[Topic] Workflow" convention
- Minor typo: "an governed" should be "a governed" in the Overview
- DB idle-connection playbook excerpt stops short of showing the full kill-query step
- Architecture diagrams are present but no Mermaid renderings for interactive exploration on the site

**Suggestions:**
1. Fix the "an governed" typo in the Overview
2. Add a subtitle or alias so "Integration Architecture" maps to the framework's Workflow section for reviewers
3. Consider adding a Mermaid version of the dual-path topology for inline rendering on GitHub Pages

---

### 7. High-Availability AAP with EDB PostgreSQL DR

**File:** [README-EDB.md](README-EDB.md)
**Score: 8.7 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4.5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 4 |
| Business Framing (10%) | 4.5 |

**Stats:** ~7,130 words | 1 YAML block | 3 Mermaid diagrams (architecture, data flow, failover sequence) | 6 phases, 23 titled substeps

**Strengths:**
- Reference-grade architecture: Mermaid diagrams (dual-DC topology, steady-state data flow, failover sequence) plus sizing and component tables
- Operational honesty about failover impact on sessions, in-flight jobs, EDA activations, and DNS TTL
- End-to-end scope from infrastructure provisioning through production cutover, plus an Operational Runbook section
- Strong validation surface: per-stage checklist, health-check scripts, failback procedure, and troubleshooting table
- Clear "Who Benefits" and Crawl/Walk/Run tables connecting engineering work to stakeholder language

**Weaknesses:**
- Unified INI inventory example for DC2 may have grouping issues that could cause install failures if copied literally
- Failover testing alternates between `pg_ctl promote` and EFM-orchestrated behavior without a clear single authority
- Unlike other AAP guides, there is no featured Automation Hub collection table (fine for the topic, but a convention gap)
- Missing KB blockquote under the title

**Suggestions:**
1. Validate and fix the unified inventory INI grouping so DC2 host/variable assignments are unambiguous
2. Add a short "Support and boundaries" note clarifying Red Hat vs EDB support scope
3. For 3-5 key commands (`podman ps`, `efm cluster-status`, `pg_is_in_recovery`), show verbatim expected output

---

### 8. Unlock AIOps with ServiceNow LEAP and Ansible MCP server

**File:** [README-AIOps-ServiceNow.md](README-AIOps-ServiceNow.md)
**Score: 8.7 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 5 |
| Architecture Clarity (20%) | 4.5 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 5 |
| Business Framing (10%) | 5 |

**Stats:** ~3,800 words | 2 YAML blocks | 1 hero image + 1 SVG architecture diagram + 1 Mermaid diagram | 4 walkthrough steps + 4 verification artifacts

**Strengths:**
- Complete framework alignment: all sections present and well-organized
- Two executable YAML artifacts: governed template-as-code and ITSM correlation with multi-agent rationale
- Multi-agent visibility narrative with clear "when to skip" guidance
- Dedicated MCP deployment topology section with trust boundaries, TLS/mTLS, and token rotation
- Real-world customer reference (Mutua Madrileña: 50% incident reduction)

**Weaknesses:**
- Walkthrough steps are UI-navigation-oriented rather than API/CLI-oriented
- Multi-agent visibility narrative could benefit from a concrete two-agent scenario example

**Suggestions:**
1. Add a short API-based alternative for Step 2 (connector setup)
2. Add a concrete multi-agent scenario showing two agents updating the same incident

---

### 9. AIOps automation with Ansible

**File:** [README-AIOps.md](README-AIOps.md)
**Score: 8.5 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 3 |
| Production Readiness (10%) | 4.5 |
| Business Framing (10%) | 4.5 |

**Stats:** ~7,500 words | 8 YAML blocks | 6+ substantive workflow/concept images | 4 pipeline phases with 16 numbered substeps

**Strengths:**
- Strong systems narrative: clear contrast between deterministic EDA scaling and AI-in-the-middle architecture
- Risk-aware layering with operational impact matrix and Crawl/Walk/Run framing
- Comprehensive reference tables for event types, observability tools, message queues, and AI endpoints
- "Where Do Good Playbooks Come From?" section maps four playbook sources to maturity stages

**Weaknesses:**
- Validation lacks verbatim sample outputs -- weaker as a standalone cookbook
- No single explicit "Solution Walkthrough" heading; depth is spread across sections 1-4
- AAP YAML snippets embed HTML emoji in `name` fields, which breaks copy-paste as valid YAML

**Suggestions:**
1. Add verbatim expected output for each pipeline stage
2. Sanitize YAML examples so template names are plain strings suitable for copy-paste
3. Insert the KB blockquote under the H1 per publishing standards

---

### 10. AI Infrastructure automation with Ansible

**File:** [README-IA.md](README-IA.md)
**Score: 7.3 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4 |
| Architecture Clarity (20%) | 4 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 3 |
| Production Readiness (10%) | 3 |
| Business Framing (10%) | 3 |

**Stats:** ~1,927 words | 3 YAML blocks | 1 workflow screenshot | ~8-10 major phases

**Strengths:**
- Clear two-collection story (`infra.ai` for provisioning, `redhat.ai` for model serving) with Automation Hub links
- Multiple integration paths: CLI inventory vs AAP EC2 sync, curl vs Ansible module for validation
- Honest scope note that AWS is an example while `infra.ai` supports other targets

**Weaknesses:**
- Missing canonical Overview, Prerequisites, and Maturity Path sections per the framework
- Validation has no verbatim expected output and no troubleshooting table
- No persona table, no quantified business pain

**Suggestions:**
1. Add an Overview section with a problem statement and consolidated Prerequisites table
2. Expand Validation with sample success output and a 3-5 row troubleshooting table
3. Add persona mapping and business framing

---

### 11. Intelligent Assistant with Red Hat AI Inference Server

**File:** [README-Intelligent-Assistant-RHAIIS.md](README-Intelligent-Assistant-RHAIIS.md)
**Score: 6.9 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4 |
| Architecture Clarity (20%) | 3 |
| Technical Executability (25%) | 3 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 3 |
| Business Framing (10%) | 4 |

**Stats:** ~1,625 words | 0 YAML blocks (2 YAML snippets in `~~~` fences) | Arcade demo + 1 GPU screenshot | ~12-14 major operations

**Strengths:**
- Tight integration target: connects RHAIIS container flags required for Lightspeed
- Actionable OpenShift wiring: Kubernetes Secret keys and AAP CR spec.lightspeed fields
- Concrete validation with curl test and expected answer text
- Rich Arcade demo embed for visual learners

**Weaknesses:**
- Missing framework sections: no Overview, Solution (components/personas), Workflow/Architecture, or Maturity Path
- No formal architecture diagram
- YAML snippets use `~~~` fences instead of ` ```yaml `

**Suggestions:**
1. Add an Overview with problem statement and a Workflow section with a simple diagram
2. Fix `podman run` formatting; convert `~~~` to ` ```yaml `
3. Add a Validation heading with a troubleshooting table

---

## Cross-Cutting Observations

**What changed since the May 2026 review:**

- **Four new guides** scored 9.2-9.8, raising the quality bar significantly
- **Windows Cert Rotation** is the new standard for AIOps validation (three decision paths, three test scenarios)
- **AAP HA/DR on OpenShift** is the deepest single guide in the collection and introduces the "validated test scenarios with observed SLAs" pattern -- all other guides should aspire to this level of production evidence
- **Mermaid adoption is now standard** -- all new guides use Mermaid diagrams (the convention rule change is paying off)
- **MCP coverage is growing** -- DevTools and ServiceNow guides both document MCP server integration

**Patterns that work well across guides:**
- Per-stage operational impact tables (Windows, OpenShift-EDA, HA/DR, EDB)
- Mermaid diagrams for workflow visualization (all new guides)
- Alternative architecture comparison tables (OpenShift-EDA: KafkaSink vs Channel)
- Validated test scenarios with timing data (HA/DR)
- Three-path decision logic with AI (Windows Cert)
- Arcade + video demos (Windows Cert, ServiceNow)

**Recurring gaps across guides:**
1. **KB blockquote under the title** -- still missing from most guides
2. **Source repo links** -- many guides show code excerpts but don't link to a full runnable repo
3. **Cost/resource estimates** -- only Windows Cert and DevTools address this consistently
4. **Inline mermaid styles** -- Windows Cert uses `style` directives that conflict with conventions
5. **YAML copy-paste fidelity** -- AIOps guide still embeds HTML emoji in YAML `name` fields

**Ranking rationale:**
- HA/DR on OpenShift (9.8) takes the top spot by depth, validated SLAs, and production-hardened procedures
- Windows Cert Rotation (9.5) ties with DevTools -- Windows wins on validation depth, DevTools wins on breadth
- OpenShift-EDA (9.2) is a strong foundational guide limited only by its deliberately basic immediate outcome
- The original top guides (Splunk, Instana, EDB, ServiceNow) remain strong but are now joined by guides that raise the bar on executable depth and production evidence
