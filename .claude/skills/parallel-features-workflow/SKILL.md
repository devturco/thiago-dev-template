---
name: parallel-features-workflow
description: Run 2+ independent features in parallel using git worktrees + 1 OpenSpec change per feature + multiple sessions/subagents. Use when user says "paraleliza X, Y, Z", "em paralelo", "várias features ao mesmo tempo", "multi-agent".
---

# Parallel Features Workflow

Run **multiple independent features** in parallel by isolating each one in its own git worktree, with its own OpenSpec change, and its own session/subagent. Eliminates file conflicts between agents and guarantees each feature ships behind a separate PR.

> **Why this skill exists.** The `subagent-driven-development` skill parallelizes *tasks within a single feature*. This skill parallelizes *features themselves*. They compose: a parallel feature dispatch can internally use `subagent-driven-development` per feature if that feature has 5+ tasks.

> **Trigger rule.** Only invoke when there are genuinely 2+ independent features/fixes. "I have one feature with 5 tasks" is NOT this skill — that's `subagent-driven-development`.

## When to Use

Activate when **all** of the following hold:
- User has 2+ independent features or fixes
- Features don't share runtime state, don't depend on each other's output, don't touch same files
- Each feature warrants its own spec (≥30 min of work, or ≥1 schema/UI change)
- User signaled parallelism ("paraleliza", "em paralelo", "várias ao mesmo tempo")

**Do NOT use when:**
- Only 1 feature → `add-feature` or `subagent-driven-development`
- Features with hard dependency → ship A first, then B
- Single fix / one-line change → overkill
- Refactor touching 1 shared file → can't parallelize
- User exploring scope ("should we do A or B?") → `brainstorming` first

## Hard Gate: Independence Audit

Before touching any worktree, **prove** the features are independent.

For each pair of features, ask:
- Both need a migration in the same table? (schema gate) → SEQUENTIAL
- Both edit the same router file? (file gate) → SEQUENTIAL
- Both depend on each other to compile/test? (compile gate) → SEQUENTIAL
- Both need a long-lived dev server on same port? (port gate) → SEQUENTIAL

**If any gate fails:** stop and tell user. Do NOT silently serialize — ask which feature to ship first.

## The Process

```
1. Independence audit (hard gate)
       ↓ (passed)
2. Create N worktrees (1 per feature)
       ↓
3. Open N sessions (one per worktree) — Claude Code / Copilot Agent / multiple subagents
       ↓
4. Each session writes proposal.md → user reviews all specs
       ↓
5. Each session implements its spec → reviews → PR
       ↓
6. N independent PRs merged to main
       ↓
7. Cleanup worktrees
```

### Step 1: Create Worktrees

Run from **main repo root**, NOT inside any existing worktree:

```bash
# Ensure .worktrees/ is ignored
ls -d .worktrees 2>/dev/null || mkdir .worktrees
git check-ignore -q .worktrees || {
  echo "/.worktrees/" >> .gitignore
  git add .gitignore && git commit -m "chore: isolate parallel worktrees dir"
}

# Create N worktrees, each with its own branch
for FEAT in auth billing notifications; do
  git worktree add ".worktrees/$(basename "$PWD")-$FEAT" -b "feat/$FEAT"
done

git worktree list
```

> **Pitfall: working tree dirty.** `git worktree add` refuses if main repo has uncommitted changes. Commit or stash first.
>
> **Pitfall: port collisions.** Multiple worktrees may try to run dev server on same port. Each worktree's `.env` should bind unique port (`PORT=3001`, etc.). Or only run dev server in one at a time.

### Step 2: Open N Sessions

For each worktree, open a separate session:
- **Claude Code:** `cd .worktrees/<repo>-<feat> && claude` in separate terminal
- **Copilot Agent:** Open VSCode → File → Open Folder → worktree path
- **Subagents (within Claude Code):** Task tool, one per worktree

Each session reads its worktree's `openspec/changes/<feat>/` and implements that feature.

### Step 3: User Review Gate (Mandatory)

Before any implementation starts, **user reviews every spec**:
1. Show user the proposal.md + design.md (NOT the full tasks.md)
2. Ask: approve / reject / modify
3. Rejected specs go back to Step 2 with feedback
4. Approved specs are locked

### Step 4: Ship as N Independent PRs

Each worktree ends in its own branch. Use `finishing-a-development-branch` once per worktree:

```bash
cd .worktrees/<repo>-auth
bun typecheck && bun check && bun test
git push -u origin feat/auth
gh pr create --fill --base main
# Repeat for feat/billing, feat/notifications
```

> **Critical:** do NOT merge all three branches into one PR. Independent features → independent PRs → independent deploys.

### Step 5: Cleanup

After all PRs merged:
```bash
cd <main-repo-root>
git worktree remove .worktrees/<repo>-auth
git worktree remove .worktrees/<repo>-billing
git worktree remove .worktrees/<repo>-notifications
git worktree prune
```

## Brief Template Per Feature (paste into each session)

```markdown
You are implementing feature "<name>" in worktree `<abs-path>` on branch `feat/<name>`.

SCOPE (do only this):
- <1-3 bullets>

DO NOT TOUCH:
- Any file under `packages/<other-feature>/`
- Any file under `apps/<unrelated-area>/`
- The shared `src/server/db/schema/<unrelated-table>.ts`

DELIVERABLES:
- openspec/changes/<name>/proposal.md
- openspec/changes/<name>/design.md
- openspec/changes/<name>/tasks.md
- openspec/changes/<name>/specs/<capability>/spec.md (if new capability)

DEFINITION OF DONE:
- Every requirement has acceptance scenarios
- Every task has a test/verify step
- Spec lists exact files to create/modify
- No mention of files outside SCOPE
```

## Anti-Patterns (from the failure mode this skill prevents)

| ❌ Don't | ✅ Do |
|---|---|
| Spawn N agents with same prompt and hope | One brief per agent, scope-bound |
| Skip independence audit because features "look different" | Run audit; schema/file/port/compile gates |
| Start implementation before user reviews specs | Mandatory review gate at Step 3 |
| Edit files outside scope to "help" another agent | Stop and re-dispatch |
| Merge multiple features into one mega-PR | One PR per feature, branched from main |
| Reuse a single dev server across worktrees | Distinct ports or sequential dev-server usage |

## Quick Reference

| Situation | Action |
|---|---|
| 2+ independent features | This skill — full pipeline |
| 1 feature with 5+ tasks | `subagent-driven-development` (not this) |
| 1 small feature | `add-feature` (not this) |
| Features with shared schema | Serialize the schema change first, then parallelize the rest |
| Features with same file in scope | Refactor shared part first, then parallelize