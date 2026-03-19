# Daily Workflow

How to use this system day-to-day.

## Session Lifecycle

```
┌──────────────────────────────────────────────────────────┐
│  1. START SESSION                                         │
│     Claude reads CLAUDE.md → runs heartbeat automatically │
│     Or: /meta-heartbeat                                   │
│                                                           │
│  2. WORK                                                  │
│     Normal development work                               │
│     Claude logs decisions and learnings to daily memory    │
│                                                           │
│  3. END SESSION                                           │
│     Say "wrap up" or: /meta-wrap-up                       │
│     Review deliverables → update memory → distill → done  │
└──────────────────────────────────────────────────────────┘
```

## Starting a Session

### First Time Setup

1. Fill in `context/USER.md` with your details
2. Customize `context/SOUL.md` for your development style
3. Start Claude Code in the project directory

### Every Session After

The heartbeat runs automatically (triggered by CLAUDE.md). 

Claude will:
- Load your identity and preferences
- Check recent session context
- Create today's daily memory file
- Flag any stale context files
- Greet you with relevant context

If the heartbeat didn't run (e.g., CLAUDE.md not yet read), invoke manually:
```
/meta-heartbeat
```

## During a Session

### Let Claude Log Naturally

Claude updates the daily memory file throughout the session. You don't need to do anything special — just work normally. Key decisions and learnings get captured automatically.

### Explicit Memory Updates

If you want Claude to remember something specific:
- "Remember this for next time" → updates daily memory or MEMORY.md
- "Add this to the soul file" → updates SOUL.md
- "Note my preference for X" → updates USER.md

### Adopting New Skills

When you find a skill you want to add:
```
/meta-adopt-skill https://github.com/user/repo/tree/main/.claude/skills/cool-skill
```

This runs the full review process before installing.

### Checking Skills

```
/meta-skill-catalog              # Show current inventory
/meta-skill-catalog audit        # Check for issues
/meta-skill-catalog rebuild      # Rebuild from disk
```

## Ending a Session

Say "wrap up", "we're done", or "that's it for today". Or invoke directly:
```
/meta-wrap-up
```

Claude will:
1. Review what was done (git status, changed files)
2. Update the daily memory with session details
3. Distill any long-term learnings to MEMORY.md
4. Ask for feedback (optional)
5. Offer to commit (only if you ask)

## Multi-Session Days

If you start a second session on the same day, the heartbeat appends a new session header to the existing daily file:

```markdown
## Session 1 — 09:30
### Goal
...

## Session 2 — 14:15
### Goal
[Pending — awaiting user goal]
```

This keeps the full day's context in one file.

## Weekly Maintenance

Every few sessions (or weekly), the system benefits from:

1. **Memory pruning**: Review MEMORY.md, remove entries that are no longer relevant
2. **Archiving**: Move daily files older than 30 days to `context/memory/archive/`
3. **Skill audit**: Run `/meta-skill-catalog audit` to check for issues
4. **Freshness check**: The heartbeat flags stale files, but a manual review helps

Archiving is currently a **manual task** — ask Claude to "archive old daily files" during a session, or do it yourself. The heartbeat flags files older than 30 days as stale, which serves as a reminder. You can automate this with `/loop` if you prefer.

## Tips

### Keep CLAUDE.md Lean
Every line in CLAUDE.md competes for attention. Target under 200 lines. Move details to context files or skill instructions.

### Prune Aggressively
MEMORY.md should contain curated wisdom, not a diary. If an entry isn't useful anymore, remove it.

### Trust the System
The heartbeat loads your context automatically. You don't need to tell Claude "read my preferences" — it already did.

### Adapt Over Time
This is a starting point. As you use it, you'll discover what works and what doesn't. Update SOUL.md, adjust the heartbeat, add new skills. The system should evolve with you.
