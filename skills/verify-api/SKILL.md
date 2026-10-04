---
name: verify-api
description: Verify an interface against the installed system before you write a call to it. Read the lock file, the installed declarations, or the tool's help output. Do not write a call from memory. Use before you use a library, a framework, a CLI flag, or an HTTP route, and after a dependency update.
---

# Verify the API

Your memory of an interface has no version. The installed system has one. When the two do
not agree, the installed system is correct. Code written from memory of an API is the
most frequent source of a failed build or a wrong call.

## 1. When to verify

Verify before you write the first call to:

- A library or framework function that you did not already use in this session.
- A CLI flag or a subcommand.
- An HTTP route or a response field.
- Any interface, after a dependency update changes its package.

A build that passes is not proof. A dynamic language accepts a call to a function that
does not exist, and fails at run time.

## 2. Where the ground truth is

Read the surface that is installed, in this order. Stop when you have the fact.

1. The lock file gives the exact version: `package-lock.json`, `yarn.lock`,
   `poetry.lock`, `Cargo.lock`.
2. The installed declarations give the symbols. `grep` the symbol in
   `node_modules/<package>/**/*.d.ts`. For Python, run
   `python -c "import m; print(dir(m))"`.
3. The tool gives its own flags: `<tool> --help`, or `<tool> <subcommand> --help`.
4. The documentation for that exact version, when the declarations do not answer.
   Documentation for "latest" describes a version that you possibly do not have.

One `grep` of a declaration file costs less than one failed build and its repair.

A symbol that you cannot find in the installed system does not exist for this project.
Do not call it, and do not import the package that your memory says has it. A model that
invents a package name is a known attack path, not only an error.

## 3. Record the fact with its version

Write the verified fact together with the version that it belongs to. Example:
"expo-router 6.0.8: `dismissTo` exists in `router.d.ts`". A fact without a version is a
rumor. When several tasks need the fact, put it in the project's facts file: the context
pack (see [manager](../manager/SKILL.md)) or the project's `CLAUDE.md`.

Read the facts file before you verify. A stored interface fact is valid while the lock
file still shows the version that the fact names. Check the lock file first: for an
interface fact, the lock file is the defining source, and this check is the source check
that a digest fact requires (see [context-budget](../context-budget/SKILL.md)). When the
version changed, verify the fact again. One verification for each version, not one for
each session.

## 4. The limits of this skill

- Verification shows that a symbol exists, with its signature. It does not show the
  behavior. A test shows the behavior (see [write-tests](../write-tests/SKILL.md)).
- Do not read a full declaration file to find one symbol. `grep` the symbol
  (see [context-budget](../context-budget/SKILL.md)).
- A verified fact ages. After a dependency update, the facts for that package are
  unverified again.
