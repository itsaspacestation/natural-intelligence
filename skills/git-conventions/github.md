# GitHub PR Lifecycle

Reference file of the [`git-conventions`](SKILL.md) skill. Read it when a PR lifecycle
operation targets GitHub: create, describe, diff, gate, merge, rebase, CI status, auth.

**REQUIRED BACKGROUND:** the [`git-conventions`](SKILL.md) skill owns the forge
routing rule and the git-versus-forge boundary. Load it first. Review threads and
suggestions belong to the [`code-review`](../code-review/SKILL.md) skill.

`gh` flags below were checked against `gh pr create --help` and `gh pr edit --help`
(gh 2.101.0).

## Create and describe

Write the description markdown to a file with the Write tool, pick the reviewer (rule
below), then:

```bash
gh pr create --title "<title>" --body-file <file> --assignee @me --reviewer <username>
```

Commands follow the shell rules in [`software-engineer`](../software-engineer/SKILL.md#onboarding).

Reviewer selection, in order:
1. `CODEOWNERS` exists (root, `.github/` or `docs/`): GitHub auto-requests the matching
   owners on creation — pass no `--reviewer`, do not duplicate them.
2. Otherwise the top recent committer of the touched files, excluding the author and bots:
   `git shortlog -sne --since="6 months ago" -- <paths>`
3. No candidate: create without `--reviewer` and tell the user to pick one.

The assignee is always me (`--assignee @me`).

Edit an existing description. Write the description to a file with the Write tool, then:

```bash
gh pr edit <number> --body-file <file>
```

## Diff

```bash
gh pr diff <number>
```

Local `git diff` covers uncommitted work only.

## Merge gates

Merge only when GitHub reports the PR clean, approved, and not a draft:

```bash
gh pr view <number> --json mergeStateStatus,reviewDecision,isDraft
```

Gate: `mergeStateStatus == "CLEAN"`, `reviewDecision == "APPROVED"`, and
`isDraft == false`. On a repository with no required-review rule `reviewDecision`
comes back empty: then require at least one `APPROVED` entry in `latestReviews`
(add it to the `--json` list). Never bypass a failing gate.

## Merge, auto-merge, cancel

```bash
gh pr merge <number>                   # merge now
gh pr merge <number> --auto            # merge when requirements pass
gh pr merge <number> --disable-auto    # cancel auto-merge
```

## Rebase / branch update

Forge only, never local rebase plus force-push:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/update-branch -X PUT
```

## CI status

```bash
gh pr checks <number>
```

## Auth

```bash
gh auth status
```

On failure, tell the user to run `gh auth login`. Never create, read, or store
tokens yourself.
