Repository Catalog


Comparative Analysis Table
Extracted Best Practices
The most consistent pattern is to keep project instructions short, local, and hierarchical: root-level instructions define global behavior, while nested files override for subprojects �. Another recurring best practice is to separate planning from implementation and then enforce QA through hooks or dedicated reviewers, rather than asking one agent to do everything at once �. Strong templates also emphasize explicit commands for build, test, and lint workflows, because agents work far better when the repository tells them exactly how to validate changes �.
Missing Opportunities
The biggest gaps are architecture drift, context loss across long sessions, weak end-to-end QA, and inconsistent deployment workflows. Most public templates still do not fully solve database consistency, design-system coherence, multi-tenant SaaS structure, or repeated review loops that catch regressions before deploy �. There is also a gap between “agent can code” and “agent can ship production-ready full-stack SaaS,” especially for auth, storage, payments, email, analytics, observability, and CI/CD integration �.
Recommended Architecture
Use a single orchestrator agent with seven specialists: Product Manager, Solution Architect, UI/UX Designer, Frontend Engineer, Backend Engineer, QA & Security, and DevOps & Deployment. This aligns with Claude Code’s subagent model, where each subagent has a custom prompt, scoped tool access, and returns only final results to the orchestrator �. Put AGENTS.md at the root for portability, keep CLAUDE.md as a pointer or compatibility shim, and rely on hooks to enforce format, tests, security checks, and deployment readiness �.
Context Strategy
Use a layered context model: global principles in CLAUDE.md, repo-wide rules in AGENTS.md, feature-specific notes in nested AGENTS.md files, and ephemeral work plans in task files like docs/specs/*.md or work/plan.md. This minimizes token bloat and helps the agent load only the nearest relevant instructions, which is a documented strength of AGENTS.md nesting �. Add command-driven summaries after each major milestone so the orchestrator can compress state into durable artifacts instead of depending on chat memory �.
Workflow Strategy
The mandatory workflow should be Requirements → Product Spec → Architecture Plan → Database Design → UI System Design → Implementation → Testing → Security Review → Deployment → Documentation, with a required gate between each stage. That workflow is consistent with spec-driven templates and with multi-stage review practices described in public Claude Code resources �. Each gate should be enforced by a hook or reviewer agent that can block progression when tests, lint, type checks, or security checks fail �.
Complete Agent Framework Blueprint
Folder tree
.
├─ CLAUDE.md
├─ AGENTS.md
├─ .claude/
│  ├─ agents/
│  │  ├─ pm.md
│  │  ├─ architect.md
│  │  ├─ uiux.md
│  │  ├─ frontend.md
│  │  ├─ backend.md
│  │  ├─ qa-security.md
│  │  └─ devops.md
│  ├─ commands/
│  │  ├─ spec.md
│  │  ├─ plan.md
│  │  ├─ build.md
│  │  ├─ test.md
│  │  ├─ review.md
│  │  └─ deploy.md
│  ├─ skills/
│  ├─ hooks/
│  └─ memory/
├─ docs/
│  ├─ product/
│  ├─ architecture/
│  ├─ db/
│  ├─ ui/
│  ├─ qa/
│  └─ ops/
├─ app/
├─ components/
├─ server/
├─ db/
├─ tests/
├─ scripts/
└─ .github/
   ├─ workflows/
   └─ pull_request_template.md
Agent definitions
Product Manager Agent: converts requirements into scoped user stories, acceptance criteria, and release slices �.
Solution Architect Agent: selects stack, service boundaries, data model strategy, and integration patterns �.
UI/UX Designer Agent: defines layout system, design tokens, states, and interaction rules for app-quality interfaces �.
Frontend Engineer Agent: implements screens, components, routing, client state, and accessibility �.
Backend Engineer Agent: builds APIs, auth, business logic, data access, and background jobs �.
QA & Security Agent: runs test strategy, reviews edge cases, threat models, and regression checks �.
DevOps & Deployment Agent: handles envs, CI/CD, observability, release process, and rollback planning �.
Prompt architecture
Each agent prompt should define purpose, scope, inputs, outputs, tools, invariants, and escalation rules. Keep prompts short and opinionated: one job per agent, one artifact per stage, one handoff format, and no overlapping authority unless explicitly delegated �. Include a strict output schema for every stage so the next agent can consume the result without interpretation.
Memory architecture
Use durable memory files for product decisions, stack choices, and non-obvious conventions, and never rely on chat history as the only source of truth. Store decisions as append-only markdown logs under .claude/memory/ and link them from AGENTS.md so the model knows where to look first �. Add a “decision register” and “open questions” file to prevent repeated re-litigation of resolved choices.
Review loops
Enforce at least three review passes: implementation review, QA/security review, and deployment readiness review. A practical pattern is “build, verify, adversarial review, fix, re-verify,” which is already visible in community workflows �. Reviewer agents should be able to reject changes with concrete failure reasons and required remediation steps.
Quality gates
Minimum gates should include lint, type check, unit tests, integration tests, build success, security scan, accessibility checks, and deployment dry-run. Hooks are the best place to automate these because they run at lifecycle points and can block or annotate tool usage �. For production SaaS, add API contract checks, schema migration validation, and smoke tests against preview deployments.
Implementation Roadmap
Start with a repo-wide AGENTS.md and a root CLAUDE.md shim for compatibility �.
Define the seven subagents and their output schemas using Claude Code subagent conventions �.
Add hooks for session start, post-tool-use, pre-commit, test enforcement, and deployment gating �.
Build command files for spec, plan, implement, test, review, and deploy to standardize the workflow �.
Add a full-stack opinionated stack template with auth, database, storage, email, payments, telemetry, and CI/CD.
Create a QA/security package with threat modeling, regression tests, and accessibility checks �.
Iterate with template projects that mimic SaaS, dashboards, and consumer app patterns, then tune prompts against failures.
References and URLs
Claude Code product page �
Claude Code sub-agents docs �
AGENTS.md �
AGENTS.md GitHub repo �
OpenAI Agents SDK AGENTS.md �
Awesome Claude Code �
Awesome Claude Code subagents �
Claude Code template �
Claude Code workflow �
Spec Kit template �
Swift Claude Code framework �
Salesforce Claude framework �
Claude Code hooks guide �
Claude Code QA agents �
Claude Code agents �


####
Below is a concrete v1 repository spec you can drop into a new project and start using immediately. It is designed around the seven-agent workflow you specified, uses a portable AGENTS.md root policy, and keeps CLAUDE.md as a compatibility shim plus concise project anchor �.
1) Repository layout
.
├─ CLAUDE.md
├─ AGENTS.md
├─ package.json
├─ .claude/
│  ├─ agents/
│  │  ├─ product-manager.md
│  │  ├─ solution-architect.md
│  │  ├─ uiux-designer.md
│  │  ├─ frontend-engineer.md
│  │  ├─ backend-engineer.md
│  │  ├─ qa-security.md
│  │  └─ devops-deployment.md
│  ├─ commands/
│  │  ├─ spec.md
│  │  ├─ plan.md
│  │  ├─ design.md
│  │  ├─ build.md
│  │  ├─ test.md
│  │  ├─ review.md
│  │  └─ deploy.md
│  ├─ hooks/
│  │  ├─ pre-tool-use.sh
│  │  ├─ post-tool-use.sh
│  │  ├─ subagent-start.sh
│  │  ├─ subagent-stop.sh
│  │  ├─ stop.sh
│  │  └─ validate-output.sh
│  └─ memory/
│     └─ decisions.md
├─ docs/
│  ├─ product/
│  ├─ architecture/
│  ├─ db/
│  ├─ ui/
│  ├─ qa/
│  └─ ops/
├─ src/
├─ server/
├─ db/
├─ tests/
├─ scripts/
└─ .github/
   └─ workflows/
2) CLAUDE.md
Use this as a short compatibility file. It should not duplicate everything in AGENTS.md; instead it should point to the canonical instructions and define the high-level operating mode.
# CLAUDE.md

This repository uses `AGENTS.md` as the primary agent instruction file.

## Project Mission

Build production-ready full-stack web applications with a seven-agent workflow:
1. Product Manager Agent
2. Solution Architect Agent
3. UI/UX Designer Agent
4. Frontend Engineer Agent
5. Backend Engineer Agent
6. QA & Security Agent
7. DevOps & Deployment Agent

## Operating Principles

- Prefer small, reviewable increments.
- Never skip the required workflow stages.
- Preserve architectural consistency across product, UI, backend, database, tests, and deployment.
- When uncertain, consult `AGENTS.md` and the nearest nested agent instruction file.
- Update durable project memory when a decision is finalized.

## Required Workflow

Requirements
→ Product Spec
→ Architecture Plan
→ Database Design
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

## Canonical Instructions

- Root policy: `AGENTS.md`
- Agent prompts: `.claude/agents/*.md`
- Commands: `.claude/commands/*.md`
- Memory: `.claude/memory/decisions.md`

## Quality Bar

All generated code must be:
- production-oriented,
- consistent with repository conventions,
- tested,
- secure by default,
- deployable with minimal manual repair.
3) AGENTS.md
This is the main repo instruction file. It should be practical, explicit, and optimized for coding agents. AGENTS.md is intended for build steps, tests, conventions, and other agent-specific guidance, and nested AGENTS.md files can override it in subdirectories �.
# AGENTS.md

## Repository purpose

This repository is a template for autonomous full-stack web app generation with Claude Code.

The system is optimized for:
- product definition,
- architecture planning,
- UI generation,
- backend implementation,
- QA/security review,
- deployment automation,
- documentation.

## Core rule

Do not jump directly into implementation.

Always follow this sequence:

Requirements
→ Product Spec
→ Architecture Plan
→ Database Design
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

## Agent model

Use seven specialized agents:
- product-manager
- solution-architect
- uiux-designer
- frontend-engineer
- backend-engineer
- qa-security
- devops-deployment

The orchestrator should delegate one stage at a time and require explicit handoff artifacts before continuing.

## Project conventions

- Prefer TypeScript.
- Prefer server-side validation for all critical inputs.
- Prefer explicit schemas for API payloads and database records.
- Keep business logic out of UI components.
- Keep UI components pure and reusable.
- Centralize design tokens and shared UI primitives.
- Keep deployment config in version control.

## Required artifacts

Before implementation, the following artifacts must exist:

- `docs/product/spec.md`
- `docs/architecture/plan.md`
- `docs/db/schema.md`
- `docs/ui/system.md`
- `docs/qa/test-plan.md`
- `docs/ops/deployment.md`

## Build and test expectations

Agents should discover the exact commands from `package.json`, but the default expectation is:

- install dependencies
- run type checks
- run lint
- run unit tests
- run integration tests where available
- build the application
- run smoke checks
- verify deployment configuration

If tests or checks fail, fix the root cause before concluding.

## Security expectations

- Validate all user input.
- Avoid secret leakage into logs or prompts.
- Never hardcode secrets.
- Review auth, authorization, file uploads, payments, and webhooks carefully.
- Check for injection, unsafe redirects, insecure object access, and missing access control.

## Memory and decisions

Record durable decisions in:

- `.claude/memory/decisions.md`

Write decisions only when they are final and actionable.

## Handoff rule

Each agent must produce:
- summary of findings,
- decisions made,
- open questions,
- next artifact to create.

## Style rule

Prefer concise, structured output.
Use bullet lists for decisions, risks, and next actions.
Use tables for comparisons.
Do not produce speculative implementation without a staged plan.
4) Seven agent prompts
These are file contents for .claude/agents/*.md. They are written as subagent definitions in the format Claude Code supports: YAML frontmatter plus a Markdown system prompt �. I’ve kept them scoped and reusable.
product-manager.md
---
name: product-manager
description: Converts requirements into product specs, user stories, acceptance criteria, and delivery slices
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: blue
maxTurns: 8
---

You are the Product Manager Agent.

Your job:
- turn vague requirements into a precise product specification,
- identify personas, use cases, and user journeys,
- define MVP scope and non-goals,
- write acceptance criteria,
- produce delivery slices that can be implemented incrementally.

Inputs you need:
- user goals,
- target users,
- business model,
- product constraints,
- known technical constraints,
- competitive references.

Outputs you must produce:
- product summary,
- user personas,
- core workflows,
- functional requirements,
- non-functional requirements,
- MVP scope,
- out-of-scope items,
- acceptance criteria,
- open questions,
- recommended next artifact.

Rules:
- Do not design implementation details unless they affect scope.
- Prefer clarity over completeness.
- If requirements are ambiguous, list explicit assumptions.
- Optimize for a full-stack web app builder, not a generic app.

Memory behavior:
- Record durable product decisions.
- Record recurring product patterns and scope boundaries.
- Keep entries short and dated.

Handoff format:
- Summary
- Decisions
- Risks
- Open questions
- Next step
solution-architect.md
---
name: solution-architect
description: Defines stack, architecture, services, data boundaries, and integration strategy
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: purple
maxTurns: 8
---

You are the Solution Architect Agent.

Your job:
- translate product requirements into a maintainable technical architecture,
- choose the stack and major libraries,
- define service boundaries,
- define data flows,
- define integration and deployment constraints,
- identify risks and architecture tradeoffs.

Inputs you need:
- product spec,
- non-functional requirements,
- target deployment environment,
- expected scale,
- integration requirements.

Outputs you must produce:
- architecture overview,
- stack recommendation,
- system boundaries,
- request/data flow diagrams in text form,
- key technical decisions,
- risks and mitigations,
- dependency list,
- implementation constraints,
- next artifact.

Rules:
- Prefer simple architectures first.
- Avoid premature microservices.
- Make auth, storage, payments, email, analytics, and deployment first-class concerns.
- Ensure the backend and database plan are consistent with the product scope.

Memory behavior:
- Record stack choices, service boundaries, and major integration decisions.
- Update memory when architecture is finalized.

Handoff format:
- Summary
- Decision log
- Constraints
- Risks
- Next step
uiux-designer.md
---
name: uiux-designer
description: Designs the UI system, layout rules, interaction patterns, and design tokens
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: pink
maxTurns: 8
---

You are the UI/UX Designer Agent.

Your job:
- define the UI system,
- specify page structure and information hierarchy,
- define reusable layout and component patterns,
- define design tokens and interaction states,
- make the app feel polished and production-ready.

Inputs you need:
- product spec,
- user journeys,
- architecture constraints,
- target device strategy,
- brand direction if any.

Outputs you must produce:
- UI principles,
- design tokens,
- typography and spacing rules,
- page-by-page structure,
- component inventory,
- empty/loading/error states,
- accessibility requirements,
- responsive behavior,
- handoff notes for frontend implementation.

Rules:
- Favor clear, modern, app-like UI.
- Be explicit about layout, spacing, states, and component behavior.
- Keep implementation guidance aligned with the chosen frontend stack.
- Design for production, not demo polish.

Memory behavior:
- Record reusable UI patterns, layout decisions, and token choices.
- Save recurring accessibility or interaction rules.

Handoff format:
- Summary
- UI rules
- Components
- States
- Accessibility
- Next step
frontend-engineer.md
---
name: frontend-engineer
description: Implements the frontend, components, state management, routing, and accessibility
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: green
maxTurns: 12
---

You are the Frontend Engineer Agent.

Your job:
- implement pages, components, and client-side behavior,
- keep the UI consistent with the design system,
- handle loading, empty, and error states,
- implement accessibility and responsiveness,
- keep business logic out of the view layer.

Inputs you need:
- product spec,
- architecture plan,
- UI system spec,
- API contracts,
- test expectations.

Outputs you must produce:
- implemented UI code,
- reusable components,
- routing and page structure,
- client state approach,
- accessibility notes,
- frontend tests where applicable,
- implementation summary.

Rules:
- Follow the approved UI system exactly.
- Use shared primitives before creating new ones.
- Avoid duplicating business logic.
- Prefer small components with clear props.
- If API contracts are unclear, stop and request clarification.

Memory behavior:
- Record reusable frontend patterns and component decisions.
- Record any tricky integration issues and fixes.

Handoff format:
- Summary
- Files changed
- UI behaviors implemented
- Open issues
- Next step
backend-engineer.md
---
name: backend-engineer
description: Implements APIs, validation, business logic, auth, storage, emails, and database access
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: orange
maxTurns: 12
---

You are the Backend Engineer Agent.

Your job:
- implement APIs and server logic,
- define and enforce validation,
- implement authentication and authorization,
- integrate database, storage, email, payments, and webhooks,
- keep data access consistent and safe.

Inputs you need:
- product spec,
- architecture plan,
- database design,
- API requirements,
- security requirements.

Outputs you must produce:
- server code,
- route handlers or controllers,
- domain logic,
- validation schemas,
- database queries or ORM models,
- migration support,
- integration code,
- backend tests when appropriate.

Rules:
- Validate inputs at the server boundary.
- Enforce authorization on every sensitive operation.
- Keep business rules centralized.
- Avoid leaking secrets or internal errors.
- Make migrations and schema changes explicit.

Memory behavior:
- Record data model decisions, API conventions, and integration patterns.
- Record recurring backend pitfalls and corrections.

Handoff format:
- Summary
- Files changed
- API/data changes
- Security notes
- Next step
qa-security.md
---
name: qa-security
description: Verifies correctness, tests behavior, checks edge cases, and reviews security risks
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: red
maxTurns: 10
---

You are the QA & Security Agent.

Your job:
- validate that implementation matches requirements,
- run and interpret tests,
- identify defects and regressions,
- assess security risks,
- verify production readiness.

Inputs you need:
- product spec,
- architecture plan,
- implementation diff,
- test output,
- deployment plan.

Outputs you must produce:
- QA findings,
- test coverage gaps,
- security findings,
- risk severity,
- recommended fixes,
- go/no-go recommendation.

Rules:
- Be skeptical.
- Verify claims against the code and tests.
- Check auth, authorization, data leakage, injection, file upload, CSRF, SSRF, XSS, IDOR, and secret handling.
- Report failures with reproduction steps.
- Prefer blocking findings over vague advice.

Memory behavior:
- Record repeated defect patterns and security concerns.
- Record recurring test gaps and missing checks.

Handoff format:
- Summary
- Test results
- Security findings
- Blockers
- Next step
devops-deployment.md
---
name: devops-deployment
description: Prepares CI/CD, environment configuration, release workflows, observability, and deployment validation
tools: Read, Grep, Glob, Bash
model: sonnet
memory: project
color: cyan
maxTurns: 10
---

You are the DevOps & Deployment Agent.

Your job:
- define deployment workflow,
- validate environment variables and secrets handling,
- prepare CI/CD,
- ensure repeatable builds,
- define rollback and monitoring expectations,
- verify production release readiness.

Inputs you need:
- architecture plan,
- backend and frontend implementation,
- deployment target,
- environment requirements,
- test and QA results.

Outputs you must produce:
- deployment plan,
- CI/CD workflow,
- environment variable matrix,
- release checklist,
- rollback plan,
- observability recommendations,
- production readiness assessment.

Rules:
- Deployment must be repeatable and documented.
- Environment values must never be hardcoded.
- Include preview and production guidance when relevant.
- Prefer conservative release steps with explicit validation.

Memory behavior:
- Record deployment conventions, environment patterns, and release decisions.
- Record platform-specific gotchas.

Handoff format:
- Summary
- Deployment plan
- Env matrix
- Risks
- Next step
5) Hook set
These are practical starter hook scripts. Claude Code supports lifecycle hooks, and subagents can also define hooks in frontmatter or the main session settings �.
.claude/hooks/pre-tool-use.sh
#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"
input="$(printf '%s' "$payload" | jq -r '.tool_input // {}')"

if [ "$tool" = "Bash" ]; then
  if printf '%s' "$input" | grep -Eq 'rm -rf /|sudo rm -rf|curl.*|s*bash|wget.*|s*bash'; then
    echo "Blocked risky shell command." >&2
    exit 2
  fi
fi

exit 0
.claude/hooks/post-tool-use.sh
#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
tool="$(printf '%s' "$payload" | jq -r '.tool_name // empty')"

mkdir -p .claude/logs
printf '%s
' "$payload" >> .claude/logs/tool-events.jsonl

if [ "$tool" = "Edit" ] || [ "$tool" = "Write" ]; then
  git diff -- . ':!node_modules' > .claude/logs/latest-diff.txt || true
fi

exit 0
.claude/hooks/subagent-start.sh
#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
agent_type="$(printf '%s' "$payload" | jq -r '.agent_type // empty')"

mkdir -p .claude/logs
printf '%s %s
' "$(date -Is)" "START $agent_type" >> .claude/logs/subagents.log

exit 0
.claude/hooks/subagent-stop.sh
#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
agent_type="$(printf '%s' "$payload" | jq -r '.agent_type // empty')"

mkdir -p .claude/logs
printf '%s %s
' "$(date -Is)" "STOP $agent_type" >> .claude/logs/subagents.log

exit 0
.claude/hooks/stop.sh
#!/usr/bin/env bash
set -euo pipefail

mkdir -p .claude/memory
if [ -f .claude/memory/decisions.md ]; then
  tail -n 200 .claude/memory/decisions.md > .claude/memory/decisions.tmp || true
  mv .claude/memory/decisions.tmp .claude/memory/decisions.md
fi

exit 0
.claude/hooks/validate-output.sh
#!/usr/bin/env bash
set -euo pipefail

payload="$(cat)"
text="$(printf '%s' "$payload" | jq -r '.text // empty')"

if printf '%s' "$text" | grep -qiE 'TODO|FIXME|placeholder'; then
  echo "Output contains unresolved placeholders." >&2
  exit 2
fi

exit 0
6) Command set
These are the user-facing workflow commands.
.claude/commands/spec.md
Generate or refine the product spec.

Steps:
1. Gather requirements.
2. Identify target users and use cases.
3. Define MVP scope.
4. List out-of-scope items.
5. Write acceptance criteria.
6. Save the result to `docs/product/spec.md`.

Output must include:
- Summary
- Scope
- Requirements
- Acceptance criteria
- Open questions
- Next artifact
.claude/commands/plan.md
Create the technical plan.

Steps:
1. Read the product spec.
2. Choose the architecture.
3. Define the stack.
4. Define data and service boundaries.
5. Write the implementation plan.
6. Save the result to `docs/architecture/plan.md`.

Output must include:
- Summary
- Stack
- Boundaries
- Key decisions
- Risks
- Next artifact
.claude/commands/design.md
Design the UI system.

Steps:
1. Read the product spec and architecture plan.
2. Define design tokens and layout rules.
3. Define page structure and component inventory.
4. Define states and accessibility rules.
5. Save the result to `docs/ui/system.md`.

Output must include:
- Summary
- UI principles
- Tokens
- Components
- States
- Accessibility
- Next artifact
.claude/commands/build.md
Implement the approved plan.

Steps:
1. Read product, architecture, database, and UI docs.
2. Implement the smallest coherent slice.
3. Keep changes aligned to the required architecture.
4. Add or update tests where needed.
5. Summarize files changed and remaining gaps.

Output must include:
- Summary
- Files changed
- Implemented slice
- Risks
- Next step
.claude/commands/test.md
Run the full validation loop.

Steps:
1. Run lint, type checks, and tests.
2. Run any available integration or smoke checks.
3. Identify failures and fix root causes.
4. Record test results and gaps.

Output must include:
- Summary
- Commands run
- Results
- Failures
- Next step
.claude/commands/review.md
Perform a quality and security review.

Steps:
1. Inspect the implementation against the spec.
2. Check for correctness, maintainability, and security.
3. Identify blockers and risks.
4. Recommend fixes or approve progression.

Output must include:
- Summary
- Findings
- Severity
- Blockers
- Next step
.claude/commands/deploy.md
Prepare the release.

Steps:
1. Read implementation and QA results.
2. Verify environment variables and build requirements.
3. Validate CI/CD workflow.
4. Confirm rollback and observability plan.
5. Produce deployment checklist.

Output must include:
- Summary
- Deployment steps
- Environment matrix
- Risks
- Release checklist
7) Memory file
.claude/memory/decisions.md
# Decision Log

This file records durable project decisions only.

## Format
- Date
- Decision
- Reason
- Impact
- Related files

## Example
- 2026-05-22: Use TypeScript for all application code.
  - Reason: better maintainability and safer refactoring.
  - Impact: frontend, backend, shared types, tests.
  - Related files: `package.json`, `tsconfig.json`, `docs/architecture/plan.md`

## Rules
- Record only final decisions.
- Keep entries short.
- Prefer one decision per bullet.
- Update when a decision changes.
8) How the workflow should run
Start with spec to define the product.
Run plan to choose the architecture.
Run design to lock the UI system.
Run build for the first implementation slice.
Run test to validate the slice.
Run review for QA and security.
Run deploy only after passing gates.
Record durable outcomes in .claude/memory/decisions.md �.
9) Recommended next step
The next best move is to turn this into a real starter repo with a default stack, for example Next.js + TypeScript + Prisma + PostgreSQL + Tailwind + Playwright, and then add a first pass of package.json, CI workflow, and sample docs/*.md artifacts. The Claude Code docs explicitly support subagents with scoped tools, model choice, memory, hooks, and isolated worktrees, which makes this framework a good fit for a serious production template �.

####
I’ll proceed with a React + Vite v1 stack and keep the same agent framework, but adapt the repo conventions, commands, and quality gates to a frontend-first app builder. Vite’s production model is build-then-serve from dist/, so the framework should explicitly treat build output, preview/deploy, and type checking as first-class gates �.
1) React Vite v1 stack
Recommended default stack for this template:
React 18+
Vite
TypeScript
React Router
TanStack Query
Zustand or lightweight local state
Tailwind CSS
shadcn/ui or a similar component layer
Vitest + React Testing Library
Playwright for e2e
ESLint + Prettier
Optional backend adapter later, but v1 should stay frontend-first
Vite’s docs emphasize vite build for production and dist/ as the build artifact directory, so your deployment and validation commands should revolve around that output �. React + Vite templates commonly pair with TypeScript, unit tests, linting, and CI from the beginning, which fits the production quality bar you want �.
2) Updated repository shape
Use this structure for a React Vite app builder:
.
├─ CLAUDE.md
├─ AGENTS.md
├─ package.json
├─ vite.config.ts
├─ tsconfig.json
├─ index.html
├─ src/
│  ├─ app/
│  ├─ components/
│  ├─ features/
│  ├─ routes/
│  ├─ lib/
│  ├─ hooks/
│  ├─ styles/
│  ├─ test/
│  └─ main.tsx
├─ public/
├─ docs/
│  ├─ product/
│  ├─ architecture/
│  ├─ ui/
│  ├─ qa/
│  └─ ops/
├─ .claude/
│  ├─ agents/
│  ├─ commands/
│  ├─ hooks/
│  └─ memory/
├─ tests/
│  └─ e2e/
└─ .github/
   └─ workflows/
This keeps the subagent and workflow system intact while making the app structure idiomatic for React Vite and easier for the frontend agent to navigate. A separate src/features/ layer gives the builder a clean path to scale beyond a toy demo without turning everything into one component soup.
3) React Vite command set
Update the command files to reflect frontend-first workflows:
.claude/commands/build.md
Implement the approved slice in React + Vite.

Steps:
1. Read the product spec, architecture plan, and UI system.
2. Implement the feature in `src/`.
3. Keep components reusable and typed.
4. Add unit tests and, if needed, e2e coverage.
5. Summarize files changed and any remaining gaps.

Output must include:
- Summary
- Files changed
- Implemented slice
- Risks
- Next step
.claude/commands/test.md
Run the frontend validation loop.

Steps:
1. Run type checks.
2. Run lint.
3. Run unit tests.
4. Run Playwright or other e2e checks if available.
5. Fix root causes for failures.

Output must include:
- Summary
- Commands run
- Results
- Failures
- Next step
.claude/commands/deploy.md
Prepare the Vite production release.

Steps:
1. Verify `npm run build` succeeds.
2. Confirm `dist/` is the output directory.
3. Validate preview or hosting settings.
4. Check environment variables.
5. Produce release checklist.

Output must include:
- Summary
- Deployment steps
- Environment matrix
- Risks
- Release checklist
4) Vite-specific AGENTS.md
Here is the React Vite version of the root policy:
# AGENTS.md

## Repository purpose

This repository is a React + Vite template for autonomous app generation.

## Required workflow

Requirements
→ Product Spec
→ Architecture Plan
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

## Stack defaults

- React
- Vite
- TypeScript
- React Router
- TanStack Query
- Zustand or minimal local state
- Tailwind CSS
- Vitest
- React Testing Library
- Playwright

## Build expectations

- `npm run dev` for local development
- `npm run build` for production
- `npm run preview` for production smoke verification
- `npm run lint`
- `npm run test`
- `npm run test:e2e` when present
- `npm run typecheck`

## Architecture rules

- Keep UI logic in components.
- Keep shared logic in `src/lib/`.
- Keep domain logic in feature modules.
- Prefer typed props and typed API contracts.
- Keep routes thin and feature-driven.

## Production rule

Do not consider the app complete until:
- build succeeds,
- type checks pass,
- lint passes,
- tests pass,
- preview works,
- deployment config is documented.

## Memory

Record durable decisions in `.claude/memory/decisions.md`.
5) React Vite CLAUDE.md
# CLAUDE.md

This repository is a React + Vite application template for autonomous code generation.

## Mission

Generate production-ready frontends with a structured workflow and specialized subagents.

## Workflow

Requirements
→ Product Spec
→ Architecture Plan
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

## Canonical instructions

- Root policy: `AGENTS.md`
- Agents: `.claude/agents/*.md`
- Commands: `.claude/commands/*.md`
- Memory: `.claude/memory/decisions.md`

## Quality bar

- typed,
- modular,
- tested,
- accessible,
- production-ready,
- buildable with Vite.
6) React Vite agent adjustments
Your seven agents stay the same, but their scope becomes frontend-centered. The frontend agent now owns routing, component composition, data fetching, and client state. The backend agent becomes optional or adapter-based in v1, and can be used only if you later add a server/API layer.
Minimal agent priority order
Product Manager Agent
Solution Architect Agent
UI/UX Designer Agent
Frontend Engineer Agent
QA & Security Agent
DevOps & Deployment Agent
Backend Engineer Agent only when a backend exists
This keeps the template aligned with React Vite’s natural strengths while preserving the full system for future expansion.
7) Recommended package.json scripts
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "test": "vitest",
    "test:watch": "vitest --watch",
    "test:e2e": "playwright test"
  }
}
Vite explicitly uses vite build for production artifacts, and a production deployment should serve the generated dist/ folder rather than the dev server �. That means your deployment hooks should verify build output, not just local runtime behavior.
8) Hooks to add for React Vite
Add these as the first working version:
pre-tool-use.sh: block risky shell commands and prompt for build/test-safe actions.
post-tool-use.sh: log file diffs and touched areas.
validate-output.sh: reject placeholder content and incomplete artifacts.
stop.sh: checkpoint durable decisions to memory.
optional pre-commit hook in Git, outside Claude, to run lint && typecheck && test.
Claude Code hooks are designed for automatic lifecycle execution, so they are a good fit for enforcing Vite build discipline and preventing unsafe shell operations �.
9) Next implementation slice
The best next slice is:
scaffold the Vite repo,
add the exact files above,
create src/app, src/routes, and src/components,
add a landing page and one representative app flow,
wire up Vitest and Playwright,
add a simple deployment target like Vercel or Netlify.
Vite production deployment is straightforward once build emits dist/, and common hosting platforms accept that structure directly �. Would you like me to generate the exact starter file tree and the first cut of package.json, vite.config.ts, and src/ files next?

####
Yes — the right next step is a frontend-specific AGENTS.md that tells Claude Code how to behave in a React + Vite repo. AGENTS.md is meant to hold build steps, tests, conventions, and other agent-facing guidance, and the closest AGENTS.md should win for the current directory �.
AGENTS.md for React Vite
# AGENTS.md

## Repository purpose

This repository is a React + Vite application template for autonomous full-stack-grade frontend generation.

The goal is to produce production-ready user interfaces, feature flows, and client-side application logic with a disciplined agent workflow.

## Primary workflow

Follow this sequence and do not skip stages unless the user explicitly requests it:

Requirements
→ Product Spec
→ Architecture Plan
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

## Stack defaults

Use these defaults unless the project documents a different choice:

- React
- Vite
- TypeScript
- React Router
- TanStack Query
- Zustand or minimal local state
- Tailwind CSS
- shadcn/ui or equivalent primitives
- Vitest
- React Testing Library
- Playwright
- ESLint
- Prettier

## Repository structure

Prefer this structure:

- `src/app` for application bootstrap and providers
- `src/routes` for route definitions
- `src/features` for feature modules
- `src/components` for shared components
- `src/lib` for utilities and shared helpers
- `src/hooks` for reusable hooks
- `src/styles` for global styles and tokens
- `tests/e2e` for Playwright tests
- `docs/` for product, architecture, UI, QA, and ops artifacts
- `.claude/` for agent prompts, commands, hooks, and memory

## Build and run commands

Use the repository scripts, but these are the expected defaults:

- `npm run dev` for local development
- `npm run build` for production builds
- `npm run preview` to verify the built app
- `npm run typecheck` for TypeScript validation
- `npm run lint` for linting
- `npm run test` for unit tests
- `npm run test:e2e` for browser tests when present

If a script is missing, inspect `package.json` and use the project-defined equivalent.

## Production expectations

Do not consider a feature complete until:

- the app builds successfully,
- TypeScript passes,
- lint passes,
- tests pass,
- the UI is responsive,
- empty, loading, and error states exist where relevant,
- accessibility is addressed,
- the feature can be previewed from the production build.

Vite production output should be treated as the source of truth for deployability, not the dev server [web:53][web:58].

## Frontend architecture rules

- Keep route files thin.
- Keep feature logic inside `src/features/<feature>/`.
- Keep shared UI primitives in `src/components/`.
- Keep utility code in `src/lib/`.
- Keep side effects in hooks or service modules.
- Keep state minimal and colocated.
- Prefer typed props and explicit data models.
- Prefer composition over inheritance.
- Prefer reusable, small components.
- Do not mix API orchestration, business logic, and rendering in one file.

## UI quality rules

- Use a coherent spacing and typography system.
- Define loading, empty, error, success, and disabled states.
- Preserve visual consistency across pages.
- Maintain accessibility, keyboard support, and semantic HTML.
- Avoid ad hoc styling when a shared token or component should be used.
- Make design decisions explicit in `docs/ui/system.md`.

## Testing rules

- Add tests for important UI behavior.
- Add tests for routing, state transitions, and data fetching when relevant.
- Prefer integration tests for user-visible flows.
- Use Playwright for critical end-to-end paths.
- Fix failing tests before moving on.

## Security rules

- Never hardcode secrets.
- Do not expose API keys in frontend code.
- Treat all user input as untrusted.
- Validate and sanitize any content rendered from external sources.
- Watch for XSS, open redirects, unsafe HTML, and auth token leakage.
- Review local storage usage carefully.

## Agent workflow rules

Use the seven agents in order:

1. Product Manager Agent
2. Solution Architect Agent
3. UI/UX Designer Agent
4. Frontend Engineer Agent
5. QA & Security Agent
6. DevOps & Deployment Agent
7. Backend Engineer Agent only if a backend is added

Each agent must produce:
- summary,
- decisions,
- risks,
- open questions,
- next artifact.

## Memory rules

Record durable decisions in:

- `.claude/memory/decisions.md`

Record only final, reusable decisions. Do not store temporary brainstorming notes there.

## Implementation rules

- Make the smallest useful change first.
- Keep diffs focused.
- Update documentation when behavior changes.
- Prefer explicit code over clever code.
- Use existing patterns before introducing new ones.
- Do not introduce unused abstractions.

## Deployment rules

- Verify the production build before deployment.
- Confirm the hosting target can serve the Vite `dist/` output.
- Document environment variables and runtime assumptions.
- Include rollback notes in `docs/ops/deployment.md`.

## Stop conditions

Pause and ask for clarification if:
- a requirement changes architecture,
- the requested behavior conflicts with the documented stack,
- the task needs a backend or external service that is not yet defined,
- API contracts are missing or inconsistent,
- the UI spec is not sufficient to implement safely.

## Output style

Prefer concise, structured output.

Use:
- bullets for decisions, risks, and next steps,
- tables for comparisons,
- short sections with clear headings.

Avoid speculative implementation detail unless the relevant stage has been completed.
Why this version works
This version stays aligned with AGENTS.md’s purpose as repo-level guidance for build steps, tests, conventions, and workflow rules, and it leverages the “nearest file wins” model so feature folders can later override it if needed �. It also bakes in the Vite production requirement that the build output, not the dev server, is what matters for release readiness �.
Recommended next file
The next file to create should be .claude/commands/spec.md, because that is the first user-facing workflow entry point after the global agent policy. After that, define docs/product/spec.md as the canonical output artifact for the product manager agent.
Would you like me to draft the matching CLAUDE.md next, or move straight to .claude/commands/spec.md?

###
Absolutely — here is a matching CLAUDE.md for the React + Vite stack. It is intentionally short, directive, and aligned with the root AGENTS.md, while reinforcing the production build and subagent workflow �.
# CLAUDE.md

This repository is a React + Vite application template for autonomous app generation.

## Mission

Build production-ready frontend applications with a structured Claude Code workflow, specialized subagents, and strong validation gates.

## Canonical instructions

- Root repository policy: `AGENTS.md`
- Agent prompts: `.claude/agents/*.md`
- Workflow commands: `.claude/commands/*.md`
- Durable decisions: `.claude/memory/decisions.md`

## Required workflow

Requirements
→ Product Spec
→ Architecture Plan
→ UI System Design
→ Implementation
→ Testing
→ Security Review
→ Deployment
→ Documentation

Do not skip stages unless the user explicitly requests it.

## Stack

Use these defaults unless the project states otherwise:

- React
- Vite
- TypeScript
- React Router
- TanStack Query
- Zustand or minimal local state
- Tailwind CSS
- shadcn/ui or equivalent primitives
- Vitest
- React Testing Library
- Playwright
- ESLint
- Prettier

## Operating principles

- Prefer small, reviewable changes.
- Keep routes thin and feature logic isolated.
- Keep shared UI primitives reusable.
- Keep business logic out of components.
- Keep state minimal and explicit.
- Favor typed interfaces and validated data contracts.
- Preserve consistency with the UI system and architecture plan.
- Record final decisions in `.claude/memory/decisions.md`.

## Production bar

A feature is not complete until:

- `npm run build` succeeds,
- TypeScript passes,
- lint passes,
- tests pass,
- the app previews correctly from the production build,
- accessibility and error states are addressed,
- deployment assumptions are documented.

Vite production output should be treated as the deployable artifact, not the dev server [web:53][web:61].

## Agent model

Use seven agents in order:

1. Product Manager Agent
2. Solution Architect Agent
3. UI/UX Designer Agent
4. Frontend Engineer Agent
5. QA & Security Agent
6. DevOps & Deployment Agent
7. Backend Engineer Agent only if a backend is added

Each agent must return:
- summary,
- decisions,
- risks,
- open questions,
- next artifact.

## Stop conditions

Pause and ask for clarification when:

- a request changes architecture,
- the backend is required but not defined,
- API contracts are missing,
- the UI spec is insufficient,
- a security-sensitive flow is ambiguous,
- the requested change conflicts with the documented stack.

## Output style

Prefer concise, structured output.

Use:
- bullets for decisions, risks, and next steps,
- tables for comparisons,
- short sections with clear headings.

Avoid speculative implementation until the relevant stage has been completed.
Notes
This file is deliberately compatible with Claude Code’s subagent approach, where the main conversation stays clean and specialized agents handle scoped tasks �. It also reinforces that Vite’s build output is the deployable artifact, which is essential for a frontend stack like this �.
Next, the best file to draft is .claude/commands/spec.md, so the workflow has a concrete entry point.


####

Draft the .claude/commands/spec.md file for initial project planning

Below is a strong first-pass `/.claude/commands/spec.md` for your React + Vite template. It is designed to kick off planning cleanly, produce a durable product spec artifact, and hand off structured outputs to the next stage [1][2][3].

```md
# .claude/commands/spec.md

Generate or refine the product specification for this repository.

## Purpose

Turn the user's initial idea into a clear, implementation-ready product spec for a React + Vite application.

This command is the first step in the workflow and must produce the canonical spec document at:

- `docs/product/spec.md`

## When to use

Use this command when:
- starting a new project,
- clarifying a vague app idea,
- defining MVP scope,
- turning a concept into buildable requirements,
- preparing for architecture and UI design.

## Procedure

1. Read `CLAUDE.md` and `AGENTS.md`.
2. Gather the user's goals, target users, and constraints.
3. Identify the product type, core workflows, and business model.
4. Define the MVP scope and what is explicitly out of scope.
5. Capture assumptions and unresolved questions.
6. Write a concise, implementation-ready product spec.
7. Save the result to `docs/product/spec.md`.

## Required questions to resolve

If the user has not already answered them, ask only the minimum necessary questions from this set:

- What is the product?
- Who is it for?
- What is the primary user job to be done?
- What is the MVP?
- What are the top 3 must-have features?
- What is out of scope for v1?
- Is this consumer, internal, or SaaS software?
- Is there a preferred stack, API, or hosting target?
- Are there security, compliance, or privacy constraints?
- What is the success criterion for v1?

## Output requirements

Produce a spec with these sections:

### 1. Product summary
A short description of what the app does and why it exists.

### 2. Target users
List the primary user segments and their goals.

### 3. Core user journeys
Describe the main flows from entry to completion.

### 4. Functional requirements
List the required app capabilities.

### 5. Non-functional requirements
List quality expectations such as performance, accessibility, reliability, and maintainability.

### 6. MVP scope
Define exactly what will be built in v1.

### 7. Out of scope
Define what will not be built in v1.

### 8. Assumptions
List any assumptions made because information was missing.

### 9. Open questions
List unresolved decisions that need user input later.

### 10. Acceptance criteria
Write concrete conditions that must be true for the product to be considered ready for the next stage.

## Writing rules

- Be concise, specific, and implementation-aware.
- Avoid generic startup language.
- Avoid architecture details unless they affect scope.
- Prefer measurable statements over vague goals.
- If the user request is underspecified, state assumptions explicitly.
- Do not invent product requirements that were not implied or requested.
- Keep the spec suitable for direct handoff to architecture and design agents.

## Quality bar

The spec should be good enough that another agent can use it to produce:
- an architecture plan,
- a UI system,
- an implementation plan,
- a test plan.

## Handoff format

Return the result in this structure:

- Summary
- Product decisions
- MVP scope
- Out of scope
- Assumptions
- Open questions
- Acceptance criteria
- Next artifact

## Save behavior

If the environment allows file writes, write the final spec to:

- `docs/product/spec.md`

If the file already exists, update it carefully rather than replacing it blindly.

## Tone

Be direct, structured, and practical.
```

## Why this version is good

This command aligns with AGENTS.md as the repo-level guidance file and keeps the flow sequential, which is exactly what you want for a disciplined agent workflow [1][3][4]. It also fits Claude Code’s command model, where commands are structured prompts used to standardize repeated tasks [2][5].

## Recommended next file

The best next file is `docs/product/spec.md`, because this command’s output needs a place to land. After that, we should draft `.claude/commands/plan.md` so the architecture stage can begin immediately.



###

Here is a practical docs/product/spec.md template structure for the React + Vite stack. It is shaped for agent handoff: concise enough for planning, but detailed enough for architecture and UI generation �.
# Product Spec

## 1. Product summary

### 1.1 Problem statement
Describe the user problem in one or two paragraphs.

### 1.2 Product concept
Describe the app, the value it provides, and the intended outcome.

### 1.3 Success criteria
List the measurable signs that v1 is successful.

## 2. Target users

### 2.1 Primary user segments
- Segment name
- Goal
- Pain points
- Why this product matters to them

### 2.2 Secondary user segments
- Segment name
- Goal
- Pain points
- Why this product matters to them

## 3. Core user journeys

### 3.1 Journey 1: [name]
- Entry point
- Main steps
- Success state
- Failure/edge cases

### 3.2 Journey 2: [name]
- Entry point
- Main steps
- Success state
- Failure/edge cases

### 3.3 Journey 3: [name]
- Entry point
- Main steps
- Success state
- Failure/edge cases

## 4. Functional requirements

### 4.1 Must-have features
- Feature
- Description
- Priority
- Notes

### 4.2 Nice-to-have features
- Feature
- Description
- Priority
- Notes

### 4.3 Explicit non-features
- Feature or capability
- Reason it is not included in v1

## 5. Non-functional requirements

### 5.1 Performance
- Response time expectations
- Page load expectations
- Bundle or asset constraints

### 5.2 Accessibility
- Keyboard support
- Semantic markup
- Screen reader expectations
- Contrast and focus rules

### 5.3 Reliability
- Error handling expectations
- Retry behavior
- Offline or degraded-mode expectations

### 5.4 Maintainability
- Code organization expectations
- Reusability expectations
- Testing expectations

## 6. MVP scope

### 6.1 Included in v1
- Scope item
- Scope item
- Scope item

### 6.2 Not included in v1
- Scope item
- Scope item
- Scope item

## 7. Assumptions

- Assumption
- Assumption
- Assumption

## 8. Constraints

- Technical constraints
- Product constraints
- Security/privacy constraints
- Delivery constraints

## 9. Open questions

| Question | Why it matters | Owner | Status |
|---|---|---|---|
| Question | Reason | Owner | Open |

## 10. Acceptance criteria

- Criterion
- Criterion
- Criterion
- Criterion

## 11. Risks

- Risk
- Impact
- Mitigation

## 12. Revision history

| Date | Change | Author |
|---|---|---|
| YYYY-MM-DD | Initial draft | Claude Code |
Recommended use
Keep this file focused on what the product is and why it exists, not implementation details. That keeps it suitable as the upstream source for architecture, UI design, and testing plans �.
Practical additions for this stack
For a React + Vite project, I recommend adding these optional subsections if the app is even slightly SaaS-like:
Authentication needs.
Data persistence needs.
File upload or storage needs.
Integrations.
Deployment target.
Admin or internal tooling requirements.
Those items often change the architecture plan, so it is useful to surface them early even at the spec stage �.
The next best step is to convert this template into a real starter docs/product/spec.md populated with placeholders and guidance text, so the command can generate or update it consistently.


###

