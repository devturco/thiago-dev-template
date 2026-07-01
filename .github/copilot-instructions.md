# GitHub Copilot Instructions

> This file is read automatically by VSCode Copilot Agent mode. For multi-tool
> instructions (Claude Code, Aider, etc.), see AGENTS.md in the repo root.

## Stack

React 19 + TanStack Router + Hono + tRPC v11 + Drizzle + PostgreSQL self-managed
(Docker local, Railway prod) + Better-Auth + Bun + Turborepo + Ultracite + evlog.

**Never** swap stack components without explicit user approval. Never use Neon
or Supabase — PostgreSQL is self-managed (Docker locally, Railway in prod).

## Workflow for new features

When user asks to "create", "add", "implement" a feature:

1. **Read** `openspec/changes/<feature>/proposal.md` if it exists — that's the source of truth.
2. **If no spec exists:** suggest creating one via `/opsx:propose <feature>` before implementing.
3. **Implement** in a git worktree: `git worktree add .worktrees/<name> -b feat/<name>`
4. **Validate** before declaring done:
   ```bash
   bun typecheck && bun check && bun test
   ```
5. **Commit** with conventional prefix: `feat(<scope>): description`
6. **PR:** `git push -u origin feat/<name> && gh pr create --fill`

## Conventions

- Named exports only (exception: route files)
- Always validate inputs with Zod 4 (`zod/v4`)
- Use `protectedProcedure` for authenticated tRPC endpoints
- Use `useTRPC()` + `useQuery()`/`useMutation()` for data fetching
- Invalidate queries after mutations
- Components under 150 lines — extract sub-components
- Use `createServerFn` for server-only operations

## Parallel features

When user has 2+ independent features to ship:

- Confirm they're independent (no shared files, schema, ports)
- Create one git worktree per feature
- Run Copilot Agent sessions in parallel (each in its own worktree)
- Each session gets a brief with scope + forbidden-files list + DoD
- One PR per feature

## Anti-patterns

- Don't fetch data with `useEffect` — use TanStack Query/tRPC
- Don't use `useState` for server state — use TanStack Query
- Don't access `process.env` in route loaders — use `createServerFn`
- Don't put business logic in components
- Don't manually construct query keys — use tRPC's key management
- Don't ship 2+ features in one PR

## Style

- Reply in PT-BR when user writes in PT-BR
- Direct, technical, no fluff
- Commands on their own line when user asks for commands
- Don't fabricate tool output — verify with real tool calls