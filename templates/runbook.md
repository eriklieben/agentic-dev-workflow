# Runbook: [Operation/Incident Type]

> **Last Updated:** [YYYY-MM-DD]
> **Owner:** [Team/Person]
> **Severity:** P1 | P2 | P3 | P4
> **Related Services:** [Service names]

## Overview

What is this runbook for? When should it be used?

**Trigger:** [What alert, symptom, or situation triggers this runbook]

## Prerequisites

- [ ] Access to [system/tool]
- [ ] Permissions: [required roles]
- [ ] Tools: [CLI tools, dashboards, etc.]

## Diagnosis

### Step 1: Assess the Situation

```bash
# Check service health
[command]
```

**Expected:** [What healthy looks like]
**If unhealthy:** Proceed to Step 2

### Step 2: Identify Root Cause

Check these common causes in order:

| # | Possible Cause | How to Check | Likelihood |
|---|---------------|-------------|-----------|
| 1 | [Cause] | [Command or dashboard] | High |
| 2 | [Cause] | [Command or dashboard] | Medium |
| 3 | [Cause] | [Command or dashboard] | Low |

### Step 3: Check Dependencies

```bash
# Verify database connectivity
[command]

# Verify external service availability
[command]
```

## Resolution Steps

### Scenario A: [Root Cause 1]

1. [Action step]
   ```bash
   [command]
   ```
2. [Verification step]
   ```bash
   [command]
   ```

### Scenario B: [Root Cause 2]

1. [Action step]
2. [Verification step]

### Scenario C: [Root Cause 3]

1. [Action step]
2. [Verification step]

## Rollback

If resolution makes things worse:

1. [Rollback step]
   ```bash
   [command]
   ```
2. [Verify rollback succeeded]

## Escalation

| Condition | Escalate To | Contact |
|----------|-----------|--------|
| Cannot resolve in 30 min | [Team] | [Channel/email] |
| Data loss suspected | [Team] | [Channel/email] |
| Security incident | [Team] | [Channel/email] |

## Verification

After resolution, confirm:

- [ ] Service is responding normally
- [ ] Error rates returned to baseline
- [ ] No data loss or corruption
- [ ] Monitoring shows recovery
- [ ] Affected users notified (if applicable)

## Post-Incident

- [ ] Create post-mortem if P1/P2
- [ ] Update this runbook with anything learned
- [ ] File tickets for preventive measures

## History

| Date | Change | Author |
|------|--------|--------|
| [YYYY-MM-DD] | Created | [Name] |
