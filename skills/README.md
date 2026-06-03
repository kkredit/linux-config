# Claude Code skills

Write your own [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills)
here. Each skill is a subdirectory containing a `SKILL.md` file (plus any
supporting scripts/assets), e.g.:

```
skills/
  my-skill/
    SKILL.md
    helper.sh
```

`file-install.sh` symlinks every immediate subdirectory of `skills/` into the
system-wide skill location, `~/.claude/skills/`. Because they are symlinks,
edits you make here take effect immediately — no reinstall needed.

## Skills

- `babysit-stack/` — iteratively drive a Graphite (`gt`) stack of PRs to green:
  fetch CI + reviewer/AI feedback, surface it as one-keystroke choices, fix /
  reply, resubmit, repeat. Built for low-typing, hands-off operation.
