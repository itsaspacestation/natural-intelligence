---
status: accepted
---
# Scenario selection

Addresses: [FR1](../DESIGN.md#fr1), [NFR1](../DESIGN.md#nfr1), [NFR3](../DESIGN.md#nfr3)

## Problem

Scenarios must exercise what the benchmark measures — requirements capture, system design, diagrams, task breakdown — while staying cheap enough to run 3 tools × N scenarios plus repeats under the token cap. They must not favour one tool's vocabulary.

## Options

| Option | Pros | Cons |
|---|---|---|
| A — 3 synthetic scenarios on a fixture repo (small CLI feature; API endpoint + persistence; cross-cutting refactor) | Graduated complexity; persistence scenario forces data/migration and failure-mode design; refactor forces traceability; fixture repo pins codebase state | Synthetic tasks may feel artificial; fixture repo must be built |
| B — Real backlog items from a work repo | Realistic | Not shareable; codebase state drifts; conflicts with reproducibility (NFR1) |
| C — 5+ scenarios across domains | Better coverage | Blows NFR3 cost cap with repeats and judging; more scenarios ≠ more signal at n=1 per cell |

## Decision

Option A. Three scenarios, one shared fixture repo (small, self-contained Rust service, ~1–2k lines, committed under `bench/fixture/`). Rust chosen at ratification: ni:software-engineer covers Rust natively, and all three candidates are language-agnostic, so the choice does not affect fairness. Scenarios:

1. **S1 — CLI flag**: add an output-format flag to an existing command. Tests: basic planning, low design surface.
2. **S2 — API endpoint + persistence**: new endpoint with storage and a schema change. Tests: NFRs, failure modes, data/migration, sequence diagrams.
3. **S3 — cross-cutting refactor**: extract a shared concern (e.g. error handling) used in several modules. Tests: traceability, task decomposition, dependency ordering.

Each scenario is one prompt file in `bench/scenarios/`, worded as a developer would naturally ask ("I want to add X — help me plan it before implementing"). The prompt never names skills or commands of any candidate, and never enumerates deliverables or formats (no "produce diagrams", "write a spec") — per the prompt realism rule in [FR1](../DESIGN.md#fr1).

## Consequences

Easier: reproducible (fixture committed, versions pinned); complexity gradient shows where tools diverge.
Harder: fixture repo is a build task; synthetic scenarios limit external validity — noted in report methodology.
