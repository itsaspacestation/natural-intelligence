# <NAME> — Pre-flight gate

Copy this file to `docs/workspace/<NAME>/PREFLIGHT.md` at Phase 4c, tick every box on disk (the link lint included), then commit the plan.

**Per task**:
- [ ] Types it creates or modifies reference the domain model
- [ ] Constraints are extracted from ADRs, invariants, and transformation rules
- [ ] Tests are defined — named, with expected behavior described (these become the failing tests)
- [ ] Verify command is copy-pasteable and exits 0 on success
- [ ] Acceptance criteria are pass/fail with no subjective language
- [ ] Time-box is set (split if > 90 min)
- [ ] Dependencies on other tasks are declared
- [ ] Every planned domain type appears in the requirement traceability table
- [ ] Task is `downhill` — no uncertainty remains

**Constitution completeness**:
- [ ] Domain model covers every planned domain type in diagram and traceability table
- [ ] Every type in the traceability table maps to at least one FR or NFR
- [ ] Every traceability row has a stability value (`internal` or `published`); each `published` row has a compatibility rule
- [ ] Every NFR has a measure and a verify command (or an explicit `manual: <reason>`)
- [ ] Transformations table covers every function that enforces a domain rule
- [ ] Every failure-modes row that yields a rule appears as an error-path invariant in the transformations table
- [ ] Every DESIGN.md section is filled or marked `N/A: <reason>` — no blank sections
- [ ] No constraint is ambiguous enough that two reasonable agents would interpret it differently
- [ ] Link lint green — every file reference in workspace docs is a clickable link:
  `` ! git grep --untracked -nE '(^|[^[])`([[:alnum:]._-]+/)*[[:alnum:]._-]+\.md(:[0-9]+([-,:][0-9]+)?)?`' -- 'docs/workspace/<NAME>/*.md' ``
  Run from the repository root; `--untracked` scans the workspace before it is staged, so nothing is added to the index; green when the command prints nothing (exit 1 means no match); in cmd use double quotes around the pattern.

**Autopilot readiness**:
- [ ] Build, test, and lint commands pass (green baseline) — run them now and confirm
- [ ] Known-failing tests are explicitly listed with their reason
- [ ] Every session has a `Skills` field — verify each skill name exists
- [ ] Session checkpoints are defined and ordered
- [ ] Total estimated time fits within the target session window (2–4H)

If any item fails, fix it before proceeding.

**Plan commit**: once the pre-flight gate passes, commit all workspace artifacts (`docs/workspace/<NAME>/`) with message:

```
docs(<NAME>): plan ready for autopilot

Phases 1–4 complete. DESIGN.md, ADRs, and TASKS.md pass pre-flight gate.
```

This checkpoint preserves the plan before implementation begins. The plan is the contract — it must be committed before any code changes.
