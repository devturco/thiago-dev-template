---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks. Each task gets a fresh subagent + task review + broad final review.
---

# Subagent-Driven Development

Execute plan by dispatching a fresh subagent per task, task review (spec + quality) after each, broad final review at end.

**Why subagents:** Each gets isolated context. By precisely crafting instructions and context, you keep them focused. Your session context stays clean for coordination.

**Core principle:** Fresh subagent per task + task review + broad final review = high quality, fast iteration

**Continuous execution:** Do not pause between tasks. Execute all tasks without stopping. The only reasons to stop: BLOCKED, ambiguity, all tasks done.

## When to Use

- Have implementation plan with tasks
- Tasks mostly independent (don't share state)
- Stay in same session (no context switch)

## Pre-Dispatch Checklist (load BEFORE Task 1)

1. **Worktree exists or create one** — never run on main without explicit consent
   ```bash
   git worktree add .worktrees/<repo>-<feat> -b feat/<feat>
   cd .worktrees/<repo>-<feat>
   ```
2. **Pre-flight plan scan** — once across the plan, look for:
   - Tasks that contradict each other
   - Brief bugs (wrong commands, fabricated paths, duplicate DDL)
   - Plan-mandated patterns the reviewer will flag as defects
3. **Skill load order** — load `test-driven-development` (for implementers), `requesting-code-review` (for reviewers)
4. **Brief files pre-staged** — write `task-N-brief.md` from plan BEFORE dispatching

## The Process (per task)

```
1. Dispatch implementer subagent (Task tool, subagent_type=general-purpose)
2. Implementer subagent asks questions? → answer, then proceed
3. Implementer runs tests, commits, self-reviews
4. Dispatch task reviewer (subagent_type=general-purpose) with diff
5. Reviewer reports: spec ✅ AND quality approved?
   - No → dispatch fix subagent
   - Yes → mark task complete
6. Move to next task
```

After all tasks: dispatch final code reviewer on whole branch.

## Implementer Status Handling

**DONE:** Generate diff file, dispatch task reviewer
**DONE_WITH_CONCERNS:** Read concerns first, address if about correctness
**NEEDS_CONTEXT:** Provide missing info, re-dispatch
**BLOCKED:** Assess:
- Context problem → provide more, re-dispatch same model
- Needs more reasoning → re-dispatch with more capable model
- Task too large → break into smaller pieces
- Plan wrong → escalate to user

## Model Selection

Use least powerful model that can handle each role:
- Mechanical tasks (isolated functions, clear specs) → cheapest model
- Integration/judgment → standard model
- Architecture/final review → most capable model

**Always specify model explicitly when dispatching.** Omitting inherits your session's model.

## Brief Template (paste into each implementer prompt)

```markdown
You are implementing Task N of the plan in this worktree.

READ FIRST: .superpowers/sdd/task-N-brief.md (your requirements).

YOUR TASK:
<1-3 sentences>

INTERFACES YOU TOUCH:
- file A (function X)
- file B (function Y)

OUT OF SCOPE (don't touch):
- file C
- file D

DEFINITION OF DONE:
- All tests pass
- TypeScript compiles
- Code follows conventions in CLAUDE.md
- 1 commit with conventional prefix
- Report file written to .superpowers/sdd/task-N-report.md

Report back: status (DONE / DONE_WITH_CONCERNS / BLOCKED), commit SHA, test summary.
```

## Final Whole-Branch Review

After all tasks complete, dispatch ONE final reviewer on the full branch:
```bash
git merge-base main HEAD  # MERGE_BASE
git diff MERGE_BASE HEAD  # full branch diff
```

Pass to reviewer along with: spec, plan, all task reports.