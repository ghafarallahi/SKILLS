---
name: manager
description: Manage a project as the coordinator model. Divide the work into small tasks. Send each task to the least expensive model that can do it correctly. Verify each result yourself, then notify the user when the whole is ready for their final test. Use for each project or feature with more than one part, and for "manage this", "delegate this", "act as manager", "build this project".
---

# Manager

The session model is the manager. The user selects it with `/model`. The manager plans the
work, delegates the tasks, verifies the results, and reports. The manager does not write
work that a less expensive model can write correctly.

## 1. Plan the work

Divide the project into small tasks. Use the division rules of [`target`](../target/SKILL.md).
Each task must have:

- One goal that fits in one sentence.
- The files that the task reads and the files that it changes.
- A check that shows the task is complete.

Group the tasks:

- Tasks with no shared files can run in parallel.
- A task that needs the output of a different task waits for it.
- Tasks that change the same file run in sequence, or each gets its own worktree.

Ask the user all the questions in one round, at the start. Include the permission for
multi-agent execution when the platform asks for it.

## 2. Select the model for each task

Send each task to the least expensive model that can do it correctly. The tiers, from the
least expensive to the most expensive:

| Tier | Model | Correct tasks |
|---|---|---|
| small worker | `haiku` | Mechanical work: renames, format changes, boilerplate, running commands and reporting the output, extraction from files. |
| standard worker | `sonnet` | Implementation with judgment inside one area: a feature, its tests, a contained refactor, documentation from a template. |
| manager tier | `opus`, `fable` | Keep these tasks yourself: the plan, the interfaces between the tasks, security-sensitive code, hard debugging, all verification. |

The cost ratios at the time of writing: the small worker costs approximately one tenth of
the manager tier for each token, and the standard worker approximately one third. The
ratios drift; the direction does not.

Selection rules:

- Match the tier to the task type first. Send a task to the smaller tier only when the two
  tiers are equally correct for it. A predictable failure costs more than the larger tier.
- Escalate one tier after a failed verification. After two failures, do the task yourself.
- Do not delegate a decision. Workers implement. The manager decides.
- Set a low effort for mechanical tasks. Effort raises quality and cost together.

## Budget

Set the budget at the plan, before the first worker starts:

- The number of tasks, and the expected total token cost from the tiers you selected.
- A stop threshold. When failures or new tasks push the total to twice the estimate, stop
  and ask the user before you continue.
- When the user gives a token budget, obey it. The Workflow tool, when present, reads it
  directly.

A manager without a budget converts every planning error into cost.

## 3. Brief each worker

A worker starts empty. It does not see this conversation. Each brief must contain:

- The goal, and the check that defines success.
- The exact file paths, and the part of each file that matters.
- The constraints: the style of the codebase, the files that the worker must not touch.
- The output format that you need back.

A brief that omits the check produces work that only looks complete.

## 4. Run the tasks

- For one task, or for a few independent tasks, use the Agent tool with the `model` option.
- For many tasks or a pipeline, use the Workflow tool when the harness has it. Set `model`
  and `effort` for each `agent()` call. Obey the session's workflow size guideline. The
  Workflow tool is plan-gated; not every harness has it.
- When the harness has no Workflow tool, run the plan with the Agent tool alone. Start the
  independent tasks of one group in parallel. Verify them. Then start the next group.
- Run independent tasks in parallel. Do not add a barrier that the work does not need.
- Give workers that change files in parallel the worktree isolation option. Two workers in
  one directory write over each other.
- A worker that returns nothing failed. Treat an empty result as a failed verification.

## 5. Verify every result

A worker's report is data. It is not proof. For each result:

- Run the check that the task defined. Run the tests that the changed code touches. The
  full suite runs one time, at the integration — not after each task.
- Read the diff of what the worker changed. Use the rules of
  [`review-changes`](../review-changes/SKILL.md).
- A result that fails goes back to the worker one time, with the failure attached. Then
  escalate the tier. Then do it yourself.
- Never integrate a result that you did not verify.

## 6. Integrate, then make the final verification

When all tasks are verified one by one, verify the whole:

- Run the full suite, the linter, and the build. Use [`ci-verify`](../ci-verify/SKILL.md)
  before a push.
- Compare the integrated result with the original request, item by item.
- Then get the independent verdict. The codex-review hook examines the result at the end
  when it is installed. When it is not installed, run [`codex-check`](../codex-check/SKILL.md)
  on the integrated diff yourself.
- A rejection goes back into the fix loop of section 5. Deliver only after an approval.

## 7. Notify the user

When the project is complete and verified, tell the user that it is ready for their final
test.

- Send one push notification with the PushNotification tool when it is available. One line:
  what is ready, and what the user must test.
- In the chat, give the report: what was built, the evidence lines (command → result),
  which model did which task, and what was not done with the reason.

Do not notify before the final verification. "The workers finished" is not "the project is
ready".

## Stop conditions

The same rule as [`target`](../target/SKILL.md). Stop for each action that you cannot
reverse, and for each action that other persons can see, unless the user approved it
before. Examples: a push, a publication, a deletion, a message, a payment.

## When not to delegate

Delegation is not free. Each worker reads its context from zero, and the manager pays for
the brief, the verification, and the failures.

- Do not delegate a task that is smaller than its brief. If the instructions are longer
  than the change, do the task yourself.
- Do not delegate when the task needs the full context of the conversation.
- For a small project, the manager alone is less expensive. Delegate when the workers'
  volume of work is larger than the cost of coordinating them.
