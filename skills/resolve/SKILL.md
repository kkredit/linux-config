---
name: resolve
description: >-
  Finish an in-progress git operation that stopped on merge conflicts: a
  Graphite (gt) restack, a plain git rebase, or a merge. Detects which one is
  underway, resolves the conflicts (asking when the right resolution is
  unclear), and runs the correct continue command until the operation
  completes. Use when the user says /resolve, "finish this rebase", "continue
  the restack", "fix these merge conflicts", or similar.
---

# resolve

Finish whatever conflicted git operation is currently in progress. Detect what
it is, resolve the conflicts, and drive the operation to completion.

## 1. Detect the operation (in this order)

Check from the repo root (`git rev-parse --git-dir` gives the git dir path —
use it instead of a literal `.git/` in worktrees):

1. **gt restack** — a git rebase is in progress (`rebase-merge/` or
   `rebase-apply/` exists in the git dir) **and** Graphite left continuation
   state: look for a graphite continue file in the git dir
   (`ls <git-dir> | grep -i graphite`, e.g. `.graphite_continue`). If unsure
   whether gt started the rebase (repo uses gt but no marker found), ask via
   `AskUserQuestion`: "Did this rebase come from a gt command (restack/sync/
   modify)?" — finishing a gt-initiated rebase with plain `git rebase
   --continue` breaks gt's metadata.
2. **plain rebase** — `rebase-merge/` or `rebase-apply/` exists, no graphite
   state.
3. **merge** — `MERGE_HEAD` exists.

If none of these: report that nothing is in progress (show `git status`) and
stop. If the working tree has conflict markers but no operation state, say so —
there's nothing to "continue".

## 2. Resolve the conflicts

- List them: `git diff --name-only --diff-filter=U`.
- For context on what's being applied: `git status` (shows the stopped commit
  during rebase), `git log --merge --oneline -- <file>` for the commits that
  touched each side.
- **Rebase side-swap caveat**: during a rebase, `ours` is the branch being
  rebased *onto* (upstream) and `theirs` is your commit being replayed — the
  opposite of a merge. Double-check before taking a side wholesale.
- For each conflicted file, read the conflict hunks and resolve:
  - **Obvious** (one side is a superset, pure formatting/imports, identical
    intent): just resolve it and note what you did.
  - **Unclear** (both sides made real, competing changes): ask via
    `AskUserQuestion` with short options — "Keep ours (<summary>)", "Keep
    theirs (<summary>)", "Combine both (recommended)" when a sensible merge
    exists — and show the relevant hunk in the question context.
- Stage resolved files with `git add`. Don't touch files outside the conflict
  set; never `--skip` or `--abort` without the user explicitly choosing that.

## 3. Finish the operation

Continue with the command matching the detected operation:

- **gt restack**: `gt continue` (after staging). Never use
  `git rebase --continue` for a gt-managed rebase.
- **plain rebase**: `GIT_EDITOR=true git rebase --continue` (env var skips the
  message editor).
- **merge**: `git commit --no-edit` (or `GIT_EDITOR=true git merge --continue`).

Rebases and restacks can stop again on the next commit — **loop**: when the
continue command halts on new conflicts, go back to step 2. Repeat until the
operation exits cleanly.

## 4. Verify and report

- `git status` should show a clean (or pre-existing-only) state with no
  operation in progress.
- After a gt restack, also run `gt ls` and confirm no branch still shows
  "needs restack".
- Report tersely: which operation was finished, how many conflict rounds, and
  per-file how each conflict was resolved (ours / theirs / combined).
