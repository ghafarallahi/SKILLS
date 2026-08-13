---
name: root-cause
description: Debug by narrowing to the line where reality diverges from your model, then fix the cause rather than the symptom. Use when something is broken, failing, hanging, flaky, or "worked yesterday", and when asked to debug, investigate a failure, or find why a test fails.
---

# Root cause

The bug is never where you assume. It's in the assumption you haven't checked.

## 1. Reproduce it in one command

Before theorizing, get a command that fails every time you run it. Write it down. Everything
after this depends on being able to ask "is it still broken?" and get a trustworthy answer
in seconds.

Can't reproduce it every time? Then measure it: run it N times, record the failure rate, and
make that number your instrument. A bug that fails 3 runs in 100 is reproducible enough —
you just need enough trials to tell a real change from noise, and to know that one green run
proves nothing.

Compare like with like: same trial count before and after, quoted as a fraction — `6/200
before, 0/200 after`. For a bug that fails ~3% of the time, a handful of green runs is
noise; you need enough trials that zero failures would be surprising.

Chase the conditions (environment, ordering, timing, concurrency, data) that move the rate.
A fix you can't observe changing that rate is a guess.

## 2. Read the actual error

The full text, the full stack, the exit code — not the summarized version, not the last
line. Errors usually name the file, the value, and the operation. A hang or empty output is
also evidence: it says the failure came before anything got printed.

Check the obvious environmental lies before the clever theories: stale build, wrong
binary on `PATH`, cached artifact, editing a file that's a symlink to somewhere else, the
process reading a different config than the one you changed.

## 3. Narrow by halving, not by guessing

Cut the space in half, observe, repeat. `git bisect` for "worked yesterday". Comment out
half the pipeline. Feed the smallest input that still fails. Ten cheap observations beat one
brilliant hypothesis — and take less time.

## 4. Observe values; never infer them

Print the actual value at the boundary. The variable, the path, the exit code, the raw
response. You're looking for the exact line where what the code sees stops matching what
you believe it sees — that gap is the bug's address.

Don't reason about what a function returns. Run it and look.

## 5. One change at a time

Change one thing, re-run the repro, keep or revert. Two changes at once and you can't tell
which mattered — and one of them may be a new bug you'll meet later.

## 6. Fix the cause, not the site

Once you have the failing line, ask what else routes through it. `grep` every caller of the
function you're about to patch. If four callers share the flaw, the fix belongs in the
shared path — patching the one the ticket named leaves three broken and teaches you nothing.

A fix you can't explain the mechanism of isn't a fix. "It works now" after a rebuild, a
retry, or an unrelated edit means the bug moved, not that it left.

## 7. Prove it, then fence it

- It failed before the change and passes after — verified, not assumed.
- Leave a regression test that fails against the old code. See
  [`write-tests`](../write-tests/SKILL.md).
- Report the mechanism in one sentence: what was wrong, why it produced this symptom.

## When stuck

Write down every assumption the working theory rests on, then test the one you're most
certain of. That's where it'll be — the certain assumption is the one nobody thought to
check.
