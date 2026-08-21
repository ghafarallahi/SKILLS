#!/usr/bin/env bash
# Checks that README.md's skill table and the skills/ directory agree: every skill on disk
# has a row whose link target is the skill, and every row's link target still exists.
# Matches link targets "](skills/<name>/SKILL.md)", not raw text: a row whose label names
# the path but links elsewhere does not count.
#
#   bash hooks/check-readme.sh [repo-root]
#
# Exits non-zero if either side has an entry the other doesn't.
set -uo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
README="$ROOT/README.md"
fail=0

for dir in "$ROOT"/skills/*/; do
  name=$(basename "$dir")
  [ -f "$dir/SKILL.md" ] || continue
  if ! grep -qF "](skills/$name/SKILL.md)" "$README"; then
    echo "missing row: $name"
    fail=1
  fi
done

while IFS= read -r name; do
  [ -f "$ROOT/skills/$name/SKILL.md" ] || { echo "stale row: $name"; fail=1; }
done < <(grep -oE '\]\(skills/[^/)]+/SKILL\.md\)' "$README" | sed -E 's#^\]\(skills/([^/)]+)/SKILL\.md\)$#\1#' | sort -u)

exit "$fail"
