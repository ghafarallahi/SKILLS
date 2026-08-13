---
name: commit-message
description: Write a commit message from the staged diff. Use an imperative subject and a body that gives the reason. Do not write a claim that you cannot support. Use when you commit, for "write a commit message", "commit this", or when you correct a message.
---

# Commit message

## Read the diff first

Write the message from `git diff --staged`. Do not write it from memory.

Your intention and the staged content are frequently different. An edit can be incomplete.
A debug line can remain. A file can be absent. The message must describe the staged
content.

If the staged diff contains two unrelated changes, tell the user. Offer to divide the
commit. One change for each commit makes the history usable.

## Subject

Write the subject in the imperative. Use a capital letter at the start. Do not use a full
stop at the end. Use approximately 50 characters.

The subject completes this sentence: "This commit will ...". Examples: `Add
hooks/install.sh`. `Review changes outside git repos`.

- Do not use a `feat:`, `fix:`, or `chore:` prefix if the repository does not use one. Run `git log
  --format='%s' -20`. Use the style of the repository.
- Name the change. Do not name the file. `Fix off-by-one in the retry backoff` is better
  than `Update retry.py`.
- Do not write an unclear subject: "various fixes", "updates", "cleanup".

## Body

Do not write a body for a trivial commit, such as a correction of a spelling error. For all
other commits, use a maximum line length of 72 characters. Give the data that the diff
cannot give:

- **The reason.** The diff shows the change. The diff does not show the failure, the
  alternative that you rejected, or the constraint. If you do not know the reason, ask the
  user or write no reason. An incorrect reason is worse than no reason.
- **A decision with a cost.** A limit, a known maximum, or a temporary solution. For a
  temporary solution, give the condition that makes a replacement necessary.
- **The verification.** Write only the checks that you ran.

Do not list each file. `--stat` lists the files. Do not repeat the subject.

## Do not write a claim that you cannot support

This is the most important rule. A commit message is a permanent record. An incorrect
record gives incorrect data to the person who reads it in one year.

- Do not write "tested" or "all tests pass" if you did not run the tests and see the
  result. Name the command that you ran.
- Do not write that a behavior is confirmed if you did not confirm it.
- If the work is incomplete, write this in the body. A commit that shows a limit is better
  than a commit that hides it.

## Trailers

Use the trailers of the repository. If the commits have a `Co-Authored-By:` trailer, keep
it. Put one empty line before the trailers. Write one trailer for each line.

## Then commit

Send the message on stdin. The line breaks stay correct:

```bash
git commit -F - <<'EOF'
The subject line

The body.
EOF
```

A commit is local and reversible. It needs no approval after the user asks for it. A push
is different. A push sends data to other persons. Wait for the user to ask for a push.
