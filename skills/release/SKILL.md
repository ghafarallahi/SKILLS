---
name: release
description: Release a version safely. Know the content, select the version number correctly, sequence the migrations so that you can reverse them, set the stop conditions before you start, and verify the result in production. Use when you make a release, a tag, a changelog, a migration, or a deployment.
---

# Release

Plan the method to reverse the change before you start. All the steps below follow from one
question: **when this change is incorrect, how do we return to the previous state?**

A deployment, a publication, and a tag send data to other persons, and you frequently cannot
reverse them. Wait for the approval of the person who is responsible for the system.

## 1. Know the content of the release

A release is not the current state of the main branch. Read the content:

```bash
last=$(git describe --tags --abbrev=0)
git log --oneline "$last"..HEAD
git diff "$last"..HEAD --stat
```

Look for the changes that the commit subjects do not give: a change to a schema, a new
configuration value, a new version of a dependency, and each change to the authentication or
to a payment. If a change is unexpected, stop and read it. A release is a bad time to see a
change for the first time.

## 2. Select the version number correctly

A version number is a statement about compatibility. Select it from the diff:

- **Major** — a change that a user of the code can see. Examples: a public interface that
  you removed or renamed; a different shape of a response; a command-line option that you
  removed. Also: a stricter control, a different default value, or a different exit code.
- **Minor** — a new function, and the previous behavior does not change.
- **Patch** — a correction, and no interface changes.

A change that breaks compatibility in a patch release gives incorrect data to your users.
If the ecosystem has different conventions, use those conventions.

## 3. Write the changelog for the user

Write for a person who must decide if they will install the new version:

- Put the changes that break compatibility first. Give the exact edit that the user must
  make.
- Then the new functions. Then the corrections. Give links to the issues.
- Give each item that you will remove — a function, an option, a field, or an endpoint —
  and the version that removes it.
- Say which changes need a migration, a new configuration value, or a restart.

"Various improvements and bug fixes" tells the user to read the diff.

## 4. Find the steps that you cannot reverse

Before the release, list each step that you cannot reverse:

- A migration that removes a column, changes rows, or deletes data.
- A published package. A version on a public registry is permanent, and a pushed tag is
  public.
- Messages: an email, a webhook, or a notification. You cannot recall them.
- Data in a new format that the previous version cannot read.
- Data in the cache of a different system: DNS, a CDN, or a program in a browser.

Give each of these steps a method to reverse it, or accept the risk with the person who is
responsible.

## 5. Sequence the migrations

Never release a change to a schema and the code that needs it in one step that you cannot
reverse. If you must reverse the code, the previous version must operate with the new
schema.

Use this sequence:

1. **Add** the new column or table. Permit a null value or give a default value. The
   previous code ignores it.
2. **Release the code** that writes the previous field and the new field, and reads the
   previous field.
3. **Fill** the existing rows. Use groups of rows. The operation must continue correctly
   after an interruption, and it must give the same result if you run it two times. Watch
   the load.
4. **Change the reads** to the new field. This is the step with the most risk.
5. **Remove** the previous column in a **subsequent** release, when the previous version of
   the code does not operate anywhere.

You can reverse the schema of steps 1 to 4. You cannot always reverse the data. A step that
writes over a column, a write of two fields that changes the format, or a change that
cannot give the previous value: these steps are permanent, and they look reversible. Write
into new fields. Do not write over the previous fields. Keep the previous value until step
5. Do the reverse operation one time on a copy of the production data before you do it on
the production system.

Step 5 is permanent. This is the reason that it waits.

## 6. Build one time, then move the same artifact

Build the artifact one time. Move that artifact from the test system to the production
system. Do not build it again for each system. A second build gets different dependencies, a
different base image, and a different time. The artifact that you tested is then not the
artifact that you released.

- Record the source of the artifact: the commit, the inputs of the build, and a digest of
  the artifact.
- Deploy with the digest. Do not deploy with a tag that can change. `:latest` and a tag that
  a person moved can give two different programs with the same name.
- Verify the digest at the deployment. Verify the signature if the ecosystem has one.

## 7. Set the stop conditions before you start

Decide these items before the deployment, and write them down: the measurement, the limit,
the duration that you watch, and the person who makes the decision. "An error rate above 2%
for five minutes: return to the previous version" is a condition. "We will watch it" is not.

Name the measurement that shows that the release operates. Make sure that this measurement
exists before you start. If no measurement changes when the new function fails, you cannot
see the result of the deployment.

Release to the smallest group that the platform permits: one server, a percentage of the
users, or one region. Wait sufficient time for the slow failures: the memory, the
connections, the cache, and the tasks that run each hour.

## 8. Practice the method to reverse the change

Do the reverse operation one time on a copy of the production data. Know these items before
the deployment: the exact command, the duration, the data that you lose, and if the previous
version can read the data that the new version wrote. If the
previous version cannot read the new data, you have no method to reverse the change. You
have a subsequent correction. Continue with more care.

Feature flags give the fastest method: release the code with the function disabled, enable
it, and disable it in seconds with no deployment. Set the default to disabled. Delete the
flag when the decision is permanent.

## 9. Verify on the production system

Examine the function: the real endpoint, the real task, or the real sequence of a user. Do
not examine only the status of the servers. Then watch for the duration that you selected.
Do not stop when the deployment command stops.

Say what you examined and how. "The release is complete" is not "the function operates".

## 10. After the release

- Make the tag. Never move a tag and never publish a version number a second time.
- Tell the persons who use the system, in the location that they read.
- Write each unexpected event in the procedure document now.

## Do not

- Do not release when no person who can correct a failure is available.
- Do not edit the production system directly. Each correction must go into the repository
  first. If it does not, the next deployment removes it.
- Do not put an unrelated refactor in a release that you can be required to examine
  commit by commit.
- Do not omit the pipeline for a small change. See [`ci-verify`](../ci-verify/SKILL.md).
