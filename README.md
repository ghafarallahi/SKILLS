# SKILLS

Claude Code customizations that make an independent model — OpenAI's Codex — confirm work
before it's reported as done. Claude doesn't self-certify.

Two pieces, one advisory and one enforcing:

| Path | What it is |
|---|---|
| [`skills/codex-check/SKILL.md`](skills/codex-check/SKILL.md) | A skill Claude follows when asked to verify work ("codex check this"). Advisory — it triggers on relevance. |
| [`hooks/codex-review.sh`](hooks/codex-review.sh) | A `Stop` hook. Runs on **every** turn end, no discretion involved. |
| [`hooks/reset-count.sh`](hooks/reset-count.sh) | Clears the per-session block counters so the hook will block again. |

## How the hook behaves

On each turn end it collects `git diff HEAD` plus untracked files, hands them to
`codex exec`, and reads the verdict off the last line of Codex's reply:

- **APPROVE** → silent, turn ends.
- **REJECT** → the turn is blocked and the findings are fed back to Claude to fix.
- **Anything else** → a loud `changes are UNVERIFIED` warning, turn ends.

It no-ops when the working tree is clean or the directory isn't a git repo — so it only
costs a Codex run when there's something to review. Committed work is invisible to it.

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
```

Then wire the hook up in `~/.claude/settings.json`:

```json
{
  "hooks": {
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
