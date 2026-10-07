---
name: plan
description: "Use when the user asks to plan a task or feature before implementing, create a workspace, write a design doc or ADR, break work into sessions and tasks for autopilot, resume an active workspace, or integrate workspace artifacts into docs."
---
# Plan

## When to use
- User enters plan mode or asks to plan before implementing
- User asks to create a workspace, design doc, ADR, or task breakdown
- User asks to resume, review, or amend an existing design or workspace
- User asks to integrate workspace artifacts into durable storage

## Overview

Planning must always take less time than implementation. The effort scales with
complexity, never the other way around. This file holds the triage: assess the
complexity, then load exactly one route file. Never load both.

## Complexity triage

Assess the work against three triggers, in order:

1. **Resuming?** Root `CLAUDE.md` has an `## Active workspaces` entry → load
   [complex-plan.md](complex-plan.md) and follow its Phase 0.
2. **Multi-session scope?** More than one session of work, more than ~5 tasks, or a
   domain model worth tracing → full workspace: load [complex-plan.md](complex-plan.md).
3. **Hard-to-reverse decision?** Persistence, protocol, public contract → that
   decision gets an ADR whatever the route; the route still follows trigger 2.

None of the above → small plan: load [small-plan.md](small-plan.md) and produce one
document. Heavy scaffolding on a small task reads as noise to the human and costs
tokens without adding decisions.

The complex route reads [autopilot.md](autopilot.md) at Phase 5 and drafts from
[templates/](templates/DESIGN.md).

## Rules for both routes

**Delegated and one-shot contexts: decide, do not ask.** When the requester has
delegated ("your call", "decide and continue") or cannot answer (headless run, batch
job), make the decision, record it with its reason, and continue. Ask only when
blocked by a genuine externality the codebase and brief cannot resolve (a credential,
an unstated business rule). Ratification questions in a delegated context burn turns
without adding information.

**The machine layer never disappears, it shrinks.** Every plan ends with resumable
state on disk: the full TASKS.md checklist on the complex route, the minimal task
section on the small route. A plan an agent cannot resume from is a chat message,
not a plan.

**Driving an implementation**: the [`tdd`](../tdd/SKILL.md) red run is a gate, not a
suggestion — implementation starts after the failing run is captured, and the final
report quotes it.

## Boundaries

Claude Code's built-in plan mode covers interactive approval of an immediate change;
once a plan should persist to disk, this skill owns it at either scale. Implementation
methodology belongs to [`software-engineer`](../software-engineer/SKILL.md) and
[`tdd`](../tdd/SKILL.md); commits to [`git-conventions`](../git-conventions/SKILL.md).
Commands follow the shell rules in [`software-engineer`](../software-engineer/SKILL.md#onboarding).
