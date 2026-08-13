---
name: refactor
description: Change the structure of code and keep the behavior. Get a test that passes before you start. Keep the tests passing between each step. Do not put a refactor and a correction in one commit. Use for "refactor", "clean up", "restructure", "extract", "simplify", "remove duplication".
---

# Refactor

A refactor keeps the behavior. If the behavior changes, the change is not a refactor. Such
a change is permitted. Put it in a different commit and say what it changes.

Behavior includes each item that a user of the code can see:

- The return values and the public signatures.
- The error types.
- The effects on other systems and the format of the output.
- The speed and the memory use, when other code depends on them.

A test suite that passes does not show most of these items. Ask which code uses this code,
and what its users can see.

## Name the problem first

A refactor to make code "cleaner" adds structure that nobody asked for. Before you change
the code, give the problem in one sentence:

- Four callers repeat the same control, and one caller does not have it.
- This function changes for five different reasons.
- The next case needs an edit in three files that must agree.

If you cannot name a problem, do not change the code. Code that operates is not a defect.

## Get a test that passes first

You need a check that passes now and must continue to pass. This is your only protection.

If there is no check, write a **characterization test** first. Record the behavior that the
code has now, with its defects. You do not approve the behavior. You record it, so that a
change becomes visible. See [`write-tests`](../write-tests/SKILL.md).

If you cannot test the code, that is the first refactor. Add a boundary that a test can
use. Verify the behavior manually one time. Then continue with a real check.

## Make small steps and run the tests between them

Rename, then run the tests. Extract, then run the tests. Inline, then run the tests. A
refactor that compiles only at the end is a rewrite. When it fails, you cannot know which step caused the failure.

Use simple changes. Use a tool for a mechanical change. A replacement in 30 locations with
one command is more reliable than 30 manual edits, and the diff is easier to review.

## Delete before you add structure

The most valuable refactor is a deletion. A deletion needs no design:

- Code that no code calls, a branch that no path uses, and parameters that the function
  does not use.
- Options that nobody sets, and configuration for a value that never changes.
- An interface with one implementation, a factory that makes one type, and a function that
  only calls a different function.
- An export that no other code uses.

A deletion is also the easiest change to verify. The tests pass or they do not pass.

There is one exception. The removal of an item that other code can see changes the
behavior. Examples: a public export, a command-line option, or a field in a response. Such
a removal is not a refactor. The item can also look unused from inside the code.

## Wait for the third example

Two similar parts can be an accident. Three similar parts are a pattern.

If you make a shared abstraction from two parts, the shape is usually incorrect. An
incorrect abstraction costs more than the duplication, because all subsequent code must
obey it.

Wait for the third part. Then extract only the content that the three parts share. Do not
add content for a fourth part that does not exist.

## One type of change for each commit

Never put a refactor and a correction in one commit. A diff of 400 lines with 6 lines that
change the behavior is not reviewable, and `git bisect` cannot divide it.

Move the code in one commit. Change the behavior in the next commit.

## Verify, do not estimate

- Run the test suite. It must pass before and after. Do not omit a test.
- For a change with risk, compare the behavior. Run the two versions with real input.
  Compare the output.
- Examine the callers that you did not change. A caller that expects the previous shape
  shows that the change was not a refactor.

## Do not refactor

- Code that you will delete or replace soon.
- Code with no tests that you have no reason to change today.
- Code that must be fast, if you do not measure the speed. The simpler version is sometimes
  slower.
