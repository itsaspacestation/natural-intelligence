# cross-platform — Pre-flight gate

Tick every box on disk, then commit the plan. Human gate: nothing below is ticked by the agent.

**Per task**:
- [x] Types it creates or modifies reference the domain model
- [x] Constraints are extracted from ADRs, invariants, and transformation rules
- [x] Tests are defined — named, with expected behavior described (these become the failing tests)
- [x] Verify command is copy-pasteable and exits 0 on success
- [x] Acceptance criteria are pass/fail with no subjective language
- [x] Time-box is set (split if > 90 min)
- [x] Dependencies on other tasks are declared
- [x] Every planned domain type appears in the requirement traceability table
- [x] Task is `downhill` — no uncertainty remains

**Constitution completeness**:
- [x] Domain model covers every planned domain type in diagram and traceability table
- [x] Every type in the traceability table maps to at least one FR or NFR
- [x] Every traceability row has a stability value (`internal` or `published`); each `published` row has a compatibility rule
- [x] Every NFR has a measure and a verify command (or an explicit `manual: <reason>`)
- [x] Transformations table covers every function that enforces a domain rule
- [x] Every failure-modes row that yields a rule appears as an error-path invariant in the transformations table
- [x] Every DESIGN.md section is filled or marked `N/A: <reason>` — no blank sections
- [x] No constraint is ambiguous enough that two reasonable agents would interpret it differently
- [x] Link lint green — every file reference in workspace docs is a clickable link. Run from the repository root; green when the command prints nothing (exit 1 means no match):
  `` ! git grep -nE '(^|[^[])`([[:alnum:]._-]+/)*[[:alnum:]._-]+\.md(:[0-9]+([-,:][0-9]+)?)?`' -- 'docs/workspace/cross-platform/*.md' ``

**Autopilot readiness**:
- [x] Build, test, and lint commands pass (green baseline) — no suite exists before task 1; baseline is `claude plugin validate .`
- [x] Known-failing tests are explicitly listed with their reason
- [x] Every session has a `Skills` field — verify each skill name exists
- [x] Session checkpoints are defined and ordered
- [x] Total estimated time fits within the target session window (2–4H)

**ADR ratification** (human moves `proposed` to `accepted`):
- [ ] [output-styles](./adrs/output-styles.md) — stays `proposed` until tasks 10 and 11 pass (NFR7, NFR8)
- [x] [project-onboarding](./adrs/project-onboarding.md)

**Plan commit**: once the gate passes, commit `docs/workspace/cross-platform/` and the root [CLAUDE.md](../../../CLAUDE.md) with:

```
docs(cross-platform): plan ready for autopilot

Phases 1–4 complete. DESIGN.md, ADRs, and TASKS.md pass pre-flight gate.
```

Task 0 then commits the removal as its own change, with this message:

```
refac!: remove hook-based terse mode

The injected level no longer applies since the current Claude Code
version. Drops scripts/, the 1.8.0 terse command, output style, and skill,
the hooks block in plugin.json, and every terse-level reference. Output
styles replace the hooks in a later commit.

BREAKING CHANGE: ~/.claude/ni/terse is no longer read; /ni:terse is gone,
use /output-style ni:lite, ni:full, or default.
```
