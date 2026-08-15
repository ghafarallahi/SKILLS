#!/usr/bin/env bash
# Print the CHANGELOG section for one version, for use as GitHub release notes.
#
#   bash hooks/relnotes.sh v0.2.1 [path/to/CHANGELOG.md]
#
# The output has no blank line at the start or at the end, because GitHub keeps them and
# they show as a gap above the notes.
#
# Exits 1 when the version has no section. An empty release body is worse than a failed
# command: the release publishes and nobody sees that the notes are missing.
set -uo pipefail

version=${1:-}
[ -n "$version" ] || {
  echo "usage: relnotes.sh <version> [changelog]" >&2
  exit 2
}
file=${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/CHANGELOG.md}
[ -f "$file" ] || {
  echo "no changelog at $file" >&2
  exit 1
}

# `^## ` does not match `### ...`, so a sub-heading inside the section is kept and the next
# version heading ends it.
notes=$(awk -v V="## $version" '
  $0 == V { f = 1; next }
  f && /^## / { exit }
  f { buf[++n] = $0 }
  END {
    s = 1; while (s <= n && buf[s] == "") s++
    e = n; while (e >= s && buf[e] == "") e--
    for (i = s; i <= e; i++) print buf[i]
  }
' "$file")

[ -n "$notes" ] || {
  echo "no section for $version in $file" >&2
  exit 1
}

printf '%s\n' "$notes"
