---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Review early, review often. Catch issues before they cascade.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse origin/main)
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer** (Claude Code Task tool / subagent):
- Subagent type: `code-reviewer` (already configured in `.claude/agents/code-reviewer.md`)
- Pass: `{DESCRIPTION}`, `{PLAN_OR_REQUIREMENTS}`, `{BASE_SHA}`, `{HEAD_SHA}`
- Provide: the diff between BASE_SHA and HEAD_SHA

**3. Reviewer fills two verdicts:**
- Spec compliance: does the implementation match what was requested?
- Code quality: is it well-built (test coverage, conventions, no anti-patterns)?

**4. Act on feedback:**
- **Critical** issues → fix immediately
- **Important** issues → fix before proceeding
- **Minor** issues → note for later
- **Disagreement** → push back with reasoning

## Self-Review Before Dispatching

Before requesting review, do your own pass:
1. Run `git diff BASE_SHA..HEAD_SHA --stat` — only expected files changed?
2. Run `bun typecheck && bun check && bun test` — all green?
3. Search for AI-generated anti-patterns:
   - Leftover console.log / debug prints
   - `// biome-ignore` without explanation
   - `as any` casts
   - Empty catch blocks
   - Dead code
4. Verify conventional commit messages
5. Confirm no secrets in diff (`git diff | grep -iE "password|secret|token|api_key"`)

Only after self-review passes, dispatch the reviewer.

## Tips

- Reviewer gets the diff, not your session history — keeps them focused
- If reviewer flags something as "minor" but you suspect real issue, escalate to important
- If reviewer is wrong, push back with file:line evidence