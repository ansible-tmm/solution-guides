---
layout: default
title: Review: Published Solution Guides
permalink: /opus-review-solution/
---

# Review: Published Solution Guides

*Reviewed: September 25, 2026*

## Scorecard

| Rank | Solution Guide | Score | Verdict |
|------|---------------|-------|---------|
| 1 | [Windows Certificate Rotation with AI Risk Analysis](#1-windows-certificate-rotation-with-ai-risk-analysis) | 9.8/10 | Elite AIOps guide: three decision paths, three test scenarios with syntax-highlighted output, arcade demo, video, observability callout, graceful fallback, and success metrics |
| 2 | [AIOps with Splunk and EDA](#2-aiops-with-splunk-and-event-driven-ansible) | 8.9/10 | Deepest multi-use-case guide; three integration patterns with strong validation and troubleshooting |
| 3 | [Automated Incident Remediation with IBM Instana](#3-automated-incident-remediation-with-ibm-instana) | 8.9/10 | Dual-path architecture (EDA vs native); per-use-case operational impact and unusually complete validation |
| 4 | [Unlock AIOps with ServiceNow LEAP and Ansible MCP server](#4-unlock-aiops-with-servicenow-leap-and-ansible-mcp-server) | 8.7/10 | Strong LEAP/MCP governance story with MTTR focus, customer evidence, multi-agent visibility |
| 5 | [AIOps automation with Ansible](#5-aiops-automation-with-ansible) | 8.6/10 | Strongest foundational reference architecture; curated-path framing, MCP workflow clarity, structured validation, and comprehensive event/tool catalog |

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

### 1. Windows Certificate Rotation with AI Risk Analysis

**File:** [README-AIOps-Windows-Cert-Rotation.md](README-AIOps-Windows-Cert-Rotation.md)
**Score: 9.8 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 4.75 |
| Validation/Testability (15%) | 5 |
| Production Readiness (10%) | 5 |
| Business Framing (10%) | 5 |

**Stats:** ~4,400 words | 7 YAML blocks | 1 hero image + 1 Mermaid diagram + 6 screenshots | Arcade embed + YouTube video | 4 walkthrough steps (with 3a/3b branching) | 3 validation test paths with custom `ansible-output` syntax highlighting | Observability platform callout

**Strengths:**
- Three-path AI decision routing (PROCEED, SCHEDULE, ESCALATE) is the most sophisticated workflow logic in any guide -- demonstrates real-world AI judgment, not just "ask AI and do what it says"
- Three complete validation test paths with curl commands and syntax-highlighted expected output using custom `ansible-output` Prism language
- Graceful fallback: rescue block escalates when AI is unavailable, rotation job remains available for manual launch
- "Measuring Success" table with 6 quantifiable metrics and where to find them -- sets the standard for ROI evidence
- Arcade interactive demo AND YouTube video -- both available inline
- Per-stage operational impact table with clear "why" column
- Cost notes (under $0.01/call) address a real concern about AI API usage
- Production readiness callout for Dynatrace/IBM Instana connects the demo simulation to real-world observability deployment
- Business value and Technical value promoted to h3 headings -- immediately scannable without blending into the TOC
- Decision routing (PROCEED/SCHEDULE/ESCALATE) broken into three distinct bullets for clarity

**Weaknesses:**
- Mermaid diagram uses inline `style F fill:#f9f,stroke:#333` (minor convention deviation, renders well visually)
- No link to a source repo with the full playbooks -- readers must assemble from excerpts

**Suggestions:**
1. Add a link to a GitHub repo with the complete playbook set when available
2. Consider removing the inline `style` directive from the Mermaid diagram (or keep it -- it looks good)

---

### 2. AIOps with Splunk and Event-Driven Ansible

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

### 3. Automated Incident Remediation with IBM Instana

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

### 4. Unlock AIOps with ServiceNow LEAP and Ansible MCP server

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

### 5. AIOps automation with Ansible

**File:** [README-AIOps.md](README-AIOps.md)
**Score: 8.6 / 10**

| Category | Score |
|----------|-------|
| Outcome Clarity (20%) | 4.5 |
| Architecture Clarity (20%) | 5 |
| Technical Executability (25%) | 3.5 |
| Validation/Testability (15%) | 4 |
| Production Readiness (10%) | 4.5 |
| Business Framing (10%) | 4.5 |

**Stats:** ~4,800 words | 1 YAML block | 1 Mermaid diagram | 4 substantive images + light/dark logo catalog | 4 pipeline phases (Detect → MCP → Correlate → Execute) | Key Terms glossary with 10 entries | 6-card use-case strip

**Strengths:**
- Curated-path framing is now the clearest of any guide: the opening deterministic-vs-AIOps table immediately shows why curated remediation matters, and the "Why select instead of generate?" callout anchors the entire narrative
- Four-phase workflow (Detect → MCP search → Correlate and select → Execute approved job) maps cleanly to both the Mermaid diagram and the use-case 4 cross-link -- readers always know where they are
- MCP phase has its own section with a concrete read-path table (search JTs, search workflows, RBAC boundary) -- strongest MCP coverage in the foundational guide
- Validation section now has a structured stage-by-stage checklist and a dedicated troubleshooting table (up from no structured validation in the July review)
- "Trusted sources for the approved library" table distinguishes Red Hat Lightspeed curated content, Advisor recommendations, pre-approved AAP library, RHEL System Roles, and Automation code assistant -- the only guide that separates all five sources
- Event source catalog (application, infrastructure, network/security, observability-driven) with tool-logo tables and Automation Hub links is the most comprehensive event reference across all guides
- Key Terms glossary with 10 entries and cross-links to guide sections provides a standalone reference glossary
- Production guardrails table (library-first, approvals, validation, policy) is concise and actionable
- UC04 cross-link positions this guide as the high-level walkthrough and use case 4 as the deep-dive pattern page

**Weaknesses:**
- Only one YAML block (Kafka rulebook) -- down from eight in the July review as depth was delegated to partner and use-case pages; the guide's centerpiece claim (MCP library search and governed launch) has no runnable code example
- No verbatim expected output anywhere -- validation checklist describes what to verify but never shows a concrete `ansible-output` block or API response
- Use-case strip HTML is a large block that breaks reading flow in the source markdown; readers in GitHub preview see a wall of raw HTML before the workflow sections

**Suggestions:**
1. Add a short MCP artifact -- even a 5-line `curl` or `ansible-playbook` snippet showing a governed template search and launch -- to back the architectural claim with executable proof
2. Add one verbatim `ansible-output` block (for example a successful EDA activation log or MCP search response) to the Validation section
3. Consider a second YAML block for the MCP-driven launch or a workflow-template-as-code excerpt to bring Technical Executability back toward 4

---

## Cross-Cutting Observations

**What changed since the July 2026 review:**

- **AIOps foundational guide** (8.5 → 8.6) was significantly restructured: curated-path default is now the opening thesis, four-phase workflow with MCP, structured validation checklist and troubleshooting table, Key Terms glossary, UC04 cross-link, and light/dark tool-logo catalog. YAML depth was deliberately delegated to partner and use-case pages
- **Windows Cert Rotation** remains the standard for AIOps validation (three decision paths, three test scenarios with syntax-highlighted output)
- **MCP coverage is growing** -- the ServiceNow guide documents MCP server integration alongside governed template-as-code; the foundational AIOps guide now has a dedicated MCP search phase with a read-path table
- **Closed-loop incident narratives** are now the baseline -- Splunk and Instana both demonstrate detect-through-remediate completeness with per-stage validation

**Patterns that work well across solution guides:**
- Per-stage operational impact tables (Windows, Instana)
- Three-path AI decision logic with graceful fallback (Windows Cert)
- Arcade + video demos (Windows Cert, ServiceNow)
- Dual-path or multi-pattern architecture comparisons (Instana: EDA vs native; Splunk: ITSI, webhook, OSPF)
- Measurable success metrics and ROI recap tables (Windows, Instana, ServiceNow)
- Key Terms glossaries with Automation Hub links (AIOps foundational)
- Curated-path framing with "Why select instead of generate?" rationale (AIOps foundational)

**Recurring gaps across solution guides:**
1. **Source repo links** -- many guides show code excerpts but don't link to a full runnable repo
2. **Cost estimates** -- only Windows Cert addresses AI API cost consistently
3. **MCP executable artifacts** -- the foundational AIOps guide describes the MCP search workflow but has no runnable code; adding a short `curl` or playbook snippet would back the architectural claim
4. **ansible-output highlighting** -- now available site-wide; guides with playbook output should adopt it (Windows Cert sets the standard)
5. **Missing KB blockquotes** -- Splunk and AIOps guides lack the legacy KB link under the title

**Ranking rationale:**
- Windows Cert Rotation (9.8) is the reference standard for AIOps guides: event-driven detection, AI judgment, governed execution, ITSM audit trail, and custom syntax highlighting
- Splunk and Instana tie at 8.9 -- Splunk wins on multi-use-case depth and Splunk-specific operational detail; Instana wins on dual-path architecture clarity and per-use-case validation
- ServiceNow (8.7) is the strongest MCP governance story with customer evidence and multi-agent visibility
- AIOps automation with Ansible (8.6) gains from curated-path clarity, structured validation, MCP workflow detail, and the Key Terms glossary -- but trails on executable depth (one YAML block) and lacks verbatim expected output
