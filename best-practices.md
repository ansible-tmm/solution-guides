---
layout: default
title: Best Practices
permalink: /best-practices/
inline_edit: true
---

<div class="hub-intro-row">
  <p class="guide-types-lead">AAP Guides use two authoring frameworks. Pick the one that matches your content type before you start writing or scoring a draft.</p>
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
    <h2 class="guide-type-panel__title">Solution Guide Best Practices</h2>
  </div>

  <dl class="guide-type-facts">
    <div class="guide-type-fact">
      <dt>Who it is for</dt>
      <dd>Field teams and solution architects writing partner-focused reference architectures that show how AAP solves a measurable operational problem.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What it covers</dt>
      <dd>Nine-section framework: outcome-oriented title, business framing, workflow diagrams, solution walkthrough, validation, and Crawl/Walk/Run maturity path.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>Scoring</dt>
      <dd>Weighted rubric with category-aware adjustments for AIOps and Network automation Solution Guides. AIOps Use Cases use a lighter rubric row in the same document.</dd>
    </div>
  </dl>

  <a href="{{ '/README-best-practices' | relative_url }}" class="guide-type-panel__cta">Solution Guide Framework and Rubric</a>
</section>

<section class="guide-type-panel guide-type-panel--implementation">
  <div class="guide-type-panel__header">
    <span class="guide-type-badge guide-type-badge--implementation"><i class="fas fa-cogs" aria-hidden="true"></i> Implementation Guide</span>
    <h2 class="guide-type-panel__title">Implementation Guide Best Practices</h2>
  </div>

  <dl class="guide-type-facts">
    <div class="guide-type-fact">
      <dt>Who it is for</dt>
      <dd>Platform owners and senior engineers writing deployment, tuning, and day-2 operations guides for AAP in production.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>What it covers</dt>
      <dd>Platform-focused framework: architecture decisions, step-by-step walkthroughs, validation with expected output, runbooks, and production readiness.</dd>
    </div>
    <div class="guide-type-fact">
      <dt>Scoring</dt>
      <dd>Separate rubric weighting architecture clarity, executability, validation, and day-2 readiness over business framing.</dd>
    </div>
  </dl>

  <a href="{{ '/README-best-practices-implementation' | relative_url }}" class="guide-type-panel__cta">Implementation Guide Framework and Rubric</a>
</section>

</div>

<section class="guide-types-together">
  <h2 id="why-two-rubrics">Why two rubrics?</h2>
  <p>Solution guides and implementation guides answer different questions. Scoring them with one rubric either penalizes platform guides for missing partner ROI narratives, or lets solution guides pass without production-grade validation.</p>

  <table>
    <thead>
      <tr>
        <th>Dimension</th>
        <th>Solution Guide</th>
        <th>Implementation Guide</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Primary question</td>
        <td>Why and what -- the business problem and integrated outcome</td>
        <td>How -- reliable platform configuration at scale</td>
      </tr>
      <tr>
        <td>Reader</td>
        <td>IT leaders, architects evaluating a partner integration</td>
        <td>Platform owners, SREs deploying and operating AAP</td>
      </tr>
      <tr>
        <td>Success signal</td>
        <td>Measurable operational outcome with partner context</td>
        <td>Validated deployment with runbooks and day-2 guidance</td>
      </tr>
      <tr>
        <td>Rubric emphasis</td>
        <td>Business framing, workflow narrative, partner integration depth</td>
        <td>Architecture clarity, executability, production and day-2 readiness</td>
      </tr>
    </tbody>
  </table>

  <p class="guide-types-together__closing">Not sure which type fits? See <a href="{{ '/guide-types/' | relative_url }}">Guide Types</a> for definitions, tracks, and examples.</p>
</section>
