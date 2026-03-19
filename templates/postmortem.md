# Post-Mortem: [Incident Title]

> **Date of Incident:** [YYYY-MM-DD]
> **Duration:** [Start time — End time (timezone)]
> **Severity:** P1 | P2 | P3
> **Author:** [Name]
> **Status:** Draft | In Review | Complete

## Summary

[2-3 sentences: what happened, what was the impact, and what was the root cause]

## Impact

| Metric | Value |
|--------|-------|
| Duration | [X hours Y minutes] |
| Users affected | [Number or percentage] |
| Revenue impact | [If applicable] |
| SLA impact | [If applicable] |
| Data loss | [Yes/No — details if yes] |

### Services Affected

- [Service 1]: [How it was affected]
- [Service 2]: [How it was affected]

## Timeline

All times in [timezone].

| Time | Event |
|------|-------|
| HH:MM | [First sign of trouble] |
| HH:MM | [Alert fired / User report] |
| HH:MM | [Investigation started] |
| HH:MM | [Root cause identified] |
| HH:MM | [Fix deployed] |
| HH:MM | [Service fully recovered] |

## Root Cause

[Detailed technical explanation of what caused the incident. Be specific — "a bug in X caused Y because Z".]

### Contributing Factors

- [Factor 1: e.g., missing monitoring for this scenario]
- [Factor 2: e.g., configuration drift between environments]
- [Factor 3: e.g., documentation gap]

## Detection

**How was this detected?** [Alert / User report / Monitoring / By accident]

**Detection gap:** [What should have caught this earlier?]

**Time to detect:** [How long between incident start and detection]

## Response

**What went well:**
- [Effective response action]
- [Good communication]

**What could be improved:**
- [Slow response area]
- [Missing tool or runbook]

## Action Items

| # | Action | Owner | Priority | Due Date | Status |
|---|--------|-------|---------|---------|--------|
| 1 | [Preventive measure] | [Name] | High | [Date] | Open |
| 2 | [Detection improvement] | [Name] | Medium | [Date] | Open |
| 3 | [Process improvement] | [Name] | Low | [Date] | Open |

### Categorized Actions

**Prevent recurrence:**
- [ ] [Action to fix the root cause]

**Improve detection:**
- [ ] [Action to catch this faster next time]

**Improve response:**
- [ ] [Action to resolve faster next time]

## Lessons Learned

### What went well

- [Thing that worked as designed]

### What went wrong

- [Thing that failed or was missing]

### Where we got lucky

- [Thing that could have made it worse]

## Appendix

### Related Incidents

- [Links to similar past incidents]

### Supporting Data

- [Links to dashboards, logs, graphs]

### Runbook Updates

- [ ] Updated [runbook name] with learnings from this incident
