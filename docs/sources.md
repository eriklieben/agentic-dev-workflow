# Sources & References

The patterns in this workflow are synthesized from multiple open-source implementations and community practices.

## Primary Influences

### OpenClaw Workspace Pattern
- **Repository:** [seedprod/openclaw-prompts-and-skills](https://github.com/seedprod/openclaw-prompts-and-skills)
- **Key contribution:** The SOUL.md / USER.md / MEMORY.md separation, heartbeat protocol, memory security model (MEMORY.md main-session only), daily memory files with `YYYY-MM-DD.md` format
- **Related:** [OpenClaw Heartbeat docs](https://docs.openclaw.ai/gateway/heartbeat)

## Related Projects

### Skill Repositories

| Repository | Focus |
|-----------|-------|
| [anthropics/skills](https://github.com/anthropics/skills) | Official Anthropic skills |
| [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) | Curated skills, hooks, and tools |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 500+ community skills |
| [rsmdt/the-startup](https://github.com/rsmdt/the-startup) | Spec-driven development framework |
| [trailofbits/skills](https://github.com/trailofbits/skills) | Security research skills |
| [coleam00/excalidraw-diagram-skill](https://github.com/coleam00/excalidraw-diagram-skill) | Visual diagramming |

### Frameworks & Standards

| Resource | Description |
|----------|-------------|
| [Agent Skills spec](https://agentskills.io) | Open standard for agent skills (works across Claude, Codex, etc.) |
| [ACOS v6](https://www.frankx.ai/blog/agentic-creator-os-complete-guide) | Creator-focused OS with 630+ skills |
| [OpenClaw workspace skill](https://github.com/win4r/openclaw-workspace) | AGENTS.md / SOUL.md / TOOLS.md / MEMORY.md maintenance |

### Documentation & Articles

| Article | Author | Key Insight |
|---------|--------|-------------|
| [Complete Guide to AI Agent Memory Files](https://hackernoon.com/the-complete-guide-to-ai-agent-memory-files-claudemd-agentsmd-and-beyond) | HackerNoon | Comparison of CLAUDE.md, AGENTS.md, and other memory file standards |
| [Memory Architecture for Agentic Systems](https://gist.github.com/spikelab/7551c6368e23caa06a4056350f6b2db3) | spikelab | Comprehensive survey: Tulving's framework, MCP servers, cost analysis |
| [OpenClaw 50-day workflows](https://gist.github.com/velvet-shark/b4c6724c391f612c4de4e9a07b0a74b6) | velvet-shark | 20 real production workflows with prompts |
| [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices) | Anthropic | Official guidance on CLAUDE.md, skills, and agentic patterns |
| [Agentic Heartbeat Pattern](https://medium.com/@marcilio.mendonca/the-agentic-heartbeat-pattern-a-new-approach-to-hierarchical-ai-agent-coordination-4e0dfd60d22d) | Marcilio Mendonca | Hierarchical agent coordination (expansion/contraction cycle) |
| [Extend Claude with Skills](https://code.claude.com/docs/en/skills) | Anthropic | Official skills documentation |
| [Discover Plugins](https://code.claude.com/docs/en/discover-plugins) | Anthropic | Official marketplace documentation |

### Academic Foundations

| Paper/Concept | Relevance |
|---------------|-----------|
| Tulving's Memory Taxonomy (1972) | Episodic / Semantic / Procedural → daily files / MEMORY.md / skills |
| Generative Agents (Park et al., 2023) | Observation → Reflection → Planning loop |
| Reflexion (Shinn et al., 2023) | Verbal reinforcement learning through self-reflection |
| Plain filesystem benchmark (Letta) | 74% on LoCoMo — simple markdown often beats complex systems |

## Key Design Insight

> "Plain filesystem achieves 74% on LoCoMo benchmark, beating specialized memory libraries."
> — Letta research

This workflow deliberately uses plain markdown files over databases, vector stores, or custom infrastructure. The benefits:
- Human-readable and inspectable
- Git-friendly (diffs, history, backup, collaboration)
- Zero infrastructure overhead
- LLM-native (models are trained on markdown)
- Portable across tools (works with Claude Code, Codex, Cursor, etc.)


