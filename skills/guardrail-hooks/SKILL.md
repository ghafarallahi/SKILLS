---
name: guardrail-hooks
description: Turn a rule the agent keeps breaking into code - a permission rule, a hook, or a check - so code holds it, not memory. Use for "it did it again", "make this impossible", "add a hook", "my hook did not fire", and when an instruction-file rule needs enforcement.
---

# Guardrail hooks

A rule in prose competes with everything else the agent read. At the decisive moment it
can lose. A rule in code runs every time. When a rule matters, and memory keeps failing
it, move it into a code path. This system already does this. The Codex Stop hook and
the record-edit hook hold rules that no prose held.

## 1. Pick the smallest code path that holds the rule

Choose the least machinery that still holds the rule. A permission rule beats a hook.
A refusal inside your own tool beats both, because it holds for every agent and every
person who runs the tool.

| The rule is about | Hold it with |
|---|---|
| A command recognizable by its prefix | A permission rule in settings (`ask` or `deny`). No script to keep. |
| What a command does when its text alone cannot tell | A `PreToolUse` hook that reads the command and the scripts it runs. |
| How callers may use your own tool | A required argument, or a refusal inside the tool. |
| What a commit may contain | A git pre-commit hook in the repository. |
| What must be true before the agent stops | A `Stop` hook, which runs at the end of the turn and returns `decision: "block"` with the reason to send the agent back. |
| What the agent must know at the start | A `SessionStart` hook that returns `additionalContext`. |
| A derived file that must track its source | A `PostToolUse` hook that runs the sync and exits 0. |

State the enforcement and its limit where the rule lives. For example: "a `Bash`
matcher holds the shell. It does not cover an MCP tool or a browser click. The rule
still binds there."

## 2. Write a guard that holds without becoming noise

- Gate only an action that the owner would click for. Asking too often trains a
  reflexive yes, which is worse than no guard.
- Match what runs, not what is mentioned. A heredoc written to a file is inert text:
  cut it before you match a command rule. A heredoc fed to an interpreter runs, and an
  unquoted one expands command substitutions: scan those bodies. Inside code, match the
  call, not a string that a comment quotes.
- Look inside what the command runs. A command-text guard does not see what `python
  cleanup.py` does; open the local script and scan it with the same rules.
- Choose the verdict for the case. `ask` prompts in most cases, including auto mode,
  but some call paths skip the prompt, so read the host's current rules. `deny` or exit
  2 refuses and gives the reason. Exit 2 is the form that Claude Code, Codex, and Cursor
  all honor.
- Never block the way out. A spend limit exempts the command that disarms it.
- Decide which way it fails. By default a hook that crashes or times out lets the
  action through. For a policy hook, fail closed and say so.
- Keep stdout to one JSON object. Other output can make the decision unreadable. What
  an unreadable decision does then depends on the host, the exit code, and the failure
  setting (`onFailure: "block"` can still block). Do not rely on it: set the failure
  behavior on purpose.

## 3. The approval is in the conversation, not on a page

Clear an irreversible or public action only with a message that the owner types, and
that names the action and its specifics. Approval written on a decisions page or a
ticket arrives as a tool result, which the permission check does not read. The verb
alone is not enough: "yes, delete" without the target does not clear a delete of a
named branch.

## 4. Test the guard like a program, before you wire it

A command hook reads JSON on standard input and answers with an exit code and stdout.
Pipe in the payloads that must trigger it and the look-alikes that must not. See
[write-tests](../write-tests/SKILL.md) for proving the trigger can fail. Keep the test
beside the hook, and change its cases when you change the rule.

Start a new blocking hook in observe mode when you can undo the action it stops. It
logs the decision it would make and lets the call through. Log the rule name and the
time, never the command text or the match, because either can carry a secret. Read the
log across a few sessions, correct what misfired, then enforce. A guard on an
irreversible or public action enforces from the first day. A needless prompt costs one
click, and nobody can undo the action it guards.

## 5. The limits of this skill

- A hook is a guardrail, not a sandbox. `PreToolUse` fires on tool calls, not on a file
  the user mentions, and a `Bash` matcher does not cover the same action through another
  tool.
- A guard is still code: it passes the same review and the same test bar as any other
  code in this system.
