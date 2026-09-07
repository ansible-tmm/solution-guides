# Solution Guide Reviews

Weighted rubric from [README-best-practices.md](README-best-practices.md). Score each category 1-5. Final score = sum(score x weight) x 2, out of 10. Any category below 3 means revise before publishing.

| Guide | Outcome (20%) | Architecture (20%) | Executability (25%) | Validation (15%) | Production (10%) | Business (10%) | **Score** | Verdict |
|-------|---------------|--------------------|---------------------|------------------|------------------|----------------|-----------|---------|
| [Defend, Contain, Comply](README-DCC.md) | 5 | 5 | 4 | 5 | 4 | 5 | **9.3** | Publishable once KB ID is real |
| [Zero Trust Operations](README-ZTA.md) | 5 | 5 | 4 | 4 | 4 | 5 | **9.0** | Publishable; was missing from `index.md` |
| CME draft in cme repo (`README-CME-Compliance.md`) | 4 | 4 | 4 | 4 | 3 | 4 | **7.8** | Do not publish here; superseded |
| [Reducing Residual CVE Risk](README-CME.md) | 5 | 5 | 4 | 4 | 4 | 5 | **9.0** | Publishable; Custom collection not on Hub |

---

## Defend, Contain, Comply (`README-DCC.md`)

**Score:** 9.3 / 10
**Verdict:** Strong closed-loop vulnerability lifecycle guide. Ready to publish once the Knowledge Base article ID is real.

### Strengths

- Outcome-oriented title and quantified overview (CVE-2024-38476, hours-to-seconds MTTC, OPA-enforced patching).
- Clear Defend / Contain / Comply phases mapped to AAP workflow templates, with per-stage operational impact.
- Executable walkthrough: Splunk add-on, EDA rulebook, OPA Rego gates, CIS hardening, Podman image delivery.
- Validation includes a concrete test, verbatim expected output, and a troubleshooting table with real failure modes.
- Persona table covers SecOps, platform engineering, compliance, and IT director without collapsing them into one "user."

### Weaknesses

- Knowledge Base blockquote still uses `XXXXXXX`.
- Maturity path lacks the twemoji icons used in ZTA and the starter template.
- Related Guides did not originally point at the CME compensating-controls guide (same CVE, different layer).
- EDA/Splunk path is lab-specific; production readers need an explicit "swap Splunk for any SIEM webhook" note.
- `community.general` is listed as Community while other tables in the ecosystem are inconsistent about Hub classification -- not a blocker.

### Suggestions

- Replace the KB placeholder when the customer-portal article is filed.
- Add a one-line SIEM-agnostic note in Prerequisites or the Defend walkthrough.
- Cross-link [README-CME.md](README-CME.md) so readers see containment/patching versus residual-risk scoring as complementary, not competing.
- Add twemoji to the Crawl / Walk / Run table for visual consistency with ZTA.

---

## Zero Trust Operations (`README-ZTA.md`)

**Score:** 9.0 / 10
**Verdict:** Best NIST SP 800-207 mapping in the set. Must appear on the site index.

### Strengths

- Five-layer PEP / PDP / PIP mapping with an eight-principle table that a CISO can use in a briefing.
- Workshop-backed walkthrough: IdM, Vault short-lived creds, AAP Policy as Code, SPIFFE, EDA revocation.
- Per-stage validation table plus an end-to-end brute-force simulation.
- AAP 2.6 Policy as Code requirement is called out in a correctly formatted blockquote, with a 2.5 fallback (playbook-level OPA).
- File is wrapped in `{% raw %}` because walkthrough YAML contains Jinja2.

### Weaknesses

- Listed in `README.md` but was missing from `index.md` -- GitHub Pages would not show a card.
- Knowledge Base blockquote still uses `XXXXXXX`.
- Validation `curl` used a hardcoded `admin:password` Splunk basic-auth pair.
- Related Guides skipped DCC and originally had no CME link.
- Maturity path is workshop-stage-indexed, which is accurate for the lab but slightly less transferable than DCC's operational Crawl / Walk / Run.

### Suggestions

- Add a foundational card on `index.md` (in-scope for this review pass).
- Replace hardcoded Splunk credentials with `$SPLUNK_USER` / `$SPLUNK_PASS` or a vaulted credential in a follow-up edit.
- Cross-link DCC (containment and patching) and CME (compensating controls / residual CVSS) from Related Guides.
- Keep the workshop GitHub link; it is the right demo pointer.

---

## Existing CME draft (`cme/README-CME-Compliance.md`)

**Score:** 7.8 / 10
**Verdict:** Solid collection walkthrough, but it overlaps DCC, over-claims EDA, and lives in the wrong repo. Canonical guide is [README-CME.md](README-CME.md).

### Strengths

- Six-step walkthrough grounded in real playbooks (`cve_response.yml`, `_apply_control.yml`, `configure_controller.yml`).
- Validation command matches collection usage comments; expected summary is from a real run.
- Profiles (`minimal` 25, `rhel9_baseline` 55, `full` 118) and verify-versus-remediate split are documented.
- CaC section shows surveys, approval nodes, and custom credential types.

### Weaknesses

- Title leads with "CME," which is taxonomy jargon. A VP of IT cannot tell the value from the title alone.
- Problem statement is the same "CVE drops, scramble" frame as DCC, using the same CVE-2024-38476 example, without stating what is *different* (compensating controls and environmental scoring, not vendor patching).
- Related Guides are redhat.com / GitHub product links, not sibling solution guides.
- Missing KB blockquote under the title.
- `cme.controls` is Custom (not on Automation Hub); `community.general` is a real Galaxy dependency and was absent from the collections table.
- Em dashes in job template names (the original draft used U+2014 in `CME CVE Response`) violate repo convention (`--`).
- British spelling (`organisations`, `defences`) does not match DCC / ZTA.
- Workflow narrative treats an EDA rulebook as shipped content. There is no rulebook in the collection.
- Playbook snippets use short module names (`cme_query`) that only resolve inside the collection; published guides need FQCNs.

### Suggestions (applied in `README-CME.md`)

- Reframe title around residual risk and compensating controls.
- Scope-callout to DCC: same CVE, DCC patches httpd, CME scores and applies host mitigations.
- Drop EDA as a featured walkthrough step; put scanner webhooks in Crawl / Walk / Run and Related Guides.
- Show `cme.controls.cme_query` / `cme.controls.cme_score` FQCNs.
- Mark `cme.controls` as Custom with a GitHub link; add `community.general` and `ansible.controller` to the Hub table.
- US spelling, `--` instead of em dashes, KB placeholder, internal related-guide links.

Leave `/home/nmartins/Development/Repos/cme/README-CME-Compliance.md` unchanged. Canonical copy lives in this repository.

---

## Reducing Residual CVE Risk with Compensating Controls (`README-CME.md`)

**Score:** 9.0 / 10
**Verdict:** Publishable. Custom collection is not on Automation Hub; EDA is honestly scoped as a Run-stage integration, not a shipped rulebook.

### Strengths

- Title passes the VP litmus test without requiring the reader to know what CME is.
- Explicit differentiation from DCC in Overview: patching remains the fix; this guide names, verifies, remediates, and scores compensating controls until the errata lands.
- Walkthrough follows collection facts: `cme_query` -> PRE verify -> block/rescue remediate -> POST HTML -> `cme_score`, with FQCNs and CaC as a subsection of scoring.
- Profiles, verify-only categories, and hardware/compile-time fall-through are called out so readers do not expect 118/118 green.
- Validation uses the real `cve_response.yml` invocation; troubleshooting covers MCP down, empty `cme_ids`, unregistered hosts, and approval timeout.

### Weaknesses

- `cme.controls` is GitHub-only; Hub cells for that row cannot be a published collection URL yet.
- Expected PLAY RECAP and attenuation numbers are from a prior lab run, not a CI fixture in this repo.
- No dedicated workshop card equivalent to DCC / ZTA (taxonomy site and GitHub collection are the demo pointers).

### Suggestions

- Publish `cme.controls` to Automation Hub (or Galaxy) and swap the Custom link.
- Add a short EDA rulebook to the CME repo when scanner-triggered Run is productized; then promote it into the walkthrough.
- File a KB article and replace `XXXXXXX`.

### Self-score notes

| Indicator | Minimum | Count |
|-----------|---------|-------|
| Walkthrough steps | 3 | 5 |
| YAML code blocks | 2 | 6+ |
| Diagrams | 1 | 1 ASCII + 1 Controller workflow |
| Validation scenarios | 1 | CLI + Controller API |
| Guide length | ~800 words | well above |

No category below 3. Production Readiness is 4 because CaC, RBAC, and approval gates are present, but the collection is unpublished and EDA is integration-only.

### Reasoning versus the cme-repo draft

Score rose from 7.8 to 9.0 because Outcome Clarity and Architecture Clarity moved from 4 to 5 (distinct problem from DCC, honest EDA scope, FQCNs) and Production Readiness moved from 3 to 4 (RBAC, approval, verify-only honesty). Executability and Validation stay at 4 until Hub publishing and a pinned expected-output fixture exist.
