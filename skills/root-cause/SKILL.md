---
name: root-cause
description: Find the line where the behavior of the code and your model of the code become different. Then correct the cause, not the symptom. Use when code fails, stops, or gives a different result each time, and for "debug this", "why does this fail".
---

# Root cause

The defect is not in the location that you expect. It is in the assumption that you did not
examine.

## 1. Cause the failure with one command

Before you make a theory, find a command that fails each time. Write the command down. You
must be able to ask "is it still incorrect?" and get a correct answer in seconds.

If the failure does not occur each time, measure it. Run the command N times. Record the
number of failures. Use that number as your instrument. A defect that fails 3 times in 100
runs is sufficient to measure. You need sufficient runs to see a change.

Compare the same quantities. Use the same number of runs before the correction and after
the correction. Write the result as a fraction: `6/200 before, 0/200 after`. Use sufficient
runs. Zero failures must be an unexpected result if the defect is still there. For a defect
that occurs in 3% of the runs, a small number of correct runs shows nothing.

Change the conditions that change the failure rate: the environment, the sequence, the
time, the concurrent use, or the data. A correction that does not change the rate is a
guess.

## 2. Read the error

Read the full text, the full stack, and the exit code. Do not read only the last line. An
error usually gives the file, the value, and the operation. No output is also data, and
a program that does not stop is also data. Both show that the failure occurred before the
first output.

Examine the simple causes before the complex causes:

- An old build or an old artifact in a cache.
- An incorrect program on the `PATH`.
- A file that is a symbolic link to a different location.
- A configuration file that the process reads, but you changed a different file.

## 3. Divide the search area

Divide the area in two parts. Look at the result. Do this again.

Use `git bisect` when the code was correct before. Remove one half of a pipeline. Use the
smallest input that fails. Ten small measurements are faster than one complex theory.

## 4. Look at the values

Print the value at the boundary: the variable, the path, the exit code, or the response.

Find the line where the value that the code has and the value that you expect become
different. That line is the location of the defect.

Do not make a conclusion about the result of a function. Run the function. Look at the
result.

## 5. Make one change at a time

Make one change. Run the command. Keep the change or remove it.

If you make two changes, you cannot know which change gave the result. One of the two can
also be a new defect.

## 6. Correct the cause, not the location

When you find the line that fails, find each caller. Use `grep` with the name of the
function.

If four callers have the same fault, correct the shared function. A correction in only the
caller from the report leaves three faults. It also teaches you nothing.

A correction with no mechanism is not a correction. If the code becomes correct after a
rebuild, a retry, or an unrelated edit, the defect moved. It did not go away.

## 7. Show the correction and prevent the defect

- The command failed before the change. The command passes after the change. Measure this.
- Leave a test that fails against the previous code. See
  [`write-tests`](../write-tests/SKILL.md).
- Give the mechanism in one sentence: the fault, and how it caused the symptom.

## When you cannot find the cause

Write down each assumption of your theory. Then examine the assumption that you are most
sure about. The defect is there. You are sure about it, so you did not examine it.
