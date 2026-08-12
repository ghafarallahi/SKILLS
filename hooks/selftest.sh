#!/usr/bin/env bash
# Regression check for codex-review.sh and record-edit.sh.
#
# Runs the real hook scripts against throwaway repos and folders, with a stub `codex` on
# PATH so every verdict is deterministic, instant and free. Each case gets its own TMPDIR,
# which is where the hooks keep their session state — so cases can't leak into each other.
#
#   bash hooks/selftest.sh
#
# Exits non-zero if any case fails.
set -uo pipefail

HOOKS=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REVIEW="$HOOKS/codex-review.sh"
RECORD="$HOOKS/record-edit.sh"
pass=0
fail=0

# --- harness ----------------------------------------------------------------

ok() {
  pass=$((pass + 1))
  printf '  ok   %s\n' "$1"
}

bad() {
  fail=$((fail + 1))
  printf '  FAIL %s\n     %s\n' "$1" "$2"
}

# A stub codex that prints whatever verdict the case wants, and records that it ran.
stub_codex() { # stub_codex <bindir> <verdict-line|"">
  mkdir -p "$1"
  {
    printf '#!/bin/sh\n'
    printf 'touch "$(dirname "$0")/../called"\n'
    printf 'echo "reviewed"\n'
    [ -n "${2:-}" ] && printf 'echo "%s"\n' "$2"
  } >"$1/codex"
  chmod +x "$1/codex"
}

# A PATH with no codex on it, but with the tools the hooks actually need.
path_without_codex() { # path_without_codex <bindir>
  mkdir -p "$1"
  for t in jq git; do
    ln -sf "$(command -v "$t")" "$1/$t"
  done
  printf '%s:/usr/bin:/bin' "$1"
}

run_hook() { # run_hook <script> <tmpdir> <cwd> <session> [path]
  printf '{"cwd":"%s","session_id":"%s"}' "$3" "$4" |
    TMPDIR="$2" PATH="${5:-$PATH}" bash "$1" 2>/dev/null
}

new_repo() { # new_repo <dir>
  mkdir -p "$1"
  git -C "$1" init -q .
  git -C "$1" config user.email test@test
  git -C "$1" config user.name test
  printf 'a = 1\n' >"$1/code.py"
  git -C "$1" add -A
  git -C "$1" commit -qm init
}

is_block() { printf '%s' "$1" | jq -e '.decision == "block"' >/dev/null 2>&1; }
is_warn() { printf '%s' "$1" | jq -e '.systemMessage | test("UNVERIFIED")' >/dev/null 2>&1; }

# --- cases ------------------------------------------------------------------

case_approve() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  printf 'a = 2\n' >>"$t/repo/code.py"
  stub_codex "$t/bin" "CODEX_VERDICT: APPROVE"
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/repo" s1 "$t/bin:$PATH")
  if [ -z "$out" ]; then ok "approve is silent"; else bad "approve is silent" "got: $out"; fi
  rm -rf "$t"
}

case_reject() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  printf 'a = 2\n' >>"$t/repo/code.py"
  stub_codex "$t/bin" "CODEX_VERDICT: REJECT"
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/repo" s1 "$t/bin:$PATH")
  if is_block "$out"; then ok "reject blocks the turn"; else bad "reject blocks the turn" "got: $out"; fi
  rm -rf "$t"
}

case_clean_tree() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  stub_codex "$t/bin" "CODEX_VERDICT: REJECT"
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/repo" s1 "$t/bin:$PATH")
  if [ -n "$out" ]; then
    bad "clean tree is silent" "got: $out"
  elif [ -e "$t/called" ]; then
    bad "clean tree skips codex" "codex was invoked with nothing to review"
  else
    ok "clean tree skips codex entirely"
  fi
  rm -rf "$t"
}

case_block_cap() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  printf 'a = 2\n' >>"$t/repo/code.py"
  stub_codex "$t/bin" "CODEX_VERDICT: REJECT"
  local one two three
  one=$(run_hook "$REVIEW" "$t" "$t/repo" cap "$t/bin:$PATH")
  two=$(run_hook "$REVIEW" "$t" "$t/repo" cap "$t/bin:$PATH")
  three=$(run_hook "$REVIEW" "$t" "$t/repo" cap "$t/bin:$PATH")
  if is_block "$one" && is_block "$two" && [ -z "$three" ]; then
    ok "blocks twice per session, then steps aside"
  else
    bad "blocks twice per session, then steps aside" "3rd run should be silent, got: $three"
  fi
  rm -rf "$t"
}

case_record_edit() {
  local t
  t=$(mktemp -d)
  printf 'x = 1\n' >"$t/thing.py"
  printf '{"session_id":"rec","tool_input":{"file_path":"%s"}}' "$t/thing.py" |
    TMPDIR="$t" bash "$RECORD"
  if grep -qxF "$t/thing.py" "$t/claude-codex-review/rec.files" 2>/dev/null; then
    ok "record-edit logs the written path"
  else
    bad "record-edit logs the written path" "not found in rec.files"
  fi
  rm -rf "$t"
}

case_nongit_reject() {
  local t
  t=$(mktemp -d)
  mkdir -p "$t/plain"
  printf 'x = 1\n' >"$t/plain/thing.py"
  mkdir -p "$t/claude-codex-review"
  printf '%s\n' "$t/plain/thing.py" >"$t/claude-codex-review/ng.files"
  stub_codex "$t/bin" "CODEX_VERDICT: REJECT"
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/plain" ng "$t/bin:$PATH")
  if is_block "$out"; then
    ok "reviews recorded files with no repo present"
  else
    bad "reviews recorded files with no repo present" "got: $out"
  fi
  rm -rf "$t"
}

case_nongit_approve_clears() {
  local t
  t=$(mktemp -d)
  mkdir -p "$t/plain" "$t/claude-codex-review"
  printf 'x = 1\n' >"$t/plain/thing.py"
  printf '%s\n' "$t/plain/thing.py" >"$t/claude-codex-review/ng.files"
  stub_codex "$t/bin" "CODEX_VERDICT: APPROVE"
  run_hook "$REVIEW" "$t" "$t/plain" ng "$t/bin:$PATH" >/dev/null
  if [ ! -s "$t/claude-codex-review/ng.files" ]; then
    ok "approval drops the reviewed paths"
  else
    bad "approval drops the reviewed paths" "still queued: $(cat "$t/claude-codex-review/ng.files")"
  fi
  rm -rf "$t"
}

case_cap_rollover() {
  local t i
  t=$(mktemp -d)
  mkdir -p "$t/plain" "$t/claude-codex-review"
  for i in $(seq 1 35); do
    printf 'x = %s\n' "$i" >"$t/plain/f$i.py"
    printf '%s\n' "$t/plain/f$i.py" >>"$t/claude-codex-review/roll.files"
  done
  stub_codex "$t/bin" "CODEX_VERDICT: APPROVE"
  run_hook "$REVIEW" "$t" "$t/plain" roll "$t/bin:$PATH" >/dev/null
  local first queued
  first=$(wc -l <"$t/claude-codex-review/roll.review" | tr -d ' ')
  queued=$(wc -l <"$t/claude-codex-review/roll.files" | tr -d ' ')
  run_hook "$REVIEW" "$t" "$t/plain" roll "$t/bin:$PATH" >/dev/null
  local left
  left=$(wc -l <"$t/claude-codex-review/roll.files" | tr -d ' ')
  if [ "$first" = 30 ] && [ "$queued" = 5 ] && [ "$left" = 0 ]; then
    ok "35 files: reviews 30, queues 5, finishes them next turn"
  else
    bad "35 files: reviews 30, queues 5, finishes them next turn" \
      "reviewed=$first queued=$queued left=$left (want 30/5/0)"
  fi
  rm -rf "$t"
}

case_no_codex() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  printf 'a = 2\n' >>"$t/repo/code.py"
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/repo" s1 "$(path_without_codex "$t/bin")")
  if is_warn "$out" && ! is_block "$out"; then
    ok "missing codex warns, never blocks"
  else
    bad "missing codex warns, never blocks" "got: $out"
  fi
  rm -rf "$t"
}

case_no_verdict() {
  local t
  t=$(mktemp -d)
  new_repo "$t/repo"
  printf 'a = 2\n' >>"$t/repo/code.py"
  stub_codex "$t/bin" ""
  local out
  out=$(run_hook "$REVIEW" "$t" "$t/repo" s1 "$t/bin:$PATH")
  if is_warn "$out" && ! is_block "$out"; then
    ok "unparseable verdict warns, never blocks"
  else
    bad "unparseable verdict warns, never blocks" "got: $out"
  fi
  rm -rf "$t"
}

echo "git repo"
case_approve
case_reject
case_clean_tree
case_block_cap

echo "no git"
case_record_edit
case_nongit_reject
case_nongit_approve_clears
case_cap_rollover

echo "fails open"
case_no_codex
case_no_verdict

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
