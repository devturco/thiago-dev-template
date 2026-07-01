---
name: openspec-explore
description: Investigate a topic, area, or question BEFORE proposing a change. Read codebase, identify affected specs, propose approach. Use when user says "/explore <topic>", "investiga X", "antes de propor, estuda Y".
---

# OpenSpec Explore

Investigate a topic BEFORE proposing a change. Read the codebase, identify affected specs, surface constraints, propose approach — but **don't write the spec yet**.

## When to use

- User says "explore X", "investiga X", "estuda Y antes de propor"
- Wants to understand impact of a potential change
- Wants to know which specs would be affected

## Steps

1. **Understand the topic** — if unclear, ask user via natural language (one question at a time)
2. **Scan the codebase**:
   - Read `CLAUDE.md` and `AGENTS.md` for stack/conventions
   - Use file search to find related files (skip node_modules, .git, dist)
   - Read existing `openspec/specs/*` to identify which capability areas are affected
   - Check git history: `git log --oneline -20`
3. **Read affected specs**:
   ```bash
   ls openspec/specs/<capability>/
   ```
   Read each `spec.md` to understand current behavior.
4. **Identify gaps and constraints**:
   - Current behavior vs desired
   - Missing requirements, broken patterns
   - Minimal change to address the topic
5. **Map affected files**:
   - `src/server/db/schema.ts` (DB change)
   - `src/server/trpc/routers/<domain>.ts` (API change)
   - `src/routes/...` (UI change)
   - `src/lib/auth*.ts` (auth change)
   - `migrations/` (schema change)
6. **Propose approach** in a brief markdown report:
   - **What**: 1-2 sentence summary
   - **Why**: problem it solves
   - **Affected specs**: list of `openspec/specs/<capability>` to update
   - **Affected files**: concrete paths
   - **Open questions**: clarifications needed before proposing
   - **Estimated complexity**: small / medium / large

## Output

End with: "Run `/opsx:propose <name>` to start the formal spec when ready." (or instruct user to call the appropriate prompt).