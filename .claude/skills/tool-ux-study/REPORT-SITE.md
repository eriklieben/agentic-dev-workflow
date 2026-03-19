# Report Site Generation

This document describes how to scaffold a VitePress site in the test report output directory so the user can run `npm start` to browse the report.

## When to Generate

Generate the report site at the end of **Phase 7** (after all markdown reports, expert reviews, and backlog are written). The site must be generated before the final message in Phase 8.

## Markdown Format

All report markdown files must use **YAML frontmatter** for metadata instead of inline bold text. Place a `<ReportMeta />` component after the `# heading` to render the metadata as a styled card.

### REPORT.md format

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

## Executive Summary
...
```

### tester-{username}.md format

Look up the user's roles and feature flags from `seed-data/test-users.json` (or from the seed script's default logic for non-persona users) and include them in frontmatter.

```markdown
---
persona: The Newcomer — "description"
user: Name (email@test.dev)
theme: light
viewport: desktop (1440x900)
date: YYYY-MM-DD HH:MM
readinessScore: X/10
roles:
  - early-preview
featureFlags:
  - onboarding
  - join-usergroup
  - submit-link
---

# Tester Report: Name

<ReportMeta />

**Themes contributed to**: [Theme 1](affinity-map.md#...), ...
```

### backlog.md format

```markdown
---
generatedFrom: REPORT.md, PM Review, UX Review
date: YYYY-MM-DD
testRun: theme-test-{TIMESTAMP}
testers: N (avg readiness X/10)
---

# Product Backlog — UX Test Run YYYY-MM-DD

<ReportMeta />
```

### affinity-map.md format

```markdown
---
method: Clustered from observation notes across N testers
themesIdentified: X
---

# Affinity Map — UX Test Run YYYY-MM-DD

<ReportMeta />
```

### observation-notes.md format

```markdown
---
facilitator: Team Lead (AI UX Research Facilitator)
date: YYYY-MM-DD HH:MM
testers: N
---

# Observation Notes — UX Test Run

<ReportMeta />
```

### review-product-manager.md and review-ux-designer.md

These files can also use frontmatter with relevant metadata fields and `<ReportMeta />`.

## Files to Generate

All files are created inside `${REPORT_DIR}/`.

### 1. `package.json`

```json
{
  "name": "ux-test-report",
  "private": true,
  "scripts": {
    "start": "vitepress dev",
    "build": "vitepress build",
    "preview": "vitepress preview"
  },
  "devDependencies": {
    "vitepress": "^1.6"
  }
}
```

### 2. `.vitepress/config.mts`

Generate dynamically based on the testers and reports that were actually produced.

```typescript
import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'UX Test Report',
  description: 'Think-aloud usability study results for my-project',

  appearance: true,

  themeConfig: {
    nav: [
      { text: 'Report', link: '/REPORT' },
      { text: 'Backlog', link: '/backlog' },
    ],

    sidebar: [
      {
        text: 'Overview',
        items: [
          { text: 'Report', link: '/REPORT' },
          { text: 'Affinity Map', link: '/affinity-map' },
          { text: 'Observation Notes', link: '/observation-notes' },
        ],
      },
      {
        text: 'Tester Reports',
        // Generate one entry per tester that completed successfully
        items: [
          // { text: '{Name} ({viewport}-{theme})', link: '/tester-{username}' },
        ],
      },
      {
        text: 'Expert Reviews',
        items: [
          { text: 'Product Manager', link: '/review-product-manager' },
          { text: 'UX Designer', link: '/review-ux-designer' },
          // Include WCAG Expert only if accessibility testers were spawned
          // { text: 'WCAG Expert', link: '/review-wcag-expert' },
          { text: 'Product Backlog', link: '/backlog' },
        ],
      },
    ],

    outline: {
      level: [2, 3],
    },

    search: {
      provider: 'local',
    },
  },
})
```

**Important**: The `Tester Reports` sidebar items must be generated dynamically from the actual testers that completed. For each completed tester, add:
```typescript
{ text: '{DisplayName} ({viewport}-{theme})', link: '/tester-{username}' }
```

### 3. `.vitepress/theme/index.ts`

```typescript
import DefaultTheme from 'vitepress/theme'
import './custom.css'
import ReportMeta from './components/ReportMeta.vue'

export default {
  extends: DefaultTheme,
  enhanceApp({ app }) {
    app.component('ReportMeta', ReportMeta)
  },
}
```

### 4. `.vitepress/theme/components/ReportMeta.vue`

```vue
<script setup>
import { useData } from 'vitepress'

const { frontmatter } = useData()

const labelMap = {
  date: 'Date',
  team: 'Team',
  testers: 'Testers',
  method: 'Method',
  facilitator: 'Facilitator',
  reportFolder: 'Report Folder',
  persona: 'Persona',
  user: 'User',
  theme: 'Theme',
  viewport: 'Viewport',
  readinessScore: 'Readiness Score',
  generatedFrom: 'Generated From',
  testRun: 'Test Run',
  themesIdentified: 'Themes Identified',
  avgConfidence: 'Avg Confidence',
  featureFlags: 'Feature Flags',
  roles: 'Roles',
}

const iconMap = {
  date: '📅',
  team: '👥',
  testers: '🧪',
  method: '📋',
  facilitator: '🎯',
  reportFolder: '📁',
  persona: '🎭',
  user: '👤',
  theme: '🎨',
  viewport: '📱',
  readinessScore: '⭐',
  generatedFrom: '📄',
  testRun: '🏷️',
  themesIdentified: '🔍',
  avgConfidence: '💪',
  featureFlags: '🚩',
  roles: '🔑',
}

const skipKeys = ['layout', 'title', 'description', 'head', 'hero', 'features', 'sidebar', 'outline']

const entries = Object.entries(frontmatter.value)
  .filter(([key]) => !skipKeys.includes(key))
  .map(([key, value]) => ({
    key,
    label: labelMap[key] || key.replace(/([A-Z])/g, ' $1').replace(/^./, s => s.toUpperCase()),
    icon: iconMap[key] || '•',
    value,
    isArray: Array.isArray(value),
  }))
</script>

<template>
  <div v-if="entries.length" class="report-meta">
    <div v-for="entry in entries" :key="entry.key" class="report-meta-row">
      <span class="report-meta-icon">{{ entry.icon }}</span>
      <span class="report-meta-label">{{ entry.label }}</span>
      <span v-if="entry.isArray" class="report-meta-value">
        <span v-for="tag in entry.value" :key="tag" class="report-meta-tag">{{ tag }}</span>
      </span>
      <span v-else class="report-meta-value">{{ String(entry.value) }}</span>
    </div>
  </div>
</template>

<style scoped>
.report-meta {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0;
  border: 1px solid var(--vp-c-border);
  border-radius: 8px;
  overflow: hidden;
  margin: 1rem 0 2rem;
  background: var(--vp-c-bg-elv);
}

.report-meta-row {
  display: grid;
  grid-template-columns: 2rem 10rem 1fr;
  align-items: center;
  padding: 0.6rem 1rem;
  border-bottom: 1px solid var(--vp-c-border);
  font-size: 0.9rem;
  line-height: 1.4;
}

.report-meta-row:last-child {
  border-bottom: none;
}

.report-meta-row:hover {
  background: var(--vp-c-bg-soft);
}

.report-meta-icon {
  font-size: 1rem;
  text-align: center;
}

.report-meta-label {
  font-weight: 600;
  color: var(--vp-c-text-2);
  white-space: nowrap;
}

.report-meta-value {
  color: var(--vp-c-text-1);
  word-break: break-word;
  display: flex;
  flex-wrap: wrap;
  gap: 0.35rem;
  align-items: center;
}

.report-meta-tag {
  display: inline-block;
  padding: 0.15rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
  font-family: var(--vp-font-family-mono, monospace);
  background: var(--vp-c-bg-soft);
  color: var(--vp-c-text-1);
  border: 1px solid var(--vp-c-border);
}

@media (max-width: 640px) {
  .report-meta-row {
    grid-template-columns: 2rem 1fr;
    gap: 0.25rem;
  }

  .report-meta-label {
    grid-column: 2;
    font-size: 0.8rem;
  }

  .report-meta-value {
    grid-column: 2;
  }
}
</style>
```

### 5. `.vitepress/theme/custom.css`

Use the my-project Catppuccin theme. This is the same CSS used by the project documentation site.

```css
/* ===== Light Mode — Catppuccin Latte + .NET Purple ===== */
:root {
  /* Brand */
  --vp-c-brand-1: #512bd4;
  --vp-c-brand-2: #4123aa;
  --vp-c-brand-3: #311a80;
  --vp-c-brand-soft: rgba(81, 43, 212, 0.14);

  /* Backgrounds */
  --vp-c-bg: #eff1f5;
  --vp-c-bg-alt: #e6e9ef;
  --vp-c-bg-elv: #ffffff;
  --vp-c-bg-soft: #e6e9ef;

  /* Text */
  --vp-c-text-1: #4c4f69;
  --vp-c-text-2: #5c5f77;
  --vp-c-text-3: #6c6f85;

  /* Dividers & borders */
  --vp-c-divider: rgba(76, 79, 105, 0.12);
  --vp-c-border: rgba(76, 79, 105, 0.12);
  --vp-c-gutter: #dce0e8;

  /* Status — Catppuccin Latte palette */
  --vp-c-tip-1: #40a02b;
  --vp-c-tip-2: rgba(64, 160, 43, 0.14);
  --vp-c-tip-3: rgba(64, 160, 43, 0.08);
  --vp-c-tip-soft: rgba(64, 160, 43, 0.14);

  --vp-c-warning-1: #df8e1d;
  --vp-c-warning-2: rgba(223, 142, 29, 0.14);
  --vp-c-warning-3: rgba(223, 142, 29, 0.08);
  --vp-c-warning-soft: rgba(223, 142, 29, 0.14);

  --vp-c-danger-1: #d20f39;
  --vp-c-danger-2: rgba(210, 15, 57, 0.14);
  --vp-c-danger-3: rgba(210, 15, 57, 0.08);
  --vp-c-danger-soft: rgba(210, 15, 57, 0.14);

  --vp-c-note-1: #1e66f5;
  --vp-c-note-2: rgba(30, 102, 245, 0.14);
  --vp-c-note-3: rgba(30, 102, 245, 0.08);
  --vp-c-note-soft: rgba(30, 102, 245, 0.14);

  /* Shadows */
  --vp-shadow-1: 0 1px 3px rgba(76, 79, 105, 0.06);
  --vp-shadow-2: 0 4px 12px rgba(76, 79, 105, 0.08);
  --vp-shadow-3: 0 8px 30px rgba(76, 79, 105, 0.12);

  /* Code blocks */
  --vp-code-block-bg: #e6e9ef;
  --vp-code-block-divider-color: rgba(76, 79, 105, 0.12);
}

/* ===== Dark Mode — Catppuccin Macchiato + .NET Purple ===== */
.dark {
  /* Brand */
  --vp-c-brand-1: #8a72ff;
  --vp-c-brand-2: #a599ff;
  --vp-c-brand-3: #c0b9ff;
  --vp-c-brand-soft: rgba(138, 114, 255, 0.14);

  /* Backgrounds */
  --vp-c-bg: #24273a;
  --vp-c-bg-alt: #1e2030;
  --vp-c-bg-elv: #363a4f;
  --vp-c-bg-soft: #1e2030;

  /* Text */
  --vp-c-text-1: #cad3f5;
  --vp-c-text-2: #b8c0e0;
  --vp-c-text-3: #a5adcb;

  /* Dividers & borders */
  --vp-c-divider: rgba(205, 214, 244, 0.12);
  --vp-c-border: rgba(205, 214, 244, 0.12);
  --vp-c-gutter: #181926;

  /* Status — Catppuccin Macchiato palette */
  --vp-c-tip-1: #a6da95;
  --vp-c-tip-2: rgba(166, 218, 149, 0.14);
  --vp-c-tip-3: rgba(166, 218, 149, 0.08);
  --vp-c-tip-soft: rgba(166, 218, 149, 0.14);

  --vp-c-warning-1: #eed49f;
  --vp-c-warning-2: rgba(238, 212, 159, 0.14);
  --vp-c-warning-3: rgba(238, 212, 159, 0.08);
  --vp-c-warning-soft: rgba(238, 212, 159, 0.14);

  --vp-c-danger-1: #ed8796;
  --vp-c-danger-2: rgba(237, 135, 150, 0.14);
  --vp-c-danger-3: rgba(237, 135, 150, 0.08);
  --vp-c-danger-soft: rgba(237, 135, 150, 0.14);

  --vp-c-note-1: #8aadf4;
  --vp-c-note-2: rgba(138, 173, 244, 0.14);
  --vp-c-note-3: rgba(138, 173, 244, 0.08);
  --vp-c-note-soft: rgba(138, 173, 244, 0.14);

  /* Shadows */
  --vp-shadow-1: 0 1px 3px rgba(0, 0, 0, 0.2);
  --vp-shadow-2: 0 4px 12px rgba(0, 0, 0, 0.3);
  --vp-shadow-3: 0 8px 30px rgba(0, 0, 0, 0.4);

  /* Code blocks */
  --vp-code-block-bg: #1e2030;
  --vp-code-block-divider-color: rgba(205, 214, 244, 0.12);
}

/* ===== Sidebar active link ===== */
.VPSidebar .VPSidebarItem.is-active > .item .link > .text {
  color: var(--vp-c-brand-1);
  font-weight: 600;
}

/* ===== Scrollbar ===== */
:root {
  --scrollbar-thumb: rgba(76, 79, 105, 0.2);
  --scrollbar-thumb-hover: rgba(76, 79, 105, 0.35);
  --scrollbar-track: transparent;
}

.dark {
  --scrollbar-thumb: rgba(205, 214, 244, 0.15);
  --scrollbar-thumb-hover: rgba(205, 214, 244, 0.3);
  --scrollbar-track: transparent;
}

* {
  scrollbar-width: thin;
  scrollbar-color: var(--scrollbar-thumb) var(--scrollbar-track);
}

*::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

*::-webkit-scrollbar-track {
  background: var(--scrollbar-track);
}

*::-webkit-scrollbar-thumb {
  background: var(--scrollbar-thumb);
  border-radius: 3px;
}

*::-webkit-scrollbar-thumb:hover {
  background: var(--scrollbar-thumb-hover);
}

/* ===== Screenshot images ===== */
img {
  border-radius: 8px;
  border: 1px solid var(--vp-c-border);
  max-width: 100%;
}
```

### 6. `index.md`

Generate a landing page with dynamic values from the test run.

```markdown
---
layout: home
hero:
  name: UX Test Report
  text: theme-test-{TIMESTAMP}
  tagline: "Think-aloud usability study — {N} testers, avg readiness {SCORE}/10"
  actions:
    - theme: brand
      text: View Report
      link: /REPORT
    - theme: alt
      text: Product Backlog
      link: /backlog

features:
  - title: "{N} Testers"
    details: "{comma-separated list of tester names with their viewport-theme}"
  - title: "{X} Themes Identified"
    details: "Clustered from observation notes across all testers"
  - title: "{Y} PBIs"
    details: "Prioritized backlog items with effort estimates"
  - title: "2 Expert Reviews"
    details: "Product Manager and UX Designer analysis"
---
```

### 7. Install dependencies

After writing all files, run:

```bash
cd ${REPORT_DIR} && npm install
```

## What the User Gets

After the skill completes, the user can:

```bash
cd test-reports/theme-test-{TIMESTAMP}
npm start
```

This opens a VitePress dev server (typically http://localhost:5173) with:
- A landing page with test run summary
- Sidebar navigation to all reports
- Full-text search across all documents
- Light/dark mode toggle (matching the Catppuccin theme)
- Screenshot images rendered inline in tester reports
- Styled metadata cards on every page via `<ReportMeta />`
