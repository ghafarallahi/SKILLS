---
name: write-docs
description: Write documentation that a reader can use. Run each command before you write it. Give the limits. Update the text in the same commit as the change. Use when you write or update a README, a guide, a reference, a changelog, or a docstring.
---

# Write docs

Incorrect documentation is worse than absent documentation. Absent documentation costs the
reader time. Incorrect documentation costs the reader confidence, then time, then a defect
that the reader did not expect.

## Start where the reader starts

Put the content in the sequence of the tasks of the reader. Do not use the structure of the
code.

1. What is this, and what does it change on my system?
2. The shortest procedure to make it operate.
3. What it does when it operates.
4. What it does not do.
5. The reference data, for a specific question later.

The first screen answers this question: does this help me, and what does it cost? A reader
who continues has already made the decision.

## Run each command that you write

Run each command block before you put it in the document. Use a clean system if the
document says that the system is clean. Put the real output in the document. Do not write
output that looks correct.

There are three exceptions. Do not run a command that destroys data, a command that costs
money, or a command that needs a credential, an administrator permission, or access to a
production system. Mark these commands as unverified. Say what they do.

Command blocks that nobody ran are the largest cause of incorrect documentation. An option
changes, a path exists only on your system, or you do a step from memory and do not write
it.

Give the conditions that the commands need: the versions, the credentials, the platform, or
a service that must operate. A block that operates only on your system looks the same as a
block that operates everywhere.

## Give the limits

The most useful section usually says what the product does not do:

- What occurs when a dependency is absent or a call fails.
- The limits, the timeouts, and the reason for them.
- The data that the product cannot see, and the conditions that it ignores.
- The parts that do not operate, and the parts that do not exist yet.

A reader accepts a limit. A reader does not accept a limit that you knew and did not write.

## Give the reason, not only the operation

The code gives the operation. A document has value when it gives the data that the code
cannot give: the constraint that caused this design, the alternative that you rejected and
the reason for that decision, and the failure that made the control necessary.

## Update the text in the same commit

Documentation becomes incorrect at the moment that the behavior changes. If your change
makes a sentence incorrect, correct the sentence in the same commit. A subsequent pass does
not occur.

When you review a diff, ask which sentence the diff made incorrect.

## Remove

- **Words that sell the product.** "Simple", "just", "easy", "powerful", "seamless". If the task were
  easy, the reader would not read the document. Write `run X`, not `just run X`.
- **A repetition of the signature.** `@param name The name` gives nothing. Give the units,
  the limits, the owner, and the result of a failure.
- **The same explanation in two locations.** One of the two will become incorrect. Write it
  one time. Use a link.
- **Content for a product that does not exist.** Do not document a plan.

## Show, then explain

Use real output, a real command, or a real file structure. Then write one sentence about
its meaning. A paragraph that describes what five lines can show is a paragraph that nobody
reads.

## Before you finish

- You ran each command. Each output is real.
- You can show the code for each sentence.
- A reader with this page and the listed conditions can make the product operate.
