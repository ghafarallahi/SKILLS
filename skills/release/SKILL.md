---
name: release
description: Ship a version safely — know what's in it, bump honestly, sequence migrations so rollback stays possible, define abort criteria before deploying, and verify in production afterwards. Use when cutting a release, tagging a version, writing a changelog, planning a migration, or deploying.
---

# Release

Plan the rollback before the rollout. Everything below is downstream of one question: **when
this is wrong, how do we get back?**

Deploying, publishing, and tagging are outward-facing and often irreversible. They wait for
an explicit go-ahead from the person accountable for the system.

## 1. Know what's actually in it

A release is not "whatever's on main". Read it:

```bash
last=$(git describe --tags --abbrev=0)
git log --oneline "$last"..HEAD
git diff "$last"..HEAD --stat
```

Look for what the commit subjects won't tell you: schema changes, config or env additions,
dependency bumps, anything touching auth or money. If something in there surprises you, stop
and understand it — a release is a bad time to meet a change for the first time.

## 2. Bump honestly

A version is a promise about breakage. Derive it from the diff, not from how big it felt:

- **Major** — anything a consumer can trip over: removed or renamed public API, changed
  response shape, dropped CLI flag, stricter validation, changed default, different exit
  code.
- **Minor** — new capability, backward compatible.
- **Patch** — fix with no interface change.

A breaking change in a patch release is a lie your users find out about in production. If
the ecosystem you're publishing to has its own conventions, follow those instead.

## 3. Changelog for the consumer

Written for someone who has to decide whether to upgrade, not from `git log`:

- **Breaking** first — what breaks, and the exact edit they must make.
- Then new, then fixed. Link issues.
- Deprecations with a removal version.
- Say what needs a migration, a config change, or a restart.

"Various improvements and bug fixes" tells a user to read the diff themselves.

## 4. Find the one-way doors

Before anything ships, list what cannot be undone:

- Migrations that drop columns, rewrite rows, or delete data.
- Published artifacts — a version on npm/PyPI/crates is permanent, and a pushed tag is
  effectively public.
- Emails, webhooks, push notifications: sent is sent.
- Data written in a new format that old code can't read.
- Anything third parties cache — DNS, CDN, client bundles in browsers you don't control.

Each one either gets a way back, or gets deliberately accepted with the person who owns that
call.

## 5. Sequence migrations so rollback survives

Never ship a schema change and the code that depends on it in one irreversible step —
because the rollback of that code has to still work against the new schema.

Expand, migrate, contract:

1. **Expand** — add the new column/table, nullable or defaulted. Old code ignores it.
2. **Deploy code** that writes both old and new, reads old.
3. **Backfill** existing rows, in batches, resumable, watching load.
4. **Switch reads** to the new field. This is the step to be nervous about.
5. **Contract** — drop the old column in a *later* release, once the previous version is no
   longer running anywhere.

Steps 1–4 are reversible *in schema* — but the data they touch may not be. A backfill that
overwrites a column, a dual-write that normalizes or truncates, a transform that can't
reconstruct the original: those are one-way doors wearing a reversible-looking step. Write
into new fields rather than over old ones, keep the source value until step 5, and rehearse
the reversal on a restored copy of production data before running it for real.

Step 5 is openly irreversible, which is why it waits for the previous version to be gone
everywhere.

## 6. Build once, promote that exact artifact

Build the artifact one time, and move *that* through staging to production — never rebuild
per environment. A rebuild picks up a different dependency resolution, a different base
image, a different timestamp, and then what you tested is not what shipped.

- Record what it was built from: commit SHA, build inputs, and a digest of the artifact
  itself, so what's running can be traced back to source.
- Deploy by immutable digest rather than a moving tag. `:latest` and re-pointed tags mean
  two environments can run different code under the same name.
- Verify the digest at the point of deployment, and check the signature if your ecosystem
  provides one.

## 7. Define abort criteria before you start

Decide, in advance and in writing: which metric, what threshold, how long you watch, who
calls it. "Error rate above 2% for five minutes → roll back" is a criterion. "Watch and see
how it looks" is a hope.

Name the signal that tells you it worked, and be sure it exists before deploying. If nothing
in your dashboards would change when this feature starts failing, you're deploying blind.

Roll out in the smallest increment the platform allows — canary, percentage, one region —
and let it soak long enough for the slow failures (memory, connection pools, cache misses,
the hourly job) to show up.

## 8. Rollback is a rehearsed command, not a hope

Know before you deploy: the exact command, how long it takes, what data written in the
meantime is lost or orphaned, and whether the previous version can read what this one wrote.
If the answer to that last one is no, you don't have a rollback — you have a forward fix, and
that changes how carefully you proceed.

Feature flags make the fast path: ship dark, turn on, turn off in seconds without a deploy.
Default them off, and delete them once the decision is permanent.

## 9. Verify in production

Check the thing itself — the real endpoint, the real job, the actual user path — not just
that the pods are green. Then watch through the window you defined, not until the deploy
command exits.

Say what you verified and how. "Deployed" is not "working".

## 10. Afterwards

- Tag it, and never re-point a tag or republish a version number. Immutability is the whole
  value.
- Tell the people affected, in the place they read.
- Anything that surprised you goes in the runbook now, while you remember it.

## Don't

- Deploy when nobody who can fix it is available. That's staffing, not superstition.
- Hand-edit production, or hotfix straight to a server without the change landing in the
  repo — the next deploy silently reverts it.
- Bundle an unrelated refactor into a release you may need to bisect.
- Skip the pipeline for "one small change". See [`ci-verify`](../ci-verify/SKILL.md).
