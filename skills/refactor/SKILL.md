---
name: refactor
description: Change structure without changing behavior — green tests before you start, small steps green in between, and never mixed with a fix in the same commit. Use when asked to refactor, clean up, restructure, extract, deduplicate, or simplify existing code.
---

# Refactor

Behavior-preserving by definition. The moment behavior changes it stops being a refactor and
becomes a rewrite — which is fine, but say so and commit it separately.

## Name the pain first

Refactoring toward "cleaner" is how a codebase grows a layer nobody asked for. Before
touching anything, state the concrete pain in one sentence:

- Four callers repeat the same guard, and one of them forgot it.
- This function has five reasons to change.
- Adding the next case means editing three files that must stay in sync.

No nameable pain means leave it alone. Working code you're not otherwise changing is not a
defect, however you'd have written it.

## Get green first

You need a check that passes now and must keep passing — that's the entire safety net.

If there isn't one, write a **characterization test** before you start: pin the current
behavior exactly as it is, bugs included. You're not endorsing the behavior, you're
recording it so a change becomes visible. See [`write-tests`](../write-tests/SKILL.md).

If the code can't be tested at all, that's the first refactor: introduce a seam, verify by
hand once, then proceed with a real check.

## Small steps, green in between

Rename, run. Extract, run. Inline, run. A refactor that only compiles at the end is a
rewrite wearing a disguise, and when it breaks you'll have no idea which step did it.

Prefer mechanical moves over clever ones, and use tooling for mechanical ones — a
find-and-replace across 30 sites is more trustworthy than 30 hand edits, and the diff is
reviewable.

## Delete before abstracting

The highest-value refactor is removal, and it needs no design:

- Dead code, unreachable branches, unused parameters and exports.
- Options nobody sets, config for values that never change.
- An interface with one implementation, a factory for one product, a wrapper that only
  forwards.

Deleting is also the safest change to verify: it either still passes or it doesn't.

## Rule of three

Two similar things are a coincidence; three are a pattern. Extracting a shared abstraction
from two instances usually guesses the wrong shape, and a wrong abstraction costs more than
the duplication — everyone downstream now bends around it.

Wait for the third. Then extract the thing all three actually share, not a superset that
anticipates a fourth.

## One kind of change per commit

Never mix a refactor with a fix or a feature. A 400-line diff where six lines change
behavior is unreviewable, and `git bisect` can't tell you which part broke.

Move first, in its own commit, then change behavior in the next.

## Verify, don't eyeball

- Run the suite. Green before, green after, nothing skipped.
- For anything risky, compare real behavior across the change: run both versions on real
  input and diff the output.
- Check the callers you didn't touch — the ones that assumed the old shape are where a
  "pure" refactor turns out not to have been one.

## Don't refactor

- Code that's about to be deleted or replaced.
- Untested code you have no reason to change today.
- A hot path, without measuring — the tidier version is sometimes the slower one, and
  "cleaner" is not worth a regression you didn't look for.
