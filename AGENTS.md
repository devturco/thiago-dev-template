# AGENTS.md

> Read this file FIRST before doing anything in this project. This file is read
> automatically by Claude Code, Aider, Continue, Cursor (via @-mention), and any
> other agent that follows the AGENTS.md convention. Tool-specific files (CLAUDE.md,
> .github/copilot-instructions.md) may override or extend this content.

## Project

Replace `[App Name]` below with the actual project name when forking this template.

- **Name:** [App Name]
- **Owner:** github.com/devturco
- **Template:** https://github.com/devturco/thiago-dev-template

## Stack (do not deviate without explicit user approval)

| Layer | Tech |
|---|---|
| Frontend | React 19 + TanStack Router (file-based) |
| Backend | Hono |
| API | tRPC v11 |
| ORM | Drizzle |
| DB | PostgreSQL self-managed (Docker local, Railway prod). NEVER Neon, NEVER Supabase. |
| Auth | Better-Auth |
| Runtime / pkg manager | Bun |
| Monorepo | Turborepo |
| Lint / format | Ultracite (Biome-based) — `bun check:fix` |
| Observability | evlog |
| Validation | Zod 4 (always `import { z } from 'zod/v4'`) |
| Tests | vitest via `bun test` |
| Deploy | Railway |

## Workflow (mandatory for any non-trivial change)

```
1. Brainstorm        → ask clarifying questions if scope is unclear
2. Explore codebase  → openspec-explore (identify affected files, specs)
3. Write spec        → openspec-propose (proposal.md + design.md + tasks.md)
4. User reviews spec → HARD GATE: do not implement until approved
5. Implement         → openspec-apply (executes tasks.md step by step)
   OR (for 2+ independent features) → see "Parallel work" below
6. Code review       → requesting-code-review between tasks
7. Finish            → finishing-a-development-branch: typecheck + check + test, then `git push -u && gh pr create --fill`
8. Archive           → openspec-archive (after deploy)
```

**Always read** `openspec/changes/<name>/proposal.md` before starting work on a feature.

**Definition of Done** for any feature:
- `bun typecheck` passes
- `bun check` passes
- `bun test` passes
- All tasks in `tasks.md` are committed (conventional commits: feat:/fix:/chore:)
- One PR per feature, branched from `main`

## Parallel work (only when 2+ features are independent)

When you have 2 or more features to ship and they don't share files:

1. **Independence audit** (HARD GATE): confirm no shared schema/files/ports
2. Create N git worktrees, one per feature: `git worktree add .worktrees/<repo>-<feat> -b feat/<feat>`
3. Dispatch N subagents in parallel (cap at 3 concurrent)
4. Each subagent gets: scope + forbidden-files list + DoD
5. User reviews all specs before any implementation
6. Each worktree ships as its own PR

See `openspec/changes/<name>/design.md` for the full parallel-workflow pattern. Do NOT parallelize features that touch the same files — serialize those instead.

## Conventions

- **Conventional commits:** `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`
- **One PR per feature** (never bundle unrelated features into one PR)
- **Layered commits during implementation:** 3-5 commits per feature, not 1 giant commit, not 20 tiny commits
- **NEVER include "Claude" or any AI assistant as co-author**
- **NEVER push without explicit user approval** (except via `finishing-a-development-branch`'s default Option 2)
- **NEVER edit generated files** (routeTree.gen.ts, drizzle/_journal.json without explicit task)
- **NEVER use `process.env` in route loaders** — loaders run on client too; use `createServerFn`

## File organization

```
src/
├── routes/                  # TanStack Router file-based routes
│   ├── __root.tsx
│   ├── _authed.tsx          # auth layout guard
│   └── api/
│       ├── auth/$.ts        # better-auth catch-all
│       └── trpc/$.ts        # tRPC catch-all
├── server/
│   ├── trpc/
│   │   ├── init.ts          # initTRPC + base procedures
│   │   ├── router.ts        # root router (merges sub-routers)
│   │   └── routers/         # one file per domain
│   ├── auth.ts              # betterAuth() instance
│   └── db/
│       ├── schema.ts        # Drizzle schema (single source of truth)
│       └── migrations/
├── lib/
│   ├── auth-client.ts
│   ├── validators/          # shared Zod 4 schemas
│   └── utils.ts
├── components/
│   ├── ui/                  # primitive components
│   └── [feature]/           # feature-specific components
└── hooks/                   # custom React hooks
```

## Commands

```bash
bun dev              # dev server
bun build            # production build
bun check            # Ultracite/Biome (lint + format)
bun check:fix        # auto-fix
bun typecheck        # tsc --noEmit
bun test             # vitest
bun db:generate      # generate Drizzle migration from schema
bun db:migrate       # apply migrations
bun db:studio        # Drizzle Studio (DB inspector)
```

## Anti-patterns (do NOT)

- Don't use `useEffect` for data fetching — use TanStack Query/tRPC
- Don't use `useState` for server state — use TanStack Query
- Don't use bare `zod` import — always `zod/v4`
- Don't use `.merge()` on Zod schemas — use `.extend()` (v4 change)
- Don't use `.format()` or `.flatten()` on ZodError — use `z.treeifyError()`
- Don't access `process.env` in route loaders — use `createServerFn`
- Don't put business logic in components — extract to server procedures
- Don't create barrel files (`index.ts` re-exports) — import directly
- Don't manually construct query keys — use tRPC's built-in key management
- Don't put `tanstackStartCookies()` anywhere but LAST in the better-auth plugins array
- Don't bypass Biome with `// biome-ignore` without a comment explaining why
- Don't ship 2+ features in one PR — one PR per feature, always
- Don't parallelize features that touch the same files — serialize instead

## When the user asks for a new feature

1. If the request is vague → ask 2-3 clarifying questions (use brainstorming skill)
2. If the request is clear → read openspec/changes/ to find related specs
3. Create a new openspec change: `openspec/changes/<kebab-name>/`
4. Write proposal.md + design.md + tasks.md using the OpenSpec CLI:
   ```bash
   openspec new change <name>
   ```
5. Wait for user approval before implementing
6. Implement with `openspec-apply` skill
7. Ship via `finishing-a-development-branch`

## Communication style with user

- User communicates in **PT-BR**, technical, direct, no fluff
- Reply in **PT-BR** unless the user writes in English
- When user says "escreve o comando", give the exact command on its own line
- Don't translate technical terms (gateway, bot, skill, worktree, etc.)
- Validate output and call out wrong commands
- Don't make up paths or fabricate tool output — verify with real tool calls