# GitHub Review

Reference file of the [`code-review`](SKILL.md) skill. Read it when the review lives on
a GitHub pull request: reading threads, posting replies or suggestions, resolving
threads, or troubleshooting `gh`.

## Overview

GitHub-specific tooling for the review flow. It provides the `gh` commands and API
calls; the flow itself is not here. Scope: review threads only. PR lifecycle (create,
merge, CI) belongs to the [`git-conventions`](../git-conventions/SKILL.md) skill.

**REQUIRED BACKGROUND:** the [`code-review`](SKILL.md) skill defines the flow (read ->
preview -> approve -> post + resolve), the preview format, the Disposition rules, and
the red flags. Load it first. Git rules are in the
[`git-conventions`](../git-conventions/SKILL.md) skill.

## Reading the review

Find the pull request. With no number, `gh` uses the current branch's PR. Commands
follow the shell rules in [`software-engineer`](../software-engineer/SKILL.md#onboarding).

```bash
gh pr list --search "review-requested:@me"   # PRs waiting on me
gh pr list --author "@me"                    # my own PRs
```

`gh` has no CLI verb for open review threads — no `--unresolved` equivalent. Go
through GraphQL for both the human-readable pass and the structured data. Write the
query to `threads.graphql` with the Write tool:

```graphql
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes {
          id isResolved path line startLine diffSide
          comments(first: 50) {
            nodes { databaseId author { login } body }
          }
        }
      }
    }
  }
}
```

Then run it; `-F key=@file` reads the file, and every field other than `query` is a
GraphQL variable:

```bash
gh api graphql -F query=@threads.graphql -f owner=<owner> -f repo=<repo> -F pr=<number>
```

Get `<owner>` and `<repo>` once with `gh repo view --json owner,name`. Filter to
open threads with `--jq '... | select(.isResolved | not)'` on the nodes.

Keep two ids per thread: the GraphQL thread `id` (what resolve takes) and the first
comment's `databaseId` (what the REST reply endpoint takes). `startLine` and
`diffSide` give the anchored span (`startLine`..`line` on `diffSide`), so a reply
carrying a suggestion knows exactly which lines it replaces.

For diff context:

```bash
gh pr diff <number>
gh pr view <number> --json baseRefOid,headRefOid   # base and head refs
```

In the preview, **File:line** is the thread's `path:line` and **Discussion** is a
short prefix of the thread id.

## Suggestion syntax

GitHub applies a fenced `suggestion` block when the comment is attached to the diff.
Unlike GitLab, there is **no `:-N+M` range modifier**: the block header is bare
` ```suggestion `. The suggestion replaces the line span the comment anchors —
one line, or the `start_line`..`line` range set when the comment was created.
A wider replacement needs a new comment anchored on the wider range.

Rules:
- The block content is the final code, with the file's real indentation, and no diff markers.
- Suggestions work on diff comments only. A general PR comment cannot carry an applicable suggestion.
- A suggestion edits only the anchored file. A fix in another file needs its own
  comment anchored on a kept or added line of that file; no such line in the diff
  means prose.
- A reply inside a diff thread can carry a suggestion; it applies to that thread's anchored span.
- Only kept or added lines qualify — the anchoring constraints are under
  [Posting a suggestion](#posting-a-suggestion).
- **Insertion**: anchor a single-line comment on the kept or added line adjacent to
  the insertion point; the block is that line verbatim (read from the file) followed
  by the new lines. Applying keeps the anchored line and inserts the rest. A missing
  test posts this way, never as a plain code fence on the production file.

## Posting a suggestion

The classification ladder in the [`code-review`](SKILL.md) skill decides *when*; this
is *how*. Constraints, stated plainly:

- Anchor on `line` with `side=RIGHT` (kept or added lines) only. Deleted lines
  (`side=LEFT`) never carry a fence — applying fails, a long-standing GitHub
  limitation. This is the mechanical restatement of the ladder's ban on deleted-line
  targets.
- File-level comments cannot carry an applicable suggestion.
- Commenting on unchanged lines is a 2025 preview with limited API support — do not
  rely on it.
- The legacy `position` parameter is deprecated; use `line`.

Post **all inline comments in one review call**: the reviewee gets one notification,
and batching avoids the secondary rate limits that serial comment creation trips.
`commit_id` is the PR's current head SHA, fetched immediately before posting — a stale
SHA makes the comment outdated and its suggestion unapplyable:

```bash
gh pr view <number> --json headRefOid --jq .headRefOid   # fresh head SHA
```

Write the payload to `review.json` with the Write tool (fenced blocks do not survive
inline shell quoting):

```json
{
  "commit_id": "<headRefOid>",
  "event": "COMMENT",
  "comments": [
    {
      "path": "src/Domain/Booking.cs",
      "line": 42,
      "side": "RIGHT",
      "start_line": 40,
      "start_side": "RIGHT",
      "body": "Off-by-one in the range check.\n\n```suggestion\n<replacement lines 40-42>\n```"
    }
  ]
}
```

Then post the review:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/reviews -X POST --input review.json
```

Each element anchors one comment: `path`, `line`, `side=RIGHT`, and for a multi-line
range also `start_line` + `start_side=RIGHT` — the four fields go together; omit the
`start_*` pair for a single line. The body carries the bare ` ```suggestion ` fence:
the replaced span is the anchored range, since no `:-N+M` modifier exists on GitHub.

Error path — outdated or stale anchor (422 on post, or the comment lands outdated):
refetch the head SHA once, retry once, then post the finding as prose stating the
concrete fix.

### Applying (reviewee side)

- UI only: **Commit suggestion** per comment, or add several to a batch — one commit
  for the batch. No REST endpoint and no GraphQL mutation exists to apply a
  suggestion (2026).
- The applier is the committer; each suggester becomes a co-author.
- Suggestions cannot be applied on closed or merged PRs, nor from pending reviews.

## Posting after approval

Two writes per approved `reply + resolve` thread, in this order. A thread is not done
after the reply.

**1. Reply** inside the reviewer's own thread, which is the default choice. The REST
replies endpoint takes the first comment's `databaseId`:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments/{comment_id}/replies -F body=@body.md
```

Write the body to `body.md` first with the Write tool, because fenced blocks and
backticks do not survive inline shell quoting. Only `-F` reads a file from `@file`;
`-f body=@body.md` sends the literal string. There is no uniqueness flag: to stay
idempotent on a retry, re-read the thread and skip the ones that already have your note.

Start a new inline thread when there is no existing discussion on that line:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments -F body=@body.md -f commit_id=<headRefOid> -f path=src/Domain/Booking.cs -F line=42 -f side=RIGHT
# range: add -F start_line=40 -f start_side=RIGHT
# removed line: -f side=LEFT with the old line number
```

**2. Resolve** the thread. Resolution is GraphQL-only — the thread id is the one from
the reading query, not a comment id. Write the mutation to `resolve.graphql` with the
Write tool:

```graphql
mutation($id: ID!) {
  resolveReviewThread(input: {threadId: $id}) {
    thread { id isResolved }
  }
}
```

```bash
gh api graphql -F query=@resolve.graphql -f id=<thread-id>
```

If the mutation fails, report that thread id and the error, then continue with the
next thread. Never stop the pass on one failed resolve.

**3. Verify** before reporting, as the [`code-review`](SKILL.md) skill requires:
re-run the reading query and check `isResolved` on every thread you touched.

## Setup

Check auth with `gh auth status`. On failure, tell the user to run `gh auth login`;
do not attempt to create or read tokens.

`gh api` flag semantics in this file (`-F key=@file` reads a file, `-f` does not) were
checked against `gh api --help` (gh 2.101.0); field spellings were not proven by a live
call.
