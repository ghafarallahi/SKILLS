---
name: minimal-code
description: Write the least code that does the task correctly. Use what exists before you write new code - the project, the standard library, the platform. Mark each intentional limit with a ceiling comment. Use when you write, design, or review code, select a library or dependency, and for "simplest solution", "do less", "over-engineered", "bloat", "yagni".
---

# Minimal code

The least expensive line is the line that you do not write. Each line that you write costs
again later: in review, in tests, and in each session that reads it.

This skill limits the code that you write. The [context-budget](../context-budget/SKILL.md)
skill limits the data that you read. The two skills do not conflict. Use both.

## 1. The order of solutions

Try each solution in this order. Stop at the first solution that works.

1. No code. If the need is speculative, do not build for it. State the decision in one
   line.
2. Code that the project already has. Search for a helper, a type, or a pattern before
   you write one.
3. The standard library of the language.
4. The platform: a native control, a CSS rule, a database constraint.
5. A dependency that is already installed. Do not add a new dependency for a task that a
   few lines can do.
6. The minimum new code that passes the check.

Apply the order after you understand the problem, not in place of the problem. First read
the parts of each file that the change touches. An excerpt that answers the question is
sufficient (see [context-budget](../context-budget/SKILL.md)). The order shortens the
solution. It does not shorten the understanding.

For a defect, correct the shared cause, not one symptom (see
[root-cause](../root-cause/SKILL.md)). One correction in the shared function is less code
than a guard in each caller.

## 2. Rules for new code

- Do not write an abstraction with one implementation.
- Do not write configuration for a value that does not change.
- Do not write code for a future need. The future can write its own code.
- Prefer the removal of code to the addition of code.
- Use the fewest files that the change permits.
- When two correct solutions have the same size, select the one that is correct on the
  edge cases. Less code is the goal. A weaker algorithm is not.

## 3. Mark each intentional limit

The minimum solution often has a known limit: one global lock, a linear scan, a simple
heuristic. That is permitted when you mark it where it lives:

```
# ceiling: one global lock. upgrade: one lock for each account, when throughput is a problem.
```

A `ceiling:` comment names three things: the limit, the replacement, and the condition
that requires the change. A marker that omits one of the three is a defect: nobody knows
when the limit must go, or what replaces it. To see all the
limits in a project, run `grep -rn "ceiling:"` on the source tree.

## 4. Find code that should not exist

When you review code for size, give one line for each finding, with one of these tags:

- `delete:` dead code, or a feature for a speculative need. The replacement is nothing.
- `stdlib:` a hand-written copy of a standard library function. Name the function.
- `native:` code or a dependency that does the work of a platform feature. Name the
  feature.
- `yagni:` an abstraction with one implementation, or a layer with one caller.
- `shrink:` the same logic in fewer lines. Show the shorter form.

This review finds size, not defects. A defect belongs to the
[review-changes](../review-changes/SKILL.md) skill. When there is nothing to cut, say so
in one line and stop.

## 5. Report in few lines

Show the code first. Then report at most three lines: what you did not build, and the
condition to build it. Do not write prose that defends a simplification. Give a full
explanation only when the user requests one.

## 5a. Every failure path ends visibly

Minimal code is not silent code. Each failure path ends in exactly one visible outcome:

- Raise the error, or propagate it to the caller.
- Return an explicit error value that the caller must handle.
- Log the reason and continue, by a stated decision.

These forms are forbidden:

- An empty catch block.
- A catch that returns a default value with no log.
- A retry loop that exhausts its attempts and falls through to an implicit null. After
  the last attempt, raise the last error, or return it through the function's declared
  error type.
- An exception converted silently into a value with the shape of success. A fallback
  that is logged and documented is the third permitted outcome, not this form. The
  difference is that the caller or the log can see that the failure happened.

A violated internal assumption is a defect. Crash at once. Do not return a default value
to continue.

## 6. The limits of this skill

Never remove these items to make the code smaller:

- The validation of input at a trust boundary.
- The error handling that prevents the loss of data.
- A security measure, or an accessibility feature.
- An item that the user requests explicitly. Build it. Do not argue two times.
- A calibration constant in code that controls hardware. A physical device does not match
  its specification.

Each new branch, loop, or parser keeps one check that fails when the logic breaks. See
[write-tests](../write-tests/SKILL.md) for how to prove that the check works. A trivial
one-line change does not need its own test. Do not add a test framework, or fixtures,
that the user did not request.

## 7. Do not claim a number

Do not state a savings number for code that you did not write. Code that does not exist
has no measured size, so there is no baseline. Count what exists: the `ceiling:` markers,
and the lines that a deletion removed.
