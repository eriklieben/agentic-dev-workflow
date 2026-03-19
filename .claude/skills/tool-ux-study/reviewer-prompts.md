# Expert Reviewer Prompts

Instructions for spawning expert reviewer agents in Phase 6.

---

## Product Manager Reviewer (Phase 6.1)

Spawn with:
- `subagent_type: "general-purpose"`
- `mode: "bypassPermissions"`
- `model: REVIEWER_MODEL` (from `--review-model` argument; if not set, do NOT pass `model` — let it inherit the parent model)
- `team_name: "test-run-{TIMESTAMP}"`
- `name: "product-manager"`

Prompt the PM to:
1. Read `${REPORT_DIR}/REPORT.md`
2. Explore `../my-docs` — start with README.md, then read product/feature-overview.md, product/approval-workflows.md, reference/api-endpoints.md, reference/domain-model.md, user-guide/, and any other relevant docs
3. Compare test findings against product requirements
4. Write `${REPORT_DIR}/review-product-manager.md` with:
   - Executive Assessment (product vision alignment)
   - Requirements Alignment (working, not meeting, planned but not built, not in scope)
   - Gap Analysis
   - Priority Assessment (P0/P1/P2 from PM perspective)
   - Untested Features (in docs but not covered by testing)
   - Documentation Improvements — For each doc file in `../my-docs` that needs updating, list: the file path, what's wrong or outdated (e.g. feature marked "Live" but frontend doesn't exist, missing error states, user journey doesn't match reality), and what the fix should be. Reference the specific tester findings that revealed the discrepancy.
   - Recommendations

---

## UX Designer Reviewer (Phase 6.2)

Spawn with:
- `subagent_type: "general-purpose"`
- `mode: "bypassPermissions"`
- `model: REVIEWER_MODEL` (from `--review-model` argument; if not set, do NOT pass `model` — let it inherit the parent model)
- `team_name: "test-run-{TIMESTAMP}"`
- `name: "ux-designer"`

Prompt the UX Designer to:
1. Read `${REPORT_DIR}/REPORT.md` and 3-4 individual tester reports (newcomer, blocked persona, mobile tester)
2. Explore `../my-docs` for design system docs, user journeys
3. Explore `../my-frontend/src/app` for component patterns, layouts, styles
4. Analyze from a UX design perspective: information architecture, navigation patterns, error handling, mobile-first quality, dark mode implementation, component design
5. Write `${REPORT_DIR}/review-ux-designer.md` with:
   - Design Quality Assessment
   - Information Architecture Analysis
   - Navigation & Wayfinding
   - Error Handling Patterns
   - Dark Mode Implementation
   - Mobile Design Quality
   - User Journey Analysis
   - Design Recommendations (quick wins, medium effort, major redesign)
   - Design System Gaps
   - Documentation Improvements — For each design-related doc file in `../my-docs` that needs updating, list: the file path, what's wrong or missing (e.g. design system docs missing error state patterns, user journeys that don't match actual UX, component docs that omit mobile behavior or dark mode variants), and the specific fix. Reference tester findings that revealed the gap.

---

## WCAG Accessibility Expert Reviewer (Phase 6.3)

**Skip if `--duser=0` or no accessibility testers were spawned.**

Spawn with:
- `subagent_type: "general-purpose"`
- `mode: "bypassPermissions"`
- `model: REVIEWER_MODEL` (from `--review-model` argument; if not set, do NOT pass `model` — let it inherit the parent model)
- `team_name: "test-run-{TIMESTAMP}"`
- `name: "wcag-expert"`

Prompt the WCAG expert to:
1. Read `${REPORT_DIR}/REPORT.md` and all accessibility tester reports (`tester-{username}.md` for a11y testers)
2. Read the regular tester reports to find accessibility-adjacent issues (contrast, touch targets, keyboard navigation) that non-disabled testers reported
3. Explore `../my-frontend/src/app` for component templates, ARIA attributes, semantic HTML usage
4. Explore `../my-docs` for design system docs (colors, typography, components)
5. Evaluate against **WCAG 2.2 AA** success criteria, organized by principle
6. Write `${REPORT_DIR}/review-wcag-expert.md` with:

```markdown
---
standard: WCAG 2.2 AA
date: YYYY-MM-DD
accessibilityTestersReviewed: N
---

# WCAG 2.2 AA Accessibility Review

<ReportMeta />

## Executive Assessment

{2-3 paragraphs: Overall accessibility posture. How far is the platform from AA compliance? What are the biggest barriers? Which user groups are most affected?}

## Compliance Summary

| Principle | Pass | Fail | Needs Review | N/A |
|-----------|------|------|--------------|-----|
| 1. Perceivable | X | X | X | X |
| 2. Operable | X | X | X | X |
| 3. Understandable | X | X | X | X |
| 4. Robust | X | X | X | X |
| **Total** | X | X | X | X |

## Principle 1: Perceivable

### 1.1 Text Alternatives (Level A)
- **Status**: Pass / Fail / Needs Review
- **Finding**: {description}
- **Tester evidence**: {quote from a11y testers if relevant}
- **WCAG criterion**: 1.1.1 Non-text Content

### 1.3 Adaptable (Level A)
- **Status**: ...
- **Finding**: ...

### 1.4 Distinguishable (Level AA)
- **1.4.3 Contrast (Minimum)**: {Check all text meets 4.5:1 ratio, large text 3:1}
- **1.4.4 Resize Text**: {Can text be resized to 200% without loss of content?}
- **1.4.11 Non-text Contrast**: {UI components and graphics meet 3:1}

(Continue for all relevant WCAG 2.2 AA criteria under each principle)

## Principle 2: Operable
(keyboard access, timing, seizures, navigation)

## Principle 3: Understandable
(readable, predictable, input assistance)

## Principle 4: Robust
(compatible with assistive technologies, valid HTML, ARIA usage)

## Tester-Reported Barriers

Map each accessibility tester's findings to specific WCAG criteria:

| Tester | Disability | Finding | WCAG Criterion | Severity |
|--------|-----------|---------|----------------|----------|
| {name} | {disability} | {what happened} | {criterion number} | Critical/Serious/Minor |

## Cross-Reference with Regular Testers

Accessibility-adjacent issues reported by regular testers (contrast, mobile touch targets, etc.) mapped to WCAG criteria.

## Recommendations by Priority

### Critical (Blocks access for some users)
1. **{Issue}** — WCAG {criterion}
   - **Impact**: {who is affected and how}
   - **Fix**: {specific remediation}

### Serious (Significant barriers)
1. ...

### Minor (Improvements for better experience)
1. ...

## Testing Gaps

{What couldn't be tested with AI agents? What should be tested with real assistive technology users? Suggest specific follow-up tests.}
```

---

## Product Backlog Generation (Phase 6.5)

After all reviews are complete, compile `${REPORT_DIR}/backlog.md`:

```markdown
---
generatedFrom: REPORT.md, PM Review, UX Review, WCAG Review
date: YYYY-MM-DD
testRun: theme-test-{TIMESTAMP}
testers: N (avg readiness X/10)
---

# Product Backlog — UX Test Run YYYY-MM-DD

<ReportMeta />

## Priority Legend
| Priority | Meaning | SLA |
|----------|---------|-----|
| P0 | Blocker — must fix before any user-facing release | This sprint |
| P1 | High — should fix in next sprint | Next sprint |
| P2 | Medium — backlog, plan within 2-3 sprints | 2-3 sprints |
| P3 | Low — nice to have, plan when capacity allows | Backlog |

## Effort Legend
| Effort | Meaning |
|--------|---------|
| XS | < 1 hour |
| S | 1-4 hours |
| M | 1-2 days |
| L | 3-5 days |
| XL | 1-2 weeks |

## P0 — Blockers
### PBI-001: {Title}
- **Priority**: P0
- **Effort**: {XS/S/M/L/XL}
- **Area**: {Backend/Frontend/Design system}
- **Found by**: {tester names and count}
- **Description**: {What's wrong, including root cause if known}
- **Acceptance criteria**: {Bullet list of what "done" looks like}
- **Source**: {Links to REPORT.md bugs, PM review sections, UX review sections, tester reports}

(repeat for each PBI, grouped by priority: P0, P1, P2, P3)

## Backlog Summary
| Priority | Count | Effort breakdown |
|----------|-------|-----------------|
| P0 | X | ... |
| P1 | X | ... |
| P2 | X | ... |
| P3 | X | ... |
| Total | X | |

### Sprint Planning Suggestion
{Suggest which PBIs to tackle in Sprint 1, 2, 3 with estimated impact on readiness score}
```

**Rules for PBI generation:**
- Deduplicate: If the same issue appears in REPORT.md bugs, PM review, and UX review, create ONE PBI that references all three sources
- Every consolidated bug from REPORT.md becomes a PBI (assign priority based on severity: Critical->P0, High->P1, Medium->P2, Low->P3)
- Add PBIs for WCAG failures identified by the accessibility expert — Critical WCAG failures are P0, Serious are P1
- Add PBIs for design system gaps identified by UX Designer that aren't already covered by bugs
- Add PBIs for documentation improvements identified by PM (e.g., update feature-overview.md to distinguish backend-live from frontend-live)
- Include acceptance criteria for every PBI — these should be specific and testable
- Cross-reference sources with markdown links to the relevant report sections
