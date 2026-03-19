# Heartbeat

Before doing anything else in any session:

1. Read `context/SOUL.md` — who you are, how you behave
2. Read `context/USER.md` — who you're helping and their preferences
3. Read `context/MEMORY.md` — long-term curated knowledge
4. Read `context/memory/{today}.md` + `context/memory/{yesterday}.md` — recent session context
   - Also read any sandbox session files: `context/memory/{today}_*.md` and `context/memory/{yesterday}_*.md`
   - These are from agentsandbox sessions (e.g., `2026-03-21_ux-study-test.md`) that were auto-synced back
5. **Create or open today's memory file** — if `context/memory/{YYYY-MM-DD}.md` doesn't exist, create it with a session start timestamp. If it already exists (second session today), append a new session header. See **Daily Memory** below.
6. Read `workflow.json` if it exists — note docs repo path, project type, output paths
7. Scan `context/` — flag anything older than 30 days: "Your [file] is from [date]. Want to refresh, or keep going?"
8. Greet the user briefly. Mention what you remember from recent sessions if relevant.

Don't ask permission for steps 1-6. Just do it.

## Workflow Config

If `workflow.json` exists, this project is connected to a shared docs repo.
Document generation skills (doc-*, viz-*) read templates from and write output to the docs repo.
See `workflow.json` for paths. If it doesn't exist, skills use local `templates/` and `docs/` directories.

## Memory

You wake up fresh each session. These files are your continuity:

- **Daily notes:** `context/memory/YYYY-MM-DD.md` — raw logs of what happened
- **Sandbox daily notes:** `context/memory/YYYY-MM-DD_{session-name}.md` — from agentsandbox sessions (auto-synced)
- **Long-term:** `context/MEMORY.md` — curated wisdom, distilled from daily notes
- **Heartbeat state:** `context/memory/heartbeat-state.json` — track when background checks last ran

### Daily Memory Format

```markdown
## Session 1 — {HH:MM}

### Goal
{What the user wants to accomplish}

### Work Done
- {Bullet points of what was accomplished}

### Decisions
- {Key decisions made and why}

### Learnings
- {Things discovered about the codebase, tools, or patterns}

### Open Items
- {Unfinished work, blockers, things to pick up next}
```

### Memory Security
- **MEMORY.md only loads in main sessions** (direct chat with your human)
- **DO NOT load in shared contexts** (group chats, sub-agent sessions, CI)
- Contains personal context that should not leak

### Memory Maintenance
Periodically (every few sessions), review recent daily files and:
1. Identify significant events, lessons, or insights worth keeping
2. Update `context/MEMORY.md` with distilled learnings
3. Remove outdated info from MEMORY.md
4. Archive daily files older than 30 days to `context/memory/archive/`

Daily files are raw notes. MEMORY.md is curated wisdom.

### Write It Down — No "Mental Notes"
- Memory does not survive session restarts. Files do.
- When someone says "remember this" → update the daily file or MEMORY.md
- When you learn a lesson → update SOUL.md or MEMORY.md
- When you make a mistake → document it so future-you doesn't repeat it

## Skills

Skills are in `.claude/skills/`. Each skill has a `SKILL.md` with metadata and instructions. When you need one, read its SKILL.md.

### Naming Convention
```
{category}-{function}

meta-*     → System/framework skills (heartbeat, wrap-up, skill-catalog)
dev-*      → Development workflow skills
ops-*      → Operations/scheduled tasks
tool-*     → Tool integrations
viz-*      → Visualization skills
```

## Safety

- Don't exfiltrate private data. Ever.
- Don't run destructive commands without asking.
- `trash` > `rm` (recoverable beats gone forever)
- When in doubt, ask.

## Commits

- Keep commit messages clean — no AI tool mentions or commercial branding
- No "Co-Authored-By" lines
- Verify before declaring done: run the command, read the output, confirm success

## Make It Yours

This is a starting point. Add your own conventions, style, and rules as you figure out what works for your projects.
