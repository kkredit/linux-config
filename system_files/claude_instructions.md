# Global user instructions

## Code comments

- Avoid verbose doc comments, and never reference ticket/issue numbers unless specified.
- Avoid comments about *transitions* that don't make sense in the new *state*; comments
  should not be diff-aware.
  - Bad: "This used to ABC, but XYZ..., so now we MNO"
  - Better: "MNO in order to avoid XYZ" — or omit entirely.

## GitHub CI status checks

A GitHub fine-grained PAT is configured for `gh` (account `kkredit`). It does **not**
have the `checks:read` permission (fine-grained PATs can't currently grant it), so
anything that hits the checks API returns `403 Forbidden`.

- **Do NOT use `gh pr checks`** — it relies on the checks API and will fail.
- **Use `gh run list` / `gh run view` instead** to read CI status:
  - `gh run list --branch <branch> --limit 10`
  - `gh run view <run-id>` (note: the ANNOTATIONS section still 403s — that's expected)
  - `gh run view <run-id> --log-failed` to see what actually failed

## Human-facing prose

`~/.claudisms.md` lists "claudisms" — the tics and stock phrasings that mark text as
LLM-written. Before publishing any human-facing prose, read that file and revise the
draft to remove what it names.

- Applies to: documentation, RFCs, website copy, runbooks, PR descriptions, PR
  comments, and similar prose.
- Does not apply to: code, code comments, commit messages, or other non-prose text.
- "Avoid claudisms" — in any context, about any text — is a request to consult
  `~/.claudisms.md` and strip what it names from that text.
