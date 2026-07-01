# Project: [App Name]

> **Note:** `[App Name]` is a placeholder. Replace it with the actual project name after forking this template.
>
> A fullstack TypeScript application built with **TanStack Router** (NOT TanStack Start), **tRPC v11**, **Better-Auth**, **Drizzle ORM**, and **Ultracite** (Biome-based linter/formatter).
>
> **Multi-tool note:** This `CLAUDE.md` is read by Claude Code only. For other agents (Aider, Continue, Cursor, Codex), see `AGENTS.md` in the repo root. For GitHub Copilot specifically, see `.github/copilot-instructions.md`.

## Tech Stack

| Layer | Technology | Docs |
|-------|-----------|------|
| Framework | TanStack Start (Vite, Nitro) | tanstack.com/start |
| Routing | TanStack Router (file-based) | tanstack.com/router |
| Data Fetching | TanStack Query + tRPC | tanstack.com/query, trpc.io |
| Forms | TanStack Form + Zod 4 | tanstack.com/form |
| Auth | better-auth | better-auth.com |
| Database | Drizzle ORM + PostgreSQL | orm.drizzle.team |
| Validation | Zod 4 | zod.dev |
| Linting/Formatting | Biome | biomejs.dev |
| Package Manager | bun | bun.sh |

## Commands

```bash
bun dev              # Start dev server (vinxi dev)
bun build            # Production build (vinxi build)
bun start            # Start production server
bun check            # Biome check (lint + format)
bun check:fix        # Biome auto-fix
bun db:generate      # Generate Drizzle migrations
bun db:migrate       # Run migrations
bun db:studio        # Open Drizzle Studio
bun db:auth          # Generate better-auth schema (run after adding auth plugins)
bun test             # Run tests with vitest
bun typecheck        # TypeScript type checking
```

## Workflow

### Layered commits during plan implementation

When executing a multi-step plan autonomously, commit work in logical chunks as each meaningful unit completes — don't accumulate everything for one giant commit at the end.

- After each logical group of related tasks passes typecheck + biome, make a focused commit before moving on.
- Use conventional prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`.
- Target ~3–5 commits per multi-task feature. Not 1 (review-hostile), not 20 (noise).
- Don't push to remote until the user asks. Local commits are cheap and bisect-friendly.
- Don't include Claude as a co-author.

The reason: reviewable history. Each commit should represent a coherent unit (e.g., "schema + flag + prompt", "filter logic", "render-side wiring") so the user can scan, bisect, or revert any single layer without losing the rest.

## Project Structure

```
src/
├── routes/                  # TanStack file-based routes
│   ├── __root.tsx           # Root layout (html/head/body shell, providers)
│   ├── index.tsx            # Home page /
│   ├── _authed.tsx          # Auth layout guard (protects child routes)
│   ├── _authed/             # Routes requiring auth
│   │   └── dashboard.tsx
│   ├── _public.tsx          # Public layout
│   ├── _public/
│   │   ├── login.tsx
│   │   └── signup.tsx
│   └── api/
│       ├── auth/$.ts        # better-auth catch-all handler
│       └── trpc/$.ts        # tRPC catch-all handler
├── router.tsx               # Router config (getRouter function — NEW instance per request)
├── routeTree.gen.ts         # Auto-generated route tree — NEVER EDIT
├── server/
│   ├── trpc/
│   │   ├── router.ts        # Root tRPC router (merges sub-routers)
│   │   ├── init.ts          # initTRPC, context type, base procedures, middleware
│   │   ├── client.ts        # createTRPCContext, TRPCProvider, useTRPC hook
│   │   └── routers/         # Domain-specific routers
│   │       ├── user.ts
│   │       └── [domain].ts
│   ├── auth.ts              # better-auth server config (betterAuth instance)
│   ├── auth.server.ts       # Server functions: getSession, ensureSession
│   └── db/
│       ├── index.ts         # Drizzle client
│       ├── schema.ts        # Drizzle schema (single source of truth)
│       └── migrations/
├── lib/
│   ├── auth-client.ts       # better-auth React client (createAuthClient)
│   ├── validators/          # Shared Zod 4 schemas
│   │   └── [domain].ts
│   └── utils.ts
├── components/
│   ├── ui/                  # Primitive UI components
│   └── [feature]/           # Feature-specific components
├── hooks/                   # Custom React hooks
└── styles/
    └── app.css
```

## Coding Conventions

### General

- Use `function` declarations for components, named exports only (no default exports)
- Use `const` arrow functions for utilities, callbacks, and inline functions
- Prefer explicit return types on exported functions
- Use TypeScript strict mode — no `any`, no `as` casts unless provably safe
- Collocate code: keep related files close, don't create deep folder hierarchies
- Name files in kebab-case, types in PascalCase, functions in camelCase

### TanStack Start

- IMPORTANT: `getRouter()` in `src/router.tsx` MUST return a NEW router instance each call (SSR request isolation)
- IMPORTANT: In `vite.config.ts`, `viteReact()` MUST come AFTER `tanstackStart()` in the plugins array
- IMPORTANT: Route loaders run on BOTH client and server — use `createServerFn` for server-only operations (env vars, secrets, direct DB access)
- Use `createServerFn({ method: 'POST' })` for mutations, `createServerFn({ method: 'GET' })` for reads
- Server functions support `.inputValidator()` for Zod validation
- Use `createMiddleware({ type: 'function' })` for server function middleware
- `routeTree.gen.ts` is auto-generated — NEVER edit it manually
- Root layout (`__root.tsx`) uses `createRootRouteWithContext<{ queryClient: QueryClient }>()`

### TanStack Router

- Use file-based routing exclusively — never manually define the route tree
- Route files export: `Route` from `createFileRoute`
- File naming: `__root.tsx` (root), `$param.tsx` (dynamic), `_layout.tsx` (pathless layout), `(group)/` (organizational only)
- Validate search params with Zod schemas via `zodValidator` from `@tanstack/zod-adapter`
- IMPORTANT: Always use `fallback()` from `@tanstack/zod-adapter` for search params to handle invalid URL values
- Use `loader` for data prefetching, `beforeLoad` for auth guards and context augmentation
- Use `notFound()` from `@tanstack/react-router` for 404 handling in loaders
- Use `linkOptions()` for reusable type-safe navigation configs

```tsx
// Search params with validation
import { zodValidator, fallback } from '@tanstack/zod-adapter'
import { z } from 'zod/v4'

const searchSchema = z.object({
  page: fallback(z.number(), 1).default(1),
  filter: fallback(z.string(), '').default(''),
})

export const Route = createFileRoute('/posts')({
  validateSearch: zodValidator(searchSchema),
  component: PostsPage,
})

function PostsPage() {
  const { page, filter } = Route.useSearch()
}
```

### TanStack Query + tRPC (NEW integration)

- Use `@trpc/tanstack-react-query` — the new first-class integration
- Access tRPC via `useTRPC()` hook from `createTRPCContext`
- Use `trpc.procedure.queryOptions()` with standard `useQuery()` / `useSuspenseQuery()`
- Use `trpc.procedure.mutationOptions()` with standard `useMutation()`
- IMPORTANT: Only `useSuspenseQuery` and loader prefetches participate in SSR/streaming — plain `useQuery` does NOT
- Use `queryClient.ensureQueryData()` in loaders for blocking data
- Use `queryClient.prefetchQuery()` in loaders for non-blocking background data
- Use `setupRouterSsrQueryIntegration` in `router.tsx` for SSR dehydration/hydration

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useTRPC } from '@/server/trpc/client'

function UserProfile({ userId }: { userId: string }) {
  const trpc = useTRPC()
  const queryClient = useQueryClient()

  // Query
  const { data } = useQuery(trpc.user.getById.queryOptions({ id: userId }))

  // Mutation with invalidation
  const updateUser = useMutation({
    ...trpc.user.update.mutationOptions(),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: trpc.user.getById.queryKey({ id: userId }) })
    },
  })
}
```

### TanStack Form

- Use `useForm` with Zod schema validators
- IMPORTANT: Always call both `e.preventDefault()` AND `e.stopPropagation()` in form onSubmit
- Use `form.Field` with render props (`children`) for fields
- Use `form.Subscribe` for derived state (canSubmit, isSubmitting)

### tRPC Routers

- One router file per domain in `src/server/trpc/routers/`
- tRPC instance and base procedures in `src/server/trpc/init.ts`
- Root router merges sub-routers in `src/server/trpc/router.ts`
- Client setup with `createTRPCContext` in `src/server/trpc/client.ts`
- API catch-all handler at `src/routes/api/trpc/$.ts` using `fetchRequestHandler`
- Use `protectedProcedure` for authed endpoints, `publicProcedure` for public
- Always validate inputs with Zod 4 schemas
- Keep procedures thin — extract business logic into service functions
- Use `superjson` transformer for dates, Maps, Sets serialization
- Throw `TRPCError` with appropriate codes: UNAUTHORIZED, FORBIDDEN, NOT_FOUND, BAD_REQUEST

```tsx
// src/server/trpc/init.ts
import { initTRPC, TRPCError } from '@trpc/server'
import superjson from 'superjson'

const t = initTRPC.context<Context>().create({ transformer: superjson })

export const router = t.router
export const publicProcedure = t.procedure

const isAuthed = t.middleware(async ({ ctx, next }) => {
  if (!ctx.session) throw new TRPCError({ code: 'UNAUTHORIZED' })
  return next({ ctx: { session: ctx.session } })
})

export const protectedProcedure = publicProcedure.use(isAuthed)
```

### Zod 4

- Import from `zod/v4` — NEVER use bare `zod` import
- Prefer top-level validators: `z.email()`, `z.url()`, `z.uuid()` over `z.string().email()` (tree-shakable)
- Use `z.object()` for most schemas; `z.interface()` for key-level optionality
- Use `error` param for custom error messages — NOT `message`, `invalid_type_error`, or `errorMap`
- Use `z.treeifyError()` instead of `.format()` or `.flatten()` (deprecated in v4)
- Use `.extend()` instead of `.merge()` for combining schemas
- Use `z.strictObject()` instead of `.strict()`
- For recursive types use getter syntax instead of `z.lazy()`
- `z.record()` requires 2 args; use `z.partialRecord()` for optional keys
- Schema naming: `[Entity]Schema` for base, `Create[Entity]Schema`, `Update[Entity]Schema`

```tsx
// src/lib/validators/user.ts
import { z } from 'zod/v4'

export const UserSchema = z.object({
  id: z.uuid(),
  name: z.string().min(1).max(100),
  email: z.email(),
  role: z.enum(['user', 'admin']),
})

export const CreateUserSchema = UserSchema.omit({ id: true })
export const UpdateUserSchema = UserSchema.partial().extend({ id: z.uuid() })

export type User = z.output<typeof UserSchema>
```

### better-auth

- Server config in `src/server/auth.ts` — single `betterAuth()` instance
- Client in `src/lib/auth-client.ts` using `createAuthClient` from `better-auth/react`
- Server functions in `src/server/auth.server.ts` using `createServerFn` for `getSession`/`ensureSession`
- API handler at `src/routes/api/auth/$.ts` — catch-all mounting `auth.handler`
- IMPORTANT: `tanstackStartCookies()` plugin MUST be the LAST plugin in the array
- IMPORTANT: Always pass `getRequestHeaders()` to `auth.api.getSession()` in server functions
- Use client SDK (`signIn`, `signUp`, `signOut`) for auth actions — NOT server actions
- Use `useSession()` hook for auth state in components
- Protect routes via `beforeLoad` in `_authed.tsx` layout route, not per-page
- Use `inferAdditionalFields<Auth>()` in client for type-safe additional user fields
- Set `input: false` on sensitive `additionalFields` (role, permissions) to prevent user manipulation
- After adding plugins: `bun db:auth && bun db:generate && bun db:migrate`

```tsx
// Auth guard in layout route (_authed.tsx)
export const Route = createFileRoute('/_authed')({
  beforeLoad: async ({ location }) => {
    const session = await getSession()
    if (!session) {
      throw redirect({ to: '/login', search: { redirect: location.href } })
    }
    return { user: session.user, session: session.session }
  },
  component: () => <Outlet />,
})
```

### Drizzle ORM

- Define all schemas in `src/server/db/schema.ts`
- Use relational query builder (`db.query.*`) for reads
- Use `db.insert()`, `db.update()`, `db.delete()` for writes
- Always generate migrations with `bun db:generate` — never edit migrations manually
- Use `$inferSelect` and `$inferInsert` for type inference from schema
- Define relations for `experimental: { joins: true }` in better-auth (2-3x perf boost)

### Biome

- Biome handles formatting AND linting — no Prettier or ESLint needed
- Run `bun check:fix` before committing (auto-runs via hook on file edits)
- Import organization is automatic
- See `biome.json` for rules; overrides allow default exports in route files and config files
- Do NOT add eslint or prettier configs

### Components

- No default exports — use named exports only (exception: route files)
- Props interfaces: `[ComponentName]Props`
- Keep components under 150 lines — extract sub-components when growing
- Prefer composition over prop-drilling

## Anti-Patterns (Do NOT)

- Don't use `useEffect` for data fetching — use TanStack Query/tRPC
- Don't use `useState` for server state — use TanStack Query
- Don't use `React.FC` or `React.FunctionComponent`
- Don't use default exports (except route files and config files)
- Don't use `any` — use `unknown` and narrow
- Don't use bare `zod` import — always use `zod/v4`
- Don't use `.merge()` on Zod schemas — use `.extend()` (v4 change)
- Don't use `.format()` or `.flatten()` on ZodError — use `z.treeifyError()`
- Don't access `process.env` in route loaders directly — loaders run on the client too; use `createServerFn`
- Don't put business logic in components — extract to server procedures
- Don't create barrel files (`index.ts` re-exports) — import directly
- Don't manually construct query keys — use tRPC's built-in key management
- Don't use `useQuery` expecting SSR — only `useSuspenseQuery` and loader prefetches participate in SSR
- Don't call `auth.api.getSession()` without passing `getRequestHeaders()` — session will appear anonymous
- Don't put `tanstackStartCookies()` anywhere but LAST in the better-auth plugins array
- Don't bypass Biome with `// biome-ignore` without a comment explaining why

## Error Handling

- Use TanStack Router's `errorComponent` per-route for error boundaries
- Use `notFoundComponent` per-route for 404 handling
- Use `notFound()` in loaders to throw a 404
- tRPC errors use `TRPCError` with codes: UNAUTHORIZED, FORBIDDEN, NOT_FOUND, BAD_REQUEST, INTERNAL_SERVER_ERROR
- Client-side: let query errors propagate to nearest error boundary
- Log server errors — don't swallow them silently

## Testing

- Use vitest for unit and integration tests
- Test files next to source: `foo.test.ts` alongside `foo.ts`
- Test tRPC procedures directly using `createCallerFactory`
- Test components with @testing-library/react
- Mock tRPC at the procedure level, not at the network level

## Spec-Driven Workflow (OpenSpec)

This project uses **OpenSpec** for spec-driven development. Before implementing any non-trivial feature, create a spec.

### Workflow

```
1. Brainstorm        → ask clarifying questions if scope is unclear
2. Explore codebase  → /opsx:explore <topic>  (or read openspec/specs/ manually)
3. Write spec        → /opsx:propose <feature-name>
                       (creates openspec/changes/<name>/proposal.md + design.md + tasks.md)
4. User reviews      → HARD GATE: do NOT implement until user approves proposal.md
5. Implement         → /opsx:apply  (executes tasks.md step by step)
6. Code review       → between tasks / or before PR
7. Finish            → /opsx:apply finishes by typecheck + check + test
                       then git push -u origin HEAD && gh pr create --fill
8. Archive           → /opsx:archive  (after deploy; moves to openspec/changes/archive/)
```

### Read these files before any feature work

- `openspec/changes/<feature>/proposal.md` — what & why
- `openspec/changes/<feature>/design.md` — how
- `openspec/changes/<feature>/tasks.md` — step-by-step
- `openspec/config.yaml` — project context (stack, conventions, rules)

### Definition of Done for any feature

- All tasks in `tasks.md` are committed (3-5 commits per feature, conventional prefix)
- `bun typecheck` passes
- `bun check` (Ultracite/Biome) passes
- `bun test` passes
- PR opened with `gh pr create --fill`
- User has reviewed the PR diff before merge

## Parallel Features Workflow

When the user has **2 or more independent features** to ship and they don't share files, use the **parallel workflow** instead of the sequential one above.

### When to use

- 2+ features or fixes that are independent
- Each feature is large enough to warrant its own spec
- User has signaled they want parallelism ("paraleliza", "em paralelo", "várias ao mesmo tempo")

### When NOT to use

- Only 1 feature → use the sequential workflow above
- Features with hard dependency (B depends on A) → ship A first, then B
- Single fix / one-line change → overkill
- Refactor touching 1 shared file → can't parallelize, do sequential

### Hard gate: independence audit

Before creating worktrees, prove the features are independent. If any of these is true, do NOT parallelize:

- Both features need a migration in the same table (schema gate)
- Both features edit the same router file (file gate)
- Both features depend on each other to compile/test (compile gate)
- Both need to run a long-lived dev server on same port (port gate)

### Pattern

1. **Independence audit** (hard gate — refuse to parallelize if it fails)
2. **Create N worktrees:**
   ```bash
   mkdir -p .worktrees
   echo "/.worktrees/" >> .gitignore
   git worktree add .worktrees/<repo>-<feat> -b feat/<feat>
   ```
3. **Dispatch N openspec-propose in parallel** (one subagent per worktree, max 3 concurrent)
4. **User reviews all specs** before any implementation starts
5. **Dispatch N openspec-apply in parallel** (one subagent per worktree)
6. **Ship N PRs** — one per feature, branched from main

### Brief template per feature (paste into each subagent prompt)

```markdown
You are running in worktree `<abs-path>` on branch `feat/<name>`.

SCOPE (do only this):
- <1-3 bullets>

DO NOT TOUCH:
- Any file under `packages/<other-feature>/`
- Any file under `apps/<unrelated-area>/`
- The shared `packages/db/src/schema/<unrelated-table>.ts`

DELIVERABLES:
- openspec/changes/<name>/{proposal.md,design.md,tasks.md}
- openspec/changes/<name>/specs/<capability>/spec.md

DEFINITION OF DONE:
- Every requirement has acceptance scenarios
- Every task has a test/verify step
- Spec lists exact files to create/modify
- No mention of files outside SCOPE
```

### Anti-patterns

- Spawn N agents with the same prompt and hope → always give a brief
- Skip the independence audit because features "look different" → audit first, always
- Start implementation before user reviews specs → mandatory review gate
- Edit files outside scope to "help" another agent → stop and re-dispatch
- Merge multiple features into one mega-PR → one PR per feature, always
- No snapshot tests — they rot quickly
