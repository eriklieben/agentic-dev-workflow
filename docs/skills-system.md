# Skills System

## What Are Skills?

Skills are modular capabilities packaged as a directory with a `SKILL.md` file. They teach Claude how to complete specific tasks in a repeatable way. When relevant, Claude loads the skill automatically; you can also invoke them directly with `/skill-name`.

## Skill Structure

```
.claude/skills/
└── {category}-{function}/
    ├── SKILL.md              # Required — instructions and frontmatter
    ├── references/           # Optional — detailed docs, loaded on demand
    │   └── guide.md
    ├── scripts/              # Optional — executable scripts
    │   └── helper.ps1
    └── examples/             # Optional — example outputs
        └── sample.md
```

### SKILL.md Frontmatter

```yaml
---
name: dev-test-runner
description: >
  Runs tests and reports results. Use when the user says "run tests",
  "check if it passes", or after making code changes.
disable-model-invocation: false    # true = user-only, via /name
user-invocable: true               # false = claude-only, hidden from / menu
allowed-tools: Bash(dotnet test *) # restrict tool access
context: fork                      # run in isolated subagent
agent: general-purpose             # subagent type (if context: fork)
argument-hint: "[test-filter]"     # shown during autocomplete
---

Your instructions here...
```

### Key Frontmatter Fields

| Field | Purpose | Default |
|-------|---------|---------|
| `name` | Display name and `/command` name | Directory name |
| `description` | When Claude should use this skill | First paragraph |
| `disable-model-invocation` | Block Claude from auto-triggering | `false` |
| `user-invocable` | Show in `/` menu | `true` |
| `allowed-tools` | Tools Claude can use without asking | All (with permission) |
| `context` | `fork` to run in isolated subagent | Inline |
| `model` | Override model for this skill | Current model |

### Invocation Matrix

| Setting | User invokes | Claude invokes | Use case |
|---------|:---:|:---:|------|
| Default | Yes | Yes | General skills (explain, review) |
| `disable-model-invocation: true` | Yes | No | Destructive actions (deploy, commit) |
| `user-invocable: false` | No | Yes | Background knowledge (conventions) |

## Naming Convention

Skills follow a `{category}-{function}` naming pattern:

| Prefix | Category | Examples |
|--------|----------|----------|
| `meta-` | System/framework | meta-heartbeat, meta-wrap-up, meta-adopt-skill |
| `dev-` | Development workflow | dev-test-runner, dev-code-review, dev-debug |
| `ops-` | Operations/infra | ops-deploy, ops-cron, ops-health-check |
| `tool-` | Tool integrations | tool-playwright, tool-aspire, tool-firecrawl |
| `viz-` | Visualization | viz-excalidraw, viz-codebase-map |
| `str-` | Strategy/research | str-trending-research, str-architecture-review |

### Adding New Categories

If none of the existing categories fit, create a new one. The convention is a short (2-4 letter) prefix. Document it in CLAUDE.md and the catalog.

## Skill Catalog

The catalog at `.claude/skills/meta-skill-catalog/catalog.json` is the registry of all installed skills. It tracks:

- Name and category
- Description
- When it was added
- Where it came from (built-in, adopted, created, marketplace)
- Invocation settings

### Keeping the Catalog Current

The catalog should be updated when:
- A new skill is created or adopted
- A skill is removed
- A skill's metadata changes

Use `/meta-skill-catalog` to audit the catalog against what's actually on disk.

## Writing Good Skills

### When NOT to Create a Skill

Not everything should be a skill. Before creating one, ask yourself:

- **Does this contain knowledge Claude doesn't already have?** If you ask a fresh Claude session to do the task and it does it fine, you don't need a skill. You need a skill when Claude gets something wrong because it's missing project-specific context.
- **Did a human solve the gap?** If Claude struggled with something and you intervened to fix it, that's a good skill candidate. Encode what Claude was missing, not a description of the task itself.
- **Don't ask a struggling agent to write its own skill.** If Claude can't do the task well, asking it to write a skill about the task just packages the same bad knowledge differently. You need to identify the gap and fill it yourself.

Good skills encode: project-specific conventions, hard-won solutions, repetitive multi-step workflows, and knowledge gaps that caused real failures. Bad skills re-describe things Claude already knows generically.

### Description Tips

The description determines when Claude auto-triggers the skill. Write it like search keywords:

**Bad:** "A useful tool for developers"
**Good:** "Runs the test suite and reports failures. Use when the user says 'run tests', 'check tests', or after making code changes to verified files."

Include:
- What the skill does (one sentence)
- Trigger phrases the user might say
- When NOT to trigger (if needed)

### Instruction Tips

- Lead with the action, not the explanation
- Use numbered steps for sequential workflows
- Use checklists for verification
- Reference supporting files with relative paths
- Keep SKILL.md under 200 lines — if you need more, split into `references/` files that load on demand. Every line in SKILL.md costs tokens on every activation. If it's over 200 lines, ask: does Claude need this right now, or only when it reaches that step?

### Testing Skills

1. **Manual invocation**: Run `/skill-name` and verify behavior
2. **Auto-trigger test**: Say something that should trigger it, verify it activates
3. **Negative test**: Say something similar but different, verify it doesn't activate
4. **Use skill-creator**: The built-in `/skill-creator:skill-creator` can benchmark trigger accuracy

## Skills vs Commands vs Plugins

| Feature | Skills | Commands | Plugins |
|---------|--------|----------|---------|
| Location | `.claude/skills/` | `.claude/commands/` | Marketplace |
| Supporting files | Yes (directory) | No (single file) | Yes |
| Frontmatter | Full YAML | Basic YAML | Full YAML |
| Auto-trigger | Yes | Yes | Yes |
| Namespaced | No | No | Yes (`plugin:skill`) |
| Shareable | Via git | Via git | Via marketplace |

Commands still work and share the same frontmatter. Skills are recommended for new work because they support directories with supporting files.
