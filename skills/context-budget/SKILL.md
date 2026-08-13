---
name: context-budget
description: Read the smallest amount of data that answers the question. Search before you read. Do not read a file two times. Use when a task needs many files, when a repository is large, or when the user asks to reduce token use.
---

# Context budget

Context is a budget. Every file that you read stays in the context for the remainder of the
session. You cannot remove it.

The largest cost is not the answer. The largest cost is the data that you read to find the
answer.

## 1. Search before you read

Find the lines first. Then read only those lines.

- Use `grep` or `rg` to find the symbol.
- Use `glob` to find the file.
- Read the file range around the match. Do not read the full file.
- Use a structural tool if the project has one. `smart-explore` shows the structure of a
  file. It does not show the full text.

A full read of a file with 2000 lines costs approximately 25000 tokens. A `grep` for the
same symbol costs approximately 200 tokens.

## 2. Read a slice, not a file

Use `offset` and `limit`. Start with 100 lines around the match.

Read more only when the slice does not answer the question. Two small reads cost less than
one full read of a large file.

Read the full file only in these conditions:

- The file is short. It has fewer than 300 lines.
- You must change many parts of the file.
- The structure of the file is the answer.

## 3. Do not read unchanged data two times

The context keeps the first read. A second read of the same file gives no new data, and it
costs the same number of tokens.

Before you read, ask this question: is this data already in the context?

Read the file again in these conditions:

- You changed the file, or a command changed it.
- Your first read was a small part, and you now need a different part.
- The content is not clear in the context, and a mistake would be expensive.

The same rule applies to commands.

## 4. Limit the output of commands

A command can put many lines in the context. Cut the output at the command.

- Use `head`, `tail`, `wc -l`, or `--stat`.
- Use `git diff --stat` before `git diff`.
- Use `grep -c` when you need only the count.
- Send large output to a file. Then read the part that you need.

Do not print a large file to the terminal. This is a read with more steps.

## 5. Send wide searches to a subagent

A search across many directories can put many files in the context. A subagent reads those
files in a different context. It gives you only the result.

Use a subagent when these conditions are true:

- The search touches more than approximately 10 files.
- You need the conclusion. You do not need the text of the files.

Do not use a subagent for one known file. The subagent costs more than the read.

## 6. Keep the facts, discard the data

After a large read, write down the facts that you must keep:

- The path and the line number.
- The signature or the value.
- The decision that the data supports.

Then continue. Do not go back to the data to confirm a fact that you have.

## 7. Stop when you can act

More context does not make a better decision after you have enough data.

When you can name the change and the file, make the change. Exploration after that point
adds cost. It does not add correctness.

## Do not

- Do not read a directory tree to "understand the project" before a small task.
- Do not read a full directory of tests when the error names one test.
- Do not read a lock file, a build output, or a minified file. Search these files.
- Do not re-derive a fact that the conversation contains.

## Read more when the data tells you to

A small read is not a target. Read more in these conditions:

- The code calls a function that you did not read, and the behavior of that function
  changes your answer.
- You must change a function that other code calls. Read each caller.
- A test and the code disagree.
- You are not sure. Uncertainty is the signal to read more, not to read less.

## The exception

Do not save tokens when you must understand the problem. A wrong change costs more than a
large read.

Read the full flow when the change touches money, security, data loss, or a public
interface. The budget applies to exploration. It does not apply to comprehension.
