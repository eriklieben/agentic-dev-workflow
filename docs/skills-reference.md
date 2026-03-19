# Skills Reference

Complete reference for every skill in agentic-workflow.

## Meta Skills

System-level skills for managing the workflow itself.

### meta-heartbeat

**Command:** `/meta-heartbeat`
**Trigger:** Runs automatically at session start via CLAUDE.md

Session startup ritual. Loads context files in order (SOUL → USER → MEMORY → daily files → workflow.json), creates today's daily memory file, checks for stale context, surfaces documentation status, and greets the user with relevant context.

### meta-wrap-up

**Command:** `/meta-wrap-up`
**Trigger:** "wrap up", "we're done", "end session", "that's it for today"

Session end checklist. Reviews deliverables (git status), updates daily memory, checks for documentation gaps (missing ADRs, C4 updates needed), distills learnings to MEMORY.md, collects feedback, and optionally commits work.

### meta-bootstrap

**Command:** `/meta-bootstrap [project-path] [--docs-repo path]`
**Trigger:** "set up the workflow", "bootstrap this project", "install the workflow"

Installs the workflow into any project. Creates `workflow.json`, sets up `context/` directory, copies templates to docs repo, installs all skills, adds heartbeat to CLAUDE.md, and updates `.gitignore`. Safe to re-run (updates without overwriting).

### meta-upgrade

**Command:** `/meta-upgrade [--all | --skills-only | --templates-only | --diff | --dry-run]`
**Trigger:** "upgrade the workflow", "update skills", "sync skills", "check for updates"

Compares installed skills and templates against the agentic-workflow source repo. Shows new, updated, and unchanged items. Lets you selectively apply upgrades. Creates `.bak` backups before overwriting. Never touches project-specific skills.

### meta-adopt-skill

**Command:** `/meta-adopt-skill [URL | path]`
**Trigger:** "adopt this skill", "install this skill", "add this skill"

Reviews an external skill before installing. Runs security audit (bash commands, external URLs, broad tool access), overlap analysis (against catalog), compatibility check (naming, category, size), and presents a structured review. Installs only after user approval.

### meta-skill-catalog

**Command:** `/meta-skill-catalog [inventory | rebuild | audit]`
**Trigger:** "list skills", "show skill catalog", "audit skills"

Manages the skill catalog (`catalog.json`). `inventory` lists all skills, `rebuild` regenerates catalog from disk, `audit` checks for issues (missing files, naming conflicts, orphaned directories).

### meta-continuous-learning

**Command:** `/meta-continuous-learning [--review | --extract | --status]`
**Trigger:** "learn from this session", "extract patterns", "what did we learn"

Analyzes session patterns and extracts reusable knowledge as skills, rules, or SOUL.md/MEMORY.md updates. Identifies corrections (things the user repeatedly fixed), conventions (project patterns worth codifying), techniques (debugging approaches worth remembering), workarounds (framework quirks), and workflows (repeatable processes worth automating).

Each candidate gets a confidence rating (high/medium/low) and a proposed destination. Always presents candidates for review before applying.

**Flags:**
- `--review` — Scan recent sessions for unextracted patterns (read-only)
- `--extract` — Run full extraction on current session
- `--status` — Show recently extracted patterns

**Flags:**
- `--adaptations` — Review and classify skill modifications from this session

### meta-contribute-back

**Command:** `/meta-contribute-back [skill-name | --all | --list]`
**Trigger:** "contribute back", "push learnings", "send adaptations upstream"

Packages universal and stack-specific skill adaptations from the current project and stages them in the agentic-workflow repo as a contribution branch (`contrib/{project}/{skill}`). Reads `context/adaptations.md` for pending contributions, generates contribution files with proposed changes and context, commits on a dedicated branch. Multiple contributions to the same skill from the same project accumulate on one branch.

**Flags:**
- `--all` — Contribute all pending adaptations
- `--list` — Show pending adaptations without contributing (read-only)
- (skill-name) — Contribute adaptations for a specific skill only

### meta-merge-contributions

**Command:** `/meta-merge-contributions [--skill name | --all | --list]`
**Trigger:** "merge contributions", "review contributions", "check for skill contributions"

Reviews contribution branches created by `/meta-contribute-back` and merges approved improvements into skills. Shows branch diffs, presents proposed changes with context, and applies with proper version bumps and changelog updates. Each merged contribution gets a single commit. Supports merge, reject, and defer actions.

**Flags:**
- `--list` — Show pending contribution branches (read-only)
- `--skill <name>` — Process only contributions for this skill
- `--all` — Process all pending contributions

> **Note:** This skill is designed for use in the agentic-workflow repo itself.

---

## Development Skills

Workflow skills for coding, testing, and quality assurance. Adapted for C#/.NET (ASP.NET Core, EF Core) and Angular/TypeScript.

Dev skills use **unified entry points** that auto-detect the project stack. You invoke `/dev-verify`, not `/dev-verification-backend` — the router reads project files (`.csproj`, `angular.json`) and delegates to the right sub-skill. Filter with `dotnet` or `angular` to target one stack.

### dev-commit

**Not user-invocable** — activates automatically when creating commits.

Enforces conventional commit messages following the [Angular commit message guidelines](https://github.com/angular/angular/blob/main/contributing-docs/commit-message-guidelines.md) and the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/) specification.

**Rules:** lowercase type, lowercase description, no trailing period, header under 72 characters, imperative present tense, body explains motivation (mandatory except for `docs` type), no AI attribution lines.

**Angular types:** `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `build`, `ci`. Extended types: `chore`, `style`. Reverts use `revert:` prefix.

Includes reference docs for type definitions (`references/types.md`) and extensive good/bad examples (`references/examples.md`).

### dev-verify

**Command:** `/dev-verify [dotnet | angular | --quick | --full | --fix]`
**Trigger:** "verify", "check the code", "run checks", "verify changes"

Post-change verification. Auto-detects .NET and Angular, runs both in mixed projects. Collects all findings first, then presents a numbered issue list with an inline fix menu (`[a]ll [1-N] pick [s]kip`). Fixes are re-verified automatically. Cycle repeats until clean or user skips.

For .NET projects using `EventSourcing`, also verifies event sourcing code generation is in sync (`.Generated.cs` files) and checks projection consistency.

### dev-tdd

**Command:** `/dev-tdd [dotnet | angular] [feature description]`
**Trigger:** "TDD", "write tests first", "test-driven"

Test-driven development. Plans test cases upfront with user approval, then loops RED→GREEN→REFACTOR per test. After planned tests complete, checks coverage and proposes additional tests for uncovered paths. Repeats until 80%+ coverage or user skips. Use `--target N` to override threshold.

### dev-security

**Command:** `/dev-security [dotnet | angular | --checklist | --scan | --full]`
**Trigger:** "security review", "check security", "audit security"

Security review aligned with OWASP Top 10:2025. Findings tagged by category (`[A01]`-`[A10]`) and grouped by severity (critical/high/medium/low). Inline fix menu with `[a]ll [1-N] pick [c]ritical only [s]kip`. Security fixes require review before applying.

### dev-dependency

**Command:** `/dev-dependency [nuget | npm | --audit | --patch | --minor | --major | --security]`
**Trigger:** "update dependencies", "check packages", "audit deps"

Dependency audit and update. Auto-detects NuGet and npm, runs both in mixed projects. Groups by risk (patch/minor/major/security). Major bumps always ask for confirmation.

### Sub-Skills (not directly invocable)

The following are used internally by the unified entry points above:

### dev-verification-backend

**Invoked via:** `/dev-verify` or `/dev-verify dotnet`

Post-change verification for C#/.NET code with 6 phases: build (`dotnet build`), static analysis (Roslyn analyzers with `TreatWarningsAsErrors`), format check (`dotnet format --verify-no-changes`), tests (`dotnet test` with coverage), security scan (`dotnet list package --vulnerable`), and diff review. Includes Aspire health checks, event sourcing analyzers, and CI pipeline alignment.

**Flags:** `--quick` (build + analyzers only), `--full` (all 6 phases), `--fix` (auto-fix formatting).

### dev-verification-frontend

**Invoked via:** `/dev-verify` or `/dev-verify angular`

Post-change verification for Angular/TypeScript code with 6 phases: build (`ng build --configuration production`), type check (`npx tsc --noEmit`), lint/format (`ng lint`, Prettier, Stylelint), tests (Vitest with coverage), security scan (`npm audit`), and diff review. Includes Service Worker verification, Aspire integration checks, and CI pipeline alignment.

**Flags:** `--quick` (build + type check only), `--full` (all 6 phases), `--fix` (auto-fix lint and formatting).

### dev-tdd-backend

**Invoked via:** `/dev-tdd` or `/dev-tdd dotnet`

Test-driven development for C#/.NET: RED → GREEN → REFACTOR cycle using xUnit with `Assert.*` (AAA pattern with comments), NSubstitute for mocking, `WebApplicationFactory` for integration tests, Testcontainers for real database tests. Uses `_sut` naming convention and `Operation_WhenCondition_ShouldOutcome` test naming. Supports event sourcing testing (EventSourcing), specification testing, and nested test classes for grouping scenarios.

Coverage target: 80%+. Tests behavior, not implementation. Each test is isolated.

### dev-tdd-frontend

**Invoked via:** `/dev-tdd` or `/dev-tdd angular`

Test-driven development for Angular/TypeScript: RED → GREEN → REFACTOR cycle using Vitest with @testing-library/angular for component/service tests, `HttpTestingController` for HTTP mocking, Playwright for E2E. Targets standalone components, signals, zoneless change detection, template-driven forms, and inline templates. Uses `[data-testid]` selectors.

Coverage target: 80%+. Tests behavior, not implementation. Each test is isolated.

### dev-perf

**Command:** `/dev-perf [endpoint-or-url]`
**Trigger:** "profile this endpoint", "why is this slow", "check performance", "trace analysis"

Performance profiling using Aspire distributed tracing. Exercises an endpoint, captures the trace, analyzes span patterns (aggregate rehydrations, projection reads, N+1 queries), and recommends specific fixes. After a fix, re-traces to verify the improvement.

Includes a span pattern reference for event sourcing projects — interprets blob storage read patterns to identify inefficient data access (factory iteration vs. projection lookups, duplicate rehydration, missing indexes).

Requires the Aspire MCP server (`mcp__aspire__*` tools).

### dev-search-first

**Command:** `/dev-search-first [what you need]`
**Trigger:** "add X functionality", starting a new feature, before creating a utility

Research-before-coding workflow. Searches 5 sources in parallel before writing custom code:

1. **Existing codebase** — does this already exist in the repo?
2. **NuGet / npm** — is there a well-maintained package?
3. **MCP servers / skills** — is there a configured tool for this?
4. **llms.txt** — does the framework/library have LLM-optimized docs?
5. **GitHub** — is there a maintained OSS implementation?

Includes lookup tables for common C#/.NET packages (EventSourcing, Results, StronglyTypedIds, Specifications, Polly, Serilog, HybridCache, manual mapping preferred) and Angular packages (signals over NgRx, Vitest over Jasmine, Angular Material, ag-Grid, etc.). Decision matrix: Adopt / Extend / Compose / Build.

### dev-blueprint

**Command:** `/dev-blueprint [project] "objective description"`
**Trigger:** "plan this", "break this into PRs", "multi-session plan", "roadmap"

Turns a one-line objective into a step-by-step construction plan for multi-session projects. Each step includes a self-contained context brief so a fresh agent can execute it cold.

5-phase pipeline: Research → Design → Draft → Review (adversarial) → Register. Generates a Mermaid dependency graph, detects parallelizable steps, and assigns rollback strategies.

Anti-pattern detection: big bang steps (>10 files), hidden dependencies, missing verification, context leaks between steps, no rollback strategy.

**Do not use** for tasks completable in a single PR or fewer than 3 tool calls.

### dev-iterative-retrieval

**Not user-invocable** — used internally by sub-agents for context retrieval.

Progressive context refinement pattern for multi-agent workflows. Solves the problem where sub-agents don't know what context they need until they start working.

4-phase loop (max 3 cycles): DISPATCH (broad search) → EVALUATE (score relevance 0-1.0) → REFINE (learn codebase terminology, narrow gaps) → LOOP (repeat or stop when 3+ high-relevance files found).

### dev-dotnet-build

**Not user-invocable** — referenced by `dev-verification-backend` and the `dotnet-build-resolver` agent. Uses `context: fork`.

MSBuild diagnosis and optimization. Covers binlog analysis, incremental build fixes, common MSBuild antipatterns, and `Directory.Build.props`/`.targets` organization. Conditionally installed when the project has 3+ `.csproj` files or a `Directory.Build.props`.

Includes reference docs: binlog analysis, Directory.Build organization, incremental builds, MSBuild antipatterns.

### dev-dotnet-efcore

**Not user-invocable** — used as reference material. Uses `context: fork`.

EF Core query optimization and best practices. Covers N+1 detection, query splitting, compiled queries, change tracking optimization, and migration strategies. Conditionally installed when the project uses `Microsoft.EntityFrameworkCore`.

### dev-dotnet-migrate

**Command:** `/dev-dotnet-migrate [8-to-9 | 9-to-10 | 10-to-11 | nullable | aot]`
**Trigger:** "migrate to .NET 10", "update .NET version", "enable nullable"

.NET version migration assistant. Guides step-by-step migration between .NET versions (8→9, 9→10, 10→11), nullable reference type adoption, and AOT compatibility preparation. Provides checklists and automated detection of breaking changes. Uses `context: fork`.

Includes reference docs: migration guides for each version pair, nullable references guide, AOT compatibility guide.

### dev-dependency-backend

**Invoked via:** `/dev-dependency` or `/dev-dependency nuget`

Audits and updates NuGet packages with risk-aware batching. Detects outdated, vulnerable, and deprecated packages via `dotnet list package`. Groups by risk (patch/minor/major/security), runs `dotnet build && dotnet test` after each batch.

**Breaking change handling:** Major bumps always pause for confirmation. Shows impact (file count using the namespace), links to Microsoft migration guides, lists known breaking changes for EF Core, ASP.NET Core, xUnit, Results, Polly.

**Framework upgrades:** Special .NET upgrade workflow (global.json → TargetFramework → Microsoft.* packages → build → test → Dockerfile → CI/CD).

**Flags:** `--audit` (default, report only), `--patch`, `--minor`, `--major` (always asks), `--security`, `--interactive`.

### dev-dependency-frontend

**Invoked via:** `/dev-dependency` or `/dev-dependency npm`

Audits and updates npm packages with risk-aware batching. Uses `npm outdated`, `npm audit`, and `ng update`. Groups by risk, runs `ng build && ng test` after each batch.

**Breaking change handling:** Major bumps always pause for confirmation. Shows impact (file count importing the package), links to Angular update guide, lists known breaking changes for Angular, TypeScript, RxJS, Angular Material.

**Framework upgrades:** Angular version-by-version upgrade workflow (`ng update @angular/core@N`, test, commit, repeat). Always updates @angular/core before third-party packages.

**Flags:** `--audit` (default, report only), `--patch`, `--minor`, `--major` (always asks), `--security`, `--interactive`.

### dev-security-backend

**Invoked via:** `/dev-security` or `/dev-security dotnet`

Security checklist for ASP.NET Core backend covering secrets management (Azure Key Vault, User Secrets), input validation (Results, file uploads), SQL injection prevention (EF Core parameterized queries), authentication & authorization (policies, cookie config), security headers (CSP, X-Frame-Options), CSRF, rate limiting, Problem Details (RFC 7807) for error responses, and event sourcing security (stream isolation, projection authorization, PII/GDPR considerations).

**Flags:** `--checklist` (pre-deployment checklist), `--scan` (automated scans), `--full` (checklist + scans + code review).

### dev-security-frontend

**Invoked via:** `/dev-security` or `/dev-security angular`

Security checklist for Angular frontend covering: no secrets in bundles, XSS prevention (no `bypassSecurityTrust*` with user input), client-side validation (template-driven forms), authentication patterns (HttpOnly cookies with `__Host-` prefix, functional guards/interceptors), CSRF handling, CSP implications, dependency security (`npm audit`), signal-based state security, Service Worker security, and standalone component/zoneless considerations.

**Flags:** `--checklist` (pre-deployment checklist), `--scan` (automated scans), `--full` (checklist + scans + code review).

---

## Document Skills

Generate documents from templates. All doc skills read `workflow.json` for path resolution — if it exists, templates and output go to the docs repo; otherwise, they use local `templates/` and `docs/` directories.

### doc-init

**Command:** `/doc-init [--full | --phase N | --dry-run | --skip-existing]`
**Trigger:** "init docs", "generate documentation", "bootstrap docs", "document this codebase"

Analyzes an existing codebase and generates a comprehensive documentation set across 7 phases:

| Phase | What it does | Output |
|-------|-------------|--------|
| **1** | Codebase analysis — structure, dependencies, git archaeology, domain model | Summary presented for approval |
| **2** | Architecture diagrams — C4 Context, Container, Component (Mermaid) | `architecture/system-context.md`, `containers.md`, `components-*.md` |
| **3** | Architecture Decision Records — inferred from code and git history | `adr/0001-*.md`, `adr/0002-*.md`, ... |
| **3b** | Project evolution timeline — phases, decisions, Mermaid timeline diagram | `architecture/project-evolution.md` |
| **4** | Domain reference — aggregates, events, specifications, value objects | `reference/domain-model.md` |
| **5** | API reference — endpoints grouped by feature, auth requirements | `reference/api-endpoints.md` |
| **6** | Developer onboarding — prerequisites, setup, run locally, run tests | `guides/getting-started.md` |
| **7** | Index and summary — links to all generated docs, review checklist | `index.md`, `adr/index.md` |

**Flags:**
- `--full` — Run all phases (default)
- `--phase N` — Run only phase N (e.g., `--phase 2` for just architecture diagrams)
- `--dry-run` — Run phase 1 analysis only, show what would be generated
- `--skip-existing` — Don't regenerate docs that already exist

Always presents phase 1 analysis first and waits for approval before generating. All output is marked as **draft** for human review.

### doc-prd

**Command:** `/doc-prd [feature name]`
**Trigger:** "create a PRD", "write requirements", "product spec"

Generates a Product Requirements Document with: problem statement, goals/non-goals, user stories, requirements with acceptance criteria, success metrics, and timeline.

### doc-rfc

**Command:** `/doc-rfc [proposal title]`
**Trigger:** "write an RFC", "propose a change", "technical proposal"

Generates a Request for Comments with: summary, motivation (current vs. desired state), detailed design, at least 2 genuine alternatives, drawbacks, migration strategy, and unresolved questions. Auto-increments RFC numbers.

### doc-design

**Command:** `/doc-design [system name]`
**Trigger:** "write a design doc", "technical design", "system design"

Generates a Design Document with: architecture (including C4 diagrams), component design, data design, API design, alternatives, cross-cutting concerns (security, observability, scalability, reliability), test plan, and implementation plan.

### doc-adr

**Command:** `/doc-adr [decision title]`
**Trigger:** "record this decision", "write an ADR", "document why we chose"

Generates an Architecture Decision Record in MADR format with: context, decision drivers, at least 2-3 options with pros/cons, decision outcome with justification, consequences (positive, negative, neutral), and validation criteria. Auto-increments ADR numbers.

### doc-runbook

**Command:** `/doc-runbook [operation type]`
**Trigger:** "write a runbook", "ops guide", "incident response procedure"

Generates an operational runbook with: diagnosis steps (concrete commands), common causes ordered by likelihood, resolution steps (copy-pasteable), rollback procedure, escalation criteria, and verification checklist.

### doc-postmortem

**Command:** `/doc-postmortem [incident title]`
**Trigger:** "write a post-mortem", "incident report", "document the outage"

Generates a blameless post-mortem with: impact (concrete numbers), timeline with timestamps, root cause and contributing factors, detection analysis, action items (prevent/detect/respond) with owners and due dates, and "where we got lucky" section.

### doc-spike

**Command:** `/doc-spike [research question]`
**Trigger:** "write up the spike", "research report", "compare options"

Generates a spike report with: clear question, time-box, findings with evidence, comparison table (if applicable), recommendation tied back to the question, and open questions.

---

## Visualization Skills

### viz-c4-diagram

**Command:** `/viz-c4-diagram [system name] [level]`
**Trigger:** "draw a C4 diagram", "architecture diagram", "container diagram"

Generates C4 architecture diagrams using Mermaid syntax:
- **Level 1 — Context:** `C4Context` — system, users, external systems
- **Level 2 — Container:** `C4Container` — apps, databases, queues
- **Level 3 — Component:** `C4Component` — internal structure of a container
- **Level 4 — Code:** `classDiagram` — class relationships
- **Deployment:** `C4Deployment` — infrastructure topology

---

## Tool Skills

### tool-vitepress

**Command:** `/tool-vitepress [init | dev | build | preview]`
**Trigger:** "render the docs", "start the docs site", "set up VitePress"

Manages a VitePress documentation site with Mermaid diagram support:
- `init` — install dependencies, create config, set up landing page
- `dev` — start dev server at localhost:5173
- `build` — build static site to `.vitepress/dist/`
- `preview` — build and preview

### tool-ux-study

**Command:** `/tool-ux-study [count] [--user=N] [--duser=N] [--model=sonnet|opus|haiku] [--review-model=sonnet|opus|haiku]`
**Trigger:** "run a usability test", "UX study", "test with AI users"

Spawns a managed team of AI test agents that each log in as a different seeded community member and run a think-aloud usability study. The lead agent acts as UX research facilitator — observing sessions, probing testers with follow-up questions, maintaining running observation notes, and synthesizing findings into narrative themes.

**Arguments:**
- `count` or `--user=N` — number of regular testers (default: 3, max: 15)
- `--duser=N` — number of accessibility testers simulating disabilities like blindness, motor impairment, cognitive disability, low vision, deafness (default: 1, max: 5)
- `--model` — model for tester agents (default: `sonnet`)
- `--review-model` — model for PM, UX, and WCAG reviewer agents (default: inherits from parent)

**How it works:**
1. Discovers the running app (reads Aspire resources or uses provided URL)
2. Spawns test agents in parallel, each with a unique persona and seeded browser session
3. Testers narrate their experience (think-aloud protocol) while navigating the app with screenshots
4. Facilitator observes, takes running notes, and probes testers with follow-up questions
5. After testing, spawns expert reviewers (PM, UX Designer, WCAG auditor) to cross-reference findings
6. Synthesizes everything into a final report

**Produces:**
- Individual tester reports with annotated screenshots
- Facilitator observation notes (running notes taken during testing)
- Affinity map with clustered themes
- Product Manager expert review (feature gaps, business impact)
- UX Designer expert review (interaction patterns, design recommendations)
- WCAG accessibility review with severity ratings (when accessibility testers included)
- Prioritized product backlog with effort estimates
- VitePress report site for browsing all results

### tool-worktree

**Command:** `/tool-worktree`
**Trigger:** "create a branch", "sync branches", "update worktrees", "clean up branches", "worktree"

Manages git repositories that use the bare + worktree pattern (each branch is a separate directory). Supports:
- `git wtc` — clone repo as bare + worktree
- `git wta` — add worktree (new branch or checkout existing remote)
- `git wtd` — remove worktree and delete branch
- `git wtu` — rebase current branch on main
- `git wtl` — list all worktrees
- `git wtmigrate` — convert normal clone to bare + worktree
- **Sync all** — pull main, then rebase every open worktree branch (skips dirty worktrees, aborts on conflicts)
- **Health check** — find merged branches, stale worktrees, dirty state

### tool-agentsandbox-merge

**Command:** `/tool-agentsandbox-merge [session-name] [--review | --merge | --cherry-pick | --squash]`
**Trigger:** "merge agentsandbox", "merge cb", "pull in cb work"

Merges work from a agentsandbox session worktree into the current branch. Reviews changes made by Claude in a agentsandbox worktree (`agentsandbox/<source>-<session>` branch), presents a diff summary, and merges or cherry-picks commits into the target branch. Run from the target branch (e.g. main).

**Flags:** `--review` (diff only), `--merge` (fast-forward or merge commit), `--cherry-pick` (individual commits), `--squash` (single commit).
