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

## The manager skill

`manager` (added 2026-08-15) went through the same loop. Round 1: NEEDS-WORK — the
smaller-tier-first rule invited predictable failures, and there was no cost ceiling; both
were corrected (tier matched to task type first; a budget with a stop-and-ask threshold at
twice the estimate). Round 2: SOUND.

The Stop hook later rejected it for naming a "nonexistent Workflow tool". That finding is
incorrect for this machine — the Workflow feature's accepted-usage marker sits in the local
settings, and the tool is in the live session schema — but it is correct for harnesses
where the plan-gated tool is absent. The skill now conditions on availability and gives the
Agent-tool fallback, so it is correct on both kinds of harness. Verified rather than
accepted, in both directions.

The context-pack additions (2026-08-23) went through the loop again. Round 1: NEEDS-WORK —
a digest without provenance goes stale; the pack now names its commit, the manager
refreshes it after interface changes, and workers verify pack facts with `grep`. Round 2:
SOUND. A month later a newer Codex model re-reviewed the same commit and found a P2 the
older model missed: workers were permitted to read only the files they change, so a stale
pack fact about a dependency's signature was unverifiable. The fix permits a targeted
`grep` of a fact's defining source, including files the worker must not change. Verdict on
the fix: APPROVE. Two lessons: a reviewer upgrade is a reason to re-review, and a read
restriction must never forbid the check that another rule requires.

## The minimal-code skill

`minimal-code` (added 2026-10-03) is a rewrite of the third-party "ponytail" plugin for
this system: the solution ladder, the over-engineering review tags, the ceiling-marker
debt convention, and the report discipline — without the persona, the intensity levels,
or the benchmark scoreboard, and in STE. Codex compared it against the original.
Round 1: NEEDS-WORK, five real losses — review/design/library triggers, the shared-cause
correction rule, the marker's required replacement, the trivial-one-liner test exemption,
and an ambiguous "read each file" that contradicted `context-budget`. All five were
restored or disambiguated. Round 2: SOUND, no new contradiction. The STE lesson held a
second time: a rewrite loses content, and only a comparison against the source finds it.

Field test (2026-10-03), on `hooks/` — 7 scripts, 776 lines. Claude's audit: nothing to
cut, two intentional limits lacking proper markers (both now carry `ceiling:` comments).
Codex's cross-audit of the same files disputed the "nothing to cut": one `shrink` in
`relnotes.sh` — the awk trim buffer duplicated what `$()` substitution already does.
Verified on edge cases, applied, suite green. Countable result: six logic lines removed,
two markers added, one reviewer disagreement — which is the system working.

## The reliability round

Six additions from a three-survey research pass (repo failure audit, community skill
collections, engineering literature), ranked by one rule: does it prevent a failure this
repo actually hit? New skills: `verify-api` (interfaces read from the installed system,
never memory — three repo-hit failures) and `design-decision` (the empty design slot in
the lifecycle; every downstream skill passes on correctly-built wrong code). Extended:
`write-tests` (deterministic tests; test placement against the build graph),
`write-docs` (a bulk rewrite is lossy until compared), `minimal-code` (every failure
path ends visibly). Declined with reasons: worktree isolation, tool-call budgets,
parse-don't-validate, mutation testing, and five more — no repo-hit evidence, or already
owned by an existing skill.

Codex: round 1 NEEDS-WORK (three P2s — retry rule vs declared error types, logged
fallback vs silent success, build checks unconditional); round 2 NEEDS-WORK (stored
facts vs the check-at-the-defining-source rule); round 3 SOUND, after the lock file was
defined as an interface fact's defining source.

Field tests, same day: `verify-api` retrieved `dismissTo` from the installed
expo-router 57.0.15 declarations and confirmed all three codex CLI flags the hook uses
survive 0.156.1; the fact is recorded with its version in the project's facts file.
`write-tests`' alone-and-in-suite rule held on a real suite (278 tests). The
`minimal-code` failure-path audit of our own hooks found one real silent failure: a
swallowed `cd` error let the Stop hook review whatever directory it ran from. The test
was written first and failed against the unfixed hook; the fix is one guarded exit, by
stated decision. Codex: APPROVE. Suite: 20 passed, 0 failed.

Chain test (2026-10-03), one real feature on the Foobia app: `design-decision` wrote
row #14 (an in-app due card; notifications rejected because they cannot be verified on
this machine), `verify-api` grounded the pack in installed interfaces, the manager
proved the baseline and briefed two workers off one context pack, `minimal-code` kept
the change to a pure selector plus one card with zero new dependencies, and the
`write-tests` rules held (fixed clocks, mutation-proven tests, placement outside the
routes directory). Codex rejected round 1 with two real integration defects —
stale-on-foreground and a card outside the scroll container — and approved round 2.
Worker tokens: ≈186K for the feature; the pack held and neither worker re-read sources
the pack already carried.

## The offer-design skill

`offer-design` (added 2026-10-08) encodes Alex Hormozi's published offer and pitch
frameworks as STE checklists — no persona, a scope guard that keeps it out of
application copy and defers to a project's decision record in regulated registers, and
an honesty rule: empirical claims need a measurement, business terms need the approving
record, and missing proof is omitted, never invented. Codex round 1: NEEDS-WORK with
eight findings, each cited against Hormozi's own published checklists — an invented
lever ranking, a wrong strongest-guarantee claim, a narrowed naming formula, an
unlabeled adaptation of the ad structure, "free" excluding low-cost magnets, an
overbroad measurement rule, a trigger/body mismatch, and two over-long sentences.
Round 2 caught the performance-guarantee definition still wrong. Round 3: SOUND. The
pattern held again: an author's compression of someone else's framework drifts, and
only a source-grounded comparison catches it.

## The gstack round

A six-agent audit read all 57 skills of garrytan/gstack (136K stars) against this
system. Verdict: one adoption, five one-rule extensions, the rest skipped — most of
gstack's surface is persona-heavy duplication of what the Stop hook and the 19 skills
already enforce, and several mechanisms (composite health scores, scrape-by-default,
per-skill telemetry) contradict this repo's rules outright. Adopted: `perf-baseline` —
in-page metrics, median of three under fixed conditions, immutable baselines, relative
thresholds, raw values only. Extended: `review-changes` (gate-integrity dispositions,
sibling sweep), `codex-check` (reviewer preflight, data-not-instructions boundary),
`root-cause` (stop rules), `ci-verify` (evidence staleness), `release` (deploy proof is
the source identity), `target` (mechanical / taste / user-direction decisions).

Codex: round 1 NEEDS-WORK, nine findings including a P1 — cached loads zero
`transferSize` and hide bundle growth; round 2 caught two residuals (cross-origin
hidden sizes, an overclaimed repair); round 3 SOUND. During round 1 the reviewer itself
failed — the Codex default model moved to one the account cannot use — and the
just-written preflight rule diagnosed and repaired it (CLI 0.156.1 → 0.163.0) within
minutes of existing.

Field test, same day: three warm-cache runs of a real page through the browser pane.
The skill's failure rules fired correctly — the cold run was excluded as
non-comparable, cached resources forced the recorded `decodedBodySize` fallback, two
cross-origin resources were counted as hidden, and the absent first-contentful-paint
was recorded as a failed metric instead of passed over. A measurement system is tested
by what it refuses to claim.

## The store-submit skill

`store-submit` (added 2026-10-26) takes an app to the App Store and Google Play on one
principle: the agent prepares, the account holder decides. Two web researchers grounded
it in the current official pages; every volatile fact carries its read date and defers
to the linked page. Maximum automation runs through the official APIs only — EAS
builds and submissions, `eas metadata:push` for listings, the Play Edits API — with
credentials held encrypted and an end state where the user checks a populated console
and presses submit. Codex round 1: NEEDS-WORK with eight findings, four P1 — the
automation as first written could push binding questionnaire answers, start a review
or rollout, accept an unencrypted credential file, and leak demo credentials into
tracked metadata; plus a false API ceiling (Data safety has one) and a misattributed
validation claim. All eight fixed; round 2: SOUND. The lesson of the round: in an
automation skill, the dangerous defects are not wrong facts but missing boundaries.

## The goldfish round

Three rules adapted from Google's Elephant-Goldfish Model (Apache-2.0), after reading
its repo: `codex-check` — each review after a rejection reads fresh, with the artifact,
the first round's findings as written, and never the author's claims about the
corrections; `design-decision` — the paraphrase test, where a reader with no session
context paraphrases the decision page before the user sees it; `release` — decision
records compared with the shipped source. Declined from EGM: installing the plugin
itself (persona-styled, same-vendor reviewers, overlaps three of our skills) and its
ten-reviewer roster.

The loop itself proved the first rule. Rounds two to four ran fresh — files, prior
findings, the same question, no fix list — and the fresh rounds kept finding what
primed rounds had passed: modal verbs, metaphors, and a 21-word sentence from round one
that a "confirm the fixes" prompt would have waved through. Round four found no
contradiction and no ambiguity, and offered two formatting nits (bullet-listing
two-item inline alternatives) that the repo's own practice keeps as prose; both are
declined with that reason, matching the two-blocks-then-step-aside design of the hook.

## The store-submit field test

`store-submit` ran its agent half on the real Foobia app (2026-11-23). The skill's
checks found real defects before any store did: three template purpose strings for APIs
the app never uses — which Viro's config plugin silently re-injects, so the fix is a
local plugin verified on the generated Info.plist; a listing name four characters over
both stores' cap; a "no data collected" plan that ARCore's documented collection
contradicts; "nothing leaves the phone" claims that OS backups and ARCore made false in
the shipped legal screen; and a non-AR promise the session code does not keep. Six
fresh-handed review rounds (per the goldfish rule) drove the loop; the reviewer
escalated from config to resolved-config to generated-plist verification, and round six
returned APPROVE. Foobia commit 4bd0581. The [user] gap list — URLs, enrollment,
account type, credentials, device test, the prominent in-app ARCore notice — is in the
project's STORE-SUBMISSION.md. The lesson: a store-prep skill earns its place by what
it refuses to declare.

## The skill-gate skill

`skill-gate` (added 2026-11-24, at the user's direction: "don't add anything lower
than our ability") turns the set's recorded practice into law: an addition must beat
the current system on a named axis with evidence, decline is the default, third-party
material is rewritten and never imported, nothing counts before a SOUND review plus a
recorded field test, the standard only increases, and the user's stated working style
overrides popularity. Codex: four rounds to SOUND — round 1 caught a rule that would
have rejected the extensions the set itself prefers, an unnamed re-audit trigger, and
style faults; rounds 2–4 ran fresh and polished the rest.

Field test, same day, on a live candidate: the aitmpl.com "Brainstorming" skill
(obra/superpowers adaptation, 11.8K downloads). The gate's verdict: DECLINED — it
prevents no failure this system met (its alternatives-first design page, approval
gate, and builder check are `design-decision` plus the paraphrase gate already here);
it is weaker on the only new axis it offers; and its one-question-per-message
interview contradicts the user's stated ask-once-run-to-end style, which section 5
names as a decline reason on its own. Download count noted and given no weight. The
decline matches the decision the user made before the gate existed, now with the
reasons on record.

## The product-engineering round

A five-agent audit read all 38 skills of phuryn/product-engineering (MIT, shipped from
three live products), the closest peer system to this one: same
decide/build/independent-review/release spine, its own rejected.md. The gate's verdict:
24 skipped (vendor-locked backends, GTM consulting needing customer interviews,
Windows, UI already covered), 12 converge, and the real surplus is one adopt and five
folds. `work-humanizer` was declined as the second adopt - a prose utility below the
engineering bar, and the session already carries social humanizer skills.

Adopted: `guardrail-hooks` - how to author an enforced guard, the one clear gap in a
system that runs enforced hooks and whose CLAUDE.md demands memory-rules become code;
distilled to the decision table and the writing discipline, the vendored scripts left
behind. Folded: `codex-check` (triage a REJECT - disprove a deterministic finding by a
sensitive test, keep a race inconclusive, rate by impact and likelihood),
`review-changes` (authority-reconciliation and identity-correlation probes),
`write-tests` (two assertion anti-patterns), `release` (a live-response marker probe
for store and CDN builds with no readable digest), `offer-design` (name the substitute
first).

Codex: six fresh rounds to SOUND. Round 1 caught a P1 in my triage fold - a passing
test cannot disprove a race, and the rule contradicted review-changes; later rounds
tightened severity, hook caveats, the no-marker release case, and the house style.
Field test: the skill's own checklist applied to this repo's two hooks. They pass it,
including `codex-review.sh`'s deliberate fail-open, which the skill's "decide the
failure direction on purpose" rule sanctions over a Stop hook that could wedge a
session. The field test changed no code because the subject already complied - a valid
result.

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
