---
name: write-docs
description: Write documentation someone can act on — every command actually run, limits and failure modes stated, updated in the same commit as the behavior it describes. Use when writing or updating a README, guide, reference, changelog entry, or docstring.
---

# Write docs

A doc that's wrong is worse than no doc. Missing docs cost the reader time; wrong docs cost
them trust, then time, then the bug they didn't think to suspect.

## Start where the reader starts

Order by what they're trying to do, never by how the code is organized:

1. What is this and what does it do to my machine or my workflow?
2. The shortest path to it working.
3. What it does once it's running.
4. What it deliberately won't do.
5. Reference detail, for when they come back with a specific question.

The first screen answers "will this help me, and what does it cost". Anyone still reading
after that has already decided.

## Run every command you write

Every block a reader might paste gets executed first, in a clean state if the doc claims a
clean state. Paste the real output, not a plausible rendering of it.

Three exceptions: commands that destroy data or cost money, commands needing credentials
you shouldn't exercise casually, and privileged or production-touching operations (`sudo`,
anything pointed at live infrastructure). Don't run those — mark them clearly as
unverified and say what they'll do. Everything else gets run.

Untested command blocks are the single biggest source of broken docs — a flag that changed,
a path that only exists on your machine, a step you do from muscle memory and forgot to
write down.

State the prerequisites the commands assume — versions, credentials, platform, an already
running service. A block that works only on your machine reads identical to one that works
everywhere.

## Document the limits

The most useful section is usually the one saying what the thing won't do:

- What happens when a dependency is missing or a call fails.
- Deliberate caps, timeouts, and the reason for them.
- What it doesn't see (state it can't reach, cases it ignores).
- Known-broken and not-yet-built, said plainly.

Readers forgive limits. They don't forgive discovering a limit at 2am that you knew about.

## Say why, not just what

The code already says what. A doc earns its place by carrying what the code can't: the
constraint that forced this shape, the alternative rejected and why, the failure that
motivated the guard.

## Update it in the same commit

Docs rot at the exact moment behavior changes and nobody's watching. If a change makes a
sentence false, fix the sentence in that commit — not in a cleanup pass that never comes.
When reviewing a diff, ask which sentence it just invalidated.

## Cut

- **Adjectives selling the thing.** "Simple", "just", "easy", "powerful", "seamless". If it
  were easy they wouldn't be reading. `just run X` becomes `run X`.
- **Restating the signature.** `@param name The name` is noise; document what a reader
  can't infer — units, ranges, ownership, what happens on failure.
- **Duplicate explanations.** Two places describing one behavior means one of them will be
  wrong within a month. Say it once, link to it.
- **Aspirational content.** Don't document what you plan to build.

## Show before you explain

Real output, a real command, a real file layout — then a sentence about what it means. A
paragraph describing what a five-line block would have shown is a paragraph nobody reads.

## Before you're done

- Every command run, every output real.
- No sentence you couldn't defend by pointing at code.
- A reader with only this page and the prerequisites can get to working.
