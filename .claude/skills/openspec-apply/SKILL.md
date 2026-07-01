---
name: openspec-apply
description: OpenSpec — implement a change. Read artifacts in openspec/changes/<name>/ and execute tasks.md step by step. Use when user says "/opsx:apply", "implementa isso", "executa o spec".
---

# OpenSpec Apply

Implement an OpenSpec change by reading the artifacts and executing `tasks.md` step by step.

## When to use

Trigger when user says:
- "/opsx:apply", "implementa isso", "executa o spec", "codifica a feature"
- Wants to implement a previously proposed change

## Steps

1. **Identify the change**:
   - If CLI: `openspec status --json`
   - If no CLI: `ls openspec/changes/` to find pending changes
   - If none, tell user: "No active change. Run `/opsx:propose <feature>` first."
2. **Validate the change is apply-ready**:
   - Check that `proposal.md`, `design.md`, `tasks.md` all exist
   - If any missing, point user to `openspec-propose` to finish
3. **Read all artifacts for context** (in order):
   - `openspec/changes/<name>/proposal.md` — what & why
   - `openspec/changes/<name>/design.md` — how
   - `openspec/changes/<name>/tasks.md` — implementation steps
   - `openspec/changes/<name>/specs/<capability>/spec.md` — requirements
4. **Execute tasks.md sequentially**:
   - Mark task as in-progress (use TodoWrite or task list)
   - Execute the task (write code, run migrations, add tests)
   - Verify the task (typecheck, lint, test if applicable)
   - Mark as done
   - Move to next
5. **Commit in logical chunks**:
   - After each meaningful group passes typecheck + biome, commit
   - Conventional prefixes: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`
   - Target 3-5 commits per feature (reviewable, bisect-friendly)
   - **DO NOT push to remote unless user asks**
   - **DO NOT add Claude/AI as co-author**
6. **Run quality gates**:
   ```bash
   bun typecheck
   bun check      # Ultracite/Biome
   bun test
   ```
   Fix any issues before declaring done.
7. **Show final status**:
   ```bash
   git log --oneline -10
   ```

## Hand off

After all tasks pass quality gates, switch to `finishing-a-development-branch` skill to ship the PR.