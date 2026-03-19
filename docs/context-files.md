# Context Files

The context system has four files with distinct purposes and update frequencies.

## SOUL.md — Identity

**Purpose:** Defines who the agent is, how it behaves, and what it values.

**Update frequency:** Rarely. Only when fundamental principles change.

**Location:** `context/SOUL.md`

Think of this as the agent's personality and professional standards. 

It answers:
- What kind of developer am I?
- What do I value in code?
- How should I communicate?
- What should I never do?

### Customization Tips

- Be specific about coding values ("prefer simple over clever")
- Include what annoys you ("don't say 'Great question!'")
- Add domain-specific principles for your stack
- Keep it under 100 lines

### Example Additions for .NET Projects

```markdown
## .NET Specific

- Use `System.Text.Json`, never `Newtonsoft.Json`
- Prefer minimal APIs over controllers
- Use strongly typed IDs for domain entities
- Return `Result<T>` from commands, not exceptions
```

## USER.md — User Profile

**Purpose:** Stores information about the human being helped.

**Update frequency:** Grows organically. Updated as the agent learns about the user.

**Location:** `context/USER.md`

**Security:** Main sessions only. Never load in shared contexts.

### What to Include

- Name, timezone, role
- Technical expertise (what they know well, what's new to them)
- Communication preferences
- Code style preferences
- Current focus areas and projects

### What NOT to Include

- Credentials, tokens, API keys
- Personal information beyond what's needed for work
- Judgments or assessments of the user

## MEMORY.md — Long-Term Knowledge

**Purpose:** Curated wisdom distilled from daily session notes.

**Update frequency:** Every few sessions, during wrap-up or memory maintenance.

**Location:** `context/MEMORY.md`

**Security:** Main sessions only.

### What Belongs Here

- Key architectural decisions and their rationale
- Lessons learned from debugging sessions
- Codebase gotchas that aren't obvious from the code
- User preferences discovered during work
- Things that went wrong and how they were fixed

### What Does NOT Belong Here

- Raw session logs (those go in daily files)
- Temporary task state (use Claude Code's built-in task tracking)
- Information derivable from the code (read the code instead)
- Git history (use `git log` / `git blame`)

### Memory Maintenance Cycle

```
Daily Files (raw)  ──distill──→  MEMORY.md (curated)  ──prune──→  Archive
                                                                    (>30 days)
```

1. **During wrap-up**: Promote significant learnings from today's notes to MEMORY.md
2. **Every few sessions**: Review MEMORY.md, remove outdated entries
3. **Monthly**: Archive daily files older than 30 days to `context/memory/archive/`

## Daily Memory Files — Session Logs

**Purpose:** Raw logs of what happened each day.

**Update frequency:** Every session (created/appended by heartbeat, finalized by wrap-up).

**Location:** `context/memory/YYYY-MM-DD.md`

### Format

```markdown
# 2026-03-15

## Session 1 — 09:30

### Goal
Implement the event sourcing migration for the Group aggregate

### Work Done
- Created GroupMemberAdded event
- Updated Group aggregate with When() handler
- Ran `dotnet run faes generate` to register the event
- Fixed serialization issue with DateTimeOffset

### Decisions
- Decided to use UTC for all event timestamps (consistency with existing events)
- Chose to keep member count as a projection, not aggregate state

### Learnings
- `faes generate` needs to run from the project directory, not solution root
- The `JsonSerializable` context needs the event registered before it works

### Open Items
- [ ] Projection rebuild for member counts
- [ ] Tests for the new event handler

## Session 2 — 14:15

### Goal
...
```

### Tips

- Keep entries concise — bullet points, not paragraphs
- Focus on decisions and learnings, not play-by-play
- Mark open items clearly so the next session can pick them up
- The agent should update this throughout the session, not just at wrap-up


