---
name: write-tests
description: Write tests that would actually catch the bug — proven by watching them fail against the broken code first. Use when adding tests, when asked "write a test for this", "add coverage", "is this tested", or after fixing a bug that had no test.
---

# Write tests

## Prove the test can fail

A test written after the fix usually passes for the wrong reason. Before you trust a new
test, run it against the broken code and watch it fail:

- Testing a bug fix? Revert the fix reversibly — `git stash`, a scratch worktree, or a copy
  of the file — run the test, confirm it fails with a message that names the real problem,
  then restore and confirm it passes. Never hand-edit the live file and trust yourself to
  put it back.
- Writing a test for existing code? Break that code deliberately — invert the condition,
  return the wrong default — and confirm the test goes red.

A test that has never failed is an assertion about nothing. This is the only step here that
can't be skipped.

Run the whole suite before and after, and know which failures were already there. A case
that goes green while three others turn red isn't progress.

## Test the failure paths

Happy-path coverage is the coverage that already works. Bugs live in:

- The error branch, the retry, the timeout, the cleanup that runs after a failure.
- Boundaries: 0, 1, n, n+1, empty, missing, null, duplicate.
- The second call. State left behind by the first is where idempotence dies.
- What happens when a dependency is absent, slow, or returns garbage.

Count the branches in the code you're covering. If your tests only reach the ones that
succeed, you've tested that success succeeds.

## Test the guarantee, not the implementation

Name the case after the promise it defends — `a skipped link fails loudly`, not
`test_link_2`. When the name reads like a sentence about behavior, a failure tells you what
broke without opening the file.

Assert on observable behavior: return values, exit codes, what landed on disk, what was
printed. Don't assert on internals a refactor would rename; that's a test that fails when
nothing is wrong.

## Keep each case isolated

Every case gets its own temporary state — its own directory, database, `TMPDIR`, `HOME`,
whatever the code keys off. Cases that share state pass or fail depending on order, and a
suite you can't trust is worse than no suite.

Clean up at the end of the case, not the end of the run.

## Stub the edges, not the subject

Stub what's slow, paid, networked, or nondeterministic — the API call, the clock, the model
invocation. Never stub the thing you're testing; a test of a stub proves the stub works.

Prefer a real temp file over a mocked filesystem, a real subprocess over a mocked one. The
closer the test runs to production, the more it's worth.

## Match the repo

Use whatever the project already uses. If it has no framework, don't introduce one — plain
`assert`s and a `main` that exits non-zero is a complete test suite. One command to run
everything, non-zero on failure.

## Failure output is the product

When a case fails, the output must say what was expected, what happened, and where. A bare
`FAIL case_7` sends the reader back into the code to reconstruct what you already knew.
Print the actual value.

## Don't

- Test the standard library, the framework, or the compiler.
- Write a case you can't explain the purpose of in one sentence.
- Chase a coverage number — it counts lines reached, not guarantees defended.
