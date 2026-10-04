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
# Leading blank lines: not printed until the first non-blank. Trailing blank lines:
# printed, then stripped by the $() substitution.
notes=$(awk -v V="## $version" '
  $0 == V { f = 1; next }
  f && /^## / { exit }
  f && ($0 != "" || started) { print; started = 1 }
' "$file")

[ -n "$notes" ] || {
  echo "no section for $version in $file" >&2
  exit 1
}

printf '%s\n' "$notes"
