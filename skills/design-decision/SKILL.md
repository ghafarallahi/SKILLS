---
name: design-decision
description: Before code with a structural choice, write the decision - the alternatives, the trade-offs, and the constraint that decides. Surface it to the user before you code. Use before a new feature, a new integration, a new library, a new data model, or a new protocol, and for "which approach", "how should we build this".
---

# Design decision

Every skill after this one verifies the code. None of them verifies the choice. Tests,
review, and an independent reviewer all pass on correct code that builds the wrong thing.
The most expensive failure is a correct implementation of the wrong design.

## 1. When a decision is required

A structural choice requires a written decision before the first line of code:

- A data model or a storage format.
- A library, a framework, or a new dependency.
- A protocol, an API shape, or an integration channel.
- A test strategy for a new kind of code.

A one-file correction with no structural choice does not need this. Start the work.

## 2. Question the frame one time

A task that arrives as an implementation - "write a crawler", "build a webhook", "add
custom auth" - names a tactic, not a goal. Ask one time: what is the goal, and is this
tactic the best path to it? Then continue. Do not argue two times.

## 3. Inventory before invention

For an external-data integration, list the sanctioned channels before you write any
collection code:

1. The official API, with its tier requirements and its price.
2. The vendor's data export, including a legal data-portability request.
3. Schema introspection, when the vendor left it on.
4. Collection through the user's own session, when no channel above serves every
   customer of the product.

The correct channel is the one that works for every customer in the target market, not
the most sanctioned one. Record which channels you examined, so the choice is a decision
and not an assumption.

## 4. Write the decision

One page or less, before the code:

- The goal, in one sentence.
- Two or three alternatives. For each rejected one, one reason.
- The constraint that decides: tier access, scale, team skill, time. A preference is
  not a constraint.
- The selected path, and the first thing that breaks it.

## 5. Surface it, then wait

Show the decision to the user before you code. Wait for agreement, unless the user gave
standing permission for this kind of choice. A user cannot push back on a decision that
nobody surfaced. Thirty minutes of investigation costs less than one week of code in the
wrong direction.

## 6. The limits of this skill

- This skill ends when the decision is agreed. The implementation belongs to the other
  skills, [minimal-code](../minimal-code/SKILL.md) first.
- A decision ages like a digest. When a constraint changes, the decision is open again.
- Do not use this skill to delay. One page, two or three alternatives, one pass.
