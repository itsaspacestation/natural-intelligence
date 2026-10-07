---
name: git-conventions
description: "Use when the user asks to commit, stage, branch, diff, write a commit message, or perform any git operation, and when the user asks to describe or summarise a change for review, such as a merge request or pull request description (MR, PR). Also use when discussing version control workflows or git safety."
---
# Git Conventions

## When to use
- User asks to commit, stage, diff, or perform any git operation
- User asks to create a branch or write a commit message
- User asks to check differences with a previous version
- User asks to describe or summarise a change for review (merge request, pull request)
- User mentions "git", "commit", "branch", "diff", "MR", "PR", or "version control"
- User is ready to commit after completing a task

## Overview

Rules for safe and consistent git usage, from the commit to the change description.

Reviewing code or answering review feedback is the
[`code-review`](../code-review/SKILL.md) skill. Forge commands live in its
[gitlab.md](../code-review/gitlab.md) (`glab`) and [github.md](../code-review/github.md)
(`gh`) reference files.

## Forge routing

Pick the forge CLI (`gh` or `glab`) in this order. Never guess.

1. An explicit argument or user statement wins. A project path or URL names the forge.
2. Otherwise read `git remote get-url origin`. Host `github.com` routes to `gh`;
   host containing `gitlab` routes to `glab`.
3. Unknown host: check `gh auth status` and `glab auth status` for a matching
   configured host. Still ambiguous: ask the user.

Missing origin remote: ask the user.

## Git versus forge

`git` owns local state. The forge CLI owns everything on the server.

| Operation | Tool |
|---|---|
| stage, commit, branch, local diff, log, worktree | `git` only |
| push | `git push` — command rules below unchanged |
| MR/PR create, description, edit | forge CLI — never a clipboard; assign me, pick the reviewer from the change (rule in the forge file) |
| MR/PR diff for review | forge CLI — local `git diff` only for uncommitted work |
| threads, approvals, merge, CI status | forge CLI only |
| rebase / branch update of a pushed MR/PR branch | forge CLI only — never local rebase plus force-push |

Concrete lifecycle commands per forge: [gitlab.md](gitlab.md) (GitLab, `glab`) and
[github.md](github.md) (GitHub, `gh`).

## Rules

Before committing, the code must compile and tests must pass, none failing or ignored.

1. Push only when the user asks for it in the current turn. Never push on your own after a commit. Push the current branch to its upstream, never to `master` or `main` directly.
2. Never use `--force`.
3. Never amend to modify files: add a fix commit and explain the reason.
4. Use git freely when checking differences with the previous version.
5. A task should be committed when tests pass (with assertions) and code coverage is verified.

## Commit message

Short and exact. Why over what: the diff already says what changed.

### Subject

`<type>(<scope>): <imperative summary>`, scope optional.

Types:

- `feat:` for feature
- `fix:` when fixing the codebase
- `refac:` for refactoring, mostly to prepare or finish a feat
- `chore:` to cleanup the codebase, removing dead code
- `docs:` when touching .md files or documentation
- `test:` when touching test only
- `perf:` for a measured performance change
- `build:` or `ci:` for build tooling or pipeline changes
- `revert:` when reverting a prior commit

Rules: imperative mood ("add", "fix", "remove", never "added" or "adds"), 50 characters
when possible and 72 at most, no trailing period, no restating the file name when the
scope already says it. Match the project convention for capitalisation after the colon.

### Body

Skip it when the subject is self-explanatory. Add one only for a non-obvious why, a
breaking change, migration notes, or linked issues. Wrap at 72 characters, bullets with
`-`, issue references last (`Closes #42`, `Refs #17`).

Always add a body for: breaking changes, security fixes, data migrations, and reverts.
Future debuggers need the context.

Never in a commit message: "this commit does", "I", "we", "now", "currently", "as
requested by" (use a `Co-authored-by` trailer), AI attribution, emoji unless the project
convention requires it.

Examples:

- Not: `feat: add a new endpoint to get user profile information from the database`
- Yes:
  ```
  feat(api): add GET /users/:id/profile

  Mobile client needs profile data without the full user payload
  to reduce LTE bandwidth on cold-launch screens.

  Closes #128
  ```
- Breaking change:
  ```
  feat(api)!: rename /v1/orders to /v1/checkout

  BREAKING CHANGE: clients on /v1/orders must migrate to /v1/checkout
  before 2026-06-01. Old route returns 410 after that date.
  ```

## Change description

When asked to describe a change for review, whatever the forge calls it (merge
request, pull request):

1. Write a concise markdown description of the work done to a file.
2. Route per [Forge routing](#forge-routing), then create or update the MR/PR from
   that file with the forge CLI: commands in [gitlab.md](gitlab.md) or
   [github.md](github.md).

## Boundaries

This skill owns git usage, commit messages, forge routing, the git-versus-forge
boundary, and the MR/PR lifecycle files. Review flows, threads, and suggestions
belong to [`code-review`](../code-review/SKILL.md). Never create, read, or store
forge tokens.
