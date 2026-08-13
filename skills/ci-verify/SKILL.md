---
name: ci-verify
description: Run the checks that the pipeline runs, before you push. Read the checks from the CI configuration. Run them against the commit that you will push. Divide new failures from failures that exist already. Use before a push or a pull request, when CI fails, or for "will this pass CI".
---

# CI verify

This skill answers two questions. Will the pipeline accept this change? When it did not
accept the change, why?

## Find the checks that control the merge

Do not run the checks that you remember. Read the pipeline:

```bash
ls .github/workflows/ .gitlab-ci.yml .circleci/ Jenkinsfile 2>/dev/null
cat .github/workflows/*.y*ml
```

Then read the files that the pipeline calls: `Makefile`, `justfile`, the scripts in
`package.json`, `composer.json`, `tox.ini`, `noxfile.py`, or `.pre-commit-config.yaml`. The pipeline
configuration is the authority. Your memory and the README are not.

Record which jobs are necessary and which jobs are advisory. Record if there is a matrix. A
result from one version gives no data about the other versions.

## Run the checks in the same way

Use the commands of the pipeline, in the sequence of the pipeline. Do not run `pytest
tests/unit` when the pipeline runs `make check`. The command of the pipeline usually adds
options that change the result, such as `-W error` or a coverage limit.

Run the fast checks first: the format, the linter, and the types. Then the tests. Then the
build. A type error that you find in two seconds must not wait for a suite of eight
minutes. A linter that passes is not a pipeline that passes. Run the full list.

## Test the code that CI will get

CI gets a commit. CI cannot see your working directory. The usual failure is a file that
you did not add to Git. All checks pass on your system, and the pipeline stops because an
import is absent.

Verify the exact commit that you will push, in a separate directory. Do not use `git
stash`. A stash removes the changes that you must verify, and it leaves them in a location
that you can forget:

```bash
git status --porcelain                      # not empty? CI will not have these files
git worktree add /tmp/verify HEAD           # the commit that you will push
cd /tmp/verify && <run the checks>
git worktree remove /tmp/verify
```

If `git status --porcelain` gives output, decide if those files belong in the commit. A
correct result on a directory with changes shows nothing about the push.

Also use the same conditions as the pipeline. Use the language version from the workflow.
Install the dependencies from the lock file into an empty directory. Do not use the
packages that your system installed before. Set the necessary environment variables.

These differences cause most of the failures:

- Old dependencies and a different runtime version.
- A file system that ignores capital letters.
- A different time zone or a different language setting.
- Network access that your system has and the runner does not have.

## Divide new failures from old failures

Before you conclude that your change caused a failure, run the same checks on the base
commit. Use a separate directory again:

```bash
git worktree add /tmp/base "$(git merge-base HEAD origin/HEAD)"
cd /tmp/base && <run the checks>
git worktree remove /tmp/base
```

"This also fails on the base commit" changes your next action. It also saves the reviewer
the same work. Do not correct an old failure inside an unrelated change. The diff then
becomes difficult to review.

## When CI fails and your system passes

Do not run the pipeline again only to see if the result changes. That costs minutes and
gives no data. Run it again after you change something, or to measure a failure that is not
consistent.

Read the full log from the **first** error. Do not read only the last line. The subsequent
errors are usually results of the first error.

Then compare the conditions: the version, the dependencies, the working directory, the
environment variables, the parallel jobs, and the sequence of the tests. The sequence is a
usual cause. CI runs the tests in a different sequence, and this shows shared state that
your system hides.

If the failure is not consistent, the test has a defect. See
[`root-cause`](../root-cause/SKILL.md) for the method to measure a failure rate.

## Make the pipeline pass honestly

A test that you disable, a limit that you reduce, or `continue-on-error` makes the pipeline
green. It does not make the code correct.

If you must disable a check to complete the work, write this in the pull request body. Give
the reason and the condition that permits you to enable it again. A test that nobody
disabled visibly is a test that all persons believe is running.

## Report what you ran

Give the command and the result line. Do not give a claim:

```
make lint     → ok
pytest -q     → 214 passed, 3 skipped
npm run build → built in 12.4s
```

"CI should pass" is not a verification. If you could not run a check, name the check and
the reason. Do not imply a verification that you do not have.
