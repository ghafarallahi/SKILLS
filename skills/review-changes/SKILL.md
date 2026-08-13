---
name: review-changes
description: Review a diff for defects that would actually bite — correctness, data loss, security, races — verifying each finding against the code before reporting it. Use when asked to "review this", "review my changes", "look over this diff", "is this correct", or before opening a pull request.
---

# Review changes

A review is worth something only if a finding means "this breaks". Manufacture nothing.

## 1. Get the real diff

`git diff --staged`, `git diff main...HEAD`, or the PR — establish the base explicitly, or
you'll review changes that were already on the branch and miss the ones that weren't.

## 2. Read past the diff

The diff shows changed lines, not the code that depends on them. Before judging a changed
function, find its callers (`grep` the symbol) and read them. Most real defects live in the
gap between what a function now does and what its existing callers still assume.

Ask for each changed function: who calls this, what do they pass, and what do they do with
what comes back?

## 3. Rank by what it costs

Report in this order, and spend your attention the same way:

1. **Data loss, corruption, security.** Deletes the wrong thing, leaks a credential, trusts
   unvalidated input at a boundary, widens permissions.
2. **Correctness.** Wrong result, off-by-one, inverted condition, unhandled error path,
   swallowed exception, wrong default.
3. **Breaks under load or concurrency.** Race, deadlock, unbounded growth, leaked handle,
   N+1 against a real dataset.
4. **Contract breaks.** A caller, schema, or public signature that no longer holds.
5. **Missing coverage** for logic that would fail silently.

## 4. Verify before you report

For every candidate finding, try to refute it. Construct the concrete case: these inputs,
this state, this wrong output or crash. Walk the actual code path — don't infer from the
function's name.

If you can't produce a failing case, it isn't a finding — with one exception: a defect you
can argue mechanically but not reproduce on demand (a race, a TOCTOU window, an unbounded
retry). Report those as the mechanism plus the interleaving that triggers it, and label them
as reasoned rather than reproduced.

Everything else without a failing case: ask it as a question, or drop it. A confident wrong
finding costs the author more time than silence would.

Run the tests and whatever static checks the repo has, and separate what this diff broke from
what was already red. "Fails on main too" is information the author needs.

## 5. Report

Per finding, three lines at most:

- `path/to/file.ext:42` — where.
- One sentence: what's broken.
- The failure case: inputs → wrong behavior.

Most severe first. No summary of what the diff does — the author wrote it. No praise
section. No count-padding.

**Don't report:** style, naming taste, formatting, "consider extracting this", hypothetical
future requirements, or anything a linter owns. If the codebase's own conventions are
broken, that's one line, at the bottom.

## 6. Say when it's clean

If the diff is sound, say exactly that and stop. Inventing a marginal finding to look
thorough trains the author to skim your reviews — which is what makes the real finding get
missed later.

## Note

This is the by-hand method. [`codex-check`](../codex-check/SKILL.md) is the other half:
handing the same diff to an independent model so a second opinion is on record. They stack
well — review first, then let Codex disagree with you.
