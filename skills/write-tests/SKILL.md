---
name: write-tests
description: Write a test that finds the defect. Show that the test fails against the incorrect code first. Use when you add a test, for "write a test for this", "add coverage", "is this tested", or after you correct a defect that had no test.
---

# Write tests

## Show that the test can fail

A test that you write after the correction usually passes for an incorrect reason. Run the
test against the incorrect code. See it fail. Then use it.

- **For a correction of a defect:** remove the correction in a reversible way. Use `git
  stash`, a temporary worktree, or a copy of the file. Run the test. The test must fail with
  a message that names the defect. Then put the correction back. The test must then pass.
  Do not edit the file manually and then rely on your memory to put it back.
- **For code that exists:** make the code incorrect. Invert a condition or return an
  incorrect default value. The test must fail.

A test that never failed does not test anything. Do not omit this step.

Run the full test suite before the change and after the change. Know which tests failed
before. A new test that passes while three other tests fail is not progress.

## Test the paths that fail

The paths that succeed already work. Defects are in these locations:

- The error path, the retry, the timeout, and the cleanup after a failure.
- The limits: 0, 1, n, n+1, empty, absent, null, and a duplicate value.
- The second call. State from the first call causes a failure here.
- The conditions when a dependency is absent, slow, or gives incorrect data.

Count the branches in the code. If your tests use only the branches that succeed, you test
that success succeeds.

## Test the promise, not the implementation

Name the test for the promise that it protects: `a skipped link fails loudly`. Do not name
it `test_link_2`. A name that is a sentence about the behavior shows you the fault with no
need to open the file.

Test the behavior that you can see: the return value, the exit code, the content of a file,
or the output. Do not test the internal parts: a private function, an internal name, a data
structure inside the code, or the number of calls to a function. A refactor changes these
parts, and then the test fails when the code is correct.

## Isolate each test

Give each test its own temporary state: its own directory, database, `TMPDIR`, or `HOME`.
Use the value that the code reads.

Tests that use the same state pass or fail with the sequence. You cannot use the results.

Do the cleanup at the end of each test, not at the end of the suite. This includes the
temporary state, the open handles, and each change that the test made outside itself.

## Replace the external parts, not the subject

Replace the parts that are slow, that cost money, that use the network, or that give a
different result each time. Examples: an API call, the clock, or a model.

Never replace the code that you test. A test of a replacement tests the replacement.

Use a real temporary file, not a simulated file system. Use a real subprocess. A test that
is nearer to production has more value.

## Use the tools of the project

Use the tools that the project uses: the test framework, the assertions, the fixtures, and
the file layout. If the project has no framework, do not add one. Assertions and a `main`
function that exits with a value that is not zero are sufficient.

One command must run all the tests. The command must exit with a value that is not zero
after a failure.

## The output of a failure is the product

After a failure, the output must give the expected value, the actual value, and the
location. `FAIL case_7` sends the reader back to the code. Print the actual value.

## Do not

- Do not test the standard library, the framework, or the compiler.
- Do not write a test if you cannot give its purpose in one sentence.
- Do not use a coverage percentage as a target. It counts the lines that ran. It does not
  count the promises that you protect.
