# Codex review of the skills

Every skill in `skills/` was submitted to Codex (`gpt-5.6-sol` via `codex exec`) for an
independent verdict, revised against the findings, and resubmitted. This records what it
found, what changed, and what was declined — including where Codex was wrong.

Reproduce a single verdict with:

```bash
codex exec --skip-git-repo-check "Read $PWD/skills/<name>/SKILL.md. It is a workflow skill
for an AI coding agent. Judge it hard on three things: (1) would following it measurably
improve the code or the process, (2) is any instruction wrong, harmful, vague, or
unfalsifiable, (3) what single thing is missing that would matter most. End with exactly one
line: SKILL_VERDICT: SOUND or SKILL_VERDICT: NEEDS-WORK"
```

## Result

| Skill | Round 1 | Round 2 | Round 3 |
|---|---|---|---|
| `commit-message` | NEEDS-WORK | **SOUND** | — |
| `review-changes` | NEEDS-WORK | **SOUND** | — |
| `pr-description` | NEEDS-WORK | NEEDS-WORK | **SOUND** |
| `write-docs` | NEEDS-WORK | NEEDS-WORK | **SOUND** |
| `target` | NEEDS-WORK | NEEDS-WORK | held |
| `root-cause` | NEEDS-WORK | NEEDS-WORK | held |
| `refactor` | NEEDS-WORK | NEEDS-WORK | held |
| `write-tests` | NEEDS-WORK | held | — |
| `codex-check` | NEEDS-WORK | contested | — |

**On round 1 being 9/9 NEEDS-WORK:** the prompt asked "what single thing is missing", and
any missing thing forces the negative verdict. A unanimous first round says more about the
question than about the skills. The findings inside it were still worth having.

## What changed

- `codex-check` — a redaction rule (`.env`, key material, tokens, customer data never leave
  the machine) and a requirement to send test results alongside the diff.
- `commit-message` — don't invent a rationale; if the why isn't in the history, ask or omit.
- `pr-description` — discover the base branch instead of assuming `main`; use the repo's PR
  template if it has one; keep secrets out of pasted output.
- `review-changes` — a defect you can argue mechanically but not reproduce (a race, a TOCTOU
  window) is reportable as *reasoned rather than reproduced*; separate what the diff broke
  from what was already red.
- `refactor` — behavior means everything observable from outside, including API
  compatibility and performance; removing a public export is a behavior change, not a
  deletion.
- `root-cause` — a flaky bug gets measured, not wished away: same trial count before and
  after, quoted as a fraction.
- `target` — verification before reporting, with the command and its result line kept as
  evidence.
- `write-docs` — three exceptions to "run every command" (destructive, credentialed,
  privileged), and state the prerequisites.
- `write-tests` — revert the fix *reversibly* (stash, worktree, copy) rather than hand-editing
  the live file; baseline the full suite so a new green isn't hiding three new reds.

## Declined, with reasons

- **"Fail-first testing and deliberate code-breaking are overbroad"** (`write-tests`). That
  rule is the skill. It's now reversible, which was the legitimate half of the objection.
- **"Rule of three is too absolute"** (`refactor`), **"harmful absolutes"** (`root-cause`),
  **"smallest possible steps"** (`target`). These are deliberately sharp heuristics. Hedging
  every rule into "consider possibly" produces a document that can't be followed or
  violated, which is worse than one that's occasionally too strict.
- **"Platform-specific tool names"** (`target`). `TaskCreate` and `AskUserQuestion` are the
  actual tools in this harness. Naming them is correct here.
- **`codex-check` "still lacks redaction guidance and test-result requirements."** Both were
  added before that round; the file contains them at lines 39 and 43. Verified rather than
  accepted — which is what `review-changes` asks of any finding.

## Gaps Codex identified in the set

1. **CI/build verification** — tests, lint, type checks and build in a reproducible
   environment before merge. *Since added: [`ci-verify`](skills/ci-verify/SKILL.md), SOUND on
   the second round — its first draft told you to `git stash -u` before running checks, which
   would have verified the base instead of the candidate.*
2. **Security and dependency auditing** — vulnerabilities, exposed secrets, supply-chain
   risk. *Since added: [`security-audit`](skills/security-audit/SKILL.md), SOUND on the second
   round — Codex corrected "any unvalidated path is a finding" (safety comes from how the
   sink is called, not from an upstream filter) and supplied the business-logic abuse
   section the first draft lacked entirely.*
3. **Release and deployment** — versioning, changelogs, migrations, rollout and rollback.
   *Since added: [`release`](skills/release/SKILL.md), SOUND on the second round — Codex
   caught that "steps 1–4 are individually reversible" overclaims (a backfill that overwrites
   is a one-way door in reversible clothing) and supplied build-once/promote-the-same-digest,
   which the draft omitted.*

All three gaps are now closed. Each new skill went through the same loop: draft → Codex
verdict → revision → confirmation. All three were NEEDS-WORK on the first pass, and in every
case the finding was a real defect rather than a matter of taste — an unsafe `git stash`,
a wrong claim about what makes a sink safe, and an overstated reversibility guarantee.

## The rewrite into Simplified Technical English

All 14 skill files were rewritten in ASD-STE100. Codex compared each file against its
previous version and answered one question: did the rewrite lose an instruction?

The first pass lost content in **12 of 13** files. The losses were real, not stylistic:

- `security-audit` — "do not escape the input" for SQL; the link-local ranges; the persons
  who decide about the corrections for previous versions.
- `target` — the stop rule became five examples instead of a rule about every action that
  you cannot reverse.
- `release` — the rehearsal of the reverse operation on a copy of the production data.
- `codex-check` — the trigger for `/codex-check`; the request in the words of the user.
- `write-tests`, `refactor`, `ci-verify`, `code-comments`, `write-docs`, `commit-message`,
  `root-cause`, `review-changes` — one or two instructions each.

Two rounds of correction put these back. A third comparison gave only differences of one
word, such as "recursion" for "reentrancy". Those were corrected, and the loop stopped.

**The lesson: a rewrite into a controlled language is lossy. A comparison against the
previous version is not optional.**

Asked which existing skill is most valuable, it named `target`: "disciplined scoping and
end-to-end execution make every specialized skill more effective."
