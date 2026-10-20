<p align="center"><img src="assets/logo.svg" alt="ni" width="300"></p>

[![Linux](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/linux.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/linux.yml) [![Windows](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/windows.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/windows.yml) [![macOS](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/macos.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/macos.yml)

# ni

**Never Claude alone.** You and I: Claude NI.

**ni** stands for natural intelligence, as opposed to artificial. Say it *nickel* (French: spot on, good enough) or *nice* (UK/US). Either way, it is the human staying in the loop.

ni is a Claude Code plugin, distributed through the [itsaspacestation marketplace](https://github.com/itsaspacestation/claude-marketplace). Its `skills/` folder also works as a plain skills source for Copilot CLI, Cursor, and Gemini CLI.

## Benchmark vs other plugin

Medians of 3 trials per scenario, [ni-bench](https://github.com/itsaspacestation/ni-bench), claude-sonnet-5-5, Claude Code 2.1.285, 2026-10-20. ni 2.2.0 runs the `ni:full` output style. Resource percentages are relative to the best arm (100%); 🏆 marks the best plugin.

### ported-build (superpowers-evals)

| KPI | baseline | openspec 1.14.3 | superpowers 7.0.0 | ni 2.2.0 | mattpocock 1.3.1 |
|---|---|---|---|---|---|
| tokens_total | 100% (2 018 tok) | 43% (4 707 tok) | 47% (4 265 tok) | 38% (5 375 tok) | 39% (5 221 tok) |
| cost_usd | 100% ($0.0608) | 37% ($0.1627) | 48% ($0.1261) | 35% ($0.1743) | 25% ($0.2473) |
| duration_s | 100% (14.7 s) | 37% (39.2 s) | 52% (28.4 s) | 34% (42.8 s) | 27% (53.5 s) |
| turns | 100% (5) | 50% (10) | 45% (11) | 33% (15) | 28% (18) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 62% (62) | 68% (68) | 62% (62) | 🏆82% (82) | 72% (72) |
| agent_executability | 40% (40) | 40% (40) | 55% (55) | 🏆85% (85) | 62% (62) |
| verbosity_score | 85% (85) | 72% (72) | 78% (78) | 85% (85) | 68% (68) |
| outcome | 67% (2/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

### ported-debug (superpowers-evals)

| KPI | baseline | openspec 1.14.3 | superpowers 7.0.0 | ni 2.2.0 | mattpocock 1.3.1 |
|---|---|---|---|---|---|
| tokens_total | 100% (593 tok) | 93% (638 tok) | 55% (1 084 tok) | 53% (1 119 tok) | 50% (1 181 tok) |
| cost_usd | 100% ($0.0344) | 99% ($0.0347) | 44% ($0.0779) | 50% ($0.0687) | 49% ($0.0702) |
| duration_s | 100% (7.4 s) | 85% (8.7 s) | 58% (12.8 s) | 62% (11.9 s) | 63% (11.7 s) |
| turns | 100% (3) | 100% (3) | 50% (6) | 50% (6) | 75% (4) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 78% (78) | 80% (80) | 85% (85) | 🏆88% (88) | 86% (86) |
| agent_executability | 45% (45) | 45% (45) | 62% (62) | 🏆82% (82) | 62% (62) |
| verbosity_score | 88% (88) | 88% (88) | 90% (90) | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |
### Reply styles vs built-in styles

| style | output tokens | reply chars | facts kept | words |
|---|---|---|---|---|
| default | 4911 | 9175 | 36/36 | 1494 |
| concise | 5286 | 10146 | 36/36 | 1617 |
| ni:lite | 3374 | 5618 | 36/36 | 899 |
| ni:full | 3271 | 3445 | 36/36 | 521 |

Setup: 10 prompts, sonnet replies, haiku judge, Claude Code 2.1.292, 2026-10-07, `scripts/style-bench.sh` in [ni-bench](https://github.com/itsaspacestation/ni-bench). ni:lite is 36% under concise on output tokens, ni:full 39% under ni:lite on visible characters, all facts kept.

## Quick tour
Claude does the heavy lifting. You make the calls. Skills trigger on their own from what you ask; the prompts below are examples.

### 1. Set up
Install as above, run `/reload-plugins`, then `/ni:help` to check the skills are loaded.

### 2. Claude plans, and I decide
> /ni:plan a workspace for the invoice export feature.

or simply
> Plan a workspace for the invoice export feature.

`ni:plan` explores the codebase and drafts `DESIGN.md`, ADRs, and `TASKS.md` under `docs/workspace/<name>/`. You spend about 30 to 40 minutes reviewing scope, settling the ADRs, and approving the tasks. Then say go: Claude runs the tasks on autopilot and stops only when a decision falls outside the plan.

For a small change, Claude Code's built-in plan mode is enough.

### 3. Claude builds, and I steer
> Fix the rounding bug in the VAT total.

`ni:software-engineer`, `ni:tdd`, and `ni:debug` enforce plan, failing test, fix, and commit, with the root cause found before any fix. `ni:git-conventions` writes the commit and the MR or PR description, routing to the right forge from the origin remote. Nothing is pushed without your go.

### 4. Claude reviews, and I judge
> /ni:code-review my branch before I open the MR.

or simply

> Review my branch before I open the MR.

`ni:code-review` checks design, tests, performance, security, and correctness, and cites every finding by file and line. You decide what to fix.

### 5. Claude reviews others, and I sign off
```
/ni:review-loop group/project
```
Works on GitLab and GitHub: pass a project path or URL, or let it read the origin remote. Reviews every MR or PR assigned to you in a loop, posts each finding as its own discussion, and reports the links. It never approves, merges, or resolves: those stay yours.

### 6. Claude merges mine once approved
```
/ni:merge-loop group/project
```
Watches your own MRs or PRs in a loop and merges each one once every reviewer has approved, threads are resolved, and CI is green. Anything blocked is reported with its reason, never forced.

### 7. Claude answers reviewers, and I approve
> Address the unresolved threads on MR !42 (or PR #42).

`ni:code-review` reads the threads, drafts the fixes and replies, and shows you a preview. Nothing is posted or resolved until you approve it.

## Requirements
- Claude Code with its own [system requirements](https://code.claude.com/docs/en/setup) per OS: macOS, Linux, or Windows (native or WSL).
- Claude Code 2.1.251 or later for live output-style switching with `/output-style`.
- `glab` for GitLab or `gh` for GitHub, depending on the forge the project uses.
- VS Code with the draw.io extension, or draw.io, only to render and export c4-graph output.

ni ships no scripts and assumes no shell: the commands in the skills are shell-neutral and run in bash, PowerShell, and cmd.

## Install
Inside Claude Code:
```
/plugin marketplace add itsaspacestation/claude-marketplace
/plugin install ni@itsaspacestation
```

Or from a shell:
```bash
claude plugin marketplace add itsaspacestation/claude-marketplace
claude plugin install ni@itsaspacestation            # user scope, every project
claude plugin install ni@itsaspacestation -s project # this project only, written to .claude/settings.json
```

Run `/reload-plugins` or start a new session. `/ni:help` lists the skills.

For a team, commit this to the project's `.claude/settings.json`. Claude Code offers the install on first launch:
```json
{
  "extraKnownMarketplaces": {
    "itsaspacestation": { "source": { "source": "github", "repo": "itsaspacestation/claude-marketplace" } }
  },
  "enabledPlugins": { "ni@itsaspacestation": true }
}
```

For other agents, copy `skills/` into `~/.copilot/`, `~/.cursor/`, or `~/.gemini/` (Windows: `%USERPROFILE%\.copilot`, `%USERPROFILE%\.cursor`, `%USERPROFILE%\.gemini`).

## Reply styles
ni ships two output styles. Switch live inside Claude Code:
```
/output-style ni:lite
/output-style ni:full
/output-style default
```

- `ni:lite`: no filler, full sentences, every technical fact kept, a scope budget per reply.
- `ni:full`: the same budget, and it also drops articles and allows fragments.
- `default`: Claude Code's built-in style.

The choice persists as `outputStyle`: per project in `.claude/settings.local.json`, or for every project in `~/.claude/settings.json` (Windows: `%USERPROFILE%\.claude\settings.json`). Live switching needs Claude Code 2.1.251 or later.

## Layout
| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest, name `ni` |
| `agents/` | Subagents with compressed output, spawned as `ni:<agent>` |
| `commands/` | Slash commands, invoked as `/ni:<command>` |
| `skills/` | The skills, invoked as `ni:<skill>` |

## Update
Auto-update is off by default for third-party marketplaces. Turn it on in `/plugin`, under **Marketplaces**, or update by hand:
```bash
claude plugin marketplace update itsaspacestation
claude plugin update ni@itsaspacestation
```
Restart Claude Code to apply.

## Develop
```bash
claude plugin validate . --strict
claude --plugin-dir .   # load from the working tree
bash .github/scripts/docs.test.sh   # docs lint, runs in CI
```

## Release
Users only get an update when `version` in `.claude-plugin/plugin.json` changes.

1. Bump `version` (semver) and commit.
2. `claude plugin validate . --strict`
3. `claude plugin tag .` creates the `ni--v<version>` tag, then push the commit and the tag.

The marketplace entry tracks the default branch, so the marketplace repository needs no change for a release.

### 2.3.0

- `create-grafana-dashboards`: new skill; infrastructure as code read first, metrics chosen from the vendor's official monitoring page, rows by RED mirroring that page's sections, quotas drawn next to their consumption metric, a pricing preview with a log-derived alternative for every paid metric family, decided by the user, generated and linted JSON in template form, a first live review, README without vendor figures, and screenshots supplied by the human and anonymised by Claude.

### 2.2.0

- `plan`: an ADR is written only when the decision is hard to reverse, surprising later, and weighed against alternatives.
- `plan`: C4, STRIDE, and sequence diagrams only when the system calls for them.
- `plan`: Phase 3 opens with a decision round when a human is present; delegated runs still decide alone.
- `plan`: a root `GLOSSARY.md`, written at integration, read at onboarding.
- `plan`: every task is a vertical slice, one behaviour across every layer it touches, verifiable alone; a wide mechanical change goes expand, migrate, contract.
- `git-conventions`: a change description carries a visual summary, before and after evidence, a reversibility call, and the checklist.
- `debug`: a tight reproduction loop before any hypothesis, a minimise phase, tagged probes.
- `tdd`: the acceptance test enters through the public surface.
- `plan`: one task at a time, each closed by its own commit, headless included; no batch of tests first, no boxes ticked at the end; a test green on its first run folds into the previous commit, never a tests-only commit.
- `plan`: the small route's plan document stays untracked; task commits carry code and tests only.
- `plan`, `tdd`: an implementation covers its own failing test only, so the next slice goes red; the complex route commits the plan at pre-flight in every context, without asking.
- `git-conventions`: stage by path, never `git add -A`; generated files are never committed.
- `plan`: a `Fit` field per task, `closed` or `open`; autopilot starts only when every task is closed, and a closed task runs on a cheaper subagent model.
- `plan`: a task subagent returns `done`, `blocked: <question>`, or `gap: <adr>`; it never pauses or asks the user.
- `code-review`: an Intent category, items 37 to 40, checks the diff against the request.
- `code-review`: item 40 checks that each commit lands one behaviour end to end.
- `retro`: new skill; turns a session's friction into checks, conventions, or pointers.

## Skills
| Skill | Use when |
|---|---|
| `ni:software-engineer` | Implementing, fixing, or refactoring with the plan, test, implement, commit workflow; onboarding on an existing project: commands discovered from the CI pipeline, wrappers, lock files, and repository conventions |
| `ni:tdd` | Writing tests first, red-green-refactor |
| `ni:debug` | Any failure or bug, before proposing a fix |
| `ni:plan` | Multi-session work with a durable workspace, design doc, and ADRs |
| `ni:git-conventions` | Any git operation, commit messages, MR or PR descriptions; routes to the forge from the origin remote and keeps the git-versus-forge boundary |
| `ni:code-review` | Reviewing a change or answering reviewer comments, GitLab and GitHub threads via glab and gh included; posts findings as one-click applicable suggestions on both forges and resolves its own threads once a new commit fixes the finding |
| `ni:retro` | After a session or a plan: turns friction into checks, conventions, or pointers; never touches product code |
| `ni:evidence-based-analysis` | Any claim about the codebase, cited by file and line |
| `ni:bias-analysis` | Comparative studies from field reports, reviews, or statistics: bias checklist sweep with verdicts |
| `ni:skill` | Creating or editing a ni skill, agent, or command |
| `ni:c4-graph` | C4 architecture diagrams as draw.io files on the C4 palette with line jumps on crossings, rendered in VS Code or draw.io and embedded as `.drawio.svg`; converts text, DOT, and draw.io sources |
| `ni:create-grafana-dashboards` | Grafana dashboards for a service, cloud resource, or runtime: metrics from the vendor's official monitoring page, rows by RED or USE, pricing preview before keeping a paid metric family or its log alternative, README with screenshots supplied by the human |

Run `/ni:help` inside Claude for the same list.

## Commands
User-invoked only; none loads on its own.

| Command | Does |
|---|---|
| `/ni:help` | List the ni skills |
| `/ni:review-loop` | Review MRs or PRs assigned to me in a /loop on GitLab or GitHub, post findings as one-click applicable suggestions where possible, resolve its own threads once a new commit fixes the finding, report the links |
| `/ni:merge-loop` | Merge my MRs or PRs approved by every reviewer in a /loop, report merged and blocked ones |

## Agents
Subagent results land in the main context verbatim, so these three return structured one-liners instead of prose.

| Agent | Use for | Returns |
|---|---|---|
| `ni:investigator` | Where is X defined, what calls Y, map this directory | `path:line - symbol - note` rows |
| `ni:builder` | Surgical edit of 1 or 2 known files | Diff receipt, or `too-big.` / `ambiguous.` |
| `ni:reviewer` | Findings-only review of a diff, branch, or file | `path:L42: severity: problem. fix.` rows |

Rule of thumb: want the result in a third of the tokens, pick ni. Want prose, pick the vanilla agent.

## Latest benchmark
benchmark tool: [ni-bench](https://github.com/itsaspacestation/ni-bench)

### Latest report
run-20261020-143432, 2026-10-20, n=3, claude-sonnet-5-5; ni 2.2.0 runs `ni:full`.

#### plan-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 88% (2 456 tok) | 54% (3 998 tok) | 53% (4 101 tok) | 100% (2 161 tok) | 54% (3 989 tok) |
| cost_usd | 100% ($0.0674) | 52% ($0.1289) | 56% ($0.1210) | 77% ($0.0879) | 42% ($0.1621) |
| duration_s | 100% (22.3 s) | 54% (41.2 s) | 70% (31.6 s) | 100% (22.2 s) | 65% (34.1 s) |
| turns | 100% (4) | 50% (8) | 67% (6) | 57% (7) | 44% (9) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 0% (1) |
| plan_words | 48% (691 words) | 44% (753 words) | 34% (978 words) | 75% (443 words) | 100% (332 words) |
| machine_words | 0 words | 189 words | 0 words | 0 words | 108 words |
| human_readability | 90% (90) | 85% (85) | 88% (88) | 90% (90) | 85% (85) |
| agent_executability | 85% (85) | 80% (80) | 85% (85) | 88% (88) | 72% (72) |
| verbosity_score | 85% (85) | 80% (80) | 82% (82) | 88% (88) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### plan-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 100% (8 166 tok) | 62% (13 126 tok) | 66% (12 340 tok) | 33% (24 395 tok) | 67% (12 215 tok) |
| cost_usd | 100% ($0.1370) | 43% ($0.3212) | 31% ($0.4469) | 28% ($0.4880) | 42% ($0.3269) |
| duration_s | 100% (63.4 s) | 61% (104.4 s) | 74% (85.4 s) | 38% (166.7 s) | 69% (92.3 s) |
| turns | 100% (3) | 27% (11) | 60% (5) | 21% (14) | 25% (12) |
| user_turns | 100% (0) | 100% (0) | 0% (1) | 100% (0) | 0% (1) |
| plan_words | 85% (2 503 words) | 65% (3 269 words) | 65% (3 251 words) | 100% (2 129 words) | 80% (2 657 words) |
| machine_words | 0 words | 730 words | 0 words | 3 610 words | 813 words |
| human_readability | 88% (88) | 88% (88) | 88% (88) | 88% (88) | 88% (88) |
| agent_executability | 62% (62) | 72% (72) | 80% (80) | 88% (88) | 62% (62) |
| verbosity_score | 78% (78) | 82% (82) | 78% (78) | 72% (72) | 82% (82) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 67% (2/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### debug-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 73% (388 tok) | 100% (285 tok) | 42% (674 tok) | 36% (800 tok) | 42% (672 tok) |
| cost_usd | 94% ($0.0325) | 100% ($0.0307) | 43% ($0.0713) | 51% ($0.0601) | 50% ($0.0607) |
| duration_s | 97% (5.7 s) | 100% (5.5 s) | 62% (8.9 s) | 60% (9.3 s) | 70% (7.9 s) |
| turns | 75% (4) | 100% (3) | 43% (7) | 50% (6) | 60% (5) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 70% (70) | 70% (70) | 85% (85) | 92% (92) | 85% (85) |
| agent_executability | 35% (35) | 30% (30) | 40% (40) | 80% (80) | 55% (55) |
| verbosity_score | 90% (90) | 90% (90) | 90% (90) | 85% (85) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### debug-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 92% (912 tok) | 100% (835 tok) | 67% (1 244 tok) | 65% (1 293 tok) | 68% (1 219 tok) |
| cost_usd | 97% ($0.0475) | 100% ($0.0462) | 54% ($0.0854) | 61% ($0.0760) | 63% ($0.0739) |
| duration_s | 94% (11.1 s) | 100% (10.5 s) | 72% (14.6 s) | 67% (15.7 s) | 77% (13.7 s) |
| turns | 100% (5) | 100% (5) | 71% (7) | 71% (7) | 100% (5) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 80% (80) | 80% (80) | 88% (88) | 90% (90) | 85% (85) |
| agent_executability | 50% (50) | 55% (55) | 62% (62) | 82% (82) | 55% (55) |
| verbosity_score | 85% (85) | 88% (88) | 88% (88) | 88% (88) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### build-small (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 100% (1 781 tok) | 92% (1 942 tok) | 59% (3 038 tok) | 40% (4 435 tok) | 64% (2 783 tok) |
| cost_usd | 100% ($0.0648) | 94% ($0.0688) | 47% ($0.1387) | 38% ($0.1722) | 26% ($0.2458) |
| duration_s | 97% (16.7 s) | 100% (16.1 s) | 59% (27.3 s) | 36% (44.4 s) | 49% (33.0 s) |
| turns | 100% (5) | 83% (6) | 50% (10) | 29% (17) | 42% (12) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 70% (70) | 70% (70) | 78% (78) | 82% (82) | 80% (80) |
| agent_executability | 55% (55) | 55% (55) | 60% (60) | 85% (85) | 72% (72) |
| verbosity_score | 85% (85) | 72% (72) | 82% (82) | 85% (85) | 80% (80) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-debug (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 100% (593 tok) | 93% (638 tok) | 55% (1 084 tok) | 53% (1 119 tok) | 50% (1 181 tok) |
| cost_usd | 100% ($0.0344) | 99% ($0.0347) | 44% ($0.0779) | 50% ($0.0687) | 49% ($0.0702) |
| duration_s | 100% (7.4 s) | 85% (8.7 s) | 58% (12.8 s) | 62% (11.9 s) | 63% (11.7 s) |
| turns | 100% (3) | 100% (3) | 50% (6) | 50% (6) | 75% (4) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 78% (78) | 80% (80) | 88% (88) | 88% (88) | 88% (88) |
| agent_executability | 45% (45) | 45% (45) | 62% (62) | 82% (82) | 62% (62) |
| verbosity_score | 88% (88) | 88% (88) | 90% (90) | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-build (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni 2.2.0 | mattpocock |
|---|---|---|---|---|---|
| tokens_total | 100% (2 018 tok) | 43% (4 707 tok) | 47% (4 265 tok) | 38% (5 375 tok) | 39% (5 221 tok) |
| cost_usd | 100% ($0.0608) | 37% ($0.1627) | 48% ($0.1261) | 35% ($0.1743) | 25% ($0.2473) |
| duration_s | 100% (14.7 s) | 37% (39.2 s) | 52% (28.4 s) | 34% (42.8 s) | 27% (53.5 s) |
| turns | 100% (5) | 50% (10) | 45% (11) | 33% (15) | 28% (18) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 62% (62) | 68% (68) | 62% (62) | 82% (82) | 72% (72) |
| agent_executability | 40% (40) | 40% (40) | 55% (55) | 85% (85) | 62% (62) |
| verbosity_score | 85% (85) | 72% (72) | 78% (78) | 85% (85) | 68% (68) |
| outcome | 67% (2/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 | 0/3 |
