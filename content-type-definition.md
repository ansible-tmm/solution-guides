# Solution Guides -- Content Type Definition

*Prepared: March 25, 2026*

---

## Use Case

### Red Hat Goal: Why is Red Hat creating this content?

Solution guides demonstrate how Ansible Automation Platform solves real operational problems -- AIOps, infrastructure provisioning, network management, ITSM integration -- using certified and validated Ansible content collections alongside partner technologies. The goal is to move customers from evaluating AAP to implementing it by providing production-ready reference architectures with executable automation code, not just conceptual overviews.

These guides directly support Red Hat's strategy to position AAP as the automation backbone for AI-driven IT operations. They showcase the platform's differentiated capabilities -- Event-Driven Ansible, Ansible Lightspeed, Red Hat AI integration -- in the context of solving measurable business problems (reducing MTTR, eliminating manual triage, enabling self-healing infrastructure). Each guide is designed to be usable by field sellers as customer-facing enablement and by SAs as implementation references.

### Visitor Intent: What is the intended recipient looking for?

Visitors are IT practitioners (SREs, network engineers, automation architects) and IT decision makers evaluating or implementing Ansible Automation Platform. Based on the content and its presentation, visitors are trying to:

- **Evaluate** whether AAP can solve a specific operational problem they face (e.g., "Can Ansible integrate with our Splunk alerts?", "How do we automate ServiceNow ticket enrichment?")
- **Implement** a working automation pipeline using AAP with their existing tools (Splunk, ServiceNow, AWS, Azure, IBM Instana)
- **Justify** investment in AAP to their leadership by seeing measurable outcomes (MTTR reduction, cost savings, compliance improvements) and an incremental adoption path (Crawl/Walk/Run)
- **Learn** how AAP components (EDA Controller, Automation Controller, Lightspeed) connect to each other and to external systems

**Potential search queries and entry points:**

| Entry Point | Example Queries |
|-------------|----------------|
| Organic search | "ansible aiops automation", "event-driven ansible splunk integration", "ansible servicenow ticket enrichment", "ansible lightspeed self-hosted setup" |
| access.redhat.com KB search | "AIOps solution guide", "EDA rulebook", "network backup ansible" |
| Internal Red Hat (field/SA) | "ansible aiops demo for customer", "splunk EDA reference architecture" |
| GitHub Pages site | Direct navigation from https://ansible-tmm.github.io/solution-guides/ with search and partner/type filtering |
| Cross-links from other guides | Each guide links to related guides, creating a discovery path (e.g., AIOps -> Splunk -> ServiceNow) |
| Hands-on workshops | Workshop participants are directed to the guides for deeper reference after completing labs |

---

## Call to Action (CTA)

Each solution guide contains 2-4 CTAs depending on the topic and partner integrations involved:

| CTA Type | Where It Appears | Tracking |
|----------|-----------------|----------|
| **Try the hands-on lab** | "Recommended Demos and Self-Paced Labs" section, linking to Instruqt labs or workshop showrooms | Instruqt lab starts, workshop registrations |
| **Clone the source code** | GitHub repository links in the Solution section (e.g., `ansible-tmm/aiops-splunk-eda`) | GitHub clone/fork counts |
| **Read the KB article** | Blockquote link at the top of every guide pointing to its access.redhat.com article | KB article page views |
| **Explore related guides** | "Related Guides" section at the bottom with cross-links to the next logical guide | GitHub Pages navigation, page views |
| **Install the Ansible collection** | Collection links throughout Prerequisites pointing to Automation Hub | Automation Hub collection installs |

The primary CTA is **try the hands-on lab or clone the source repo** -- moving the visitor from reading to doing. The secondary CTA is **explore the next guide in the journey** (e.g., after reading the foundational AIOps guide, try the Splunk, ServiceNow, or Azure integration guide).

Tracking is currently via GitHub Pages analytics (page views, time on page), KB article views on access.redhat.com, and downstream metrics from linked workshops/labs. There is no click-tracking on individual CTAs at this time.

---

## Common Sections / Document Outline

All solution guides follow a standardized framework defined in the [Best Practices for Writing Solution Guides](README-best-practices.md). The section names map 1:1 across every guide:

| Section | Purpose | Key Elements |
|---------|---------|-------------|
| **Title** | `[Topic] - Solution Guide` format, outcome-oriented | KB article link in a blockquote directly below |
| **Overview** | Problem statement (2-4 sentences), hero image, table of contents | Quantified pain where possible; linked TOC for navigation |
| **Background** | Domain context -- what the topic is and why it matters | 1-3 paragraphs; links to redhat.com topic pages |
| **Solution** | Components list, Who Benefits persona table, demos/videos/source code | Three-column persona table (Persona, Challenge, What They Gain); linked partner logos |
| **Prerequisites** | AAP version, Ansible content collections (with Automation Hub links), external systems | Collections table with Type and Purpose columns; operational impact ratings |
| **[Topic] Workflow** | Architecture diagrams, narrative walkthrough | At least one diagram (3-6 blocks); 5-8 sentence narrative |
| **Solution Walkthrough** | Step-by-step technical depth with featured YAML code | Numbered steps; featured code blocks (not full repo dumps); per-step operational impact |
| **Validation** | Concrete test, expected output, troubleshooting table | Executable test command (curl, ansible-playbook, or UI action); verbatim expected output; symptom/cause/fix troubleshooting table |
| **Maturity Path** | Crawl/Walk/Run progression specific to the use case | Table mapping maturity levels to specific automation capabilities |
| **Related Guides** | Cross-links to prerequisite, companion, and next-step guides | Annotated links explaining why each related guide is relevant |

**Unique presentation aspects:**

- **GitHub Pages site** (https://ansible-tmm.github.io/solution-guides/) with PatternFly v6 card layout, partner logo filtering (Splunk, ServiceNow, Azure, IBM Instana), text search, and type filtering (Foundational vs. Integration)
- **Jekyll layout** (`_layouts/default.html`) includes a persistent nav header, footer, Prism.js syntax highlighting with copy-to-clipboard on all code blocks, and Red Hat branding via custom SCSS extending the `jekyll-theme-dinky` base
- **Dual publishing**: Guides exist as markdown files on GitHub Pages and are also published as KB articles on access.redhat.com
- **Blockquote styling**: First line of blockquotes renders as a colored header bar (tip, warning, "why" callouts) via custom CSS

---

## Current Solution Guides

### Published Guides (GitHub Pages + access.redhat.com)

| Guide | GitHub Pages | KB Article | Status |
|-------|-------------|------------|--------|
| AIOps automation with Ansible | [README-AIOps](README-AIOps.md) | [7119667](https://access.redhat.com/articles/7119667) | Published |
| AI Infrastructure automation with Ansible | [README-IA](README-IA.md) | [7118390](https://access.redhat.com/articles/7118390) | Published |
| Intelligent Assistant with Red Hat AI Inference Server | [README-Intelligent-Assistant-RHAIIS](README-Intelligent-Assistant-RHAIIS.md) | [7130595](https://access.redhat.com/articles/7130595) | Published |

### In-Progress Guides (GitHub Pages)

| Guide | GitHub Pages | Partners |
|-------|-------------|----------|
| AIOps with Splunk and Event-Driven Ansible | [README-AIOps-Splunk-ITSI](README-AIOps-Splunk-ITSI.md) | Splunk |
| Reducing MTTR with ServiceNow Ticket Enrichment | [README-AIOps-ServiceNow](README-AIOps-ServiceNow.md) | ServiceNow |
| Event-Driven Remediation with Azure Service Bus | [README-AIOps-Azure-Service-Bus](README-AIOps-Azure-Service-Bus.md) | Azure |
| Automated Incident Remediation with IBM Instana | [README-Instana-AIOps](README-Instana-AIOps.md) | IBM Instana |
| AIOps with AWS SQS and Event-Driven Ansible | [README-SQS](README-SQS.md) | AWS |

### Legacy Guides (access.redhat.com only, under review for migration)

| Guide | KB Article |
|-------|------------|
| Automation Dashboard and Analytics | [7136383](https://access.redhat.com/articles/7136383) |
| Get started with EDA (Ansible Rulebook) | [7136720](https://access.redhat.com/articles/7136720) |
| ServiceNow ITSM Ticket Enrichment Automation | [7127603](https://access.redhat.com/articles/7127603) |
| Network Fact Gathering & Reporting | [7123361](https://access.redhat.com/articles/7123361) |
| Network Back Up and Configuration | [7123366](https://access.redhat.com/articles/7123366) |

---

## Length

| Format | Typical Length |
|--------|---------------|
| **Full solution guide** (HTML/Markdown) | 1,500--4,000 words (integration guides with multiple use cases like the Splunk guide run ~4,000 words; foundational guides like AIOps run ~3,000 words) |
| **Minimum viable guide** | ~800 words, 3 walkthrough steps, 2 YAML code blocks, 1 diagram |
| **Ideal guide** | 1,500--2,500 words, 5-8 walkthrough steps, 4-6 YAML code blocks, 2-3 diagrams |
| **Companion hands-on lab** | 60-90 minutes (referenced, not part of the guide itself) |

---

## Lifecycle

### Update Process

| Trigger | Frequency | Action |
|---------|-----------|--------|
| **AAP major release** (e.g., 2.5 -> 2.6) | ~Annually | Review all guides for compatibility; update AAP version references, collection versions, and any changed UI paths |
| **Ansible collection update** | Quarterly review | Verify featured code still works with latest certified/validated collection versions; update Automation Hub links if namespaces change |
| **Partner product change** (Splunk, ServiceNow, etc.) | As needed | Update integration-specific steps if partner APIs or configuration paths change |
| **New guide creation** | Ongoing | Author follows the starter template in Best Practices; peer review scored against the quality rubric before publishing |
| **Quality review** | Biannually | Score all published guides against the weighted rubric; flag any category below 3 for revision |

### Archival and Removal

- Guides that reference deprecated AAP features or discontinued partner integrations are moved to the "Legacy Solution Guides (Under Review)" section on the GitHub Pages site
- Legacy guides link directly to their access.redhat.com KB article rather than rendering markdown on GitHub Pages
- KB articles on access.redhat.com follow the customer portal's own archival process; the GitHub Pages site is the source of truth for current guide status
- The `_config.yml` exclude list controls which files are rendered on GitHub Pages; excluded files are not publicly accessible

---

## Owners

| Role | Name | Team |
|------|------|------|
| **Lead / SME** | Sean Cavanaugh | Ansible Automation Platform -- Technical Marketing (TMM) |
| **Content framework** | Sean Cavanaugh | Ansible Automation Platform -- Technical Marketing (TMM) |
| **Peer reviewers** | TMM team members | Ansible Automation Platform -- Technical Marketing (TMM) |

*Note: Individual guides may have additional contributing authors. The GitHub repository commit history tracks all contributors.*

---

## Measurement

### Key Performance Indicators

| KPI | What It Measures | Source |
|-----|-----------------|--------|
| **GitHub Pages page views** | Reach -- how many people are discovering and reading the guides | GitHub Pages analytics |
| **Time on page** | Engagement -- are visitors reading through the guide or bouncing | GitHub Pages analytics |
| **KB article views** | Reach via the customer portal -- how many customers find the guide through access.redhat.com | Red Hat KB analytics |
| **Hands-on lab starts** | Conversion -- are readers moving from the guide to trying the automation | Instruqt analytics |
| **GitHub repo clones/forks** | Adoption -- are practitioners taking the source code to implement | GitHub repository insights |
| **Automation Hub collection installs** | Downstream adoption -- are the featured collections being installed | Automation Hub metrics |
| **Workshop attendance** | Funnel -- are guides driving interest in live workshops | Workshop registration data |
| **Support ticket reduction** | Business impact -- are guides reducing the volume of "how do I do X with AAP" support cases | Support case tagging (indirect) |

### Effectiveness Signals

- **Positive**: High time-on-page (>3 min), lab start rate >10% of page views, GitHub stars/forks trending up, cross-link click-through between guides
- **Negative**: High bounce rate, no lab starts, stale guides with no updates for >6 months, quality score below 6/10 on the rubric
