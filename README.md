<p align="center"><img src="assets/logo.svg" alt="ni" width="300"></p>

[![Linux](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/linux.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/linux.yml) [![Windows](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/windows.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/windows.yml) [![macOS](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/macos.yml/badge.svg)](https://github.com/itsaspacestation/natural-intelligence/actions/workflows/macos.yml)

# ni

**Never Claude alone.** You and I: Claude NI.

**ni** stands for natural intelligence, as opposed to artificial. Say it *nickel* (French: spot on, good enough) or *nice* (UK/US). Either way, it is the human staying in the loop.

ni is a Claude Code plugin, distributed through the [itsaspacestation marketplace](https://github.com/itsaspacestation/claude-marketplace). Its `skills/` folder also works as a plain skills source for Copilot CLI, Cursor, and Gemini CLI.

## Benchmark vs other plugin

Medians of 3 trials per scenario, [ni-bench](https://github.com/itsaspacestation/ni-bench), claude-sonnet-5-5, Claude Code 2.1.285, 2026-10-09. ni 2.0.0 runs the `ni:full` output style. Resource percentages are relative to the best arm (100%); 🏆 marks the best plugin.

### ported-build (superpowers-evals)

| KPI | baseline | openspec 1.14.1 | superpowers 6.4.2 | ni 2.0.0 |
|---|---|---|---|---|
| tokens_total | 100% (1 854 tok) | 44% (4 187 tok) | 52% (3 548 tok) | 🏆53% (3 494 tok) |
| cost_usd | 100% ($0.0547) | 34% ($0.1593) | 48% ($0.1151) | 🏆52% ($0.1058) |
| duration_s | 100% (13.5 s) | 32% (42.0 s) | 52% (26.2 s) | 🏆53% (25.3 s) |
| turns | 100% (4) | 44% (9) | 40% (10) | 🏆44% (9) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 62% (62) | 68% (68) | 68% (68) | 🏆82% (82) |
| agent_executability | 45% (45) | 62% (62) | 62% (62) | 🏆80% (80) |
| verbosity_score | 85% (85) | 78% (78) | 80% (80) | 🏆82% (82) |
| outcome | 100% (3/3) | 67% (2/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

### ported-debug (superpowers-evals)

| KPI | baseline | openspec 1.14.1 | superpowers 6.4.2 | ni 2.0.0 |
|---|---|---|---|---|
| tokens_total | 86% (664 tok) | 100% (571 tok) | 53% (1 073 tok) | 52% (1 088 tok) |
| cost_usd | 97% ($0.0354) | 100% ($0.0341) | 44% ($0.0777) | 46% ($0.0735) |
| duration_s | 90% (8.4 s) | 100% (7.5 s) | 57% (13.1 s) | 63% (11.9 s) |
| turns | 100% (3) | 100% (3) | 50% (6) | 50% (6) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 78% (78) | 80% (80) | 85% (85) | 🏆88% (88) |
| agent_executability | 40% (40) | 40% (40) | 55% (55) | 🏆80% (80) |
| verbosity_score | 90% (90) | 90% (90) | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

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
- Chrome, only for the c4-graph PNG export.

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

An install is a full clone of this repository: `.github/` ships with the plugin but is never loaded; `docs/` and `CLAUDE.md` exist only on pull requests and are removed before merge.

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

### 2.0.0
2.0.0 drops the hook-based terse mode, which no longer works on current Claude Code, for ni's own output styles: run `/output-style ni:lite` or `/output-style ni:full`; `~/.claude/ni/terse` may be deleted.
Language reference files are replaced by project onboarding (`ni:software-engineer`).

## Skills
| Skill | Use when |
|---|---|
| `ni:software-engineer` | Implementing, fixing, or refactoring with the plan, test, implement, commit workflow; onboarding on an existing project: commands discovered from the CI pipeline, wrappers, lock files, and repository conventions |
| `ni:tdd` | Writing tests first, red-green-refactor |
| `ni:debug` | Any failure or bug, before proposing a fix |
| `ni:plan` | Multi-session work with a durable workspace, design doc, and ADRs |
| `ni:git-conventions` | Any git operation, commit messages, MR or PR descriptions; routes to the forge from the origin remote and keeps the git-versus-forge boundary |
| `ni:code-review` | Reviewing a change or answering reviewer comments, GitLab and GitHub threads via glab and gh included; posts findings as one-click applicable suggestions on both forges and resolves its own threads once a new commit fixes the finding |
| `ni:evidence-based-analysis` | Any claim about the codebase, cited by file and line |
| `ni:bias-analysis` | Comparative studies from field reports, reviews, or statistics: bias checklist sweep with verdicts |
| `ni:skill` | Creating or editing a ni skill, agent, or command |
| `ni:c4-graph` | C4 architecture diagrams as crossing-minimised mermaid flowcharts for GitLab and VS Code; converts text, DOT, and draw.io sources |

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
run-20261009-171135, 2026-10-09, n=3, claude-sonnet-5-5; ni 2.0.0 runs `ni:full`.

#### plan-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 86% (2 481 tok) | 47% (4 564 tok) | 49% (4 423 tok) | 100% (2 146 tok) |
| cost_usd | 100% ($0.0692) | 44% ($0.1572) | 52% ($0.1328) | 76% ($0.0910) |
| duration_s | 84% (20.7 s) | 37% (46.5 s) | 54% (32.3 s) | 100% (17.4 s) |
| turns | 100% (3) | 38% (8) | 38% (8) | 43% (7) |
| user_turns | 100% (0) | 100% (0) | 0% (1) | 100% (0) |
| plan_words | 72% (671 words) | 52% (933 words) | 56% (868 words) | 100% (484 words) |
| machine_words | 0 words | 205 words | 0 words | 0 words |
| human_readability | 88% (88) | 85% (85) | 88% (88) | 88% (88) |
| agent_executability | 85% (85) | 80% (80) | 88% (88) | 87% (87) |
| verbosity_score | 82% (82) | 78% (78) | 80% (80) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### plan-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 100% (7 530 tok) | 64% (11 782 tok) | 68% (11 003 tok) | 39% (19 373 tok) |
| cost_usd | 100% ($0.1287) | 45% ($0.2845) | 61% ($0.2097) | 32% ($0.4040) |
| duration_s | 100% (57.3 s) | 57% (99.9 s) | 56% (103.0 s) | 43% (134.8 s) |
| turns | 100% (3) | 30% (10) | 60% (5) | 23% (13) |
| user_turns | 100% (0) | 100% (0) | 0% (1) | 100% (0) |
| plan_words | 99% (2 479 words) | 82% (2 989 words) | 93% (2 652 words) | 100% (2 458 words) |
| machine_words | 0 words | 726 words | 0 words | 2 418 words |
| human_readability | 90% (90) | 88% (88) | 88% (88) | 90% (90) |
| agent_executability | 82% (82) | 88% (88) | 90% (90) | 90% (90) |
| verbosity_score | 80% (80) | 82% (82) | 80% (80) | 72% (72) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### debug-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 77% (381 tok) | 100% (295 tok) | 42% (709 tok) | 37% (801 tok) |
| cost_usd | 97% ($0.0324) | 100% ($0.0314) | 44% ($0.0711) | 50% ($0.0629) |
| duration_s | 100% (5.7 s) | 99% (5.7 s) | 61% (9.3 s) | 53% (10.6 s) |
| turns | 75% (4) | 100% (3) | 43% (7) | 50% (6) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 72% (72) | 60% (60) | 80% (80) | 88% (88) |
| agent_executability | 35% (35) | 20% (20) | 35% (35) | 70% (70) |
| verbosity_score | 90% (90) | 90% (90) | 90% (90) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### debug-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 92% (845 tok) | 100% (778 tok) | 74% (1 058 tok) | 68% (1 149 tok) |
| cost_usd | 99% ($0.0417) | 100% ($0.0415) | 53% ($0.0779) | 57% ($0.0734) |
| duration_s | 87% (9.9 s) | 100% (8.6 s) | 66% (13.0 s) | 61% (14.0 s) |
| turns | 100% (4) | 100% (4) | 67% (6) | 67% (6) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 78% (78) | 72% (72) | 88% (88) | 88% (88) |
| agent_executability | 35% (35) | 35% (35) | 60% (60) | 80% (80) |
| verbosity_score | 88% (88) | 88% (88) | 88% (88) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### build-small (home-grown)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 100% (1 300 tok) | 71% (1 819 tok) | 50% (2 592 tok) | 55% (2 373 tok) |
| cost_usd | 100% ($0.0510) | 77% ($0.0663) | 46% ($0.1101) | 50% ($0.1017) |
| duration_s | 100% (13.3 s) | 72% (18.5 s) | 56% (23.6 s) | 61% (21.6 s) |
| turns | 100% (4) | 67% (6) | 50% (8) | 40% (10) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 72% (72) | 62% (62) | 80% (80) | 85% (85) |
| agent_executability | 55% (55) | 45% (45) | 72% (72) | 82% (82) |
| verbosity_score | 80% (80) | 70% (70) | 82% (82) | 80% (80) |
| outcome | 100% (3/3) | 67% (2/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-debug (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 86% (664 tok) | 100% (571 tok) | 53% (1 073 tok) | 52% (1 088 tok) |
| cost_usd | 97% ($0.0354) | 100% ($0.0341) | 44% ($0.0777) | 46% ($0.0735) |
| duration_s | 90% (8.4 s) | 100% (7.5 s) | 57% (13.1 s) | 63% (11.9 s) |
| turns | 100% (3) | 100% (3) | 50% (6) | 50% (6) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 78% (78) | 80% (80) | 85% (85) | 88% (88) |
| agent_executability | 40% (40) | 40% (40) | 55% (55) | 80% (80) |
| verbosity_score | 90% (90) | 90% (90) | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-build (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni 2.0.0 |
| --- | --- | --- | --- | --- |
| tokens_total | 100% (1 854 tok) | 44% (4 187 tok) | 52% (3 548 tok) | 53% (3 494 tok) |
| cost_usd | 100% ($0.0547) | 34% ($0.1593) | 48% ($0.1151) | 52% ($0.1058) |
| duration_s | 100% (13.5 s) | 32% (42.0 s) | 52% (26.2 s) | 53% (25.3 s) |
| turns | 100% (4) | 44% (9) | 40% (10) | 44% (9) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 62% (62) | 68% (68) | 68% (68) | 82% (82) |
| agent_executability | 45% (45) | 62% (62) | 62% (62) | 80% (80) |
| verbosity_score | 85% (85) | 78% (78) | 80% (80) | 82% (82) |
| outcome | 100% (3/3) | 67% (2/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |
