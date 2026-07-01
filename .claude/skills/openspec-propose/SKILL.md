---
name: openspec-propose
description: OpenSpec — propose a new change. Create proposal.md + design.md + tasks.md for a feature. Use when user says "/opsx:propose X", "spec X", "create a feature X".
---

# OpenSpec Propose

Propose a new change — create the OpenSpec artifacts in `openspec/changes/<name>/`.

## When to use

Trigger when user says:
- "propose X", "spec X", "create a feature X"
- "/opsx:propose <feature name or description>"
- Wants to start spec-driven development

> **Note on CLI:** If `openspec` CLI is available globally (`which openspec` or `npx openspec --version`), use it: `openspec new change <name>`. Otherwise, create the files manually following the structure below.

## Steps

1. **If no input provided, ask user** what they want to build (one question, open-ended)
2. **Derive a kebab-case name** (e.g. "add user authentication" → `add-user-auth`)
3. **Check OpenSpec installation**:
   ```bash
   openspec --version 2>&1 || npx openspec --version
   ```
4. **Create the change directory**:
   - With CLI: `openspec new change "<name>"` (creates scaffolded change at `openspec/changes/<name>/`)
   - Without CLI: `mkdir -p openspec/changes/<name>/specs/<capability>` manually
5. **Create artifacts in dependency order**:
   - `proposal.md` — what & why (1-2 paragraphs, problem statement, goals, non-goals)
   - `design.md` — how (architectural decisions, trade-offs, data model, affected files)
   - `tasks.md` — implementation steps (each task = 1 commit, with test/verify step)
   - `specs/<capability>/spec.md` — requirements with `## Acceptance` scenarios (if adding new capability)
6. **Get build status** (CLI):
   ```bash
   openspec status --change "<name>" --json
   ```
   Confirm `applyRequires` artifacts are all `done`.
7. **Show final status** and prompt user: "Run `/opsx:apply` to start implementing."

## Rules (from openspec/config.yaml)

- Proposals under 500 words
- Always include "Non-goals" section
- List affected files explicitly
- Every requirement has acceptance scenarios
- Tasks broken into max 2-hour chunks
- Each task has a test/verify step

## Hand off

After proposal.md is approved by user, switch to `openspec-apply` skill to implement.