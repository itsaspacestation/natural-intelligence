---
status: accepted
---
# Token measurement source

Addresses: [FR3](../DESIGN.md#fr3), [NFR1](../DESIGN.md#nfr1)

## Problem

Token consumption is a headline KPI. Claude Code exposes usage three ways: session transcript JSONL (`~/.claude/projects/**/*.jsonl`, per-message `usage` fields), OTEL metrics export, and interactive `/cost`. The source must be scriptable, per-run attributable, and reproducible.

## Options

| Option | Pros | Cons |
|---|---|---|
| A — Transcript JSONL | Per-message granularity (input, output, cache_read, cache_creation); already written by every run; parseable offline after the run; no setup | Path resolution per project dir needed; format is internal, may change between CLI versions |
| B — OTEL export | Official telemetry surface | Requires collector setup; aggregated metrics lose per-message detail; overkill for local one-operator runs |
| C — `/cost` | Zero setup | Interactive only; not machine-readable; no breakdown |

## Decision

Option A. The runner records the session id at launch, locates its transcript, and the metrics extractor sums the four usage fields per run into `metrics.json`. Context overhead (skill injection) is measured as input tokens of the first user turn minus the scenario prompt's own token count. CLI version pinned in `run-meta.json`; extractor asserts the expected JSONL shape and fails loudly on schema drift (see Failure modes: version drift).

## Consequences

Easier: zero infrastructure; per-message breakdown enables the context-overhead metric.
Harder: internal-format dependency — a CLI upgrade can break the extractor; mitigated by pinning and shape assertion.
