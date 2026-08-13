# Changelog

## v0.1.0

First tagged version. Nothing to upgrade from; this is what you get on a fresh install.

### What it does to your machine

`hooks/install.sh` symlinks 12 skills and 2 hook scripts into `~/.claude/`, and adds one
`PostToolUse` and one `Stop` entry to `~/.claude/settings.json`. Your existing settings are
copied to `settings.json.bak` before the file is rewritten, and nothing else in it is
touched. Requires `codex` (authenticated), `jq`, and `git`.

**After installing, every turn that leaves changed files is reviewed by Codex before it can
be reported as done.** A rejection is fed back for a fix rather than shown to you as a
suggestion. That is a real change to how the agent behaves — see
[Deliberate limits](README.md#deliberate-limits) before deciding.

### Included

- **Hooks** — `codex-review.sh` (Stop), `record-edit.sh` (PostToolUse), plus `install.sh`,
  `selftest.sh`, `reset-count.sh`.
- **Skills** — `target`, `codex-check`, `commit-message`, `pr-description`,
  `review-changes`, `write-tests`, `root-cause`, `refactor`, `write-docs`, `ci-verify`,
  `security-audit`, `release`.

### Limits worth knowing before you install

- **Fails open.** If `codex` is missing, crashes, or returns nothing parseable, the hook
  warns `changes are UNVERIFIED` and lets the turn end. It never wedges a session.
- **Two blocks per session.** After that it steps aside rather than looping; run
  `hooks/reset-count.sh` to re-arm.
- **Costs a Codex call** on every turn that leaves uncommitted changes. Committing is what
  ends a review cycle.
- **Your diff leaves the machine.** It's sent to Codex. `skills/codex-check` says to skip
  files carrying credentials, but nothing enforces that — review what you point it at.
- Outside a git repo it reviews the files the session wrote, capped at 30 per turn.

### Uninstalling

Remove the two entries from `~/.claude/settings.json` (or restore `settings.json.bak`) and
delete the symlinks under `~/.claude/skills/` and `~/.claude/hooks/`. Nothing else was
written.

### Verified

`bash hooks/selftest.sh` → `17 passed, 0 failed`, run against the tagged commit in an
isolated worktree, plus an install into a scratch `HOME` from that same tree.
