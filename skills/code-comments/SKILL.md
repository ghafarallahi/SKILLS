---
name: code-comments
description: Write the comments that survive — why over what, the constraint the code can't show, updated in the same diff as the code they describe. Use when adding or reviewing comments, writing docstrings for a public API, or deciding whether a piece of code needs explaining at all.
---

# Code comments

A stale comment is worse than no comment. Missing explanation costs a reader ten minutes;
a confident wrong one sends them down a path the code abandoned two years ago, and they
trust it because someone wrote it deliberately.

Write few, make them load-bearing, keep them true.

## First, try to delete it

Most comments are a symptom. Before writing one, see whether the code can just say it:

- A better name — `retryAfterThrottle` needs no comment; `handle2` does.
- A named constant instead of `86400 // seconds in a day`.
- An extracted function whose name is the sentence you were about to write.
- An early return instead of `// if we get here, the user is valid`.

If restructuring says it, restructure. A comment is what's left when the language can't
carry the meaning.

## Comment the why, and the things code can't hold

What survives review and stays useful:

- **Why this way** — the alternative you rejected, the constraint that forced the shape,
  the reason the obvious approach doesn't work here.
- **The surprise** — a workaround for an upstream bug (link it), an ordering that looks
  arbitrary but isn't, an optimization that made the code uglier and why it was worth it.
- **The invariant** — what must stay true, especially if a future edit could quietly break
  it. "Callers hold the lock" belongs in the code.
- **The lie in the interface** — a function whose name promises more or less than it does,
  until someone renames it.
- **Deliberate limits** — a shortcut with a known ceiling, named, with what would justify
  replacing it. A tagged marker (`TODO`, `NOTE`, or your codebase's own) makes them
  greppable later.
- **The domain rule** — code that encodes a business or regulatory decision should say
  which rule it implements and where that rule actually lives: the policy doc, the contract
  clause, the statute, the person who decided. `if (turnover > 85000)` is unreadable without
  it, and unmaintainable when the threshold changes and nobody knows what it was tracking.

Link the issue, RFC, ticket, spec or commit that holds the full story. One URL beats a
paragraph that's a summary of a summary.

## Don't write

- **Narration.** `i++ // increment i`, `// loop over users`, `// constructor`.
- **Signature restatement.** `@param name The name.` Document what a reader can't infer:
  units, ranges, ownership, nullability, what happens on failure.
- **Diff commentary.** `// added error handling`, `// changed per review`, `// new`. That's
  what the history is for, and it's meaningless within a week.
- **Commented-out code.** Delete it. Git remembers, and nobody dares remove it later
  because they don't know if it's load-bearing.
- **Section banners** in a file that would be better split.
- **Apologies.** `// this is ugly but works` — either explain why it must be this way, or
  fix it.

## Docstrings on a public API are a contract

For anything other people call, document what they can't read off the type:

- Units and ranges (`timeout` in seconds? milliseconds?).
- What it does on failure — returns null, throws, retries, blocks.
- Side effects, allocations, whether it mutates its arguments.
- Thread-safety and reentrancy, if that's a question anyone could have.
- Ownership: who closes the handle, who frees the buffer.

An example beats prose for anything with a non-obvious call shape.

## TODOs that mean something

A bare `TODO: fix this` is a wish with no owner and no date. Make it actionable: what needs
doing, and a link to the issue tracking it. If it isn't worth an issue, it isn't worth a
TODO — either do it now or delete the line.

## Keep them true

This is the part that matters most and gets skipped:

- Change the code, re-read the comments around it in the same diff. If your change made a
  sentence false, fix it now — a follow-up pass never comes.
- Reviewing a diff, read the comments as claims to verify, not as decoration. A comment
  that contradicts the code it sits above is a finding, not a nit.
- Renaming or moving code takes its comments with it. Orphaned explanations point at
  nothing.
- If a comment can't be kept true — it describes something in flux — say less, or delete
  it. Silence is honest.

## Match the codebase

Density and style are house conventions, not personal ones. Read the file you're editing:
if it uses a doc format (`javadoc`, `rustdoc`, `docstring`), use it; if it comments only at
module boundaries, don't start annotating every branch. Consistency is what makes an
unusual comment stand out as important.
