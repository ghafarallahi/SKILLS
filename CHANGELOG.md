# Changelog

## v0.2.0

Two new skills, and every skill file rewritten in Simplified Technical English.

### Upgrade

Re-run the installer. It links the two new skills; it changes nothing else.

```bash
cd ~/MyProject/SKILLS && git pull && bash hooks/install.sh
```

Nothing breaks. The skill names, the hook paths, and the two `settings.json` entries are
unchanged, so an existing install keeps working without the pull.

### New skills

- **`context-budget`** — read the smallest slice that answers the question. Search before
  you read, read a range instead of a file, cap command output, send wide searches to a
  subagent. It also says when to read *more*: uncertainty is a signal to read more, and the
  budget never applies to understanding the problem.
- **`code-comments`** — comments that carry what code cannot: the reason, the invariant, the
  domain rule and where that rule authoritatively lives. Plus the rule that gets skipped —
  re-read the comments next to any code you change, in the same commit.

### All skill files are now ASD-STE100

Short sentences, active voice, one meaning per word, enumerations as lists, no metaphor. An
instruction that can be read two ways is a defect in a document whose only job is to be
followed.

**The rewrite lost instructions in 12 of 13 files.** Each file was compared against its
previous version, and the losses were real: "do not escape the input" for SQL, the
link-local ranges, rehearsing a rollback against restored production data, and a stop rule
that had collapsed from *any* irreversible action into five examples. Two rounds restored
them. [`CODEX-REVIEW.md`](CODEX-REVIEW.md) records what was lost and what came back.

If you had read a skill before, read it again — the wording is different everywhere, even
where the instruction is identical.

### Also

- A GitHub Actions workflow runs `hooks/selftest.sh` on every push and pull request. The
  README test badge now reflects a real run instead of a number kept by hand.
- `actions/checkout` is pinned by commit SHA, and the workflow has `contents: read` only.

### Unchanged

17 test cases, 5 hook scripts, and the same deliberate limits: it fails open, and it blocks
at most twice per session.

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
