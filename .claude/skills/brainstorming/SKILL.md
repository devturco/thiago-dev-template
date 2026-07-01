---
name: brainstorming
description: Use before any creative work — creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation.
---

# Brainstorming

Help turn ideas into fully formed designs through natural collaborative dialogue. Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

## Hard Gate

**Do NOT write code, scaffold a project, or take any implementation action until you have presented a design and the user has approved it.** Applies to EVERY project regardless of perceived simplicity.

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Process

1. **Understand current project state** — read `CLAUDE.md`, `AGENTS.md`, scan existing code structure
2. **Ask one question at a time** to refine the idea (scope, edge cases, data model, UX, etc.)
3. **Present a design** — short markdown covering: what, why, affected files, acceptance criteria
4. **Get explicit approval** — wait for "approved" / "ok" / "pode ir" / "go" before any implementation
5. **After approval, hand off** to `openspec-propose` skill (or directly to implementation for tiny changes)

## When NOT to use

- Pure bug fixes with obvious root cause → skip directly to fix
- User gave a complete spec already → skip to `openspec-apply` or direct implementation
- Trivial config changes → no brainstorm needed