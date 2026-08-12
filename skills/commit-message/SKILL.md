---
name: commit-message
description: Write a commit message from the actual staged diff — imperative subject, a body that explains why, no invented claims. Use when committing, when asked to "write a commit message", "commit this", "what should this commit say", or when amending or rewording an existing message.
---

# Commit message

## Read the diff first

Write from `git diff --staged`, never from memory of what you set out to do. What you
intended and what's staged drift apart constantly — half-finished edits, a debug line left
in, a file you forgot to add. The message describes what's actually there.

If the staged diff turns out to be two unrelated changes, say so and offer to split it. One
logical change per commit is what makes `git log` worth reading later.

## Subject

Imperative mood, capitalized, no trailing period, ~50 characters. It completes the sentence
"applying this commit will…" — `Add hooks/install.sh`, `Review changes outside git repos`,
`Lead the README with a quick start`.

- No `feat:` / `fix:` / `chore:` prefixes unless the repo already uses them. Match the
  existing log — run `git log --format='%s' -20` and follow what you see.
- Name the change, not the file that moved. `Fix off-by-one in the retry backoff` beats
  `Update retry.py`.
- Nothing vague: no "various fixes", "updates", "cleanup", "misc".

## Body

Skip it for genuinely trivial commits (a typo, a version bump). Otherwise wrap at 72 and
answer what the diff can't:

- **Why.** The diff shows what changed; it can't show the failure mode you hit, the
  alternative you rejected, or the constraint that forced the shape.
- **Decisions with a cost.** A deliberate limit, a known ceiling, a shortcut and its
  upgrade path.
- **Verification** — but only what you actually ran. See below.

Don't enumerate every file; that's what `--stat` is for. Don't restate the subject in
longer words.

## Never claim what you didn't do

The single rule that matters most. A commit message is a durable record, and a false one
misleads whoever bisects to it a year from now.

- Don't write "tested" / "verified" / "all tests pass" unless you ran them and saw them
  pass. Say what you ran.
- Don't describe intended behavior as confirmed behavior.
- If something is unfinished or known-broken, put it in the body. A commit that admits a
  gap is worth more than one that hides it.

## Trailers

Match the repo. If commits here carry a `Co-Authored-By:` trailer, keep it — a blank line
before the trailer block, one per line.

## Then commit

Pass the message on stdin so the body keeps its line breaks:

```bash
git commit -F - <<'EOF'
Subject line here

Body here.
EOF
```

Committing is local and reversible, so it needs no confirmation once asked for. **Pushing
is not** — it's outward-facing, so it waits for the user to ask.
