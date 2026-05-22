# WebForge Agent System
### Elite React+Vite Business App Production Pipeline

> A complete AI agent system built on OpenCode that transforms a user description of a business productivity tool into a fully scaffolded, production-ready React+Vite web application — spec to deployment config.

---

## 🎯 What This Is

WebForge is an **OpenCode agent system** — a structured set of AI agents, context files, and slash commands that work together as a senior engineering team.

You describe a business tool. WebForge produces the complete codebase.

### What Gets Built

Every WebForge run produces:
- **Master Spec** (`docs/MASTER-SPEC.md`) — full product specification
- **React+Vite project** — complete typed TypeScript source
- **All feature modules** — types, API, hooks, Zustand store, Zod schemas
- **Deployment config** — Vercel or Cloudflare Pages, GitHub Actions CI/CD
- **QA Report** (`docs/QA-REPORT.md`) — validation before delivery

---

## 🏗️ System Architecture

```
.opencode/
├── agent/                    # Specialist agents
│   ├── architect-agent.md    # Master orchestrator (primary)
│   ├── spec-agent.md         # Spec writer
│   ├── ui-agent.md           # React UI scaffolder
│   ├── coder-agent.md        # Business logic implementer
│   ├── deploy-agent.md       # Deployment configurator
│   └── qa-agent.md           # Quality auditor
│
├── command/                  # Slash commands (entry points)
│   ├── new-app.md            # 🚀 Full pipeline (main command)
│   ├── spec.md               # Spec only
│   ├── scaffold-ui.md        # UI scaffold only
│   ├── implement-feature.md  # Feature logic only
│   ├── add-feature.md        # Add feature to existing project
│   ├── deploy-setup.md       # Deployment config only
│   ├── qa-check.md           # QA audit only
│   └── research.md           # Research mode
│
└── context/                  # Domain knowledge injected into agents
    ├── core/
    │   └── essential-patterns.md    # Universal quality standards
    ├── stack/
    │   └── react-vite-standards.md  # React+Vite+TypeScript rules
    ├── design/
    │   └── ui-design-system.md      # shadcn/ui + Tailwind patterns
    ├── api/
    │   └── api-patterns.md          # TanStack Query + API layer
    └── deploy/
        └── deployment-standards.md  # Vercel + Cloudflare + CI/CD
```

---

## 🚀 Quick Start

### Prerequisites
- [OpenCode](https://opencode.ai) installed
- A Brave Search API key (for research capabilities)

### Setup
```bash
# 1. Clone / copy this system
git clone [this-repo] my-project-name
cd my-project-name

# 2. Add your Brave Search API key
# Edit opencode.json → replace "YOUR_BRAVE_API_KEY_HERE"

# 3. Start OpenCode
opencode
```

### Run the Full Pipeline
```
/new-app "A CRM for freelancers to track clients, projects, invoices, and follow-ups. Users log in, manage their client list, create projects per client, track invoice status, and get reminders for follow-ups. Deploy on Vercel."
```

That's it. WebForge runs the complete pipeline.

---

## 📋 Slash Commands Reference

### `/new-app [description]`
**The main command.** Runs the full pipeline end-to-end.

```
/new-app "An expense tracking tool for small businesses. Track expenses by category and project, upload receipts, generate monthly reports. Team members submit expenses, managers approve them."
```

**Pipeline:** Spec → UI Scaffold → Feature Logic → Deploy Config → QA

---

### `/spec [description]`
Generate just the master specification without writing code.

```
/spec "A booking system for yoga studios — classes, instructors, student management"
```

**Output:** `docs/MASTER-SPEC.md`

---

### `/scaffold-ui [optional focus]`
Scaffold all React components from an existing `docs/MASTER-SPEC.md`.

```
/scaffold-ui
/scaffold-ui "focus on the task board feature"
```

**Output:** All pages, layouts, and components in `src/`

---

### `/implement-feature [feature name or "all"]`
Implement business logic for a feature (or all features).

```
/implement-feature "projects"
/implement-feature "all features"
```

**Output:** types.ts, api.ts, hooks.ts, store.ts, schemas.ts per feature

---

### `/add-feature [description]`
Add a new feature to an existing project.

```
/add-feature "notifications feature — in-app notifications when tasks are assigned or updated"
```

**Output:** Spec updated + new feature fully implemented

---

### `/deploy-setup [platform]`
Generate deployment configuration.

```
/deploy-setup "Vercel"
/deploy-setup "Cloudflare Pages"
```

**Output:** Platform config, GitHub Actions, .env.example, README

---

### `/qa-check [optional focus]`
Run QA audit on the project.

```
/qa-check
/qa-check "focus on TypeScript errors"
```

**Output:** `docs/QA-REPORT.md`

---

### `/research [topic]`
Research a technical decision for the project.

```
/research "best auth solution for React — Supabase vs Clerk vs Auth0"
/research "React drag-and-drop libraries for kanban board"
```

**Output:** `docs/research/[topic].md` with comparison + recommendation

---

## 🤖 Agent Roles

| Agent | Role | Mode |
|-------|------|------|
| **Architect** | Master orchestrator — reads spec, delegates to all others | Primary |
| **Spec** | Transforms descriptions into structured MASTER-SPEC.md | Subagent |
| **UI** | Scaffolds all React components, pages, layouts | Subagent |
| **Coder** | Implements types, API, hooks, stores, schemas | Subagent |
| **Deploy** | Generates all deployment and CI/CD config | Subagent |
| **QA** | Audits all outputs against production standards | Subagent |

---

## 🧠 Context System

Context files are the knowledge base injected into agents. They are NOT prompts — they are structured domain knowledge.

| Context File | Content | Used By |
|-------------|---------|---------|
| `core/essential-patterns.md` | Universal code quality standards | All agents |
| `stack/react-vite-standards.md` | React+Vite+TypeScript conventions | UI, Coder |
| `design/ui-design-system.md` | shadcn/ui, Tailwind, layout patterns | UI Agent |
| `api/api-patterns.md` | TanStack Query, Zustand, API layer | Coder Agent |
| `deploy/deployment-standards.md` | Vercel, Cloudflare, GitHub Actions | Deploy Agent |

### Customizing Context
Edit these files to adapt the system to your preferences:
- Change the default backend (Supabase → custom API → Firebase)
- Adjust design tokens to your brand
- Add company-specific coding standards
- Add project-specific patterns

---

## 📦 Output Structure

After running `/new-app`, your project will have:

```
your-project/
├── .opencode/              # WebForge agent system (this repo)
├── docs/
│   ├── MASTER-SPEC.md      # Complete product specification
│   ├── QA-REPORT.md        # QA validation report
│   └── research/           # Research documents
├── src/                    # Generated React+Vite source
│   ├── app/
│   ├── features/
│   ├── components/
│   ├── lib/
│   └── types/
├── .github/
│   └── workflows/
│       └── ci.yml
├── public/
│   └── _redirects          # (Cloudflare) or vercel.json
├── .env.example
├── .gitignore
├── vite.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── package.json
└── README.md
```

---

## ⚙️ Configuration

### opencode.json
Configure MCP tools and agent settings:
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "brave-search": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-brave-search"],
      "enabled": true,
      "environment": {
        "BRAVE_API_KEY": "YOUR_KEY_HERE"
      }
    }
  }
}
```

---

## 🧩 Extending the System

### Add a New Agent
1. Create `.opencode/agent/my-agent.md`
2. Define frontmatter (mode, model, tools, mcp)
3. Write the agent's role, context loading, and process
4. Reference it in a new command or from the architect

### Add a New Command
1. Create `.opencode/command/my-command.md`
2. Specify the `agent:` to use
3. Load relevant `@context` files
4. Write the task instructions with `$ARGUMENTS`

### Add New Context
1. Create `.opencode/context/[domain]/[topic].md`
2. Write structured knowledge (patterns, examples, rules)
3. Reference it in agents that need it (`@.opencode/context/...`)

---

## 📚 Example Projects to Build

Try these descriptions with `/new-app`:

**Freelancer CRM:**
```
/new-app "CRM for freelancers — clients, projects, invoices, time tracking. Invoice status: draft/sent/paid. Deploy Vercel."
```

**Team Expense Tracker:**
```
/new-app "Expense management for small teams. Submit expenses with receipt upload, approve/reject workflow, monthly budget reports by category. Vercel."
```

**Content Calendar:**
```
/new-app "Content calendar for marketing teams. Plan blog posts and social media, assign to writers, track drafts through review/publish workflow. Cloudflare Pages."
```

**OKR Tracker:**
```
/new-app "OKR tracking tool. Companies set quarterly objectives, teams set key results, weekly check-ins with progress percentage. Admin dashboard with company-wide view. Vercel."
```

---

## 🔧 Troubleshooting

### Agent not finding context files
Ensure you run OpenCode from the root of this repo (where `opencode.json` is).

### Brave Search not working
Check your `BRAVE_API_KEY` in `opencode.json`. Get a free key at https://api.search.brave.com/

### TypeScript errors in output
Run `/qa-check` to get a detailed error report, then ask the Coder Agent to fix specific files.

---

## 📜 System Principles

1. **Context Before Execution** — agents load structured knowledge before acting
2. **Spec as Single Source of Truth** — every agent reads `docs/MASTER-SPEC.md`
3. **TypeScript Strict Always** — no exceptions, zero `any`
4. **Production-First** — every output is deployable, not prototype
5. **shadcn/ui Native** — all UI via shadcn primitives, no raw HTML
6. **TanStack Query for Server State** — no `useEffect` for data fetching

---

*WebForge — Built on the OpenCode agent framework, inspired by the personal-agent-systems pattern by Darren Hinde.*
