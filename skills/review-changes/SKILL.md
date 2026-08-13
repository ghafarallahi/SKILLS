---
name: review-changes
description: Review a diff for defects that cause a failure: incorrect results, data loss, security faults, and race conditions. Verify each finding against the code before you report it. Use for "review this", "review my changes", "is this correct", or before a pull request.
---

# Review changes

A review has value only when a finding shows a real failure. Do not report a finding that
you cannot support.

## 1. Get the correct diff

Use `git diff --staged`, or `git diff main...HEAD`, or the pull request. Name the base
commit. If you do not name the base, you will review changes that were already on the
branch, and you will not see the new changes.

## 2. Read more than the diff

The diff shows the changed lines. It does not show the code that uses those lines.

Before you judge a changed function, find each caller. Use `grep` with the name of the
function. Read each caller. Most defects are in the difference between the new behavior of
the function and the behavior that the callers expect.

For each changed function, answer these questions:

- Which code calls this function?
- Which values does the caller send?
- What does the caller do with the result?

## 3. Put the findings in order of cost

Report the findings in this sequence. Give your attention in the same sequence.

1. **Data loss, data corruption, and security.** The code deletes incorrect data, sends a
   credential, accepts input at a trust boundary with no control, or gives more permission.
2. **Incorrect results.** An incorrect value, an off-by-one error, an inverted condition, an
   error path with no handler, an exception that the code catches and then ignores, or an
   incorrect default value.
3. **Failure with load or with concurrent use.** A race condition, a deadlock, unlimited
   growth, an open handle, or a query for each row.
4. **A broken contract.** A caller, a schema, or a public signature that is no longer
   correct.
5. **Absent tests** for logic that can fail with no message.

## 4. Verify a finding before you report it

For each possible finding, try to show that it is incorrect. Make the failure case: these
inputs, this state, this incorrect result. Read the code path. Do not use the name of the
function to make a conclusion.

If you cannot make a failure case, the item is not a finding. There is one exception. You
can report a defect that you can show with a mechanism, but you cannot cause on demand.
Examples: a race condition, a time-of-check-to-time-of-use window, or an unlimited retry.
Report the mechanism and the sequence that causes it. Write that the finding is reasoned,
not caused.

For all other items with no failure case: ask a question, or remove the item. An incorrect
finding costs the author more time than no finding.

Run the tests and the static checks of the repository. Divide the failures that this diff
caused from the failures that were already there. "This also fails on main" is data that
the author needs.

## 5. Report

Use a maximum of three lines for each finding:

- `path/to/file.ext:42` — the location.
- One sentence: the defect.
- The failure case: the inputs and the incorrect behavior.

Put the most severe finding first. Do not summarize the diff. The author wrote it. Do not
add a list of good points. Do not add findings to increase the count.

**Do not report** these items: style, a preference for a name, a format, "you can extract
this", a future requirement, or an item that a linter controls.

If the change does not obey the conventions of the repository, write one line at the end.

## 6. Report that the diff is correct

If the diff has no defect, write this and stop. Do not add a small finding to show
thoroughness. A reviewer who adds unnecessary findings teaches the author to read the
reviews quickly. Then the author does not see the important finding.

## Note

This is the manual method. [`codex-check`](../codex-check/SKILL.md) sends the same diff to
an independent model, and puts that second opinion on the record. Use the two methods
together. Do the manual review first.
