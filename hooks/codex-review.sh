#!/usr/bin/env bash
# Stop hook: independent Codex review of work in progress. Blocks the turn on REJECT.
#   git repo    -> reviews `git diff HEAD` plus untracked files.
#   non-git dir -> reviews the files this session actually wrote, recorded by record-edit.sh.
# Fails open (never blocks) when codex is missing, errors, or returns no parseable verdict —
# a hook that can jam the session is worse than an unverified change, so it says so loudly instead.
set -uo pipefail

input=$(cat)
j() { printf '%s' "$input" | jq -r "$1"; }

cwd=$(j '.cwd // ""')
[ -n "$cwd" ] && cd "$cwd" 2>/dev/null

session=$(j '.session_id // "nosession"')
state="${TMPDIR:-/tmp}/claude-codex-review"
mkdir -p "$state"
f="$state/$session.review"
touched="$state/$session.files"

if git rev-parse --git-dir >/dev/null 2>&1; then
  diff=$(git --no-pager diff HEAD 2>/dev/null)
  untracked=$(git ls-files --others --exclude-standard 2>/dev/null)
  [ -z "$diff$untracked" ] && exit 0
  {
    printf '%s\n' "$diff"
    [ -n "$untracked" ] && printf '\n--- untracked files (read these) ---\n%s\n' "$untracked"
  } >"$f"
  what="The diff is in $f; untracked file paths are listed at the end of it — read those files directly."
  mode=git
else
  # No git, so no diff to take: fall back to the paths this session wrote.
  files=$(sort -u "$touched" 2>/dev/null | while IFS= read -r p; do
    [ -f "$p" ] && printf '%s\n' "$p"
  done)
  [ -z "$files" ] && exit 0
  n=$(printf '%s\n' "$files" | wc -l | tr -d ' ')
  printf '%s\n' "$files" | head -30 >"$f"
  what="This is not a git repository, so there is no diff — $f lists the files written this session (showing up to 30 of $n; any remainder is reviewed on the next turn). Read them and judge them as they stand."
  mode=files
fi

count=$(cat "$state/$session.count" 2>/dev/null || echo 0)
# ponytail: 2 blocks per session max, then hand it back to the user rather than loop
[ "$count" -ge 2 ] 2>/dev/null && exit 0

command -v codex >/dev/null 2>&1 || {
  echo '{"systemMessage":"codex not installed — changes are UNVERIFIED"}'
  exit 0
}

msg="$state/$session.msg"
: >"$msg"
out=$(codex exec --color never --skip-git-repo-check -o "$msg" </dev/null "Review the work in progress here. $what Reject only for real defects: bugs, broken syntax, wrong paths, security issues, or code that plainly does not do what it claims. Do not reject on style or taste. End your reply with a single line: CODEX_VERDICT: <APPROVE|REJECT>" 2>&1)
rc=$?
# the agent's final message only — the full session log is just noise in the block reason
last=$(cat "$msg" 2>/dev/null)
[ -n "$last" ] && out="$last"

verdict=$(printf '%s' "$out" | grep -oE 'CODEX_VERDICT: (APPROVE|REJECT)' | tail -1)

if [ "$verdict" = "CODEX_VERDICT: REJECT" ]; then
  echo $((count + 1)) >"$state/$session.count"
  jq -n --arg r "Codex reviewed your changes and REJECTED them. Fix the issues below, then finish.

$out" '{decision:"block", reason:$r, systemMessage:"Codex rejected the changes — Claude is fixing them"}'
  exit 0
fi

if [ -n "$verdict" ]; then
  # Approved: nothing commits in a non-git folder, so clear the list by hand or every later
  # turn re-reviews the same files. Drop only the paths actually sent to Codex — anything
  # past the 30-file cap stays queued for the next turn instead of being forgotten.
  if [ "$mode" = files ]; then
    sort -u "$touched" 2>/dev/null | grep -vxF -f "$f" >"$touched.keep" || :
    mv "$touched.keep" "$touched"
  fi
  exit 0
fi

jq -n --arg c "$rc" --arg o "${out: -400}" \
  '{systemMessage:("codex review inconclusive (exit " + $c + ") — changes are UNVERIFIED: " + $o)}'
exit 0
