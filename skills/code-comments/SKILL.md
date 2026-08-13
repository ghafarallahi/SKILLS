---
name: code-comments
description: Write comments that give the reason and the constraint that the code cannot show. Update a comment in the same commit as the code. Use when you add or review comments, when you write a docstring for a public interface, or when you decide if code needs an explanation.
---

# Code comments

An incorrect comment is worse than no comment. An absent explanation costs the reader ten
minutes. An incorrect explanation sends the reader to a design that the code no longer has,
and the reader trusts it because a person wrote it.

Write few comments. Make each comment necessary. Keep each comment correct.

## First, try to remove the comment

Most comments show a fault in the code. Before you write a comment, try to make the code
give the same data:

- A better name. `retryAfterThrottle` needs no comment. `handle2` needs one.
- A constant with a name, in place of `86400 // seconds in a day`.
- A function with a name that is the sentence that you were about to write.
- An early return, in place of `// if we get here, the user is valid`.

If a change to the code gives the data, change the code. A comment is what remains when the
language cannot hold the meaning.

## Write the reason and the data that code cannot hold

These comments keep their value:

- **The reason for this design.** The alternative that you rejected, the constraint that
  caused this shape, and why the usual method does not operate here.
- **The unexpected part.** A temporary solution for a defect in a different product. Give
  the link. Also: a sequence that looks arbitrary, or an optimization that made the code
  less clear. For the optimization, give the measurement that made it necessary.
- **The rule that must stay true.** Write it when a subsequent edit can break it. Example:
  the callers hold the lock.
- **An incorrect name.** A function whose name gives more or less than the function does,
  until a person changes the name.
- **A known limit.** A temporary solution with a maximum, and the condition that makes a
  replacement necessary. Use a marker such as `TODO` or `NOTE`, so that you can find them.
- **A rule from the business or from a regulation.** Give the rule that the code
  implements. Give the location of that rule: the policy document, the contract, the law, or
  the person who decided. `if (turnover > 85000)` has no meaning without this. It also
  becomes impossible to maintain when the value changes.

Give a link to the issue, the specification, or the commit with the full data. One link is
better than a short summary of a summary.

## Do not write

- **A description of the operation.** `i++ // increment i`. `// loop over users`.
- **A repetition of the signature.** `@param name The name`. Give the units, the limits, the
  owner, and the result of a failure.
- **A description of the change.** `// added error handling`. `// changed per review`. The
  history has this data. The comment has no value after one week.
- **Code that you made into a comment.** Delete it. Git keeps it. If you leave it, no
  person will remove it later, because they do not know if it is necessary.
- **A title for a section** in a file that you must divide into two files.
- **An apology.** `// this is ugly but works`. Give the reason, or correct the code.

## A docstring on a public interface is a contract

For code that other persons call, give the data that the types cannot give:

- The units and the limits. Is `timeout` in seconds or in milliseconds?
- The result of a failure: null, an exception, a retry, or a block until a condition is
  true.
- The effects on other systems, the memory that it allocates, and if the function changes
  its arguments.
- Which values can be null, and what the function does with a null value.
- Use with more than one thread, and reentrancy, if a caller can ask these questions.
- The owner: which code closes the handle or releases the memory.

An example is better than text for a call with an unusual shape.

## Write a TODO that has a meaning

`TODO: fix this` has no owner and no date. Write the necessary task and a link to the issue.
If the task does not need an issue, it does not need a TODO. Do the task now, or delete the
line.

## Keep the comments correct

This is the most important part, and persons omit it:

- When you change code, read the comments near it in the same commit. If your change made a
  sentence incorrect, correct the sentence now. A subsequent pass does not occur.
- When you review a diff, read each comment as a statement to verify. A comment that
  disagrees with its code is a finding.
- When you move code or change its name, move its comments with it. An explanation with no code shows nothing.
- If you cannot keep a comment correct, write less or delete it. No comment is honest.

## Use the conventions of the codebase

The quantity and the style are conventions of the project. Read the file that you edit. If
it uses a documentation format, use the same format. If it has comments only at the start of
each module, do not add a comment to each branch. A consistent style makes an unusual
comment visible.
