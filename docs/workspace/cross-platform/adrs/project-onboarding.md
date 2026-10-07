---
status: accepted
---
# Project onboarding instead of language files

Addresses: [FR3](../DESIGN.md#fr3), [FR7](../DESIGN.md#fr7)

## Problem

`software-engineer` ships two language references, [rust.md](../../../../skills/software-engineer/rust.md)
and [dotnet.md](../../../../skills/software-engineer/dotnet.md). One embeds a single
machine's toolchain paths and host-specific binaries, so it fails everywhere else.
Adding one file per popular language was planned, then judged too complex: many files
to keep short, current, and shell-neutral, plus a support list to maintain. What the
agent needs is not a table of commands per language but a way to onboard on any
existing project and derive its commands from the project itself.

## Options

| Option | Pros | Cons |
|---|---|---|
| A. One file per popular language | Explicit support list. | Many files, stale commands, framework and version drift, a list users read as a promise. |
| B. No language files; one onboarding reference that tells the agent how to read a project and its host | Nothing language-specific to maintain. Works for any project that already builds. Commands come from the project's own sources of truth. | More reading per task; no printed support list. |
| C. Keep the two existing files, fix paths | Small change. | Still one machine's setup; no answer for other projects. |

## Decision

Option B. The two language files are deleted. A new reference
[onboarding.md](../../../../skills/software-engineer/onboarding.md) owns project
discovery and the shell rules; [software-engineer/SKILL.md](../../../../skills/software-engineer/SKILL.md)
replaces its `## Stack` table with a short `## Onboarding` section that links it and
makes it the first step of every task on a project the agent has not analysed in the
session.

**Onboarding checklist** (the reference file, in this order, each item with the files
to read and what to extract):

1. **Host**: operating system, shell in use, architecture. Decides which command forms
   apply and whether the project's toolchain can run here at all.
2. **Project stack**: languages, frameworks, runtime versions. Sources: marker files
   at the repo root and in subprojects, version pin files, manifest files, README.
3. **Target platform**: where the software runs (operating systems, architectures,
   containers, cloud or device targets). Sources: build configuration, container
   files, deployment descriptors, CI matrix. Decides which variants matter and which
   tests can run locally.
4. **Package manager and build system**: from lock files and committed wrappers or
   runners. Exactly one manager is chosen; never recommend switching.
5. **CI pipeline**: read the pipeline definition first. It is the authoritative list of
   build, test, lint, format, and coverage commands, their order, the environment
   variables and services they need, and the matrix of platforms the project claims to
   support. Reproduce those commands locally in the same order.
6. **Repository conventions**: Makefile or justfile targets, project CLAUDE.md,
   CONTRIBUTING, editor configuration, pre-commit configuration. These override tool
   defaults.
7. **Test and coverage tooling**: framework, runner, coverage reporter, where reports
   land. Prefer the machine-readable format the toolchain already emits.
8. **Variant selection**: when one language has several runtimes, toolchain
   generations, or frameworks, decide from the project files which one applies, then
   check the host can run it. If it cannot, say so and stop; never substitute another
   toolchain.
9. **Command form**: prefer the committed wrapper or runner over a global binary; one
   command per line, no shell syntax; per-shell lines only where the invocation differs
   (see the shell table in the same file). Run the whole suite, not only the changed
   project. After each edit run the cheapest check the toolchain offers.
10. **Trace**: record which source gave each command, in the task's final report.

**Shell table** (same file): bash, PowerShell, cmd columns for wrapper invocation,
environment variables, temp and home directories, quoting, path separators, and the
list of constructs banned from skill snippets.

Generic design opinions the old files carried (model absence and failure as values,
small named types for domain values, no sentinel values) move to `## Code quality` in
the skill as language-neutral rules. Neither the skill nor this plan names a language
or toolchain as an example.

## Consequences

Easier: nothing to maintain per language; any project that builds today is supported;
the CI pipeline becomes the single source of truth for commands; one owner for shell
rules. Harder: one discovery pass per project per session; users get "any project that
already builds" instead of a support list.
