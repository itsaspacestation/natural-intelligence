---
status: accepted
---
# Judge model and blinding protocol

Addresses: [FR4](../DESIGN.md#fr4), [NFR2](../DESIGN.md#nfr2)

## Problem

Quality scores (FR4) drive the headline comparison. A biased or noisy judge invalidates the benchmark. Three choices bundle here: which model judges, how scoring noise is controlled, and how blinding works.

## Options

| Option | Pros | Cons |
|---|---|---|
| A — Claude Opus judge, 3× median per dimension, anonymised artifacts | Strong rubric-following; median kills outlier scores; same API already in use | Same-family bias: Claude judging Claude-generated artifacts; judge cost ~3× |
| B — Claude Sonnet judge, 3× median | Cheaper; still adequate for rubric scoring | Weaker on long multi-file artifact sets; same family bias |
| C — Cross-vendor judge (e.g. GPT) | Removes same-family bias | New dependency, new API key, harder to reproduce for team; style bias replaces family bias |
| D — Human-only scoring | No model bias | Does not scale to 9 runs × 5 dimensions × 3 repeats; subjective drift |

## Decision

Option A. All three tools produce artifacts via the same underlying model, so same-family bias applies equally to every candidate — it shifts absolute scores, not the ranking. Blinding protocol:

1. Copy artifacts to `judged/<run-id>/`, strip tool names, file names normalised (`doc-1.md`, `doc-2.md`), directory structure flattened with an index.
2. NFR2 grep gate must pass before judging.
3. Judge scores each dimension 3 times in independent calls; median kept.
4. Human spot-checks 20% of (artifact, dimension) pairs; disagreement > 1 point on more than a third of the sample triggers one rubric-calibration pass (capped per Rabbit holes).

## Consequences

Easier: reproducible with existing tooling and credentials; ranking robust to shared bias.
Harder: absolute scores not comparable to other benchmarks; judging adds ~3× rubric-call cost, covered by [NFR3](../DESIGN.md#nfr3) cap.
