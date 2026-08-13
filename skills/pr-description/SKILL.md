---
name: pr-description
description: Write a pull request description for the reviewer. Give the reason, the location to start reading, the verification, and the work that is not in the request. Use when you open a pull request, write a pull request body, or summarize a branch.
---

# PR description

A commit message explains a change to a person in the future. A pull request description
explains the change to one tired person who must decide today if the change is safe. Write
for that person.

## Read the full branch first

Find the base branch. Do not assume that it is `main`:

```bash
base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
# If this gives no result, ask, or read the name from the remote:
#   git remote show origin | sed -n 's/.*HEAD branch: //p'
git log "$base"..HEAD --oneline
git diff "$base"...HEAD --stat
git diff "$base"...HEAD
```

Use three dots. Three dots compare the branch with the base commit. Two dots compare the
branch with the current state of the base branch, which can contain other changes.

Look for `.github/PULL_REQUEST_TEMPLATE.md`, or the same file in `docs/` or `.gitlab/`. Use
that structure. A team that wrote a template wants the template.

The pull request is the sum of the commits. It usually shows a fact that no single commit
shows.

If the diff contains two unrelated changes, say this and offer to divide the pull request.
This costs you one minute. It saves the reviewer one hour.

## Give the reason first

Write 2 to 4 sentences: the problem, and the difference after the change. Do not give the
implementation. The reviewer reads the implementation in the diff. The reviewer cannot read
the failure that occurred without this change, or the constraint that caused this shape.

If the change corrects a reported defect, give the symptom in the words of the reporter.
Then give the mechanism in your words.

## Give the location to start reading

This is the most useful line in a pull request:

> Start at `parser.go:88`. That is the only change of behavior. The other changes are the
> rename that it made necessary.

A reviewer has limited attention. Use it correctly. Name the part with risk, the part that
you cannot reverse, and the part that you are least sure about. A diff of 600 lines with 20
important lines must say which 20 lines.

## Give the verification

Give the commands that you ran, and the part of the output that has a meaning. Give a
result line, not one thousand lines of a log. Do not give output that contains a token, a
host name, or customer data.

Never give a test that you did not run. See [`write-tests`](../write-tests/SKILL.md).

```
bash hooks/selftest.sh    → 17 passed, 0 failed
```

Give the negative check when you have one: the code that you made incorrect, to show that
the new test finds the defect.

## Give the possible damage

- What fails if this change is incorrect, and who sees the failure first.
- The migrations, the configuration, the environment variables, and the feature flags. Say
  if you can reverse them.
- The method to reverse the change. If a revert is not sufficient, write the method here.

## Give the work that is not in the request

Name the work that you did not do, the subsequent tasks, and the parts that are incomplete.
This stops a reviewer from asking for work that you already decided against. It also stops
the request from becoming larger during the review.

## Remove

- A description of each file. The list of files gives this data.
- A repetition of each commit message. They are one click away.
- "Minor refactor" on a diff of 400 lines, or a description that the diff disagrees with.
- Words that sell the change. The reviewer decides about risk.

## Title

Use the rules of the commit subject: imperative, specific, and no type prefix if the
repository does not use one. See [`commit-message`](../commit-message/SKILL.md).

## Then stop

Write the description and give it to the user. A push, the creation of the pull request,
and a request for a review send data to other persons. Wait for the user to ask.
