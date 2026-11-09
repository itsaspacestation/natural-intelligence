# Autopilot

Reference file of the [`plan`](SKILL.md) skill. Read it when entering Phase 5 — it holds the full Phase 5 execution contract and the Phase 6 integration steps.

**REQUIRED BACKGROUND:** the [`plan`](SKILL.md) skill defines the phases, workspace structure, and constitution this file enforces.

## Phase 5 — Implement (autopilot)

Work through TASKS.md session by session. **Execution is delegated — the orchestrator does not implement inline.** It runs each task as its own subagent (the documented [subagents](https://code.claude.com/docs/en/sub-agents.md) feature), one at a time, and stays free to monitor and surface gaps.

**Why a per-task subagent loop**: inline execution has two failure modes — (a) the orchestrator fills its context, compaction fires, and the in-flight thread is lost; (b) the model drifts and fails to advance sequential work on its own. Delegating each task to a **fresh-context subagent** fixes both: no single window holds all of TASKS.md, and the orchestrator's loop — driven by the durable TASKS.md checklist, not by memory — advances tasks deterministically. After each subagent returns, the orchestrator **re-runs the session checkpoint itself** before trusting the result.

**The execution unit is `ni:implementer`** — its agent file owns the per-task contract: load the session's `Skills`, red test, green implementation, refactor, verify, check off only when green, commit only on success, and return one first line (`done`, `blocked: <question>`, or `gap: <adr slug>`) plus evidence. It never pauses and never asks the user; on hesitation it returns `blocked` to the orchestrator. The coding is cheap because the task is `closed`; the judgement stays with the orchestrator, which answers `blocked` questions on its own (stronger) model.

**Durability invariants** (these make execution compaction- and crash-proof):
- **Check off a box only when its criterion is green; commit only on success.** A half-done task leaves no checkmark and no commit, so a re-run re-attempts it from clean state (idempotent).
- **Advance the root `CLAUDE.md` `## Active workspaces` `task N/M` pointer after each task** — it is the durable resume anchor (see [Phase 0](complex-plan.md#phase-0--resume-run-on-every-start)).
- **The orchestrator re-runs the session checkpoint after each subagent returns** — verifying real green state rather than trusting a subagent's "done" (a subagent can stop mid-task from its own compaction).

**The orchestrator loop** (documented subagents; the user's "go" at pre-flight is the trigger):

1. From TASKS.md, take the first unchecked task whose `Depends on` tasks are all done.
2. Spawn `ni:implementer` for it (the Agent/Task tool), passing the task spec. Its agent file defaults the model to `sonnet`; override per task via the Agent tool's `model` parameter — `haiku` for a trivial `closed` task (mechanical edits, light toolchain), because the checkpoint re-run in step 3 is the safety net, not the implementer's model. An `open` task never reaches this loop (pre-flight gate).
3. When it returns, re-run the verify/checkpoint command yourself. If green and the box is checked, advance the `CLAUDE.md` pointer and move on; otherwise re-open the task.
4. On a `blocked` result, decide in a delegated context, record the decision and its reason in the task, then **resume the same implementer with the answer** (SendMessage to the agent, where available — its context survives) or re-spawn fresh as the fallback; otherwise park the task and batch the question for the session checkpoint (see severity 2 below). On a `gap` result, draft/collect the `proposed` ADR, park that task and its dependents, and pick the next independent task (see severity 3 below).
5. Repeat until the session's tasks are done, then run the session checkpoint and commit.

The loop is driven by the **on-disk checklist**, not conversational memory — so a restart (new session, `/clear`, compaction) resumes by re-reading TASKS.md (Phase 0), not by remembering where it was. Long runs can be paced with [`/loop`](https://code.claude.com/docs/en/scheduled-tasks.md) so the orchestrator wakes, advances one task, and checkpoints. Sessions that must run concurrently can use [worktrees](https://code.claude.com/docs/en/worktrees.md) for isolation.

**Optional accelerator (research preview)**: where [Dynamic Workflows](https://code.claude.com/docs/en/workflows.md) is available, the same loop can run as one deterministic script — a `for` over tasks, one `agent()` call each, with `resumeFromRunId` replaying completed tasks instantly. This is a portability-optional speed-up; the orchestrator loop above is the baseline and works anywhere subagents do.

**Autonomy model**: tasks define goals and constraints, not step-by-step scripts — the agent decides *how* to achieve them. The constitution (defined in [complex-plan.md](complex-plan.md#constitution)) is the boundary. See the constitution section for what the agent can and cannot do autonomously. The freedom is in the *how*, never in the *what*: every task that reaches this loop is `Fit: closed` ([complex-plan.md](complex-plan.md#phase-4b--task-specification)), so the executor has nothing to negotiate and nobody to ask.

**How the agent validates its own changes**: before moving to the next task, the agent checks:
1. Does the change have a corresponding test that was red before the implementation?
2. Does the change respect every constraint listed on the task?
3. Does every type still map to its FR/NFR in the traceability table?
4. Do the transformation invariants still hold?
5. Does the verify command pass?

If all four pass, the change is within the constitution — continue. If any fails, classify the gap below.

**Discovery — exception handling**:

Discovery during implementation means the planning phase missed something. If Phase 4 was done thoroughly, discovery should be rare.

**Severity levels**:

1. **Within constitution** (agent continues) — the agent needs to adjust types, add fields, or rework an approach, but the change respects all ADRs, invariants, and requirements. This is normal autonomous adaptation, not discovery. Continue without stopping.

2. **Ambiguous** (`ni:implementer` returns `blocked: <question>`) — the implementer is unsure whether a change respects the constitution. It leaves no checkmark and no commit, writes the question into the task, and returns. The orchestrator decides in a delegated context, records the decision and its reason in the task, and resumes the implementer with the answer (or re-spawns); otherwise it parks the task and surfaces the batch of `blocked` questions at the session checkpoint. Nobody pauses mid-task to ask.

3. **Outside constitution** (agent analyzes, proposes, and keeps independent work moving) — an ADR decision is wrong, a requirement is missing or contradictory, an invariant cannot be satisfied, or a new external dependency is needed. The agent does **not** halt blankly and dump the raw problem on the human. It does the legwork autonomously and hands the human a *decision, not a problem*:
   - **Analyze the option space.** For a genuinely contested decision, fan out a judge panel (parallel subagents, one arguing each viable option); for a simple one, analyze inline.
   - **Write a `proposed` ADR** in `workspace/adrs/` using the standard ADR template — options table, consequences, and a clear **recommendation**.
   - **Do NOT implement the decision.** ADRs are hard-to-reverse by definition; building dependent work on an unratified choice is the exact mistake ADRs exist to prevent.
   - **Park the blocked task and its dependents** (from the `Depends on` field), then continue with independent tasks so the run stays productive.
   - **Surface the batch of `proposed` ADRs at the session checkpoint** for ratification.

   The human ratifies — or picks a different option — moving the ADR `proposed` -> `accepted`. Only then does the agent resume the parked tasks. This keeps the agent autonomous (it owns research, recommendation, and keeping other work moving) while preserving the human as the sole ratifier of hard-to-reverse choices.

**When an outside-constitution gap triggers, go back to the relevant phase**:
- ADR decision wrong → Phase 3 (new or superseded ADR), then re-run Phase 4c pre-flight
- Requirement change → Phase 2 (update DESIGN.md), then Phase 4b-4c
- Design assumption invalidated → Phase 2-3 (update design + ADRs), then Phase 4a-4c
- Rabbit hole encountered → update DESIGN.md Rabbit holes section, split or simplify the affected task, re-run Phase 4c

**After all sessions complete**: once every session checkpoint passes and all acceptance criteria are checked off, proceed immediately to Phase 6. Do not stop or wait for user input — integration is part of the autopilot.

## Phase 6 — Integrate

Promote the validated artifacts from the workspace to its durable home `docs/YYYYMMDD_<NAME>/` (folder prefixed with the integration date):
0. Run the [`retro`](../retro/SKILL.md) skill on the sessions; in a delegated context, record its table at the checkpoint and continue.
1. Create `docs/YYYYMMDD_<NAME>/` with a `README.md` index if it does not exist (an existing dated folder for this work means you are amending — append to it).
2. Move ADRs to `docs/YYYYMMDD_<NAME>/adrs/` — rename each to `<slug>.md`, set status to `accepted`. No numbering.
3. Move DESIGN.md to `docs/YYYYMMDD_<NAME>/designs/<name>.md`
4. Add or update the terms the workspace resolved in GLOSSARY.md at the repo root. One entry per term, alphabetical: `**Term**: definition in one or two sentences. Replaces: <words not to use>.` No types, functions, or file paths. This step creates the file when it is missing; nothing else does.
5. Update `docs/YYYYMMDD_<NAME>/README.md` — add links to the new design and ADRs
6. Rewrite any cross-reference links so they resolve from the new locations (a superseded ADR references its replacement by path, not number)
7. Delete `docs/workspace/<NAME>/` — TASKS.md and PREFLIGHT.md die with it, git history preserves them
8. Remove the workspace entry from `CLAUDE.md` `## Active workspaces`

**Integration commit**: after all integration steps are complete, commit with message:

```
docs(<NAME>): integrate workspace into docs/YYYYMMDD_<NAME>

ADRs and design moved to docs/YYYYMMDD_<NAME>/ (status accepted).
README updated. Workspace deleted — git history preserves TASKS.md.
```
