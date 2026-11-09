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
- Phase 3 — decision rounds, then any remaining ADR ratification: ~10 min — make the hard decisions the agent cannot
- Phase 4b — Tasks: ~10 min — review task goals and constraints
- Phase 4c — Pre-flight: ~5 min — final approval before autopilot
- **Total: ~30–40 min of human attention buys 2–4H of uninterrupted autopilot**

Everything else (exploring the codebase, drafting documents, building the domain model, writing tasks, running pre-flight checks) is agent work.

**Why this pays off**: without planning, the agent stops mid-autopilot on an outside-constitution gap. The human must context-switch, understand the problem, make a decision, and restart the agent. One interruption costs more than the entire planning phase — and it often cascades into more interruptions.

## Delegation model

This route is **explicitly orchestrated** — do not run every phase inline on the main thread. The main agent is the **orchestrator**: it stays responsive to the human, holds a small context, and delegates heavy work to subagents. Prescribe delegation; do not rely on it emerging.

- **Phase 4a (Analysis)** — fan out read-only `Explore` subagents **in parallel**, one per axis (domain model, build/test/lint commands, interfaces/contracts, dependencies, existing patterns). Each burns its own context and returns structured findings; the orchestrator synthesizes the `## Analysis` section.
- **Phases 2–3 (Design/ADRs)** — for a genuinely contested decision, spawn parallel agents arguing each viable option (judge panel), then synthesize the ADR. For simple decisions, draft inline.
- **Phase 5 (Implementation)** — the orchestrator runs a **per-task subagent loop** (one fresh-context `ni:implementer` per task), monitors, re-runs checkpoints, and surfaces gaps — it does **not** implement inline. (Optionally accelerated by Dynamic Workflows where available — see Phase 5.)

**Why this matters**: an orchestrator that does everything inline fills its own context, triggers compaction, and loses the thread. Delegation keeps the orchestrator thin (so it rarely compacts) and gives each unit of work a fresh context (so no single window carries the whole job). This is what restores the "listen to the human while monitoring ongoing work" behavior.

## Structure

the root is `./docs`

```
GLOSSARY.md                     <- at the repo root, not under docs/: one entry per term, written at Phase 6

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

Create the workspace files in as few tool calls as the host allows: one Write per file is
correct, but draft the small files (ADRs under 40 lines) in the same turn as DESIGN.md;
PREFLIGHT.md is never drafted, it is copied (Phase 4c). Never a shell heredoc. The number
of files, not the number of turns, is the measure of a plan.

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

**Decision round.** Skip the round in delegated or one-shot contexts; the agent decides per [SKILL.md](SKILL.md#rules-for-both-routes). With a human present, Phase 3 opens with a round:

1. List every decision whose prerequisites are settled, numbered.
2. Each item names the decision, the options in one line, and the recommended answer with its reason. Phrase it so that "yes" accepts the recommendation.
3. The human replies with numbers and "yes", or an alternative.
4. A decision that depends on an open item waits for the next round.
5. Repeat until nothing is open.
6. Accepted answers go to DESIGN.md, or to an ADR written `accepted` when they pass the admission test below. The round is the ratification; only an ADR drafted outside a round goes to `proposed`.

Not: `3. Cache store: which one do you want?`
Yes: `3. Cache store: SQLite or JSON file. Recommend SQLite: survives restarts, one dependency already present. Yes?`

ADRs emerge during design and keep emerging during implementation as new knowledge surfaces.

**Admission test.** Write an ADR only when all three hold:
1. The decision is hard to reverse.
2. A later reader would not guess the reason without the record.
3. Real alternatives were weighed.

Examples that usually pass: persistence, protocol or API style, public-contract versioning. Also a constraint inherited from an external system, or a security constraint on a crossed boundary.

Not an ADR: conventions go to the DESIGN.md Design section, inherited facts to Context, naming choices to the glossary.

Options weighed with external evidence (benchmarks, adoption, reviews, vendor claims) get the [`bias-analysis`](../bias-analysis/SKILL.md) sweep. Run it before the ADR leaves `draft`. In a judge panel, each panellist sweeps its own evidence.

ADRs link back to the requirements they address:

Template: [templates/adr.md](templates/adr.md). Read it before drafting.

ADR status lifecycle: `draft` -> `proposed` -> `accepted` -> `superseded-by <ref>`

- `draft` — the agent is still working the decision out.
- `proposed` — the agent has finished analysis and has a recommendation, awaiting human ratification. **The agent may drive an ADR to `proposed` autonomously; only the human moves `proposed` -> `accepted`.**
- `accepted` — ratified by the human, in a decision round or from `proposed`; now part of the constitution.
- `superseded-by <ref>` — replaced by a later decision.

### Phase 4 — Write TASKS.md (autopilot-ready)

Phase 4 is the highest-effort phase. Its goal: build a constitution strong enough that the agent never hits an outside-constitution gap during implementation. The agent will adapt within the constitution — that is expected and normal.

Phase 4 has three sub-phases that must be completed in order.

#### Phase 4a — Analysis

Before writing any task, explore the codebase to ground the plan in reality.

**Delegate this — do not explore inline.** Fan out read-only `Explore` or `ni:investigator` subagents **in parallel**, one per axis below. Findings follow the [`evidence-based-analysis`](../evidence-based-analysis/SKILL.md) skill: every claim cites `file:line`. Each returns structured findings; the orchestrator synthesizes them into the `## Analysis` section of TASKS.md (see template below for format). Parallel exploration keeps the orchestrator's context small and shortens wall-clock time. Axes (one subagent each):

- **Build & test commands**: exact commands to build, test, lint, format
- **Domain model**: read GLOSSARY.md first when it exists; its terms are the names the model uses. Then types/structs with attributes, relationships, and requirement traceability
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

**Fit.** The `Fit` field records whether the task text alone carries the work. `closed`: the task is `downhill` and self-contained; every decision is made, the test is named with its expected value, the verify command, the files, the Slice, and the commit are stated, so a fresh subagent on a cheaper model finishes it without asking. `open`: judgement is left to the executor; a decision is pending, a test has no expected value, or two agents would read a constraint differently. An `open` task goes back to the Phase 3 decision round or is split in Phase 4a. Autopilot starts only when every task of the session is `closed`; the executor then has nothing to negotiate, whatever its model ([autopilot.md](autopilot.md#phase-5--implement-autopilot)).

**Slices.** Every task is one slice, per the rule in [SKILL.md](SKILL.md#rules-for-both-routes). The named test enters through the public surface ([`tdd`](../tdd/SKILL.md)). The `Slice` field holds one value:

- `<behaviour and layers>`: the behaviour and the layers it crosses, verified alone.
- `prefactoring`: the task only makes the next slice easy; that slice depends on it.
- `expand`, `migrate`, `contract`: one step of a wide mechanical change, sequenced below.
- `whole — <reason>`: nothing can run before the whole exists; the reason is reviewable.

A wide mechanical change is a rename or a retype whose one edit breaks many callers. Add the new form beside the old (`expand`). Migrate callers in batches sized by blast radius, one task each, depending on the expand task (`migrate`). Remove the old form in a task that depends on every batch (`contract`).

`Depends on` carries the edges. A task whose dependencies are all done is ready; readiness, not numbering, decides the order. Size each task to one fresh context: the task text plus its links is all the agent needs. INVEST applies: Independent, Negotiable, Valuable, Estimable, Small, Testable.

Not: `1. Schema  2. API  3. UI  4. Tests`
Yes: `1. Create an order with one line (schema, API, UI, test)  2. Reject an empty order (API, UI, test)`

#### Phase 4c — Pre-flight gate

Before moving to Phase 5, the entire TASKS.md must pass the pre-flight gate. This is the last human checkpoint before autopilot: the human's "go" starts Phase 5. The plan commit is not that gate.

Copy [templates/preflight.md](templates/preflight.md) to the workspace as `PREFLIGHT.md` with one substitution of `<NAME>` (a single shell command or one Write of the template text), never draft it. Tick every box on disk. Every box must be checked before autopilot starts. The plan-commit instruction lives in the template: once the boxes are ticked, commit the plan in every context, delegated and headless included, and never ask whether to. The copied PREFLIGHT.md keeps the one-line link lint from the template; never expand it into per-shell variants.

### Phase 5 — Implement (autopilot)

Work through TASKS.md session by session: the orchestrator runs a per-task subagent loop, one fresh-context subagent per task, driven by the on-disk TASKS.md checklist. The constitution is enforced on every change; discovery is classified by severity. Read [autopilot.md](autopilot.md) before starting.

### Phase 6 — Integrate

Promote the validated artifacts to their durable home `docs/YYYYMMDD_<NAME>/`. Delete `docs/workspace/<NAME>/` (PREFLIGHT.md dies with TASKS.md) and remove the workspace entry from `CLAUDE.md` `## Active workspaces`. The 8 steps and the commit template are in [autopilot.md](autopilot.md).

## Cross-referencing

Every identifier or reference in any document must be a clickable link to its definition. If an identifier appears and is not a link, it is a defect. The files in `templates/` show the linking conventions — follow them consistently.

## Amending existing work

To amend or extend work that was already integrated:
1. Create a new `docs/workspace/<NAME-v2>/`
2. Reference the existing design by its path: `Amends: [YYYYMMDD_<NAME>/designs/<name>.md](../../YYYYMMDD_<NAME>/designs/<name>.md)`
3. Follow the same workflow (DESIGN.md -> ADRs -> TASKS.md -> quality gates -> integrate)
4. Superseded ADRs get status `superseded-by docs/YYYYMMDD_<NAME>/adrs/<new-slug>.md`
