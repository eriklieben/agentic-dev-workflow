# Skill Adoption

How to evaluate, review, and integrate external skills into this workflow.

## Why a Review Process?

External skills are powerful — they can execute bash commands, read/write files, and make API calls. 

Adopting a skill without review can:
- **Create overlap** with existing skills (confusing Claude about which to use)
- **Break conventions** (wrong naming, missing frontmatter, poor structure)
- **Introduce security risks** (arbitrary code execution, data exfiltration)
- **Bloat context** (too many skills eat into the token budget for descriptions)

The `/meta-adopt-skill` skill provides a structured review process.

## Finding Skills

### Marketplaces

Claude Code has a built-in plugin marketplace:

```bash
# Browse available plugins
/plugin

# Install from official marketplace
/plugin install plugin-name@claude-plugins-official

# Add a community marketplace
/plugin marketplace add owner/repo
```

### Community Repositories

| Repository | Focus |
|-----------|-------|
| [anthropics/skills](https://github.com/anthropics/skills) | Official Anthropic skills |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Curated list of skills, hooks, and tools |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 500+ community skills |
| [sickn33/antigravity-awesome-skills](https://github.com/sickn33/antigravity-awesome-skills) | 1000+ skills collection |
| [coleam00/excalidraw-diagram-skill](https://github.com/coleam00/excalidraw-diagram-skill) | Visual diagramming |
| [trailofbits/skills](https://github.com/trailofbits/skills) | Security research skills |

### Individual Skills

Skills are just directories with a SKILL.md. You can find them:
- In GitHub repositories (search for "claude code skill")
- In blog posts and tutorials
- In the [Claude Code docs](https://code.claude.com/docs/en/skills)

## The Adoption Process

### Quick Version

```
/meta-adopt-skill https://github.com/user/repo/tree/main/.claude/skills/skill-name
```

This runs the full review process: fetch → security audit → overlap check → compatibility → adaptation plan → present review → install (with approval).

### Step-by-Step

#### 1. Security Audit

Every skill is audited for:

| Check | What to Look For |
|-------|-----------------|
| Bash commands | What exactly does it run? Any `rm`, `curl` to external URLs? |
| External URLs | Does it fetch from or post to external services? |
| Allowed tools | Does it grant broad tool access (`Bash(*)`)? |
| Scripts | Read every bundled script — does it do what it claims? |
| Data handling | Does it instruct Claude to send data externally? |

**Risk levels:**
- **Low**: Read-only, no bash, no external calls
- **Medium**: Bash commands scoped to safe operations, no external calls
- **High**: Broad bash access, external URLs, or unclear scripts

High-risk skills are flagged and require explicit user acknowledgment.

#### 2. Overlap Analysis

The skill is compared against every existing skill in `catalog.json`:

- **Trigger overlap**: Would the same user prompt activate both skills?
- **Functional overlap**: Do they accomplish similar things?
- **Naming conflict**: Same name or confusingly similar?

If overlap is found, options are:
- **Adopt anyway**: Both skills coexist (different enough to justify)
- **Merge**: Combine the new skill's ideas into the existing one
- **Replace**: The new skill is strictly better, remove the old one
- **Skip**: The existing skill is sufficient

#### 3. Compatibility Check

| Check | Requirement |
|-------|-------------|
| Naming | Follows `{category}-{function}` convention |
| Category | Assigned to correct category (meta, dev, ops, tool, viz) |
| Context files | Respects memory security (no MEMORY.md in sub-agents) |
| Quality | SKILL.md is well-structured, instructions are clear |
| Size | Under 500 lines (split if larger) |

#### 4. Adaptation

Most external skills need minor modifications to fit the workflow:

- Rename to follow the naming convention
- Adjust frontmatter (add `disable-model-invocation` if destructive)
- Update description for better trigger accuracy
- Split large skills into supporting files

The adoption skill shows a diff between the original and adapted version.

#### 5. Installation

After user approval:
1. Skill directory created at `.claude/skills/{category-function}/`
2. Adapted SKILL.md written
3. Supporting files copied
4. Catalog updated in `catalog.json`
5. Daily memory updated with the adoption decision

## Example: Adopting the Excalidraw Skill

```
User: /meta-adopt-skill https://github.com/coleam00/excalidraw-diagram-skill

### Skill Adoption Review: excalidraw-diagram

**Source:** github.com/coleam00/excalidraw-diagram-skill
**Security Risk:** Low (generates HTML files, no external calls)
**Overlap:** None
**Category:** viz
**Proposed Name:** viz-excalidraw-diagram

#### What It Does
Generates interactive Excalidraw diagrams from natural language descriptions.
Creates .excalidraw files that can be opened in Excalidraw.

#### Changes Needed
- Rename from "excalidraw-diagram" to "viz-excalidraw-diagram"
- Add disable-model-invocation: true (generates files, user should control when)

#### Recommendation
Adopt with changes

Approve? (y/n)
```

## Bulk Evaluation

When evaluating multiple skills (e.g., from a marketplace), use `/meta-skill-catalog audit` after installation to check for issues across all skills.

## Removing Skills

1. Delete the skill directory from `.claude/skills/`
2. Run `/meta-skill-catalog rebuild` to update the catalog
3. Note the removal in today's daily memory


