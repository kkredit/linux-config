---
name: babysit-stack
description: >-
  Iteratively shepherd a Graphite (gt) stack of PRs to "clean": fetch CI status
  and reviewer/AI-agent feedback for every PR in the stack, surface it as
  one-keystroke choices, apply fixes / reply to comments, resubmit with gt, and
  loop until the whole stack is green with no open feedback. Optimized for
  hands-off, low-typing operation while the user does other work. Use when the
  user says /babysit-stack, "work my stack", "babysit my PRs", "address feedback
  on the stack", "get my stack green", or similar.
---

# babysit-stack

Drive a Graphite stack to a clean state with as little typing from the user as
possible. The user submits a stack, then wants you to grind through round after
round of CI failures and reviewer/AI-agent comments, checking in only when a
real decision is needed.

## Prime directive: minimize the user's typing

This is the whole point of the skill. The user is doing other work in parallel
and wants to drive you one-handed or from a mobile device, so:

- **Default to `AskUserQuestion`** for every decision. Its options are
  selectable with a single click/keystroke — that is the preferred UX. Put your
  recommended option first and append " (recommended)" to its label.
- Use `multiSelect: true` whenever the user might want to pick several items at
  once (e.g. "which of these fixes should I apply?").
- When you have more than 4 options, or are listing many comments/PRs, print a
  compact **lettered menu** instead and tell the user to reply with the
  letter(s): `[a]` apply all, `[b]` pick individually, `[c]` skip this PR, `[s]`
  stop. Accept comma-separated letters (`a,c`) for multi-pick.
- Free-text chat is the fallback, not the default. Only ask for prose when you
  genuinely need it (e.g. "what should I reply to this reviewer?") — and even
  then, offer canned replies as letter options first (`[a]` "Done, fixed in
  latest push" `[b]` "Good catch, addressing" `[c]` write my own).
- Never make the user retype context you already have. Summarize state tersely;
  don't dump raw logs unless asked (offer `[v]` view full log as an option).
- Batch decisions. One round = one (or few) questions covering the whole stack,
  not one question per comment.

## The loop

Each invocation runs rounds until the stack is clean or the user stops.

### 1. Map the stack

- **Default to the current branch's stack — don't ask which one.** `gt ls`
  (alias for `gt log short`) shows the stack and marks the current branch.
  - If the current branch is part of a stacked diff, operate on the **entire
    current stack** (every branch from the trunk-most ancestor up through the
    top of this stack, excluding trunk).
  - If the current branch is a standalone branch (no stack), operate on just
    that one branch's PR.
  - **Only when invoked from the trunk branch** (`main`/`master`/`trunk`,
    where there's no current stack to infer) ask the user — via
    `AskUserQuestion` — which branch or stack to babysit.
- Use `gt ls --reverse` for trunk→top order. Collect the ordered branch names
  for the chosen stack (exclude trunk/`main`).
- For each branch, resolve its PR:
  `gh pr view <branch> --json number,title,url,state,isDraft,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup,reviews,comments`
  (skip branches with no PR — note them).

### 2. Gather feedback per PR

For each PR, collect:

- **CI**: `gh pr checks <branch> --json name,state,bucket,link` (or read
  `statusCheckRollup` from step 1). Bucket into pass / fail / pending. For
  failures, fetch logs only when about to act:
  `gh run view <run-id> --log-failed` or `gh pr checks <branch>` then follow the
  failing check's link.
  - When the user names a failing job/spec, reproduce it locally with the
    project's real runner before editing (find the package's actual name + test
    command — e.g. `pnpm --filter <pkg> run test -- <path>`; a wrong filter
    silently runs nothing and looks like a pass). Expect some local-only
    failures from missing infra (LocalStack, a DB, secrets) — confirm a failure
    is in your stack's diff (`git diff <base>..HEAD --name-only`) before
    attributing it to your changes.
- **Inline review comments** (where AI agents like Graphite/Diamond, CodeRabbit,
  Copilot, etc. leave actionable suggestions):
  `gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate` (fields of
  interest: `id`, `path`, `line`, `body`, `user.login`, `in_reply_to_id`,
  `created_at`). Bot logins are suffixed `[bot]` (e.g. `coderabbitai[bot]`) —
  match on that, not the bare name.
- **Top-level review summaries & verdicts**: from the `reviews` / `comments`
  JSON in step 1 (`reviewDecision` of `CHANGES_REQUESTED` etc.).
- **Restack / conflict needs**: if `gt ls` shows a branch needs restack, or
  `mergeable` is `CONFLICTING`.

#### Rechecking comments — AI reviewers are slow and asynchronous

Treat "no comments yet" as **"not done yet,"** not "clean." Hard-won rules:

- **Re-sweep every PR's comments at the start of every round** — never carry
  forward a stale "this PR is clean." AI reviewers (CodeRabbit especially)
  finish **large PRs minutes later** than small ones, so a PR that showed 0
  comments on your first pass can sprout several after you've moved on. Don't
  conclude a PR is clean until the reviewer has posted its **completion signal**
  (CodeRabbit's "Actionable comments posted: N" / walkthrough summary; a
  `reviews` entry; Graphite's verdict). Absence of comments ≠
  reviewed-and-clean.
- **Draft PRs skip auto-review.** CodeRabbit posts "Review skipped — Draft
  detected" and does nothing until you either mark the PR ready or comment
  `@coderabbitai review` on it. If the stack is draft and you want feedback to
  grind on, trigger explicitly (see Reference) — otherwise you'll wait forever
  for comments that never come.
- **A re-review usually does NOT post a new top-level comment.** It adds/updates
  *inline* comments and may just reply in-thread or edit its existing summary.
  So polling "did a new issue-comment appear?" is unreliable — poll the **inline
  comment set** and the reviewer's replies instead.
- **Distinguish new findings from history and replies.** Addressed inline
  comments are NOT deleted — they persist (often re-anchored to a shifted line),
  so a flat count is meaningless. To find genuinely-new actionable items after a
  push, filter `created_at` newer than your trigger AND `in_reply_to_id == null`
  (a non-null reply is the bot acknowledging *you*, not a new finding):
  `gh api .../pulls/{n}/comments --paginate -q '.[] | select(.user.login=="coderabbitai[bot]") | select(.created_at > "<iso>") | select(.in_reply_to_id == null)'`.
  For true resolution state use the GraphQL `reviewThreads.isResolved` query
  (see Reference); a fixed finding's thread stays *open* unless someone resolves
  it.

Track which review comments are already resolved/replied so you don't re-surface
them. If you skip the GraphQL resolution check, at least skip comments that
already have a reply, and map each finding to the fix/branch that addressed it.

### 3. Present the round

Show a one-screen summary of the whole stack, e.g.:

```
Stack (3 PRs):
  ① add-api      #812  ✓ CI   2 review comments
  ② update-fe    #813  ✗ CI (lint)   1 review comment
  ③ docs         #814  ⏳ CI pending   clean
```

Then ask, via `AskUserQuestion`, what to tackle this round. Good first question
options (multiSelect): "Fix CI on #813", "Address review comments on #812",
"Wait for pending CI", "Resubmit as-is", "Stop". Keep labels short.

### 4. Act on the selections

- **Code changes**: `gt co <branch>` (or `gt checkout`), make the edit, then
  `gt modify` to amend the branch and auto-restack everything upstack. Use
  `gt modify -c -m "..."` only if the user wants a new commit instead of an
  amend. Prefer surgical edits that directly address the failing check /
  comment.
- **Replying to inline comments**: offer canned replies as letter options; reply
  with
  `gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies -f body="..."`.
- **General PR reply**: `gh pr comment <branch> --body "..."`.
- **Resolving threads** (optional, nice for clean state): GraphQL
  `resolveReviewThread` — see Reference.
- For ambiguous fixes, show the proposed diff and confirm with a yes/no
  `AskUserQuestion` before writing — but for obvious CI fixes (lint, format,
  type errors with one clear fix), just do it and report.

### 5. Resubmit

- `gt ss` (their alias for `gt submit --stack --no-web`). When running
  unattended, add flags to avoid prompts: `gt submit --stack --no-edit --quiet`.
  Use `--restack` if branches drifted. Never pass `--ai`/`--edit` in the
  hands-off path (those open prompts).

### 6. Wait & re-poll

After resubmit, CI needs time. Tell the user you're waiting (they can keep
working) and either:

- Poll: re-check `gh pr checks` for the affected PRs every ~60–90s for a few
  cycles (`gh pr checks <branch> --watch --fail-fast` blocks until done for a
  single PR), **or**
- Hand back: report current state and let the user re-invoke / say "continue"
  later. If they want true background pacing, suggest `/loop` (e.g.
  `/loop 5m continue babysitting the stack`).

When you're waiting on an **AI reviewer's re-review** (not CI), run the poll as
a background command and watch the **inline-comment set / reviewer replies**
(per the rechecking rules above), not "a new top-level comment" — and give large
PRs a longer window. Don't declare "clean" the moment the poll window closes;
declare it only when the re-review's completion signal shows **no new actionable
findings** (filtered by `created_at` + `in_reply_to_id == null`).

Then go back to step 1. **Stop when**: every PR is ✓ CI, no unresolved
actionable comments, and `reviewDecision` is not `CHANGES_REQUESTED` — or the
user picks Stop.

## Operating principles

- Be terse in the terminal; reserve detail for when the user asks (`[v]`).
- Surface blockers immediately (merge conflict, failing build that needs a human
  decision) rather than guessing.
- Don't fabricate fixes for CI failures you can't see — fetch the log first.
- Don't resolve/dismiss a reviewer's comment without either fixing it or getting
  the user's OK.
- Preserve stack integrity: always `gt modify` (not raw `git commit --amend`) so
  descendants restack; resubmit the whole stack so PR bases stay correct.
- One round per check-in by default; only chain rounds without asking when the
  user said "just get it green" / picked an "auto" option.

## Reference

Stack & submit:

- `gt ls` / `gt ls --reverse` — view stack
- `gt co <branch>` — checkout a branch in the stack
- `gt modify` — amend current branch + restack upstack
- `gt restack` — rebase the stack onto latest parents
- `gt sync` — pull trunk, rebase, prune merged branches
- `gt ss` → `gt submit --stack --no-web`; hands-off:
  `gt submit --stack --no-edit --quiet [--restack]`

GitHub data (need `{owner}/{repo}` — get via
`gh repo view --json owner,name -q '.owner.login+"/"+.name'`):

- `gh pr view <branch> --json number,title,url,state,isDraft,reviewDecision,mergeable,mergeStateStatus,statusCheckRollup,reviews,comments`
- `gh pr checks <branch> [--json name,state,bucket,link] [--watch --fail-fast]`
- `gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate` — inline
  review comments
- `gh run view <run-id> --log-failed` — failing CI logs

Responding:

- `gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies -f body="..."`
  — reply inline
- `gh pr comment <branch> --body "..."` — top-level comment
- `gh pr comment <branch> --body "@coderabbitai review"` — force an AI re-review
  (required on **draft** PRs, which CodeRabbit otherwise skips)
- Resolve a thread (GraphQL):
  ```
  gh api graphql -f query='mutation($id:ID!){resolveReviewThread(input:{threadId:$id}){thread{isResolved}}}' -f id=<threadId>
  ```
  Get thread IDs + resolution state:
  ```
  gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){repository(owner:$o,name:$r){pullRequest(number:$n){reviewThreads(first:100){nodes{id isResolved comments(first:1){nodes{author{login} body}}}}}}}' -f o=<owner> -f r=<repo> -F n=<number>
  ```
