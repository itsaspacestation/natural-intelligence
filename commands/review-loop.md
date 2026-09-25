---
description: Review MRs assigned to me in a loop, post findings, report the links
argument-hint: "[gitlab project path or URL]"
---
Start a dynamic /loop that reviews every MR assigned to me in the project given in
$ARGUMENTS (default: the current repository's origin). The `ni:code-review` skill owns the
review itself (built-in pass, checklist subagents, finding format, glab commands); this
loop owns the mechanics around it.

Each iteration:

1. List open MRs where I am reviewer: `glab mr list --reviewer=@me --repo <path>`.
2. Skip an MR when I already approved it (`glab api projects/:id/merge_requests/<iid>/approvals`)
   or when it was reviewed in an earlier iteration and has no new commits and no reviewer replies.
3. Review each remaining MR with the giving-a-review flow of `ni:code-review`.
4. Diff against the merge-base of the MR branch and its target, never two-dot against the
   target head: a branch forked before later merges shows those merges as deletions.
5. Post each finding as its own MR discussion, severity-prefixed, with `file:line` in the
   body. This command's standing instruction is the approval for these first-review comments.
6. Report the posted comment links grouped by MR: one section per MR, links listed under it.
7. When a loop finding conflicts with an existing comment or thread, do not publish
   that finding: hold it, ask me for help with both positions summarised, and post
   only what I decide. The standing approval never covers a conflicting comment.
8. Carry state forward in the loop prompt: append the reviewed MR ids with
   "skip unless new commits or reviewer replies".

Loop mechanics: run the check now, then ScheduleWakeup with the amended prompt. Idle tick
1200-1800 s; review subagents notify on completion, so the wakeup is only a fallback. Any
prompt amendment (skip rules, output grouping) rewrites the ScheduleWakeup prompt, never a
separate note.

Boundaries: never approve, merge, close, or resolve anything: those stay my calls. Replies
to existing reviewer threads keep the preview-then-approval flow of `ni:code-review`; only
first-review comments ride the standing approval. The loop dies with the session; a durable
schedule is /schedule, not /loop.
