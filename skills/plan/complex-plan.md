# Complex plan — workspace and autopilot

Reference file of the [`plan`](SKILL.md) skill. Route: multi-session work (see the
triage in SKILL.md). Phases 0–6, the workspace structure, and the constitution live
here; the Phase 5 execution contract is in [autopilot.md](autopilot.md).

## Goal

**Who does what**:
- The **agent** does the heavy lifting: explores the codebase, drafts DESIGN.md, builds the domain model, writes tasks, runs pre-flight
- The **human** reviews, makes decisions (ADRs), and says "go"

**Human time budget** (for a 2–4H implementation session):
- Phase 2 — DESIGN.md: ~10 min — review requirements, confirm scope
- Phase 3 — ADRs: ~10 min — make the hard decisions the agent cannot
- Phase 4b — Tasks: ~10 min — review task goals and constraints
- Phase 4c — Pre-flight: ~5 min — final approval before autopilot
- **Total: ~30–40 min of human attention buys 2–4H of uninterrupted autopilot**

Everything else (exploring the codebase, drafting documents, building the domain model, writing tasks, running pre-flight checks) is agent work.

**Why this pays off**: without planning, the agent stops mid-autopilot on an outside-constitution gap. The human must context-switch, understand the problem, make a decision, and restart the agent. One interruption costs more than the entire planning phase — and it often cascades into more interruptions.

## Delegation model

This route is **explicitly orchestrated** — do not run every phase inline on the main thread. The main agent is the **orchestrator**: it stays responsive to the human, holds a small context, and delegates heavy work to subagents. Prescribe delegation; do not rely on it emerging.

- **Phase 4a (Analysis)** — fan out read-only `Explore` subagents **in parallel**, one per axis (domain model, build/test/lint commands, interfaces/contracts, dependencies, existing patterns). Each burns its own context and returns structured findings; the orchestrator synthesizes the `## Analysis` section.
- **Phases 2–3 (Design/ADRs)** — for a genuinely contested decision, spawn parallel agents arguing each viable option (judge panel), then synthesize the ADR. For simple decisions, draft inline.
- **Phase 5 (Implementation)** — the orchestrator runs a **per-task subagent loop** (one fresh-context subagent per task), monitors, re-runs checkpoints, and surfaces gaps — it does **not** implement inline. (Optionally accelerated by Dynamic Workflows where available — see Phase 5.)

**Why this matters**: an orchestrator that does everything inline fills its own context, triggers compaction, and loses the thread. Delegation keeps the orchestrator thin (so it rarely compacts) and gives each unit of work a fresh context (so no single window carries the whole job). This is what restores the "listen to the human while monitoring ongoing work" behavior.

## Structure

the root is `./docs`

```
docs/workspace/<NAME>/          <- temporary focus space while planning + implementing
  adrs/                         <- draft ADRs (slug-named: <decision-slug>.md)
  DESIGN.md                     <- draft Design Doc
  TASKS.md                      <- Work Breakdown (lives and dies with workspace)

docs/YYYYMMDD_<NAME>/           <- durable home for the feature (date = integration day)
  README.md                     <- what this feature is + links to its designs and ADRs
  adrs/
    <slug>.md                   <- durable ADR, status accepted
  designs/
    <name>.md                   <- durable Design Doc
```

A **workspace is both a feature and a temporary focus space**. `<NAME>` (the agent session name) identifies the work while drafting under `docs/workspace/<NAME>/`, and becomes the durable home `docs/YYYYMMDD_<NAME>/` at integration — the folder is prefixed with the integration date. Scope the workspace at the level you want it to live — broad (e.g. `storage`, `performance`) to gather related decisions over time, narrow for a one-off. The dated folder is the unit; inside, ADRs and designs are slug-named and distinguished by subdirectory. There is **no global ADR counter**.

## Document Order

Strict order — each document depends on the previous:

1. **DESIGN.md** — always first (context, FR, NFR, non-goals, design)
2. **adrs/*.md** — emerge during design (one per hard-to-reverse decision)
3. **TASKS.md** — derived from DESIGN.md (one task per FR/NFR, with acceptance criteria)

## Constitution

The **constitution** is the set of rules the agent cannot break unilaterally during implementation. It is built across Phases 2–4 and enforced during Phase 5.

The constitution is composed of:
- **Requirements** (FR/NFR) — what the system must do and under what constraints; each NFR carries a measurable scenario and a verify command (or an explicit `manual: <reason>`)
- **ADR decisions** — hard-to-reverse choices that are settled and not open for re-evaluation
- **Domain model** — the planned types, their attributes, and relationships
- **Requirement traceability** — which types address which FR/NFR, and each type's stability (`internal` or `published`)
- **Transformation invariants** — the rules each function must enforce (input → output, with the invariant that must hold), including error-path invariants from the failure modes table
- **External dependencies** — the crates/packages/services the project uses, no new ones without approval
- **TDD rule** — every code change requires a corresponding test: failing test first, then implementation, then green (see [TDD skill](../tdd/SKILL.md)). No code is committed without a test that proves it works.

**Within the constitution** (agent acts autonomously, no need to stop — `internal` stability only):
- Add fields or attributes to types when needed to satisfy an invariant
- Rename types or fields for clarity, as long as the traceability table intent is preserved
- Split a type into smaller types (e.g., extract a value object) when it makes the model cleaner
- Add helper functions or intermediate transformations
- Adjust signatures when a constraint requires it
- Choose how to organize code (files, modules, visibility)

**Outside the constitution** (agent stops *implementing*, then analyzes and proposes — see [Phase 5 severity 3](autopilot.md#phase-5--implement-autopilot)): the agent does not change these unilaterally, but it does the analysis itself and drafts a `proposed` ADR with a recommendation for the human to ratify — it hands the human a decision, not a raw problem:
- Change an ADR decision (e.g., switch from REST to gRPC, change a persistence strategy)
- Change a type or function marked `published` in the traceability table (external consumers depend on it)
- Add, remove, or alter a requirement (FR/NFR)
- Violate a documented invariant or transformation rule
- Skip an acceptance criterion that cannot be met
- Introduce a new external dependency not listed in analysis

If the constitution is well-built, the agent never stops. If it's incomplete, the agent will hit an outside-constitution gap and must halt. The quality of the constitution determines the quality of the autopilot.

## Rules

### Phase 0 — Resume (run on every start)

Before doing anything else — including after context compaction, `/clear`, or a new session — reconstruct state from disk. **Disk and git are the source of truth; never trust conversational memory for where work stands.**

1. Read root `CLAUDE.md` `## Active workspaces` → find the active workspace and phase.
2. If a workspace is active, load the `plan` skill and read its `TASKS.md`.
3. In TASKS.md: checked acceptance criteria = done; the first unchecked task is the resume point. Check `PREFLIGHT.md` state alongside TASKS.md — unchecked boxes mean the pre-flight gate has not passed.
4. Run `git log --oneline` and the active session's checkpoint command → confirm what is actually committed and green.
5. Resume at the first unchecked task. If the checkpoint disagrees with the checkboxes, trust the checkpoint and re-open the affected task.

If no workspace is active, proceed to Phase 1.

### Phase 1 — New need

Create the workspace and register it in the project's root `CLAUDE.md`. Name it `<NAME>` after the current agent session (fall back to a short slug of the work if the session is unnamed) — this keeps the draft folder traceable to the session that owns it. The same `<NAME>` becomes the durable home `docs/YYYYMMDD_<NAME>/` (date-prefixed) at integration (Phase 6) — a workspace is both the feature and its temporary focus space.

Create `docs/workspace/<NAME>/adrs/` (the Write tool creates missing folders when it
writes the first file). No shell command is needed.

Add a self-describing entry under `## Active workspaces` — this is the resume anchor (Phase 0 reads it; update it after every task; remove it at Phase 6). Name only the `plan` skill; per-session skills live in TASKS.md.

```markdown
## Active workspaces
- [<NAME>](docs/workspace/<NAME>/TASKS.md) — Phase 5, task 4/7
  RESUME: load the `plan` skill, then read TASKS.md (checked = done) + `git log --oneline`;
  continue at first unchecked task; re-run the session checkpoint before trusting state.
```

### Phase 2 — Write DESIGN.md

DESIGN.md is the entry point. It must be written before anything else.

Each FR and NFR gets an anchor for cross-referencing:

Template: [templates/DESIGN.md](templates/DESIGN.md). Read it before drafting.

### Phase 3 — Write ADRs

An ADR records any decision worth explaining. ADRs emerge during design and continue to emerge during implementation as new knowledge surfaces.

**What warrants an ADR:**
- Hard-to-reverse decisions (database choice, API style, protocol)
- Trade-offs where both options have merit (consistency vs availability, simplicity vs performance)
- Constraints inherited from external systems or business rules
- Rejected alternatives that someone might propose again later
- Conventions chosen among valid options (naming, error handling strategy, logging format)
- Versioning and compatibility strategy for `published` contracts (wire format, breaking-change policy)
- Security constraints from a STRIDE pass on a crossed trust boundary

When options are weighed with external evidence (benchmarks, adoption, reviews, vendor claims), apply the [`bias-analysis`](../bias-analysis/SKILL.md) skill to that evidence before moving the ADR to `proposed`. In a judge panel, each panellist sweeps its own evidence.

ADRs link back to the requirements they address:

Template: [templates/adr.md](templates/adr.md). Read it before drafting.

ADR status lifecycle: `draft` -> `proposed` -> `accepted` -> `superseded-by <ref>`

- `draft` — the agent is still working the decision out.
- `proposed` — the agent has finished analysis and has a recommendation, awaiting human ratification. **The agent may drive an ADR to `proposed` autonomously; only the human moves `proposed` -> `accepted`.**
- `accepted` — ratified by the human; now part of the constitution.
- `superseded-by <ref>` — replaced by a later decision.

### Phase 4 — Write TASKS.md (autopilot-ready)

Phase 4 is the highest-effort phase. Its goal: build a constitution strong enough that the agent never hits an outside-constitution gap during implementation. The agent will adapt within the constitution — that is expected and normal.

Phase 4 has three sub-phases that must be completed in order.

#### Phase 4a — Analysis

Before writing any task, explore the codebase to ground the plan in reality.

**Delegate this — do not explore inline.** Fan out read-only `Explore` or `ni:investigator` subagents **in parallel**, one per axis below. Findings follow the [`evidence-based-analysis`](../evidence-based-analysis/SKILL.md) skill: every claim cites `file:line`. Each returns structured findings; the orchestrator synthesizes them into the `## Analysis` section of TASKS.md (see template below for format). Parallel exploration keeps the orchestrator's context small and shortens wall-clock time. Axes (one subagent each):

- **Build & test commands**: exact commands to build, test, lint, format
- **Domain model**: types/structs with attributes, relationships, and requirement traceability
- **Interfaces / traits / contracts**: behavioral contracts new code must satisfy
- **Transformations**: functions that convert between types — input → output, with invariants
- **Dependencies**: external crates/packages/services, their versions and API surfaces
- **Constraints discovered**: anything the design did not anticipate

Every *planned domain type* must appear in the requirement traceability table. The agent may introduce additional implementation types as long as they serve a traced type.

If analysis reveals design gaps, go back to Phase 2/3 and update DESIGN.md and ADRs before writing tasks.

#### Phase 4b — Task specification

Each task is derived from a FR or NFR. Each task must be **self-contained**: an agent reading only that task (plus linked references) has everything it needs to execute.

Task references are clickable links to DESIGN.md anchors and relevant ADRs:

Template: [templates/TASKS.md](templates/TASKS.md). Read it before drafting.

**Uncertainty tracking** (inspired by Shape Up's hill chart):
- `uphill` = figuring it out — the problem or approach is not yet understood. May trigger new ADRs or design changes.
- `downhill` = making it happen — the approach is clear, only execution remains.
- A task stuck `uphill` is a signal: the task is not ready for autopilot. Go back to Phase 4a — either the analysis is incomplete or the task needs splitting.
- **All tasks must be `downhill` before exiting Phase 4.** No `uphill` task may enter implementation.

Task granularity: each task should be independently completable and testable (INVEST: Independent, Negotiable, Valuable, Estimable, Small, Testable). Prefer vertical slicing — cut through all layers for a thin but complete feature.

#### Phase 4c — Pre-flight gate

Before moving to Phase 5, the entire TASKS.md must pass the pre-flight gate. This is the last human checkpoint before autopilot.

Copy [templates/preflight.md](templates/preflight.md) to the workspace as `PREFLIGHT.md` and tick every box on disk. Every box must be checked before autopilot starts. The plan-commit instruction lives in the template.

### Phase 5 — Implement (autopilot)

Work through TASKS.md session by session: the orchestrator runs a per-task subagent loop, one fresh-context subagent per task, driven by the on-disk TASKS.md checklist. The constitution is enforced on every change; discovery is classified by severity. Read [autopilot.md](autopilot.md) before starting.

### Phase 6 — Integrate

Promote the validated artifacts to their durable home `docs/YYYYMMDD_<NAME>/`, delete `docs/workspace/<NAME>/` (PREFLIGHT.md dies with TASKS.md), and remove the workspace entry from `CLAUDE.md` `## Active workspaces`. The 7 steps and the commit template are in [autopilot.md](autopilot.md).

## Cross-referencing

Every identifier or reference in any document must be a clickable link to its definition. If an identifier appears and is not a link, it is a defect. The files in `templates/` show the linking conventions — follow them consistently.

## Amending existing work

To amend or extend work that was already integrated:
1. Create a new `docs/workspace/<NAME-v2>/`
2. Reference the existing design by its path: `Amends: [YYYYMMDD_<NAME>/designs/<name>.md](../../YYYYMMDD_<NAME>/designs/<name>.md)`
3. Follow the same workflow (DESIGN.md -> ADRs -> TASKS.md -> quality gates -> integrate)
4. Superseded ADRs get status `superseded-by docs/YYYYMMDD_<NAME>/adrs/<new-slug>.md`
