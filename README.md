# SKILLS

Claude Code customizations that make an independent model — OpenAI's Codex — confirm work
before it's reported as done. Claude doesn't self-certify.

Two pieces, one advisory and one enforcing:

| Path | What it is |
|---|---|
| [`skills/codex-check/SKILL.md`](skills/codex-check/SKILL.md) | A skill Claude follows when asked to verify work ("codex check this"). Advisory — it triggers on relevance. |
| [`hooks/codex-review.sh`](hooks/codex-review.sh) | A `Stop` hook. Runs on **every** turn end, no discretion involved. |
| [`hooks/record-edit.sh`](hooks/record-edit.sh) | A `PostToolUse` hook that logs which files got written, so the review works outside git. |
| [`hooks/reset-count.sh`](hooks/reset-count.sh) | Clears the per-session block counters so the hook will block again. |

## How the hook behaves

On each turn end it collects the work in progress, hands it to `codex exec`, and reads the
verdict off the last line of Codex's reply. What counts as "work in progress" depends on
where you are:

- **In a git repo** — `git diff HEAD` plus untracked files. Committed work is invisible to
  it, so committing is what ends a review loop.
- **Anywhere else** — the files this session wrote, recorded by `record-edit.sh`. There's no
  diff to show, so Codex judges the files as they stand. At most 30 files go into one
  review; the rest stay queued for the next turn. Reviewed paths are dropped on APPROVE —
  nothing else would clear them, and every later turn would re-review the same files.

The verdict decides the turn:

- **APPROVE** → silent, turn ends.
- **REJECT** → the turn is blocked and the findings are fed back to Claude to fix.
- **Anything else** → a loud `changes are UNVERIFIED` warning, turn ends.

It no-ops when there's nothing to review — clean tree, or no files written — so it only
costs a Codex run when there's something to look at.

### Deliberate limits

- **Fails open.** Codex missing, crashed, or unparseable → warn, never block. A hook that
  can wedge a session is worse than an unverified diff.
- **Two blocks per session, max.** Then it steps aside and hands the disagreement to you
  rather than looping. Run `hooks/reset-count.sh` to re-arm it.

## Install

The repo is canonical; `~/.claude` holds symlinks to it.

```bash
git clone https://github.com/rekopad/SKILLS.git ~/MyProject/SKILLS
ln -s ~/MyProject/SKILLS/skills/codex-check ~/.claude/skills/codex-check
ln -s ~/MyProject/SKILLS/hooks/codex-review.sh ~/.claude/hooks/codex-review.sh
ln -s ~/MyProject/SKILLS/hooks/record-edit.sh ~/.claude/hooks/record-edit.sh
```

Then wire both hooks up in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          { "type": "command", "command": "bash ~/.claude/hooks/record-edit.sh", "timeout": 10 }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ~/.claude/hooks/codex-review.sh",
            "timeout": 300,
            "statusMessage": "Codex reviewing changes..."
          }
        ]
      }
    ]
  }
}
```

Requires `codex` (`npm install -g @openai/codex`), authenticated, plus `jq` and `git`.
