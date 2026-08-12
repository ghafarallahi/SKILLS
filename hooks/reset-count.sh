#!/usr/bin/env bash
# Clear the per-session block counters so codex-review.sh will block again.
# Useful after you've resolved a disagreement and want the review re-armed.
set -euo pipefail

state="${TMPDIR:-/tmp}/claude-codex-review"
rm -f "$state"/*.count
echo "cleared block counters in $state"
