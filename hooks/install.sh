#!/usr/bin/env bash
# Install these skills and hooks into ~/.claude: symlink them, then merge the hook entries
# into settings.json without disturbing anything already in there.
#
#   bash hooks/install.sh
#
# Idempotent — re-running reports what's already in place and changes nothing. Honors $HOME,
# so you can rehearse it against a scratch directory first.
set -uo pipefail

REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
CLAUDE="$HOME/.claude"
SETTINGS="$CLAUDE/settings.json"
REVIEW_CMD="bash ~/.claude/hooks/codex-review.sh"
RECORD_CMD="bash ~/.claude/hooks/record-edit.sh"
changed=0

for t in jq git; do
  command -v "$t" >/dev/null 2>&1 || {
    echo "missing required tool: $t" >&2
    exit 1
  }
done

# --- symlinks ---------------------------------------------------------------

link() { # link <source> <destination>
  local src=$1 dst=$2
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "  ok      $dst"
      return 0
    fi
    ln -sfn "$src" "$dst"
    echo "  relink  $dst"
    changed=1
    return 0
  fi
  if [ -e "$dst" ]; then
    # A real file or directory someone else put there — never clobber it.
    echo "  SKIP    $dst already exists and is not a symlink" >&2
    return 1
  fi
  ln -s "$src" "$dst"
  echo "  link    $dst"
  changed=1
}

mkdir -p "$CLAUDE/skills" "$CLAUDE/hooks"
echo "symlinks"
link "$REPO/skills/codex-check" "$CLAUDE/skills/codex-check"
link "$REPO/skills/target" "$CLAUDE/skills/target"
link "$REPO/hooks/codex-review.sh" "$CLAUDE/hooks/codex-review.sh"
link "$REPO/hooks/record-edit.sh" "$CLAUDE/hooks/record-edit.sh"

# --- settings.json ----------------------------------------------------------

echo "settings.json"
had_settings=1
[ -f "$SETTINGS" ] || {
  had_settings=0
  echo '{}' >"$SETTINGS"
}

if ! jq -e . "$SETTINGS" >/dev/null 2>&1; then
  echo "  $SETTINGS is not valid JSON — fix it first, nothing was changed" >&2
  exit 1
fi

merged=$(jq \
  --arg rev "$REVIEW_CMD" \
  --arg rec "$RECORD_CMD" '
  .hooks //= {}
  | .hooks.PostToolUse //= []
  | .hooks.Stop //= []
  | if ([.hooks.PostToolUse[].hooks[]?.command] | index($rec)) then .
    else .hooks.PostToolUse += [{
      matcher: "Write|Edit",
      hooks: [{ type: "command", command: $rec, timeout: 10 }]
    }] end
  | if ([.hooks.Stop[].hooks[]?.command] | index($rev)) then .
    else .hooks.Stop += [{
      hooks: [{
        type: "command",
        command: $rev,
        timeout: 300,
        statusMessage: "Codex reviewing changes..."
      }]
    }] end
' "$SETTINGS")

if [ -z "$merged" ]; then
  echo "  merge failed — $SETTINGS left untouched" >&2
  exit 1
fi

if [ "$merged" = "$(jq . "$SETTINGS")" ]; then
  echo "  ok      both hooks already configured"
else
  if [ "$had_settings" -eq 1 ]; then
    cp "$SETTINGS" "$SETTINGS.bak"
    printf '%s\n' "$merged" >"$SETTINGS"
    echo "  wrote   $SETTINGS (previous copy at $SETTINGS.bak)"
  else
    printf '%s\n' "$merged" >"$SETTINGS"
    echo "  wrote   $SETTINGS"
  fi
  changed=1
fi

# --- prerequisites ----------------------------------------------------------

echo "codex"
if command -v codex >/dev/null 2>&1; then
  echo "  ok      $(codex --version 2>/dev/null || echo installed)"
else
  echo "  codex not found — the hook will warn UNVERIFIED instead of reviewing." >&2
  echo "  install it with: npm install -g @openai/codex" >&2
fi

echo
[ "$changed" -eq 1 ] && echo "Installed. Restart Claude Code so it picks up the new settings." ||
  echo "Nothing to do — already installed."
