# GitLab MR Lifecycle

Reference file of the [`git-conventions`](SKILL.md) skill. Read it when an MR lifecycle
operation targets GitLab: create, describe, diff, gate, merge, rebase, CI status, auth.

**REQUIRED BACKGROUND:** the [`git-conventions`](SKILL.md) skill owns the forge
routing rule and the git-versus-forge boundary. Load it first. Review threads and
suggestions belong to the [`code-review`](../code-review/SKILL.md) skill.

## Create and describe

Write the description markdown to a file with the Write tool, pick the reviewer (rule
below), then:

```bash
glab mr create --title "<title>" --description-file <file> --assignee @me --reviewer <username>
```

Commands follow the shell rules in [`software-engineer`](../software-engineer/SKILL.md#onboarding).

Reviewer selection, in order:
1. `CODEOWNERS` exists (root, `.gitlab/` or `docs/`): the owners matching the touched paths.
2. Otherwise the top recent committer of the touched files, excluding the author and bots:
   `git shortlog -sne --since="6 months ago" -- <paths>`
3. No candidate: create without `--reviewer` and tell the user to pick one.

The assignee is always me (`--assignee @me`).

Edit an existing description. Write the description to a file with the Write tool, then:

```bash
glab mr update <iid> --description-file <file>
```

## Diff

```bash
glab mr diff <iid>
```

Local `git diff` covers uncommitted work only.

## Merge gates

Merge only when GitLab reports the MR mergeable and not a draft:

```bash
glab api "projects/:id/merge_requests/<iid>" --jq '.detailed_merge_status, .draft, [.reviewers[].username]'
glab api "projects/:id/merge_requests/<iid>/approvals" --jq '.approved, [.approved_by[].user.username]'
```

Gate: `detailed_merge_status == "mergeable"`, `draft == false`, `approved == true`,
and `approved_by` not empty (at least one approval). Never bypass a failing gate.

## Merge, auto-merge, cancel

```bash
glab mr merge <iid>                    # merge now
glab mr merge <iid> --auto-merge       # merge when pipeline succeeds
# cancel auto-merge
glab api -X POST "projects/:id/merge_requests/<iid>/cancel_merge_when_pipeline_succeeds"
```

## Rebase / branch update

Forge only, never local rebase plus force-push:

```bash
glab mr rebase <iid>
```

## CI status

```bash
glab ci status
glab ci status --branch <branch>
```

## Auth

```bash
glab auth status
```

On failure, tell the user to run `glab auth login`. Never create, read, or store
tokens yourself.
