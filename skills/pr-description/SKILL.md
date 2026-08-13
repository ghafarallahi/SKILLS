---
name: pr-description
description: Write a pull request description aimed at the reviewer — why it exists, where to start reading, how it was verified, what's deliberately not in it. Use when opening a PR, drafting a PR body, or when asked "write the PR description" or "summarize this branch".
---

# PR description

A commit message explains a change to the future. A PR description explains it to one tired
person who has to decide whether it's safe, today. Write for them.

## Read the whole branch first

Find the base branch rather than assuming `main`:

```bash
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
# nothing? ask, or read it off the remote — don't assume main:
#   git remote show origin | sed -n 's/.*HEAD branch: //p'
git log "$base"..HEAD --oneline
git diff "$base"...HEAD --stat
git diff "$base"...HEAD
```

Check for `.github/PULL_REQUEST_TEMPLATE.md` (or `docs/`, `.gitlab/`) and fill that structure
instead of inventing your own — a team that wrote a template wants it used.

Three dots, not two — you want the branch against its merge base, not against wherever main
has drifted to. The PR is the sum of the commits, and it usually says something none of them
say alone.

If the diff turns out to be two unrelated changes, say so and offer to split the PR. That
costs you a minute and saves the reviewer an hour.

## Lead with why

First paragraph, 2–4 sentences: the problem, and what's different once this lands. Not the
implementation — the reviewer gets that from the diff. What they can't get from the diff is
what went wrong without this, or what forced the shape.

If it fixes a reported bug, state the symptom in the reporter's words, then the mechanism in
yours.

## Point at where to start

The single highest-value line in any PR body:

> Start at `parser.go:88` — that's the only behavior change. Everything else is the rename
> it forced.

Reviewers ration attention. Spend it for them: name the risky hunk, the one-way door, the
part you're least sure about. A 600-line diff with 20 interesting lines should say which 20.

## Say how it was verified

Commands you actually ran, and the part of the output that matters — a result line, not a
thousand lines of log, and never output carrying tokens, hostnames, or customer data.

Never a test you didn't run — see [`write-tests`](../write-tests/SKILL.md) for what counts
as verified.

```
bash hooks/selftest.sh    → 17 passed, 0 failed
```

Include the negative check when there is one: what you broke on purpose to confirm the new
test catches it.

## State the blast radius

- What breaks if this is wrong, and who notices first.
- Migrations, config, env vars, feature flags — and whether it's a one-way door.
- How to roll back. If rollback isn't just a revert, that belongs in the body, not in an
  incident channel later.

## Say what's not in it

Scope you deliberately left out, follow-ups you plan, known-rough edges. This is what stops
a reviewer from spending their review asking for things you already decided against — and
it's how you keep a "while you're in there" from doubling the diff.

## Cut

- File-by-file narration. The Files tab already did that.
- Restating each commit message; they're one click away.
- "Minor refactor" on a 400-line diff, or any other description the diff contradicts.
- Selling adjectives. The reviewer is deciding on risk, not buying anything.

## Title

Same rules as the commit subject — imperative, specific, no type prefix unless the repo uses
one. See [`commit-message`](../commit-message/SKILL.md).

## Then stop

Draft the body and hand it over. Opening the PR, pushing the branch, and requesting review
are outward-facing — they wait for the user to ask.
