# Report Templates

Templates for all reports generated during the UX study. Used in Phases 4 and 5.

---

## Observation Notes Template (Phase 4.1)

Create `${REPORT_DIR}/observation-notes.md`:

```markdown
---
facilitator: Team Lead (AI UX Research Facilitator)
date: YYYY-MM-DD HH:MM
testers: N
---

# Observation Notes — UX Test Run

<ReportMeta />

---

```

### Per-Tester Entry (Phase 4.2, Step C)

Append for each tester report:

```markdown
## Tester: {username} ({viewport}-{theme}) — Score: X/10

**Emotional arc**: {1-2 sentences — e.g., "Started curious, became frustrated at navigation, recovered on events page"}
**Key friction**: {bullet list of friction moments with severity}
**Delight**: {what worked well}
**Pattern matches**: {Does this confirm or contradict patterns from earlier testers? e.g., "Third tester to struggle with proposals — confirms navigation pattern issue"}
**Notable quote**: > "{the most vivid think-aloud quote from this tester}"
**Screenshots reviewed**: {list which screenshots you read and what you saw, or "None — smooth experience"}

---
```

### Pattern Check Entry (Phase 4.2, Step D)

Add every 2-3 testers:

```markdown
## 🔍 Pattern Check (after N testers)

**Emerging friction patterns**:
- {pattern}: seen in {tester1, tester2} — severity: {level}
- {pattern}: seen in {tester1} — watching for confirmation

**Emerging delight patterns**:
- {pattern}: praised by {tester1, tester2}

**Contradictions or surprises**:
- {e.g., "Daan found groups intuitive but Sophie struggled — might be persona-dependent or theme-dependent"}

**Hypotheses forming**:
- {e.g., "Navigation to proposals may be the #1 friction point — 3/4 testers struggled"}

---
```

---

## Affinity Map Template (Phase 5.2)

Create `${REPORT_DIR}/affinity-map.md`:

```markdown
---
method: Clustered from observation notes across N testers
themesIdentified: X
---

# Affinity Map — UX Test Run YYYY-MM-DD

<ReportMeta />

---

## Theme 1: {Descriptive theme name}

**Pattern**: {1-2 sentences describing the underlying pattern — what's actually happening, not just what page it's on}
**Severity**: Critical / Serious / Minor
**Frequency**: {N} of {total} testers encountered this
**Affected configurations**: {e.g., "all viewports", "dark mode only", "mobile only"}

**Tester evidence**:
- **{tester1}** ({viewport}-{theme}): > "{quote}" — {context}
- **{tester2}** ({viewport}-{theme}): > "{quote}" — {context}
- **{tester3}** ({viewport}-{theme}): > "{quote}" — {context}

**Insight**: {What this pattern reveals about the platform's UX — the "so what?"}
**Recommendation**: {Specific, actionable recommendation}

---

## Theme 2: {name}
(same structure)

---

...

## Standalone Observations

Observations that didn't cluster into themes but are still noteworthy:

- **{tester}** ({viewport}-{theme}): {observation} — "{quote}"
- ...
```

**Guidelines for theming:**
- Group by the **problem**, not by page or feature. "Navigation confusion" is a theme; "Groups page issues" is not.
- Aim for **5-10 themes** for a typical run. Fewer than 5 means you're being too broad; more than 10 means you're being too granular.
- A theme needs at least 2 testers' evidence to be a theme. Single-tester observations go in "Standalone Observations."
- Positive themes count too — "Onboarding creates confidence" is a valid theme if multiple testers praised it.
- Include both friction themes and delight themes.

---

## Individual Tester Report Template (Phase 5.3)

Write to `${REPORT_DIR}/tester-{username}.md`. Look up the user's roles and feature flags from `seed-data/test-users.json`.

```markdown
---
persona: {persona_name} — "{one-line persona summary}"
user: {user_name} ({user_email})
theme: {theme}
viewport: {viewport}
date: YYYY-MM-DD HH:MM
readinessScore: X/10
roles:
  - {role1}
  - {role2}
featureFlags:
  - {flag1}
  - {flag2}
---

# Tester Report: {username}

<ReportMeta />

**Themes contributed to**: [Theme 1](affinity-map.md#theme-1-name), [Theme 3](affinity-map.md#theme-3-name), [Theme 7](affinity-map.md#theme-7-name)

## My Experience (Think-Aloud Summary)

{3-5 sentences in first person from the persona's perspective. This is the emotional journey summary — how did the platform feel overall? What was their emotional arc? Did they start confused and become confident? Did they start confident and hit a wall? Include direct quotes from their think-aloud narration.}

> "The most memorable moment was when..." — a single standout quote

## Emotional Journey

| Step | Page | Emotion | Confidence (1-5) |
|------|------|---------|-------------------|
| 1 | Login | {emoji + word: curious, confident, confused...} | 4 |
| 2 | Dashboard | {emoji + word} | 3 |
| 3 | Groups | {emoji + word} | 5 |
| ... | ... | ... | ... |

## Follow-Up Exchange

{Include this section ONLY if the tester received a probe question in Phase 4.3}

**Facilitator asked**: "{the follow-up question}"
**{tester} responded**: "{their response}"
**Insight gained**: {what we learned from this exchange that wasn't in the original report}

## Journey Screenshots & Commentary

Each screenshot below is captioned with the tester's think-aloud observations. Pay special attention to screenshots where the tester was **stuck, confused, or found a bug** — their description explains what went wrong.

### 1. Login Page
![Login]({prefix}-01-login.png)
> {Think-aloud description: what they saw, what they expected, how they felt. If they were stuck, what confused them.}

### 2. Dashboard
![Dashboard]({prefix}-02-dashboard.png)
> {Think-aloud: First impression? Did it feel welcoming? Could they understand what to do next?}

### 3. Groups
![Groups]({prefix}-03-groups.png)
> {Think-aloud: What stood out? Could they find what they were looking for?}

### 4. Group Detail
![Group Detail]({prefix}-04-group-detail.png)
> {Think-aloud: Is the information clear? Did they feel confident joining?}

### 5. Events
![Events]({prefix}-05-events.png)
> {Think-aloud description}

### 6. Event Detail
![Event Detail]({prefix}-06-event-detail.png)
> {Think-aloud description}

### 7. Links
![Links]({prefix}-07-links.png)
> {Think-aloud description}

### 8. Companies
![Companies]({prefix}-08-companies.png)
> {Think-aloud description}

### 9. Conferences
![Conferences]({prefix}-09-conferences.png)
> {Think-aloud description}

### 10. Settings
![Settings]({prefix}-10-settings.png)
> {Think-aloud description}

### Bug Screenshots
For each bug found, include the screenshot with a description of the problem:

![Bug: {short description}]({prefix}-bug-01-desc.png)
> **BUG ({severity})**: {What's wrong, what did they expect, what actually happened. "I tried to click the button but nothing seemed to happen..."}

## Task Results

| # | Task | Result | Confidence (1-5) | Think-Aloud Quote |
|---|------|--------|-------------------|-------------------|
| 1 | {task} | PASS | 5 | "This was straightforward, I found it immediately" |
| 2 | {task} | FAIL | 1 | "I spent ages looking for this and couldn't find it" |
| 3 | {task} | PARTIAL | 3 | "I think I did it but I'm not sure it actually worked" |

## Friction Moments

Moments where the tester hesitated, got confused, or felt frustrated:

1. **{Page/Action}** — Severity: {Critical/Serious/Minor}
   > "{Think-aloud quote about the friction}"
   > What happened: {description of what went wrong or was confusing}

2. **{Page/Action}** — Severity: {severity}
   > "{quote}"
   > What happened: {description}

## Delight Moments

Things that pleasantly surprised the tester or worked really well:

1. **{Page/Feature}**
   > "{Think-aloud quote about why this was nice}"

## Bugs Found

| # | Severity | Page | Description | Screenshot |
|---|----------|------|-------------|------------|
| 1 | Critical | Groups | Map markers invisible in dark mode | ![bug]({prefix}-bug-01-desc.png) |

Severity scale: **Critical** (can't complete task) > **Serious** (significant frustration) > **Minor** (annoying but not blocking) > **Suggestion** (enhancement idea)

## Theme Observations ({theme} mode)
- {Issues or praise specific to this color scheme}
- {Contrast problems, invisible elements, unstyled components}

## Viewport Observations ({viewport})
- {Issues or praise specific to this screen size}
- {Overflow, truncation, touch target problems}

## What Worked Well
- {Positive observations — things that felt polished, intuitive, or delightful}

## Pain Points
- {Frustrations, confusion, awkward flows, missing features}
```

---

## Main REPORT.md Template (Phase 5.4)

Write to `${REPORT_DIR}/REPORT.md`:

```markdown
---
date: YYYY-MM-DD HH:MM
team: test-run-{TIMESTAMP}
testers: N (X completed, Y failed)
method: Think-aloud protocol with persona-based scenario testing
facilitator: AI UX Research Facilitator with active observation and probing
reportFolder: test-reports/theme-test-{TIMESTAMP}/
---

# UX Research Report — Think-Aloud Usability Study

<ReportMeta />

## Supporting Documents

| Document | Description |
|----------|-------------|
| [Affinity Map](affinity-map.md) | Thematic clustering of all observations ({X} themes identified) |
| [Observation Notes](observation-notes.md) | Running facilitator notes from the live sessions |
| Individual Reports | {N} tester reports linked in the test matrix below |

## Executive Summary

{Write this as a 2-3 paragraph narrative. Tell the story of what happened when N users tried this platform. What's the overall emotional verdict? Don't list metrics — weave them into the narrative naturally.

Example tone: "When ten users sat down with my-project for the first time, most found their footing quickly — the onboarding wizard and getting-started checklist drew consistent praise, with newcomers describing the platform as 'welcoming.' But beneath this positive first impression, a recurring frustration emerged: nearly half the testers couldn't find the proposals feature, wandering through group tabs and top-level navigation without success. This navigation gap was the study's most significant finding, affecting both newcomers and experienced users across all viewports.

Dark mode, tested by five users, revealed several contrast issues that ranged from uncomfortable to blocking — map markers disappeared entirely on the groups page, and two testers abandoned tasks because they couldn't read button text. Mobile users generally had smooth experiences, though the events map proved unusable on smaller screens.

Overall readiness sits at X/10, with confidence that targeted fixes to navigation and dark mode contrast would lift scores significantly."}

## Test Matrix & Individual Reports

| # | User | Persona | Theme | Viewport | Score | Confidence | Report |
|---|------|---------|-------|----------|-------|------------|--------|
| 0 | Daan | The Newcomer | light | desktop | 8/10 | 4.2/5 | [Full report](tester-daan.md) |
| 1 | Sophie | The Regular | dark | desktop | 7/10 | 3.8/5 | [Full report](tester-sophie.md) |
| ... |

## Thematic Findings

Each finding below is a theme that emerged across multiple testers. For the full evidence with all tester quotes, see the [Affinity Map](affinity-map.md).

### Finding 1: {Descriptive theme name}

{2-4 paragraphs telling the story of this finding. Include:
- What happened — describe the user experience narratively
- Who was affected — which testers, which configurations
- Representative quotes (2-3, attributed to testers)
- Root cause hypothesis — why you think this happens
- Impact — what this means for real users}

> "{The most vivid quote}" — {tester}, {persona} ({viewport}-{theme})

> "{A contrasting or confirming quote}" — {tester}, {persona} ({viewport}-{theme})

**Severity**: {Critical/Serious/Minor}
**Affected**: {N} of {total} testers
**Recommendation**: {Specific, actionable recommendation connected to the evidence above}

---

### Finding 2: {name}
{same narrative structure}

---

(Continue for all themes from the affinity map. Order by severity/impact, not by frequency.)

## What Works Well

{Write this as 2-3 paragraphs of narrative, not a bullet list. Celebrate what the platform does right. Include tester quotes that show genuine delight. This section matters — it tells the team what to protect and build on.

Example: "The onboarding experience consistently earned praise across all configurations. Five of ten testers specifically called out the getting-started checklist as helpful, with Daan noting 'I actually know what to do next, which is rare for a new platform.' The dashboard's welcoming tone set the right expectations, and testers who completed onboarding reported higher confidence scores for subsequent tasks.

The events page was another bright spot..."}

## Configuration-Specific Findings

### Dark Mode

{Narrative summary of dark mode experience across all dark-mode testers. Not a bullet list — tell the story. Which issues are dark-mode-specific? Which are shared with light mode? Include quotes.}

### Light Mode

{Same narrative treatment.}

### Mobile (375x812)

{Narrative summary of mobile experience. What works well on mobile? What breaks? Include quotes from mobile testers.}

### Desktop (1440x900)

{Narrative summary.}

## Recommendations

Connect each recommendation back to the thematic findings with evidence chains.

### Must Fix (Critical & Serious)

1. **{Recommendation}**
   - **Evidence**: Finding {N} — {brief description}. {N} testers affected.
   - **Quote**: > "{supporting quote}" — {tester}
   - **Impact**: {What improves if this is fixed}

2. ...

### Should Fix (Minor)

1. **{Recommendation}**
   - **Evidence**: Finding {N}
   - **Impact**: {improvement}

### Suggestions (Enhancement Ideas)

1. **{Idea}** — suggested by {tester}

## Study Limitations & Methodology Note

This study used AI-simulated testers performing think-aloud usability testing. While this approach provides broad coverage across viewports, themes, and personas, it has inherent limitations:

- **AI testers may not struggle the same way humans do.** Real users might find different things confusing or delightful. AI testers tend to be more systematic in their exploration than real users.
- **Emotional responses are simulated.** The think-aloud quotes reflect what an AI persona would say, not genuine human emotion. Use them as indicators of potential friction/delight, not as proof.
- **No real accessibility testing.** While the "Accessibility User" persona checks for some issues, it cannot replace testing with actual assistive technology users.
- **Session independence.** Each tester operates independently — they don't influence each other the way real users sharing experiences might.

**Recommendation**: Use these findings as a prioritized starting point. Validate critical findings with 2-3 real human testers before committing to major redesigns.

## Overall Assessment

**Readiness Score**: X/10
**Average Confidence**: X/5
**Recommendation**: Ready / Needs fixes / Not ready

{2-3 sentence verdict written as narrative, using emotional language drawn from the tester quotes. This is the "if I had to tell someone in an elevator" summary.}
```
