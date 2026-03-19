# Architecture

## Directory Structure

```
agentic-workflow/
├── CLAUDE.md                              # Entry point — heartbeat boot sequence
├── context/
│   ├── SOUL.md                            # Identity, values, behavior rules
│   ├── USER.md                            # User profile and preferences
│   ├── MEMORY.md                          # Long-term curated knowledge
│   └── memory/
│       ├── YYYY-MM-DD.md                  # Daily session logs
│       ├── heartbeat-state.json           # Background check timestamps
│       └── archive/                       # Daily files older than 30 days
├── .claude/
│   ├── skills/
│   │   ├── meta-heartbeat/SKILL.md        # Session start ritual
│   │   ├── meta-wrap-up/SKILL.md          # Session end ritual
│   │   ├── meta-adopt-skill/SKILL.md      # Skill review & adoption
│   │   ├── meta-skill-catalog/
│   │   │   ├── SKILL.md                   # Catalog management
│   │   │   └── catalog.json               # Skill registry
│   │   └── {category}-{function}/         # Your skills go here
│   ├── commands/                          # Legacy command files (still work)
│   └── hooks_info/                        # Hook configurations
└── docs/                                  # This documentation
```

## Three-Layer Context Loading

Context loads in tiers to minimize token usage:

### Layer 0: Always Loaded (~2-3K tokens)
- **CLAUDE.md** — boot sequence, core rules, skill naming convention
- **Skill descriptions** — one-line descriptions from all SKILL.md frontmatter

These load automatically at the start of every session. Keep them lean.

### Layer 1: Session Start (~3-5K tokens)
- **context/SOUL.md** — identity and behavior (loaded by heartbeat)
- **context/USER.md** — user profile (loaded by heartbeat)
- **context/MEMORY.md** — long-term knowledge (loaded by heartbeat, main sessions only)

Loaded by the heartbeat skill at session start. Not loaded by sub-agents.

### Layer 2: Hot Working Memory (~1-3K tokens)
- **context/memory/{today}.md** — today's session log
- **context/memory/{yesterday}.md** — yesterday's session log

Loaded by heartbeat for recent context. Grows during the session.

### Layer 3: On-Demand (variable)
- **Full skill content** — loaded when a skill is invoked
- **Supporting files** — loaded when referenced by a skill
- **Older daily files** — loaded on request for historical context

Only loaded when needed to keep the context window efficient.

## Token Budget Guidelines

| Component | Target Size | Notes |
|-----------|-------------|-------|
| CLAUDE.md | < 200 lines | Every line competes with actual work |
| SOUL.md | < 100 lines | Core identity, not a novel |
| USER.md | < 100 lines | Grows over time, prune regularly |
| MEMORY.md | < 200 lines | Curate aggressively |
| Daily memory | < 100 lines/session | Raw notes, summarized at wrap-up |
| Skill descriptions | < 50 chars each | Used for auto-triggering |
| Full skill content | < 500 lines | Split into supporting files if larger |

**Total budget at session start:** ~5-8K tokens (Layers 0-2)

Compare: Claude Code's context window is ~200K tokens (Sonnet/Haiku) or ~1M tokens (Opus 4.6). This uses ~3-4% (200K) or <1% (1M) for persistent context, leaving 96%+ for actual work.

## Data Flow

```
Session Start                     During Session                Session End
─────────────                     ──────────────                ───────────
SOUL.md ──────┐                                                ┌──→ daily memory
USER.md ──────┤                   User works                   │    updated
MEMORY.md ────┼──→ Context ──→    Claude assists ──→ Notes ────┤
daily files ──┘    loaded         Decisions made               ├──→ MEMORY.md
                                  Learnings happen             │    distilled
                                                               └──→ context files
                                                                    updated
```

## Security Model

| File | Main Session | Sub-Agent | Group Chat | CI |
|------|:---:|:---:|:---:|:---:|
| CLAUDE.md | Yes | Yes | Yes | Yes |
| SOUL.md | Yes | Yes | Yes | Yes |
| USER.md | Yes | No | No | No |
| MEMORY.md | Yes | No | No | No |
| Daily files | Yes | No | No | No |

**Rule:** Personal context (USER.md, MEMORY.md, daily files) stays in main sessions only. Identity context (SOUL.md) is safe to share.
