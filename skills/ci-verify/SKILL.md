---
name: ci-verify
description: Run the checks the pipeline will run, before pushing — discovered from the CI config rather than guessed, against a clean tree, with pre-existing failures separated from new ones. Use before pushing or opening a PR, when CI is red, or when asked "will this pass CI".
---

# CI verify

Two questions this answers: *will merge accept this*, and *when it didn't, why not*.

## Discover what actually gates merge

Never run the checks you remember. Read the pipeline:

```bash
ls .github/workflows/ .gitlab-ci.yml .circleci/ Jenkinsfile 2>/dev/null
cat .github/workflows/*.y*ml
```

Then the task runners it calls — `Makefile`, `justfile`, `package.json` scripts, `tox.ini`,
`noxfile.py`, `.pre-commit-config.yaml`, `composer.json`. The authority on what must pass is
the pipeline definition, not habit and not the README.

Note which jobs are required versus advisory, and whether there's a matrix — passing on one
version says nothing about the other three.

## Run them the way CI does

In the pipeline's own order, with its own commands. Not `pytest tests/unit` when CI runs
`make check`; the wrapper usually adds flags that change the outcome (`-W error`,
`--frozen-lockfile`, coverage thresholds).

Cheap gates first — format, lint, types — then tests, then build. A type error found in two
seconds shouldn't wait behind an eight-minute suite. But a green lint is not a green
pipeline: finish the list before you call it verified.

## Test what CI will actually see

CI checks out a commit. It cannot see your working directory. The classic failure is a file
that was never `git add`ed: everything passes locally and the pipeline dies on a missing
import.

So verify the exact commit you're about to push, in a tree of its own — never by stashing,
which removes the changes you're trying to verify and leaves them parked somewhere you can
forget them:

```bash
git status --porcelain                      # uncommitted? CI will not have it
git worktree add /tmp/verify HEAD           # the SHA that will land
cd /tmp/verify && <run the checks>
git worktree remove /tmp/verify
```

If `git status --porcelain` isn't empty, decide deliberately whether those files belong in
the commit. A clean local run over a dirty tree proves nothing about the push.

Also reproduce what the environment pins: the language version from the workflow, a clean
dependency install from the lockfile (not your warm `node_modules`), and required env vars.
The usual gaps between "passes here" and "passes there" are stale dependencies, a different
runtime version, a case-insensitive filesystem, locale or timezone, and network access you
have and the runner doesn't.

## Separate new failures from old

Before believing you broke something, run the same checks on the merge base — again in its
own tree, so your working copy is never disturbed:

```bash
git worktree add /tmp/base "$(git merge-base HEAD origin/HEAD)"
cd /tmp/base && <run the checks>
git worktree remove /tmp/base
```

"Fails on main too" changes what you do next — and telling a reviewer that saves them the
same detour. Never fix a pre-existing failure silently inside an unrelated change; it makes
the diff unreviewable.

## When CI fails and local passes

Don't re-run it hoping. That's a coin flip you pay for in minutes.

Read the full log from the **first** error, not the last line — later errors are usually
consequences. Then compare environments: version, dependency resolution, working directory,
env vars, parallelism, ordering. Test ordering is a common one — CI's shuffle or sharding
exposes shared state your local sequential run hides.

If it's genuinely flaky, that's a bug in the test, not weather. See
[`root-cause`](../root-cause/SKILL.md) for measuring a failure rate rather than wishing at
it.

## Going green honestly

Skipping a test, loosening a threshold, or adding `continue-on-error` makes the badge green
without making the code correct. If a check has to be disabled to land, say so in the PR body
in plain words, with why and what re-enables it. A silently skipped test is a test everyone
believes is running.

## Report what ran

Command and result line, nothing invented:

```
make lint     → ok
pytest -q     → 214 passed, 3 skipped
npm run build → built in 12.4s
```

"CI should pass" is not a verification. If you couldn't run something — no credentials, no
Docker, a job that only runs on the runner — say which and why, rather than implying
coverage you don't have.
