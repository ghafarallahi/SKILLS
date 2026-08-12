---
name: target
description: Break a task into the smallest possible steps, ask every open question in one batch up front, then run all the way to the end without stopping to check in. Use when the user says "/target", "go to the end", "run it to the end", "don't stop and ask me", "do the whole thing", or hands over a multi-step task and walks away.
---

# Target

One round of questions, then no interruptions until it's done.

## 1. Break it down first

Before asking anything, decompose the task into the smallest steps that can each be
finished and checked on their own. Write them out with `TaskCreate` so the user can watch
progress while they're away.

- Small enough that a step failing tells you exactly what broke.
- Ordered so blocked steps sit at the end, not the middle.
- Split anything you can't name a success check for — that's a sign it's still two steps.

The breakdown is what surfaces the real questions. A task decomposed badly produces
vague questions; a task decomposed well produces sharp ones.

## 2. Ask everything at once

Read the whole breakdown, collect every genuine unknown, and ask them in a single
`AskUserQuestion` round (up to 4 per call, so batch tightly).

**Only ask what changes what you build.** For everything else, pick the obvious default,
state it in your summary, and move on. A question you could answer by reading the code is
not a question — go read it. Interrogation defeats the point of the command.

Ask about: which of two incompatible designs, destinations that can't be guessed (repo,
branch, path), visibility and blast radius, missing credentials or access.

Don't ask about: naming, formatting, library choice with an obvious default, anything
already settled in the conversation, or permission to continue.

## 3. Run to the end

Work the list top to bottom without checking in. Mark each step with `TaskUpdate` as you
go. When something surprises you mid-run, decide it yourself under a stated assumption and
keep going — record the assumption for the final report.

If a step is genuinely blocked, do every other step first, then report what's left. Never
stall the whole run on one blocked item.

**Still stop for:** anything irreversible or outward-facing that the user hasn't already
authorized — pushing, publishing, deleting, sending, spending. "Run to the end" is
permission to skip check-ins, not permission to take those actions unasked.

## 4. Report once, at the end

- What got done, what didn't, and why.
- Every assumption you made instead of asking.
- Anything you found that's worth a follow-up.

State failures plainly with their output. A run that finished 9 of 12 steps and says so is
worth more than one that claims 12.

## Notes

If the codex-review Stop hook is installed, it reviews the whole run when you finish — so
the end of a `/target` run is also where an independent model gets its say. Expect the
occasional block on the last step; fix and finish.
