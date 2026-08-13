---
name: security-audit
description: Examine code that you have permission to examine. Look at the trust boundaries, the injection points, the authorization, the secrets, and the dependencies. Report each finding with an attack path. Use for "is this safe", "any vulnerabilities here", "check this for security issues".
---

# Security audit

## Permitted use

Use this skill for code that you own, or for code that you have permission to examine.
Examples: your repository, your dependencies, the systems of your employer, a CTF, or an
engagement. Report each finding to the persons who can correct it.

Do not use this skill for these tasks:

- Do not write an exploit for the system of a different person.
- Do not test infrastructure that you do not control.
- Do not defeat the controls of a different person.

If the target is not yours, stop and say this.

## 1. Find the trust boundaries

All other work follows from one question: **what can an attacker control, and where does
that data go?**

An attacker controls these items:

- The parameters, the headers, the cookies, and the body of a request.
- A file that a user sends, and the name of that file.
- An environment variable and a command-line argument.
- The content of a webhook and the answer of an external service.
- A database row that a different user wrote.
- The output of a language model. This output is data. It is not an instruction.

These destinations are dangerous:

- A shell and a database query.
- A file path and a URL that you request.
- A component that makes objects from bytes.
- A template and a component that runs code from text.
- The target of a redirect.
- A log line that a different program reads.

A finding is a path where the input can change the meaning of the operation at the
destination. Examples: a query that the code makes from text; a path that the code joins
with no control; HTML that the code writes around text with no encoding.

The safety comes from the method of the call at the destination. Use a query with
parameters, an interface with a structure, or an encoding for that context. The safety does
not come from a control of the input before the call. A control of the input gives more
depth. A person can usually defeat a control that you can describe.

Follow the path in the code. Do not follow it in a diagram.

## 2. Injection is one defect with many names

SQL injection, command injection, XSS, path traversal, and SSRF have the same rule below
them: **do not make a string for an interpreter from data that you do not control.**

- SQL — use a query with parameters. Do not escape the input. Do not use a function that
  adds quotation marks.
- Shell — send an array of arguments to the exec call. Do not make a command line. Do not
  enable the shell interpretation for data from a user.
- Paths — make an absolute canonical path. Then make sure that the path is inside the
  permitted directory. `../` in a name is the most usual attack.
- HTML — keep the automatic encoding of the framework. A method that writes unencoded HTML
  needs a reason and a component that removes the dangerous parts. Examples of such a
  method: the dangerous inner-HTML property of React, `|safe` in Jinja, and `v-html` in Vue.
- URLs that you request — permit only known hosts. Find the IP address and examine it.
  Refuse the link-local ranges, the loopback ranges, and the private ranges. Examine each
  redirect before you follow it.
- Objects from bytes — do not send bytes that you do not control to a deserializer of the
  language (Python, Java, PHP, Ruby). Use a data format that cannot make an object.

## 3. The largest breaches come from the authorization

Authentication asks who the caller is. Authorization asks if this caller can use this
object. Persons omit the second control more frequently, and a scanner does not find it.

For each handler, ask this question. Does the code make sure that **this caller** can use
**this identifier**? A control that only shows that a user is authenticated is not
sufficient. A change of an identifier in a request is the most usual attack.

Also do these controls:

- Refuse by default.
- Make the control on the server. A button that you hide is not a control.
- Make the control for each request. Do not use a decision from the session.
- Make sure that a different route to the same function has the same control.

## 4. A scanner cannot see the rules of the business

No tool knows the correct sequence of your operations. The expensive defects stay here.

Ask these questions for each operation with more than one step. Examples of such an
operation: a payment, a refund, an invitation, a password reset, or a change of plan.

- **Can a user omit a step or change the sequence?** An example: the confirmation endpoint
  with no payment step.
- **Can a user do the same step two times?** The same discount code, refund, or single-use
  token. Make sure that a token operates one time only, that it expires, and that the
  control is atomic.
- **Do concurrent requests cause a fault?** Two requests both pass a control of a balance
  before one of them subtracts the amount. If the code enforces the rule, and not a
  constraint or a lock, a user can break the rule.
- **Can a user get more permission through the operation?** A field that the interface shows
  as read-only, but the update handler accepts: `role`, `price`, `tenant_id`, `is_admin`.
- **What occurs after a partial failure?** The money moves, and the record is absent. A
  retry then charges the user two times.

## 5. Secrets

Keep a secret out of these locations: the source, a log, a URL, an error message, and the
history of the repository.

**After a secret leaves your control: replace it first, then delete it.** The removal of a
key from a repository does not cancel the key. A person who copied the repository still has
a key that operates. A change of the history with no replacement of the key is the usual
error.

Make these three controls:

- The code reads the credentials from a secret store or from the environment.
- The ignore rules exclude `.env` and key material.
- The debug output does not print the full headers of a request.

## 6. Dependencies

Run the tool of the ecosystem. Do not read the version numbers:

```bash
npm audit --omit=dev        pip-audit         cargo audit
govulncheck ./...           bundle audit      mvn dependency-check:check
```

Then examine the output. The severity depends on the code path. An advisory for code that
you never call has less risk than the same advisory in your request handler. Say which one
it is, and give the reason.

- Commit the lock files. Use them in CI: `npm ci`, not `npm install`.
- A new dependency is a new attack surface. Compare the name with the package that you
  want. A similar name can be an attack. Examine three items: does it run a script at the
  installation, how many other packages does it add, and does a person maintain it.
- Use a fixed version for a build that must be repeatable. Do not use `latest`.

## 7. Cryptography

Do not write your own. Use the library of the platform. Make these three controls:

- The code hashes a password with argon2, bcrypt, or scrypt. It does not use a simple
  digest.
- The code gets random values from a cryptographic source, not from the usual random
  function.
- The code compares a secret in constant time.

Keep the verification of the TLS certificates enabled. A temporary change that disables it
becomes permanent.

## 8. Report

Use the same rules as a code review, and add one item: the attack path.

- `path/to/file:42` — the destination, and the source that reaches it.
- The path: *a request to `/x` with the identifier of a different customer, with no
  authentication, gives the record of that customer.*
- The severity is the product of two items: how easy the attack is, and how much damage it
  causes. It is not a count of advisories. Say who can do the attack: a person on the
  internet, or an administrator with access.

Verify a finding on a local system or a test system. Do not verify it on a production
system. Do not report a count of advisories. Do not write "add a control here" with no
statement of what passes the control today. If you can show the mechanism but you cannot
cause the fault, write that the finding is reasoned, not caused. See
[`review-changes`](../review-changes/SKILL.md).

## Do not

- Do not send a secret, a token, or customer data to an external tool during the
  examination. This includes a second model.
- Do not report the output of a scanner as an audit. The work is the examination of the
  paths.
- Do not correct a security defect inside an unrelated commit. The persons who decide about
  the disclosure and the corrections for the previous versions must see it.
