---
name: multi-use-case-solution-guide
description: >-
  Structure or merge Ansible Automation Platform Solution Guides that cover
  multiple use cases under one partner topic (Use Case A/B/C). Use when combining
  guides, adding a second use case, writing Splunk/ServiceNow-style multi-outcome
  SGs, or updating catalog cards and legacy redirects for those guides.
---

# Multi-use-case Solution Guides

Canonical rules live in [README-best-practices.md](../../../README-best-practices.md#23-multi-use-case-solution-guides). Copy the skeleton from [Appendix: Multi-use-case starter](../../../README-best-practices.md#appendix-multi-use-case-starter).

## When to use this pattern

- One partner (ServiceNow, Splunk, and so on) has **two or more distinct operational outcomes**
- You would otherwise publish duplicate catalog cards or leave a legacy guide that drifts

Do **not** use this for the six foundational AIOps patterns in `README-AIOps.md` -- those stay as the AIOps Use Case track, not separate Solution Guide catalog entries.

## Required shape

1. Broader `<h1>` + Solution Guide badge + partner hero
2. Overview: problem statement, Use Case A/B jump links, comparison table (outcome / impact / maturity)
3. In-page Table of Contents with **bold** links to each use case
4. Shared Background, Solution (tag components by UC), Prerequisites **once** with UC-tagged rows -- do not repeat Prerequisites inside use cases
5. Each use case as `<h2 id="use-case-a-…">Use Case A: …</h2>` with nested `###` Demos/labs (only assets for that UC), Workflow, Walkthrough, Validation, Summary -- **not** a mixed demos dump at the top
6. Single Next Steps CTA at the end (no Related Guides section)

## Catalog and redirects

- **Card body:** sell outcomes readers care about. Never "two use cases under one Solution Guide" or other authoring meta.
- **Legacy URL:** thin `meta refresh` + link to `#use-case-…` (see `README-ServiceNow-ITSM.md` / `README-AIOps-Ticket-Enrichment.md`).

## Scoring

Apply the **Multi-use-case Solution Guide** rubric row in best practices: cap Outcome / Architecture / Validation at 3 if use cases are unclear in ToC, lack per-UC flow, or lack per-UC validation. Depth minimums apply **per use case**.

## Reference examples

- `README-AIOps-ServiceNow.md`
- `README-AIOps-Splunk-ITSI.md`
