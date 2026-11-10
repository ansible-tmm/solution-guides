# Legacy KB guide retirement

GitHub tracking only (not published on the AAP Guides microsite). Use this file when someone asks where a retired access.redhat.com catalog card went.

**Status:** Removed from the AAP Guides home page **Legacy Solution Guides** section on the fork (`fix/catalog-ig-taxonomy-fork` / fork `main`). Official product documentation (or open Jiras) owns the follow-on path.

## Where each guide went

| Retired catalog card | Former KB article | Destination / follow-on | Jira |
|----------------------|-------------------|-------------------------|------|
| Get started with EDA (Ansible Rulebook) | [7136720](https://access.redhat.com/articles/7136720) | Being folded into EDA product docs as a "Getting Started with Rulebooks" section (linked from existing gap work) | [AAP-91972](https://redhat.atlassian.net/browse/AAP-91972) |
| Network Fact Gathering & Reporting | [7123361](https://access.redhat.com/articles/7123361) | Review against existing AAP 2.7 networking playbook docs and decide merge vs replace: [Gather and display network device info with a playbook](https://docs.redhat.com/en/documentation/red_hat_ansible_automation_platform/2.7/develop-assembly_networking_playbook) | [AAP-99047](https://redhat.atlassian.net/browse/AAP-99047) |
| Network Back Up and Configuration | [7123366](https://access.redhat.com/articles/7123366) | Add KB content into the AAP documentation set | [AAP-99048](https://redhat.atlassian.net/browse/AAP-99048) |

Anyone with Jira access can open the tickets above to see migration status. The KB articles may remain on access.redhat.com until docs land; they are no longer promoted from the AAP Guides catalog.

## Migrated into a multi-use-case guide

| Former Legacy catalog card | Destination |
|----------------------------|-------------|
| ServiceNow ITSM Ticket Enrichment | [ServiceNow ITSM automation with Ansible](README-AIOps-ServiceNow.md#use-case-a-servicenow-itsm-ticket-enrichment) (Use Case A). Legacy path [`README-ServiceNow-ITSM.md`](README-ServiceNow-ITSM.md) redirects. The Legacy gallery on the home page is empty and removed. |

## Why we removed them

The catalog is for full markdown Solution and Implementation Guides in this repo. access.redhat.com-only cards without a maintained markdown guide here were confusing the field and duplicating (or drifting from) official docs work tracked in Jira.

## Slack / field blurb

```text
AAP Guides: we retired three legacy access.redhat.com cards from the catalog. Content is migrating into official AAP docs -- track in Jira:

• EDA getting started (KB 7136720) → AAP-91972
• Network fact gathering (KB 7123361) → AAP-99047 (vs AAP 2.7 networking playbook docs)
• Network backup & config (KB 7123366) → AAP-99048

Tracking file (GitHub): https://github.com/IPvSean/solution-guides/blob/main/LEGACY-KB-RETIREMENT.md
```
