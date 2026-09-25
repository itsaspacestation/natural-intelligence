---
description: Merge my approved MRs in a loop, report what merged and what is blocked
argument-hint: "[gitlab project path or URL]"
---
Start a dynamic /loop that merges every approved MR authored by me in the project given in
$ARGUMENTS (default: the current repository's origin). This command's standing instruction
is the approval for each merge that passes every gate below; anything short of all gates
is reported, never merged.

Each iteration:

1. List my open MRs: `glab mr list --author=@me --repo <path>`.
2. For each MR, read state: `glab api projects/:id/merge_requests/<iid>` for
   `detailed_merge_status` and `draft`, and
   `glab api projects/:id/merge_requests/<iid>/approvals` for `approved`.
3. Merge gates, all required: not a draft, `approved` is true, no unresolved threads,
   `detailed_merge_status` is `mergeable` or only waiting on a running pipeline.
4. Gates pass and pipeline succeeded: `glab mr merge <iid> --repo <path>`.
   Gates pass but pipeline still running: `glab mr merge <iid> --auto-merge --repo <path>`,
   then re-check it next iteration.
5. `detailed_merge_status` is `need_rebase`: rebase my own branch with
   `glab mr rebase <iid> --repo <path>`, then re-check next iteration.
6. Failed pipeline, conflicts, missing approval, or unresolved threads: skip, and report
   the MR with its blocking reason.
7. Report each iteration: merged MRs with links, auto-merge set, blocked MRs with reasons.
8. Carry state forward in the loop prompt: append merged MR ids as done, and pending ids
   with their last known blocker.
9. Stop the loop when no open MR authored by me remains.

Loop mechanics: run the check now, then ScheduleWakeup with the amended prompt. Waiting on
a pipeline: match the delay to its usual duration (300-600 s). Otherwise idle tick
1200-1800 s. Any prompt amendment rewrites the ScheduleWakeup prompt, never a separate note.

Boundaries: never approve my own MRs, never merge with a failed or absent pipeline, never
force merge, never resolve someone else's thread, never touch MRs I did not author. Fixing
a failed pipeline or answering threads is separate work: notify me instead. The loop dies
with the session; a durable schedule is /schedule, not /loop.
