---
name: target
description: Divide a task into small steps. Ask all the questions in one group. Then do all the steps to the end with no interruption. Use for "/target", "go to the end", "run it to the end", "do not stop and ask me", "do the whole thing".
---

# Target

Ask the questions one time. Then do not interrupt the user again.

## 1. Divide the task first

Divide the task into the smallest steps. Each step must have an end and a check. Record the
steps with `TaskCreate`. The user can then see the progress.

- Make each step small. A failure must show you the exact fault.
- Put the blocked steps at the end of the list.
- Divide a step again if you cannot name a check for it. It is two steps.

The division shows you the questions. A bad division gives unclear questions. A good
division gives precise questions.

## 2. Ask all the questions in one group

Read the full list of steps. Collect the unknown items. Ask them in one `AskUserQuestion`
call. The call accepts a maximum of 4 questions.

**Ask only about an item that changes the work.** For all other items, select the usual
option, record the selection, and continue. Do not ask a question that the code answers.
Read the code.

Ask about these items:

- Two designs that you cannot use together.
- A destination that you cannot know: a repository, a branch, or a path.
- The persons who can see the result, and the possible damage.
- A credential or an access permission that you do not have.

Do not ask about these items: a name, a format, a usual library, an item that the
conversation contains, or permission to continue.

## 3. Do the steps to the end

Do the steps in sequence. Do not stop to ask the user. Mark each step with `TaskUpdate`.

If an unexpected condition occurs, make the decision. Record the assumption. Continue.

If a step is blocked, do all the other steps first. Then report the blocked step. Do not
stop the full task for one step.

**Stop for each action that you cannot reverse, and for each action that other persons can
see**, if the user did not approve it before. Examples: a push, a publication, a deletion,
a message, or a payment. The list is not complete. "Go to the end" permits you to stop the
check-ins. It does not permit these actions.

## 4. Verify before you report

Run the checks of the project: the test suite, the linter, or the build. Compare the result
with the request, step by step.

Keep the evidence. Put the command and the result line in the report. Do not report that
the check passed.

## 5. Report one time at the end

- The steps that are complete, the steps that are not complete, and the reasons.
- Each assumption that you made.
- Each item for a subsequent task.

Report a failure with its output. A report of 9 complete steps from 12 is better than an
incorrect report of 12.

## Note

If the codex-review hook is installed, it examines the full task at the end. Expect an occasional rejection at
the last step. Correct the fault. Then complete the task.
