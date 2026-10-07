---
status: accepted
---
# Terse as output styles: no hooks, two styles, built-in switch

Addresses: [FR1](../DESIGN.md#fr1), [FR10](../DESIGN.md#fr10), [NFR6](../DESIGN.md#nfr6), [NFR7](../DESIGN.md#nfr7), [NFR8](../DESIGN.md#nfr8)

## Problem

ni 1.8.0 carries terse mode on two hooks (`SessionStart`, `UserPromptSubmit`, bash plus
`jq` and `python3`) and one output style with `force-for-plugin: true`. This is the
mechanism adapted from the upstream "caveman" project, and on the current Claude Code
version it does not work at all: the injected level is ignored, replies stay at default
length, and the hooks are the only platform-specific runtime in the plugin. The
upstream mechanism is therefore abandoned, not ported.

Claude Code ships its own built-in `Concise` output style since 2.1.237. A ni terse
mode is only worth shipping if it beats `Concise` on a measured comparison: fewer output
tokens for the same prompts, with every technical fact kept. Users still want three
levels: off, lite, full.

Facts from the Claude Code docs (output-styles and plugins manifest reference):
- A plugin ships styles in `output-styles/`; several files are allowed.
- Frontmatter: `name`, `description`, `keep-coding-instructions` (default `false`),
  `force-for-plugin` (plugin only, overrides the user's `outputStyle`, first loaded wins).
- Users switch with `/output-style <name>` or `/config`; the choice lands in
  `.claude/settings.local.json` (project) or `outputStyle` in `~/.claude/settings.json`.
  A switch takes effect on the next message (2.1.251 and later).
- No documented way for a plugin command to switch the style programmatically.
- Plugin styles surface as `<plugin>:<file stem>`: the 1.8.0 file
  [terse.md](../../../../output-styles/terse.md) is reported as `ni:terse` in this session.

## Options

| Option | Pros | Cons |
|---|---|---|
| A. Two plugin styles [lite.md](../../../../output-styles/lite.md) and [full.md](../../../../output-styles/full.md) (`ni:lite`, `ni:full`); off is `/output-style default`; switching and persistence through the built-in `/output-style` | No runtime, no hooks, works on every host. Documented switch path with live effect and persistence. Nothing to maintain beyond two markdown files. | Users learn one built-in command. |
| B. Same styles plus a `/ni:terse [off\|lite\|full]` command | Familiar name. | Cannot switch or persist (no documented programmatic switch); restates the rules into context on every call; duplicates the style bodies. |
| C. One style with `force-for-plugin: true` | Zero user action. | Overrides the user's own style choice; one level only; this is the 1.8.0 design that did not hold. |
| D. Keep hooks, port to bash 3.2 | Keeps 1.8.0 behaviour. | Mechanism does not work on the current version; platform runtime returns. |

## Decision

Option A.

- [lite.md](../../../../output-styles/lite.md): `description` one sentence,
  `keep-coding-instructions: true`, no `name` (the file stem is the name), no
  `force-for-plugin`. Body: the lite ruleset (no filler, hedging, preamble, recap, or
  tool narration; full sentences under 20 words; technical facts, code, commands, and
  errors exact; persisted text in short full sentences; plain prose for security
  warnings and irreversible actions).
- [full.md](../../../../output-styles/full.md): same frontmatter pattern. Body: the lite
  rules plus drop articles, fragments allowed, shortest synonym, no fake broken grammar,
  no invented abbreviations.
- No command. README documents `/output-style ni:lite`, `/output-style ni:full`,
  `/output-style default`, and the project versus user scope of the setting. The
  picker names are confirmed once from the picker and copied into the README.
- Both bodies are written fresh for ni; no upstream wording is copied, so the
  [NOTICE](../../../../NOTICE) does not change.
- Each body stays under 60 lines.
- **Benchmark against `Concise`** (NFR7): a fixed set of 10 prompts (5 explanation,
  5 code-change requests on a sample repo) runs once under `default`, `concise`,
  `ni:lite`, and `ni:full` with `--output-format json`; output tokens and a per-prompt
  checklist of technical facts are recorded. Ship only if `ni:lite` uses fewer output
  tokens than `concise` and `ni:full` has a shorter visible reply (characters of the
  `result` text) than `ni:lite`, both with every fact kept. Output tokens include
  thinking and tool-call tokens that a style cannot control, so the full-versus-lite
  gap is read on the visible reply and the token figure is reported only. If a style
  fails, rewrite its body and rerun; the ADR stays `proposed` until the table is green.
  The result table goes in the README benchmark section.
- **Measured** (2026-10-07, four full runs): `ni:lite` beat `concise` by 31% to 36% on
  output tokens with all 36 facts kept; `ni:full` wrote 13% to 24% fewer words than
  `ni:lite`; the first body without a scope section was heavier than `default`. The
  scope and length budget, not article dropping, produces the saving.
- **Benchmark against ni 1.8.0** (NFR8): the ni-bench suites already published in the
  README run against 1.8.0 and against the 2.0.0 candidate with `ni:lite`, by a
  maintainer, by hand. Both tables go in the README. A regression beyond 5% on any KPI
  blocks the release.
- What makes the ni styles different from `Concise`: `Concise` shortens prose but keeps
  default structure (openers, summaries, narration between tool calls). `ni:lite` bans
  those structures outright and caps sentence length; `ni:full` also drops articles and
  allows fragments. Both carry the persisted-text and plain-prose exceptions `Concise`
  lacks, so MR text and security warnings stay readable.

## Consequences

Easier: the plugin stays markdown and a manifest; terse works on WSL, Linux, macOS, and
Windows alike; the user owns the choice through a documented Claude Code setting that
persists and switches live. Harder: `/ni:terse` disappears; the README release line
tells users which built-in command replaces it.
