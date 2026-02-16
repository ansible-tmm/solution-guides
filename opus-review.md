
# Review: Solution Guides and Knowledge Base Articles

*Reviewed: February 16, 2026*

## Scorecard

| Rank | Solution Guide | Score | Verdict |
|------|---------------|-------|---------|
| 1 | [Configuring Lightspeed with AI Inference Server](#1-configuring-ansible-lightspeed-intelligent-assistant-with-red-hat-ai-inference-server-on-rhel) | 8.5/10 | Full-stack technical depth from GPU drivers to AAP integration |
| 2 | [Automation Dashboard and Analytics](#2-automation-dashboard-and-analytics---solution-guide) | 8.5/10 | Best persona mapping and ROI tooling of any guide |
| 3 | [AIOps automation with Ansible](#3-aiops-automation-with-ansible---solution-guide) | 8/10 | Best narrative flow, diagrams, and reference tables |
| 4 | [Network Back Up and Configuration](#4-network-back-up-and-configuration---solution-guide) | 7.5/10 | Actionable, per-step impact ratings, backup/restore pattern |
| 5 | [AI Infrastructure automation with Ansible](#5-ai-infrastructure-automation-with-ansible---solution-guide) | 7/10 | Strong connector content between infra.ai and redhat.ai |
| 6 | [ServiceNow ITSM Ticket Enrichment](#6-servicenow-itsm-ticket-enrichment-automation---solution-guide) | 7/10 | Good CVE enrichment example, practical multi-step workflow |
| 7 | [Get started with EDA (Ansible Rulebook)](#7-get-started-with-eda-ansible-rulebook---solution-guide) | 6/10 | Strong tutorial, but reads as a manual not a solution |
| 8 | [Network Fact Gathering & Reporting](#8-network-fact-gathering--reporting---solution-guide) | 5.5/10 | Useful basics, but too thin to stand alone |

---

## How This Was Scored

Each article was evaluated against the quality scoring model from the [Best Practices for Writing Solution Guides](README-best-practices.md):

| Category | Weight |
|----------|--------|
| Outcome Clarity | 20% |
| Architecture Clarity | 20% |
| Technical Executability | 25% |
| Validation/Testability | 15% |
| Production Readiness Info | 10% |
| Business Framing | 10% |

Scores were also reconciled against an independent review by Gemini. Where our grades diverged, I re-evaluated and documented my reasoning in the "Gemini vs. Opus" section of each review.

---

## Part 1: Best Practices Document Review

The best practices framework is strong -- it provides a clear, opinionated structure that would meaningfully raise the quality bar for future guides. Below are suggestions for improvement, grounded in what I observed reviewing the two existing local guides (README-AIOps.md and README-IA.md) and all eight KB articles.

### What Works Well

- **Checklist-driven approach**: The per-section checklists make this actionable for authors and reviewable for editors.
- **Quality Scoring Model**: Having a weighted rubric brings objectivity to what is typically a subjective review process.
- **Common Failure Modes**: Calling out anti-patterns explicitly is valuable -- especially "Overview Only guides with no code" and "Screenshot-heavy, YAML-light content."
- **Crawl/Walk/Run maturity model**: This is a great concept. Neither existing guide implements it yet, which shows there is room to lead by example.

### Suggestions for Improvement

1. **Add a Starter Template / Skeleton** -- Authors need a copy-paste markdown skeleton they can duplicate and fill in. *(Implemented)*
2. **Acknowledge the KB Article Metadata Pattern** -- Published articles use Operational Impact, Business/Technical Value Drivers, Recommended Labs. *(Implemented)*
3. **Add Guidance on Linking to Automation Hub Collections** -- Every collection mentioned must link to its Automation Hub page. *(Implemented)*
4. **Add a Section on Visual Design Patterns** -- When to use diagrams vs. screenshots vs. tables vs. code blocks. *(Implemented)*
5. **Address Cross-Linking Between Guides** -- Require prerequisite and complementary guide links. *(Implemented)*
6. **Reconcile the Title Standard with Reality** -- Balance outcome-oriented titles with the `[Topic] - Solution Guide` KB convention. *(Implemented)*
7. **Add Version Tracking Guidance** -- None of the guides include AAP version tested, collection versions, or a "last updated" date.
8. **Expand Validation with AAP-Specific Patterns** -- Show how to verify Job Templates, EDA activations, and workflow chains.
9. **Self-Grade the Existing Guides** -- Demonstrate transparency by scoring README-AIOps.md and README-IA.md against the rubric.

---

## Part 2: Knowledge Base Article Reviews

---

### 1. Configuring Ansible Lightspeed intelligent assistant with Red Hat AI Inference Server on RHEL

**Link**: https://access.redhat.com/articles/7130595
**Score: 8.5 / 10**

**Gemini vs. Opus:** Gemini scored this 9.6 ("The Gold Standard"). I agree it is the strongest technical guide in the set. The full-stack coverage -- GPU drivers, NVIDIA setup, container deployment, model serving, and AAP OpenShift CR configuration -- is genuinely impressive and rare. However, I deduct points for: no architecture diagram, no business framing (why self-host?), and no persona mapping. A 9.6 implies near-perfection; a guide that starts with `dnf install` without first explaining *who this is for* and *why it matters* has room to grow. Revised up from my original 8 to **8.5**.

**Strengths:**
- Extremely practical and end-to-end: GPU setup, NVIDIA drivers, container deployment, AAP integration
- Clear validation step with curl test and expected output
- Good coverage of hardware options (NVIDIA and AMD)
- Provides the exact podman command with all required flags and explains each one
- Connects the deployment to AAP via OpenShift CR configuration -- completes the loop
- Cross-links to the AI Infrastructure guide (7118390) for the infra.ai/redhat.ai path

**Weaknesses:**
- No architecture diagram showing GPU host -> Inference Server -> AAP/OCP -> Lightspeed UI
- No business framing -- why should someone self-host vs. use cloud?
- No persona mapping
- No maturity path

**Suggestions:**
- Add 1-2 sentences framing the "why": air-gapped environments, data sovereignty, cost control
- Add an architecture diagram showing the end-to-end data flow
- Note the relationship between this guide and RHEL AI deployment -- they are complementary but different entry points

---

### 2. Automation Dashboard and Analytics - Solution Guide

**Link**: https://access.redhat.com/articles/7136383
**Score: 8.5 / 10**

**Gemini vs. Opus:** Gemini scored this 9.0 ("The Blueprint"). I largely agree -- this is the best-structured guide for business alignment. The persona mapping (Technical Teams, Operational Managers, Leadership) is exactly what the best practices doc advocates for, and no other guide does it this well. The 5-step Dashboard setup walkthrough is thorough. I revised up from 8 to **8.5** because the persona work and ROI tooling coverage genuinely set a standard. Held back from 9 because there is no architecture diagram and zero YAML/code examples.

**Strengths:**
- Excellent persona mapping (Technical Teams, Operational Managers, Leadership) with specific value propositions for each
- Thorough step-by-step setup instructions for the Automation Dashboard (5-step walkthrough)
- Good metrics tables explaining what each dashboard component measures
- Includes both on-premise (Dashboard) and cloud-based (Analytics) paths
- Strong "Next Steps" section with actionable follow-ups
- The Automation Savings Planner section is unique and high-value

**Weaknesses:**
- No architecture or workflow diagram showing how Dashboard connects to AAP instances
- Very long and dense -- could benefit from a visual overview at the top
- No featured Ansible Playbook code -- this is the only guide with zero YAML
- No explicit problem statement with quantified pain

**Suggestions:**
- Add a simple architecture diagram: AAP Instance -> OAuth2 -> Dashboard -> Reports
- Add a 2-3 sentence problem statement at the top quantifying the pain
- Consider splitting into two guides (Dashboard + Analytics) given the length
- Include a sample `clusters.yaml` configuration as featured code

---

### 3. AIOps automation with Ansible - Solution Guide

**Link**: https://access.redhat.com/articles/7119667
**Score: 8 / 10**

**Gemini vs. Opus:** Gemini scored this 9.5 ("The Logic Master"). I agree the narrative flow is the best of any guide -- the 4-part AIOps workflow breakdown is clear and well-diagrammed. The event/source/response tables are genuinely useful reference material. However, 9.5 implies near-perfection, and this guide has real gaps: Section 4 (Execute Remediation) is essentially a stub, there is no validation section, and several typos remain. Revised up from my original 7 to **8** -- credit where it's due on narrative and diagrams, but the incomplete sections and lack of validation hold it back.

**Strengths:**
- Comprehensive and ambitious -- covers the full AIOps lifecycle in a single guide
- Excellent reference tables (event types, observability tools, message queues, OpenAI-compatible tools)
- Strong workflow diagrams with clickable images
- Good featured code (EDA rulebook, API calls, survey spec, job templates)
- Effective use of callout boxes for tips, questions, and warnings
- Links to Automation Hub for every collection and tool mentioned

**Weaknesses:**
- No explicit problem statement with quantified pain
- No validation section -- the guide ends at "Execute Remediation" without showing how to verify the fix worked
- Section 4 (Execute Remediation / Policy Enforcement) is essentially a stub with just a link
- Several minor typos: "Interference" should be "Inference", "infrastrucure" (multiple), "componenets", double space in "Execute  Remediation"
- No maturity path / crawl-walk-run
- No explicit prerequisites section

**Suggestions:**
- Flesh out Section 4 (Execute Remediation) -- it is the climax of the entire workflow
- Add a validation section: "How do you know it worked?"
- Add a prerequisites section listing AAP version, required collections, and external dependencies
- Fix the typos noted above
- Add a maturity path: Manual remediation -> AI-assisted diagnosis -> AI-generated playbooks -> Fully automated self-healing

---

### 4. Network Back Up and Configuration - Solution Guide

**Link**: https://access.redhat.com/articles/7123366
**Score: 7.5 / 10**

**Gemini vs. Opus:** Gemini scored this 8.0 ("Solid Utility"). I agree it's a solid, practical guide. The per-step operational impact ratings (Low for backup, Medium for config, High for restore) are a pattern every other guide should adopt. Revised up from 7 to **7.5**.

**Strengths:**
- Good structure with 3 clear steps (Backup, Configure, Restore)
- Per-step operational impact ratings (Low, Medium, High) -- best practice that other guides should adopt
- Practical playbook examples using validated content (network.backup)
- Good warning about testing restore in dev before production
- Links to EDA network automation labs as next steps
- Lists specific Cisco IOS modules available for configuration

**Weaknesses:**
- No architecture diagram
- No explicit business framing or ROI discussion
- No validation step (how do you verify the backup was successful?)
- GitHub PAT setup is mentioned in prerequisites but not walked through
- No maturity path

**Suggestions:**
- Add a validation step after each operation (e.g., diff the backup file, verify VLAN creation)
- Add a simple diagram: Backup -> Git -> Config Change -> Validate -> Restore (if needed)
- Add maturity path: Manual backups -> Scheduled automated backups -> Config drift detection -> Self-healing network

---

### 5. AI Infrastructure automation with Ansible - Solution Guide

**Link**: https://access.redhat.com/articles/7118390
**Score: 7 / 10**

**Gemini vs. Opus:** Gemini scored this 7.5 ("Strong Connector Content"). Close to my original 7. I agree it's solid technically -- good collection references, clear validation, CLI + AAP dual paths. The half-point difference isn't worth debating. Keeping at **7**.

**Strengths:**
- Clear, well-structured walkthrough from provisioning to validation
- Good collection references (infra.ai and redhat.ai) with Automation Hub links
- Provides both CLI and AAP workflow paths
- Includes validation via both curl and the redhat.ai.completion module
- Good "Final Notes" section on extensibility

**Weaknesses:**
- No executive hook / problem statement
- No persona mapping
- No operational impact rating
- No business value framing or ROI discussion
- No maturity path
- Collection version numbers and AAP version not specified

**Suggestions:**
- Add a 2-sentence problem statement: "Provisioning AI infrastructure manually is error-prone and time-consuming..."
- Add operational impact and business/technical value driver sections
- Specify tested AAP version and collection versions
- Add a crawl/walk/run: Provision on CLI -> Automate via AAP workflow -> Integrate with Lightspeed

---

### 6. ServiceNow ITSM Ticket Enrichment Automation - Solution Guide

**Link**: https://access.redhat.com/articles/7127603
**Score: 7 / 10**

**Gemini vs. Opus:** Gemini scored this 6.5 ("Good Use Case, less technical meat"). Now that the full content is visible, I'm slightly more generous at **7**. The CVE enrichment example using Red Hat Insights is a genuinely practical multi-domain workflow (ITSM + Security + API), and the 3-step progression (gather -> create -> enrich) tells a coherent story. It does have less volume than the AI guides, but what's there is well-executed and immediately usable.

**Strengths:**
- Clear 3-step progression: gather ticket data, create tickets, enrich with CVE info
- The CVE enrichment example using Red Hat Insights is practical and multi-domain (ITSM + Security + API)
- Good use of `ansible.builtin.uri` for API integration alongside the `servicenow.itsm` collection
- Mentions `set_fact` and `set_stats` for workflow data persistence -- useful production tip
- Good prerequisites with learning path links
- References the ServiceNow store app (API for AAP) which is a real-world prerequisite people miss
- Operational impact clearly stated as None

**Weaknesses:**
- No architecture diagram showing the Ansible -> Insights API -> ServiceNow flow
- No explicit validation section (how do you confirm the ticket was enriched correctly?)
- The screenshots referenced in the original article don't appear in the fetched content
- No maturity path
- Survey usage is mentioned but not shown in detail

**Suggestions:**
- Add a diagram: AAP -> Red Hat Insights API -> ServiceNow ITSM -> Enriched Ticket
- Add a validation step: show the enriched ticket fields in ServiceNow or verify via `incident_info`
- Expand the survey example to show how `advisory_id` is captured
- Add maturity path: Manual ticket creation -> Automated enrichment -> EDA-triggered closed-loop remediation

---

### 7. Get started with EDA (Ansible Rulebook) - Solution Guide

**Link**: https://access.redhat.com/articles/7136720
**Score: 6 / 10**

**Gemini vs. Opus:** Gemini scored this 4.0 ("Needs Work -- feels like a manual, not a Solution"). This is where I had the largest change of opinion. My original score was 8 based on the technical quality of the hands-on examples and terminal output. Re-evaluating through the lens of *"is this a solution guide?"* -- Gemini is right that it reads as a tutorial/getting-started manual rather than solving a real operational problem. The webhook "Ansible is super cool" example is pedagogically clear but has zero production relevance. However, 4.0 feels too harsh for the Kafka coverage, the dynamic event data section, and the fact that it *does* teach the core EDA concepts well. Revised down from 8 to **6** -- technically competent tutorial, but wrong framing for a "Solution Guide."

**Strengths:**
- Excellent hands-on approach with clear test scenarios (matching vs. non-matching messages)
- Shows both webhook and Kafka sources -- covering dev and production patterns
- Includes actual terminal output showing what success and failure look like
- Good explanation of core components (Action, Condition, Source)
- Demonstrates dynamic event data passthrough (sender example)
- Good demo and lab links

**Weaknesses:**
- Reads as a tutorial/manual, not a solution guide -- no real-world operational outcome
- The webhook "Ansible is super cool" example has zero production relevance
- No architecture diagram showing the event flow
- No explicit business framing / problem statement
- No validation section separate from the tutorial steps
- The Kafka example assumes infrastructure is already running
- No maturity path
- Title is procedural ("Get started with...") rather than outcome-oriented

**Suggestions:**
- Reframe around a real use case: "Responding to Infrastructure Alerts with Event-Driven Ansible"
- Replace the "Ansible is super cool" example with something operational (e.g., service down alert)
- Add a brief problem statement: "Manual alert triage costs teams X hours/week..."
- Add an architecture diagram: Event Source -> Rulebook Engine -> Condition Match -> Action
- Include a note on how to test in AAP (not just CLI `ansible-rulebook`)
- Add maturity progression: Webhook dev testing -> Kafka production -> Event Streams multi-source

---

### 8. Network Fact Gathering & Reporting - Solution Guide

**Link**: https://access.redhat.com/articles/7123361
**Score: 5.5 / 10**

**Gemini vs. Opus:** Gemini scored this 5.5 ("The Basics"). I agree -- revised down from my original 6. It's useful as a starting point but simply too thin to stand alone as a solution guide. Only 2 steps with minimal depth, and Step 2 (export to reporting tool) is essentially hand-waved.

**Strengths:**
- Good prerequisite section with extensive learning path links for beginners
- Clear featured collections (Cisco IOS, network.backup)
- Simple, approachable code example
- Links to demos and self-paced labs
- Links to the companion Backup/Config guide as a next step

**Weaknesses:**
- Very thin -- only 2 steps with minimal depth
- No architecture diagram
- No validation section (how do you verify the facts were gathered correctly?)
- Step 2 (export to reporting tool) is hand-waved with "you can export your data" -- no actual code
- No business framing beyond bullet points
- No maturity path

**Suggestions:**
- Expand Step 2 with an actual Jinja2 template example or Splunk export playbook
- Add a validation step showing expected fact output structure
- Consider merging this with the Backup/Config guide since both are short and complementary
- Add a maturity path: Fact gathering -> Compliance reporting -> Drift detection -> Automated remediation

---

## Cross-Cutting Observations

**Patterns that work well across guides:**
- Linking to Automation Hub for every collection mentioned
- Providing both CLI and AAP Controller paths (IA guide, Network guides)
- Including demo/lab links alongside written content
- Per-step operational impact ratings (Network Backup guide)
- Persona mapping by stakeholder role (Dashboard guide)

**Recurring gaps across most guides:**
1. **No architecture diagrams** -- Only the AIOps guide has workflow visuals. Most guides would benefit from even a simple 3-5 block flow diagram.
2. **No explicit problem statement** -- Most guides start with "Background" or "Overview" without framing the business pain.
3. **Validation is inconsistent** -- Some guides have it (IA, Lightspeed), many do not (AIOps, Dashboard, Network Fact Gathering).
4. **No maturity path** -- Zero guides implement crawl/walk/run despite the best practices doc advocating for it.
5. **No version tracking** -- None specify AAP version tested, collection versions, or a "last updated" date.
6. **Typos and polish** -- Several guides have minor spelling/grammar issues that could be caught with a review pass.
