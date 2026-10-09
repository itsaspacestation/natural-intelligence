# Small plan — one document

Reference file of the [`plan`](SKILL.md) skill. Route: single-session task, no
multi-session trigger (see the triage in SKILL.md).

## Format

One markdown file, four sections, nothing else. No PREFLIGHT.md, no adrs/ folder, no
Mermaid diagram. An ADR exists only for persistence or a wire protocol. Every other
choice is an inline bullet: an additive flag, a CLI option, an output shape. This
applies to build tasks too.

```markdown
# <task> — plan

## Goal
One or two sentences: what exists when this is done, and how it is verified.

## Decisions
- <choice>: <option taken> — <reason in one clause>

## Tasks
- [ ] <task> — test: `<named test>` — verify: `<command>`
- [ ] <task> — test: `<named test>` — verify: `<command>`
Resume: continue at the first unchecked task; re-run the last verify before trusting state.

## Out of scope
- <explicitly excluded item> (one line each, only when the brief invites scope creep)
```

## Rules

- Decisions: at most five bullets, one per question the brief leaves open. Never
  restate what the brief fixes.
- The `## Tasks` section is the machine layer: checkboxes, named tests, verify
  commands, the resume line. A few dozen words protect the crash, rate-limit, and
  compaction cases that the full TASKS.md protects on multi-session work.
- Tasks are test-first by construction: each task names its test. Write no prose
  about TDD or the red run. No baseline task, no "run existing tests" task.
- Each task names the file and the function it changes. One behaviour per task: the
  flag wiring, the output shape, each option interaction, the error path, and the
  unchanged default are separate tasks. The five-bullet cap applies to Decisions,
  never to Tasks.
- Each named test states its assertion with a concrete expected value.
- Never name a skill or plugin inside the document.
- No documentation or help-text task unless the brief asks. Help text belongs to the
  task that adds the flag.
- Out of scope: omit the section unless the brief invites scope creep. Three lines
  at most. Extras become one line there, never sections or tasks.
- Plan exactly what the brief asks.
- The small route reads code and runs nothing. Commands run when the tasks do.
- Code snippets stay illustrative — shapes and signatures, not implementations.
- Tick boxes as tasks complete; the document is the progress tracker.

## Escalation

A small plan that grows a second hard-to-reverse decision, a domain model, or a
second session of work has outgrown this route: re-run the triage in
[`plan`](SKILL.md), switch to the complex route, and carry the content over. Say so
in one line; never maintain both formats in parallel.
