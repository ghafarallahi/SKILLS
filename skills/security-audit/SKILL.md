---
name: security-audit
description: Audit code you're authorized to audit — trust boundaries, injection sinks, authorization, secrets, and dependency risk — reporting findings with a concrete attack path instead of a checklist score. Use when reviewing security-sensitive changes, auditing a dependency, or asked "is this safe", "any vulnerabilities here", "check this for security issues".
---

# Security audit

## Scope

This is for code you own or are authorized to audit: your repo, your dependencies, your
employer's systems, a CTF, an engagement you're on. Findings get reported to whoever can fix
them.

It does not cover writing working exploits for third-party systems, testing against
infrastructure you don't control, or evading someone else's defenses. If the target isn't
yours, stop and say so.

## 1. Map the trust boundaries

Everything else is detail. For the code in front of you, answer: **what does an attacker
control, and where does it end up?**

Attacker-controlled: HTTP params, headers, cookies, bodies, uploaded files, filenames, env
vars, CLI args, webhook payloads, third-party API responses, database rows someone else
wrote, and model output — an LLM's reply is untrusted input, not a trusted instruction.

Dangerous destinations: a shell, a SQL/NoSQL query, a filesystem path, a URL you fetch, a
deserializer, a template, a dynamic-code evaluator, a redirect target, a log line that
something else parses.

A finding is a path where the sink is reached in a way that lets the input change its
meaning — a query built by concatenation, a path joined without canonicalizing, HTML written
around unescaped text. What makes a path safe is how the sink is called (a parameterized
query, a structured API, encoding chosen for that context), not the presence of a validation
step somewhere upstream: input validation is defence in depth, and a filter you can describe
is a filter someone can evade.

Trace it concretely — through the actual code, not the diagram.

## 2. Injection is one bug with many names

The rule underneath SQL injection, command injection, XSS, path traversal and SSRF is the
same: **never assemble an interpreted string out of untrusted input.**

- SQL — parameterized queries. Not escaping, not a quoting helper you wrote.
- Shell — pass an argument array to the exec call; don't build a command line, and don't
  enable shell interpretation on attacker-influenced input.
- Paths — resolve to an absolute canonical path, then verify it's inside the intended root.
  `../` in a name is the least creative attack there is.
- HTML — leave the framework's autoescaping on. Every raw-HTML escape hatch (React's
  dangerous inner-HTML prop, Jinja's `|safe`, Vue's `v-html`) is a decision that needs a
  reason and a sanitizer.
- Outbound URLs — allowlist hosts, resolve then check the IP, block link-local and private
  ranges, don't follow redirects blindly.
- Deserialization — never hand untrusted bytes to a language-native binary deserializer
  (Python's, Java's, PHP's, Ruby's). Use a data format that can't instantiate objects.

## 3. Authorization is where real breaches live

Authentication asks *who are you*; authorization asks *may you touch this specific object*.
The second is missed far more often, and it doesn't show up in a scanner.

For each handler: does it check that **this caller** may act on **this id** — not merely that
someone is logged in? Swapping an id in a request is the most common real-world exploit
there is.

Also: deny by default, check on the server (a hidden button is not access control), re-check
on every request rather than trusting a session-cached decision, and make sure the check
can't be skipped by a different route to the same function.

## 4. Business logic is the part scanners can't see

No tool knows what your workflow is supposed to mean, so this is where the expensive bugs
survive. For any multi-step flow — checkout, refund, invite, password reset, plan upgrade —
ask:

- **Can a step be skipped or reordered?** Reaching the confirmation endpoint without the
  payment one, or re-submitting an earlier step after approval.
- **Can it be replayed?** The same coupon, refund, or one-time token used twice. Are tokens
  single-use and expiring, and is the check atomic?
- **Does it race?** Two concurrent requests both passing a balance check before either
  debits. If the invariant is enforced in application code rather than by a constraint or a
  lock, assume it can be broken.
- **Does state escalate across the workflow?** A field that's read-only in the UI but
  accepted by the update handler — `role`, `price`, `tenant_id`, `is_admin` — is privilege
  escalation with extra steps.
- **What happens on partial failure?** Money moved, record not written; a retry that
  double-charges.

## 5. Secrets

Not in source, not in logs, not in URLs or query strings, not in error messages, not in the
commit history.

**If one leaked: rotate first, delete second.** Removing a key from a repo does not un-leak
it — anyone who cloned or scraped it still has a valid credential. Force-pushing history
without rotating is the classic mistake.

Check that credentials come from a secret store or env at runtime, that `.env` and key
material are ignored, and that debug output doesn't print request headers wholesale.

## 6. Dependencies

Run the ecosystem's auditor rather than eyeballing versions:

```bash
npm audit --omit=dev        pip-audit         cargo audit
govulncheck ./...           bundle audit      mvn dependency-check:check
```

Then judge what it prints. An advisory in a code path you never call is noise; a moderate
one in your request handler is not. Say which it is.

- Lockfiles committed and honored in CI (`npm ci`, not `npm install`).
- A new dependency is new attack surface: check the name against the package you meant
  (typosquats), whether it runs install scripts, how many transitive deps it drags in, and
  whether it's maintained.
- Pin what builds you; don't float on `latest` in anything reproducible.

## 7. Crypto, briefly

Don't invent it. Use the platform's library, and check three things: passwords hashed with
argon2/bcrypt/scrypt (never a bare digest), randomness from a cryptographic RNG rather than
the general-purpose one, and secret comparison in constant time. TLS verification stays on —
a disabled cert check in a "temporary" workaround is permanent.

## 8. Report

Same bar as any review finding, plus one more: an attack path.

- `path/to/file:42` — the sink, and the source that reaches it.
- The concrete path: *unauthenticated POST to `/x` with `id=` of another tenant returns
  their record.*
- Severity as **exploitability × blast radius**, not a CVE count. Who can do it — anyone on
  the internet, or an admin already inside?

Verify a finding against a local or test instance only. No CVE-count theater, no "consider
adding validation" without saying what gets through today. If you can argue the mechanism but
can't demonstrate it, label it reasoned rather than reproduced — see
[`review-changes`](../review-changes/SKILL.md).

## Don't

- Paste secrets, tokens, or customer data into any external tool while investigating —
  including a second model.
- Report a scanner's raw output as an audit. Reachability is the work.
- Fix a security bug quietly in an unrelated commit. It needs to be visible to whoever
  decides about disclosure and backports.
