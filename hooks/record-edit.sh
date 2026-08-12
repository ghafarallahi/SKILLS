#!/usr/bin/env bash
# PostToolUse hook (Write|Edit): remember which files this session wrote.
# codex-review.sh reads this list when there is no git repo to diff against.
set -uo pipefail

input=$(cat)
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_response.filePath // empty')
[ -n "$path" ] || exit 0

session=$(printf '%s' "$input" | jq -r '.session_id // "nosession"')
state="${TMPDIR:-/tmp}/claude-codex-review"
mkdir -p "$state"
printf '%s\n' "$path" >>"$state/$session.files"
exit 0
