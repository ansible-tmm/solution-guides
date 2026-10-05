---
layout: default
title: Guide Reviews
permalink: /reviews/
inline_edit: true
---

<div class="hub-intro-row">
  <p class="guide-types-lead">Published guides are scored against the rubric for their content type. Choose the review page that matches the guide you are evaluating.</p>
  <div class="edit-link-wrap edit-link-wrap--catalog">
    <a href="https://github.com/ansible-tmm/solution-guides/edit/main/{{ page.path }}"
       target="_blank" class="edit-link">
      <i class="fas fa-pencil-alt" aria-hidden="true"></i>
      Edit on GitHub
    </a>
  </div>
</div>

<div class="guide-types-grid">

<section class="guide-type-panel guide-type-panel--solution">
  <div class="guide-type-panel__header">
    <span class="guide-type-badge guide-type-badge--solution"><i class="fas fa-check-circle" aria-hidden="true"></i> Solution Guide</span>
    <h2 class="guide-type-panel__title">Solution Guide Reviews</h2>
  </div>

  <p class="guide-type-track__body">Ranked scorecard and per-guide reviews for published Solution Guides -- AIOps and Event-Driven tracks. Scored against the <a href="{{ '/README-best-practices' | relative_url }}">Solution Guide rubric</a> with track-aware adjustments.</p>

  <a href="{{ '/opus-review-solution' | relative_url }}" class="guide-type-panel__cta">View Solution Guide Reviews</a>
</section>

<section class="guide-type-panel guide-type-panel--implementation">
  <div class="guide-type-panel__header">
    <span class="guide-type-badge guide-type-badge--implementation"><i class="fas fa-cogs" aria-hidden="true"></i> Implementation Guide</span>
    <h2 class="guide-type-panel__title">Implementation Guide Reviews</h2>
  </div>

  <p class="guide-type-track__body">Ranked scorecard and per-guide reviews for published Implementation Guides -- HA/DR, database tuning, developer tooling, and platform hardening. Scored against the <a href="{{ '/README-best-practices-implementation' | relative_url }}">Implementation Guide rubric</a>.</p>

  <a href="{{ '/opus-review-implementation' | relative_url }}" class="guide-type-panel__cta">View Implementation Guide Reviews</a>
</section>

</div>
