# Agentic Workflow Documentation

A persistent context, memory, and documentation system for AI coding agents.

## Table of Contents

### Setup
- [Getting Started](getting-started.md) — first-time setup, bootstrapping, and basic usage
- [Multi-Repo Setup](multi-repo-setup.md) — connecting multiple projects to a shared docs repo

### How It Works
- [Architecture](architecture.md) — directory structure, context loading layers, token budgets
- [Context Files](context-files.md) — SOUL.md, USER.md, MEMORY.md explained
- [Hooks](hooks.md) — automatic session management via Claude Code hooks
- [Daily Workflow](daily-workflow.md) — session lifecycle, tips, weekly maintenance

### Skills
- [Skills System](skills-system.md) — skill structure, naming convention, frontmatter
- [Skill Adoption](skill-adoption.md) — evaluating and installing external skills
- [Skills Reference](skills-reference.md) — every skill explained

### Reference
- [Sources](sources.md) — research, references, and academic foundations

## Overview

Agentic Workflow implements the **Heartbeat Pattern** — a session start/end ritual that gives AI coding agents persistent memory, learning, and documentation awareness.

### Core Features

| Feature | How |
|---------|-----|
| **Session continuity** | Heartbeat loads context at start, wrap-up saves at end |
| **Persistent memory** | Daily notes → distilled into long-term MEMORY.md |
| **Document generation** | 8 doc-* skills generate from templates (PRD, RFC, ADR, etc.) |
| **Codebase docs** | doc-init analyzes code + git history → bootstraps full doc set |
| **Multi-repo** | Multiple projects share one docs repo via workflow.json |
| **Skill management** | Adopt, catalog, upgrade skills from a central source |

### Skill Inventory (37 skills)

| Category | Skills |
|----------|--------|
| **meta** (9) | heartbeat, wrap-up, bootstrap, upgrade, adopt-skill, skill-catalog, continuous-learning, contribute-back, merge-contributions |
| **dev** (15) | verify, tdd, security, dependency (unified entry points) + verification-backend/frontend, tdd-backend/frontend, security-backend/frontend, dependency-backend/frontend (sub-skills) + search-first, blueprint, iterative-retrieval |
| **doc** (8) | init, prd, rfc, design, adr, runbook, postmortem, spike |
| **viz** (1) | c4-diagram |
| **tool** (3) | vitepress, ux-study, worktree |

### Design Principles

1. **Files over memory** — if it's not written down, it doesn't exist
2. **Curated over raw** — daily notes get distilled into long-term wisdom
3. **Security by default** — personal context never loads in shared contexts
4. **Simple over clever** — plain markdown, git-friendly, human-readable
5. **Drafts over nothing** — generated docs are starting points for review
6. **Portable** — no hardcoded paths, works anywhere


