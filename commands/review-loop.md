---
description: Review MRs or PRs assigned to me in a loop, post findings, report the links
argument-hint: "[project path or URL]"
---
Start a dynamic /loop that reviews every change (MR/PR) awaiting my review in the project
given in $ARGUMENTS (default: the current repository's origin). Resolve the forge first,
per the forge routing rule of the `ni:git-conventions` skill.
The `ni:code-review` skill owns the review itself (built-in pass, checklist subagents,
finding format); this loop owns the mechanics around it. Forge commands are never
named here: review threads and listing live in the gitlab.md or github.md reference
file of `ni:code-review`; MR/PR lifecycle (approvals, diff) in the gitlab.md or
github.md reference file of `ni:git-conventions`.

Each iteration:

1. List open changes where I am reviewer: listing commands in the code-review
   reference file for the routed forge.
2. Skip a change I already approved (approval state: lifecycle reference file), or one
   reviewed in an earlier iteration that has no new commits and no reviewer replies.
3. Re-review: when a revisited change carries new commits since the last pass, run
   the own-thread auto-resolution rule of the `ni:code-review` skill before reviewing
   the new commits: evidence first, reply naming the fixing commit, then resolve — my
   own threads only, ambiguous stays open. Resolve commands live in the forge
   reference files, never here.
4. Review each remaining change with the giving-a-review flow of `ni:code-review`.
5. Diff via the forge, per the git-versus-forge boundary of the `ni:git-conventions`
   skill: the forge diff is against
   the merge-base of the source branch and its target, never two-dot against the
   target head — a branch forked before later merges shows those merges as deletions.
6. Post each finding as its own diff-anchored discussion on the change,
   severity-prefixed, with `file:line` in the body. Attach the fix as a one-click
   applicable suggestion when the classification ladder of the `ni:code-review`
   skill says so; otherwise post prose that still states the concrete fix. Batch or serialise
   the posts per the forge reference file — posting commands and payloads live
   there, never here. This command's standing instruction is the approval for these
   first-review comments.
7. Submit the verdict of the `ni:code-review` skill on each change: approve when no
   mandatory finding is left, request changes otherwise. Commands live in the
   lifecycle reference file, never here. A held finding (step 9) blocks approval
   until I decide.
8. Report the posted comment links grouped by change: one section per change, the
   verdict line first, links listed under it.
9. When a loop finding conflicts with an existing comment or thread, do not publish
   that finding: hold it, ask me for help with both positions summarised, and post
   only what I decide. The standing approval never covers a conflicting comment.
10. Carry state forward in the loop prompt: append the reviewed change ids with
   "skip unless new commits or reviewer replies".

Keep it simple: the loop orchestrates only — the review itself follows the
`ni:code-review` principles (finding format, disposition rules, red flags, no scope
creep); one concern per thread, and a suggestion is a posting mechanism, never a
licence for bigger rewrites.

Loop mechanics: run the check now, then ScheduleWakeup with the amended prompt. Idle tick
1200-1800 s; review subagents notify on completion, so the wakeup is only a fallback. Any
prompt amendment (skip rules, output grouping) rewrites the ScheduleWakeup prompt, never a
separate note.

Task panel: the one-line loop status below the input box comes from the ScheduleWakeup
`reason`. Make it the iteration status, not a generic wait: counts plus the change
waited on, for example "2 reviewed, 5 findings posted; !42 held (conflicting thread)".
Set `noop: false` on a tick that posted or held a finding, `noop: true` on a no-change
tick so quiet ticks collapse in the panel.

Boundaries: never merge or close anything: those stay my calls; resolving is limited
to my own threads per step 3; approving follows the verdict per step 7. Replies to
existing reviewer threads keep the preview-then-approval flow of `ni:code-review`; only
first-review comments, own-thread resolution, and the verdict ride the standing approval. The loop dies with the session; a durable
schedule is /schedule, not /loop.
