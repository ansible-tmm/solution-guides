
# Review: Published Solution Guides

*Reviewed: May 7, 2026*

## Scorecard

| Rank | Solution Guide | Score | Verdict |
|------|---------------|-------|---------|
| 1 | [AIOps with Splunk and EDA](#1-aiops-with-splunk-and-event-driven-ansible) | 8.9/10 | Deepest multi-use-case guide; three integration patterns with strong validation and troubleshooting |
| 2 | [Automated Incident Remediation with IBM Instana](#2-automated-incident-remediation-with-ibm-instana) | 8.9/10 | Dual-path architecture (EDA vs native); per-use-case operational impact and unusually complete validation |
| 3 | [High-Availability AAP with EDB PostgreSQL DR](#3-high-availability-aap-with-edb-postgresql-dr) | 8.7/10 | Reference-grade DR architecture with diagrams, runbooks, and failback procedures |
| 4 | [AIOps automation with Ansible](#4-aiops-automation-with-ansible) | 8.5/10 | Strong foundational reference architecture; best systems narrative, observability catalog, and playbook source mapping |
| 5 | [Unlock AIOps with ServiceNow LEAP and Ansible MCP server](#5-unlock-aiops-with-servicenow-leap-and-ansible-mcp-server) | 8.3/10 | Strong LEAP/MCP governance story with YAML artifacts, verification commands, and full framework alignment |
| 6 | [AI Infrastructure automation with Ansible](#6-ai-infrastructure-automation-with-ansible) | 7.3/10 | Clear two-collection story (infra.ai + redhat.ai); needs framework alignment and deeper validation |
| 7 | [Intelligent Assistant with Red Hat AI Inference Server](#7-intelligent-assistant-with-red-hat-ai-inference-server) | 6.9/10 | Strong hands-on RHAIIS + Lightspeed hookup; weakest framework alignment of published guides |

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

### 1. AIOps with Splunk and Event-Driven Ansible

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

### 2. Automated Incident Remediation with IBM Instana

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

### 3. High-Availability AAP with EDB PostgreSQL DR

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

### 4. AIOps automation with Ansible

**File:** [README-AIOps.md](README-AIOps.md)
**Score: 8.5 / 10** *(updated May 2026 after adding Red Hat Lightspeed content and terminology updates)*

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
- Eight YAML examples spanning rulebooks, AI completions, URIs, git publish, and dynamic AAP resources
- Comprehensive reference tables for event types, observability tools, message queues, and AI endpoints
- Boundary-oriented troubleshooting table fills a gap most architecture docs skip
- New "Where Do Good Playbooks Come From?" section maps four playbook sources (Red Hat Lightspeed CVE, Advisor, RHEL System Roles, Automation code assistant) to maturity stages
- Terminology update blockquote clarifies Ansible Lightspeed / Red Hat Insights rebranding inline

**Weaknesses:**
- Validation is organized by stage but lacks verbatim sample outputs -- weaker as a standalone cookbook
- No single explicit "Solution Walkthrough" heading; depth is spread across sections 1-4
- AAP YAML snippets embed HTML emoji in `name` fields, which breaks copy-paste as valid YAML
- Missing KB blockquote under the title per repo convention

**Suggestions:**
1. Add verbatim expected output for each pipeline stage (event body, AI response structure, code assistant JSON)
2. Sanitize YAML examples so template names are plain strings suitable for copy-paste
3. Insert the KB blockquote under the H1 per publishing standards

---

### 5. Unlock AIOps with ServiceNow LEAP and Ansible MCP server

**File:** [README-AIOps-ServiceNow.md](README-AIOps-ServiceNow.md)
**Score: 8.3 / 10** *(updated May 2026 after major content expansion: YAML artifacts, verification commands, architecture diagrams, and full framework alignment)*

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4.5 |
| Architecture Clarity (20%) | 4.5 |
| Technical Executability (25%) | 4 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 4.5 |
| Business Framing (10%) | 4 |

**Stats:** ~3,500 words | 2 YAML blocks | 1 hero image + 1 SVG architecture diagram + 2 Mermaid diagrams | 4 walkthrough steps + 4 verification artifacts

**Strengths:**
- Complete framework alignment: Overview, Background, Solution, Workflow, Prerequisites, Solution Walkthrough, Validation, Maturity Path, and Related Guides all present
- Two executable YAML artifacts: `ansible.controller.job_template` for governed template-as-code and `servicenow.itsm.incident` for optional correlation follow-up
- Multi-format architecture coverage: hero image, SVG diagram, and Mermaid flowcharts with trust boundary documentation
- Dedicated MCP deployment topology section with explicit trust boundaries, TLS/mTLS, and token rotation guidance
- Verbatim `curl` verification artifacts for each validation checkpoint (template visibility, job launch, job status, ITSM correlation)
- Strong security/governance section treating integration as production automation with least privilege, change controls, and audit completeness
- Operational impact table by stage and measurable success metrics table with quantifiable indicators
- Arcade walkthrough embed as interactive companion to the written guide

**Weaknesses:**
- Walkthrough steps are UI-navigation-oriented (click paths) rather than API/CLI-oriented -- harder to reproduce without exact ServiceNow instance configuration
- Guide title changed from the original "Reducing MTTR" framing; the new title is more accurate but the card description could better highlight the MTTR outcome
- `servicenow.itsm` follow-up is marked optional -- could be stronger as a recommended pattern

**Suggestions:**
1. Add a short API-based alternative for Step 2 (connector setup) so readers without LEAP UI access can validate programmatically
2. Strengthen the `servicenow.itsm` follow-up from "optional" to "recommended" with a note on when to skip it

---

### 6. AI Infrastructure automation with Ansible

**File:** [README-IA.md](README-IA.md)
**KB Article:** [access.redhat.com/articles/7118390](https://access.redhat.com/articles/7118390)
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
- Operational bridge to AAP via workflow template description and screenshot

**Weaknesses:**
- Missing canonical Overview, Prerequisites, and Maturity Path sections per the framework
- `provision.yml` execution is never shown with equivalent clarity to the `ilab.yml` example
- Validation has no verbatim expected output and no troubleshooting table
- No persona table, no quantified business pain, and lighter production framing than the topic warrants

**Suggestions:**
1. Add an Overview section with a problem statement and a consolidated Prerequisites table
2. Show `provision.yml` execution alongside `ilab.yml` (or the AAP job settings equivalent)
3. Expand Validation with sample success output and a 3-5 row troubleshooting table

---

### 7. Intelligent Assistant with Red Hat AI Inference Server

**File:** [README-Intelligent-Assistant-RHAIIS.md](README-Intelligent-Assistant-RHAIIS.md)
**KB Article:** [access.redhat.com/articles/7130595](https://access.redhat.com/articles/7130595)
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
- Tight integration target: connects RHAIIS container flags required for Lightspeed (`--enable-auto-tool-choice`, `--tool-call-parser`)
- Actionable OpenShift wiring: Kubernetes `Secret` keys and AAP CR `spec.lightspeed` fields
- Concrete validation with curl test to `/v1/completions` and expected answer text
- Rich Arcade demo embed for visual learners
- Cross-links to the collection-based RHEL AI deployment path (README-IA.md)

**Weaknesses:**
- Missing framework sections: no Overview, Solution (components/personas), Workflow/Architecture, or Maturity Path
- No formal architecture diagram showing GPU host, inference server, AAP/OCP, and Lightspeed flow
- `podman run` formatting may break on copy-paste due to line continuation issues
- YAML snippets use `~~~` fences instead of ` ```yaml `, reducing syntax highlighting consistency

**Suggestions:**
1. Add an Overview with problem statement and a Workflow section with a simple diagram
2. Fix `podman run` shell formatting for unambiguous line continuation; convert `~~~` to ` ```yaml `
3. Add a Validation heading with a troubleshooting table (common failures: connectivity, 401/403, OOM/GPU, wrong URL path)

---

## Cross-Cutting Observations

**Patterns that work well across guides:**
- AIOps blog post link replaces generic product page across all four AIOps guides, adding real narrative context
- Automation Hub links for every collection mentioned
- Per-step operational impact ratings (EDB, Instana, Splunk)
- Persona mapping by stakeholder role (AIOps, Instana, ServiceNow, EDB)
- Crawl/Walk/Run maturity model with specific milestones per guide
- Blockquote callouts following the short-header-then-body convention

**Recurring gaps across most guides:**
1. **KB blockquote under the title** -- Most guides do not place the `access.redhat.com` link in a blockquote directly under H1 per repo convention
2. **Verbatim validation output** -- Most guides describe success indicators but do not show literal expected output
3. **Framework section naming** -- Several guides rename or omit canonical section names (Workflow, Solution Walkthrough, Prerequisites)
4. **YAML copy-paste fidelity** -- Some guides embed HTML, emoji, or formatting in YAML that breaks literal reuse
5. **Architecture diagrams** -- Published guides now use Mermaid or image diagrams; remaining WIP guides (SQS, Azure) still have ASCII flows to convert

**Ranking rationale:**
- Splunk and Instana tie at 8.9 but Splunk edges ahead on breadth (three use cases) while Instana leads on validation rigor
- EDB at 8.7 is the deepest single-topic guide with the most operational runbook content; ASCII diagrams now replaced with Mermaid
- AIOps at 8.5 is the strongest foundational reference with the best systems narrative and playbook source mapping
- ServiceNow at 8.3 made the biggest jump (from 7.1) after adding YAML artifacts, verification commands, multi-format architecture diagrams, and full framework alignment
- IA (7.3) is solid but needs framework alignment and more executable artifacts
- RHAIIS (6.9) is the most hands-on procedural guide but weakest on framework structure
