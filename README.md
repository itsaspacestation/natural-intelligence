<p align="center"><img src="assets/logo.svg" alt="ni" width="300"></p>

# ni

**Never Claude alone.** You and I: Claude NI.

**ni** stands for natural intelligence, as opposed to artificial. Say it *nickel* (French: spot on, good enough) or *nice* (UK/US). Either way, it is the human staying in the loop.

ni is a Claude Code plugin, distributed through the [itsaspacestation marketplace](https://github.com/itsaspacestation/claude-marketplace). Its `skills/` folder also works as a plain skills source for Copilot CLI, Cursor, and Gemini CLI.

## Benchmark vs other plugin

### ported-build (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (1 962 tok) | 40% (4 901 tok) | 54% (3 636 tok) | 🏆64% (3 084 tok) |
| cost_usd | 100% ($0.0596) | 33% ($0.1804) | 49% ($0.1228) | 🏆58% ($0.1030) |
| duration_s | 100% (15.1 s) | 30% (50.8 s) | 45% (33.6 s) | 🏆63% (23.8 s) |
| turns | 100% (5) | 50% (10) | 62% (8) | 50% (10) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 55% (55) | 80% (80) | 62% (62) | 🏆80% (80) |
| agent_executability | 40% (40) | 70% (70) | 55% (55) | 🏆78% (78) |
| verbosity_score | 85% (85) | 82% (82) | 80% (80) | 🏆85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

## Quick tour
Claude does the heavy lifting. You make the calls. Skills trigger on their own from what you ask; the prompts below are examples.

### 1. Set up
Install as above, run `/reload-plugins`, then `/ni:help` to check the skills are loaded.

### 2. Pick a terse level
```
/ni:terse lite   # default: no filler, full sentences
/ni:terse full   # fragments, fewest tokens
/ni:terse off
```
The level persists across sessions. See [Terse mode](#terse-mode).

### 3. Claude plans, and I decide
> /ni:plan a workspace for the invoice export feature.

or simply
> Plan a workspace for the invoice export feature.

`ni:plan` explores the codebase and drafts `DESIGN.md`, ADRs, and `TASKS.md` under `docs/workspace/<name>/`. You spend about 30 to 40 minutes reviewing scope, settling the ADRs, and approving the tasks. Then say go: Claude runs the tasks on autopilot and stops only when a decision falls outside the plan.

For a small change, Claude Code's built-in plan mode is enough.

### 4. Claude builds, and I steer
> Fix the rounding bug in the VAT total.

`ni:software-engineer`, `ni:tdd`, and `ni:debug` enforce plan, failing test, fix, and commit, with the root cause found before any fix. `ni:git-conventions` writes the commit and the MR or PR description, routing to the right forge from the origin remote. Nothing is pushed without your go.

### 5. Claude reviews, and I judge
> /ni:code-review my branch before I open the MR.

or simply

> Review my branch before I open the MR.

`ni:code-review` checks design, tests, performance, security, and correctness, and cites every finding by file and line. You decide what to fix.

### 6. Claude reviews others, and I sign off
```
/ni:review-loop group/project
```
Works on GitLab and GitHub: pass a project path or URL, or let it read the origin remote. Reviews every MR or PR assigned to you in a loop, posts each finding as its own discussion, and reports the links. It never approves, merges, or resolves: those stay yours.

### 7. Claude merges mine once approved
```
/ni:merge-loop group/project
```
Watches your own MRs or PRs in a loop and merges each one once every reviewer has approved, threads are resolved, and CI is green. Anything blocked is reported with its reason, never forced.

### 8. Claude answers reviewers, and I approve
> Address the unresolved threads on MR !42 (or PR #42).

`ni:code-review` reads the threads, drafts the fixes and replies, and shows you a preview. Nothing is posted or resolved until you approve it.

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

For other agents, copy `skills/` into `~/.copilot/`, `~/.cursor/`, or `~/.gemini/`. 

## Layout
| Path | Purpose |
|---|---|
| `.claude-plugin/plugin.json` | Plugin manifest, name `ni` |
| `agents/` | Subagents with compressed output, spawned as `ni:<agent>` |
| `commands/` | Slash commands, invoked as `/ni:<command>` |
| `output-styles/` | The `ni:terse` output style, auto-applied while the plugin is enabled |
| `scripts/` | Hook scripts behind the terse reply mode |
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
```

## Release
Users only get an update when `version` in `.claude-plugin/plugin.json` changes.

1. Bump `version` (semver) and commit.
2. `claude plugin validate . --strict`
3. `claude plugin tag .` creates the `ni--v<version>` tag, then push the commit and the tag.

The marketplace entry tracks the default branch, so the marketplace repository needs no change for a release.

## Terse mode
Terse rests on two mechanisms:

1. **Output style.** The `ni:terse` output style overrides Claude Code's default communication style, which otherwise fights terse: it asks for full readable prose and forbids fragments. The style auto-applies while the plugin is enabled (`force-for-plugin`) and keeps the built-in coding instructions (`keep-coding-instructions`).
2. **Hooks.** ni injects the ruleset at session start and reminds Claude of the active level every turn, so replies stay short even after context compaction.

Adapted from [caveman](https://github.com/juliusbrussee/caveman) (MIT), with two levels only.

| Level | Effect |
|---|---|
| `lite` | Default. No filler, hedging, preamble, or recap. Full sentences kept. |
| `full` | Also drops articles, allows fragments. |
| `off` | Nothing injected. |

Switch with `/ni:terse lite|full|off`. The level persists in `~/.claude/ni/terse`. Persisted text (docs, MR text, comments, commit messages) follows lite rules whatever the level; code and security warnings stay in normal prose.

## Skills
| Skill | Use when |
|---|---|
| `ni:terse` | The terse ruleset itself, for reference or manual invocation |
| `ni:software-engineer` | Implementing, fixing, or refactoring with the plan, test, implement, commit workflow; Rust and .NET build, test, and coverage commands |
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
| `/ni:terse` | Set the terse reply level |
| `/ni:review-loop` | Review MRs or PRs assigned to me in a /loop on GitLab or GitHub, post findings as one-click applicable suggestions where possible, resolve its own threads once a new commit fixes the finding, report the links |
| `/ni:merge-loop` | Merge my MRs or PRs approved by every reviewer in a /loop, report merged and blocked ones |

## Agents
Subagent results land in the main context verbatim, so these three return structured one-liners instead of prose. Adapted from caveman's cavecrew (MIT).

| Agent | Use for | Returns |
|---|---|---|
| `ni:investigator` | Where is X defined, what calls Y, map this directory | `path:line - symbol - note` rows |
| `ni:builder` | Surgical edit of 1 or 2 known files | Diff receipt, or `too-big.` / `ambiguous.` |
| `ni:reviewer` | Findings-only review of a diff, branch, or file | `path:L42: severity: problem. fix.` rows |

Rule of thumb: want the result in a third of the tokens, pick ni. Want prose, pick the vanilla agent.

## Latest benchmark
benchmark tool: [ni-bench](https://github.com/itsaspacestation/ni-bench)

### Latest report
#### plan-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 81% (2 999 tok) | 55% (4 420 tok) | 53% (4 558 tok) | 100% (2 437 tok) |
| cost_usd | 100% ($0.0747) | 56% ($0.1344) | 28% ($0.2663) | 82% ($0.0909) |
| duration_s | 91% (25.4 s) | 49% (47.4 s) | 60% (39.0 s) | 100% (23.3 s) |
| turns | 100% (4) | 50% (8) | 50% (8) | 57% (7) |
| user_turns | 100% (0) | 100% (0) | 0% (1) | 100% (0) |
| plan_words | 73% (710 words) | 58% (883 words) | 51% (1 016 words) | 100% (515 words) |
| machine_words | 0 words | 192 words | 0 words | 0 words |
| human_readability | 88% (88) | 85% (85) | 88% (88) | 88% (88) |
| agent_executability | 86% (86) | 82% (82) | 90% (90) | 88% (88) |
| verbosity_score | 85% (85) | 72% (72) | 80% (80) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### plan-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (8 218 tok) | 59% (13 916 tok) | 61% (13 381 tok) | 38% (21 432 tok) |
| cost_usd | 100% ($0.1358) | 44% ($0.3074) | 29% ($0.4740) | 31% ($0.4362) |
| duration_s | 100% (64.8 s) | 52% (124.7 s) | 66% (97.9 s) | 43% (150.8 s) |
| turns | 100% (2) | 20% (10) | 36% (5.5) | 22% (9) |
| user_turns | 100% (0) | 100% (0) | 0% (1) | 100% (0) |
| plan_words | 100% (2 589 words) | 73% (3 559 words) | 75% (3 455.5 words) | 93% (2 791 words) |
| machine_words | 0 words | 870 words | 0 words | 2 649 words |
| human_readability | 90% (90) | 90% (90) | 88% (88) | 90% (90) |
| agent_executability | 85% (85) | 90% (90) | 90% (90) | 90% (90) |
| verbosity_score | 78% (78) | 80% (80) | 78% (78) | 72% (72) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (2/2) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 1/3 | 0/3 |

#### debug-easy (home-grown)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (405 tok) | 100% (404 tok) | 59% (681 tok) | 63% (645 tok) |
| cost_usd | 99% ($0.0324) | 100% ($0.0319) | 45% ($0.0704) | 49% ($0.0655) |
| duration_s | 96% (6.4 s) | 100% (6.1 s) | 59% (10.4 s) | 64% (9.6 s) |
| turns | 100% (4) | 100% (4) | 57% (7) | 57% (7) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 62% (62) | 70% (70) | 78% (78) | 85% (85) |
| agent_executability | 25% (25) | 35% (35) | 40% (40) | 65% (65) |
| verbosity_score | 90% (90) | 90% (90) | 90% (90) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### debug-complex (home-grown)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (895 tok) | 96% (935 tok) | 64% (1 398 tok) | 76% (1 173 tok) |
| cost_usd | 98% ($0.0469) | 100% ($0.0459) | 53% ($0.0861) | 58% ($0.0791) |
| duration_s | 95% (11.9 s) | 100% (11.3 s) | 66% (17.1 s) | 77% (14.7 s) |
| turns | 100% (5) | 100% (5) | 71% (7) | 56% (9) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 82% (82) | 82% (82) | 88% (88) | 88% (88) |
| agent_executability | 40% (40) | 35% (35) | 55% (55) | 80% (80) |
| verbosity_score | 85% (85) | 88% (88) | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### build-small (home-grown)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 87% (1 778 tok) | 100% (1 553 tok) | 46% (3 386 tok) | 54% (2 895 tok) |
| cost_usd | 85% ($0.0612) | 100% ($0.0522) | 42% ($0.1255) | 45% ($0.1169) |
| duration_s | 89% (16.3 s) | 100% (14.5 s) | 50% (29.0 s) | 62% (23.5 s) |
| turns | 100% (5) | 100% (5) | 45% (11) | 38% (13) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 72% (72) | 72% (72) | 85% (85) | 82% (82) |
| agent_executability | 55% (55) | 55% (55) | 80% (80) | 80% (80) |
| verbosity_score | 85% (85) | 82% (82) | 80% (80) | 80% (80) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-debug (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (613 tok) | 80% (771 tok) | 54% (1 134 tok) | 57% (1 067 tok) |
| cost_usd | 100% ($0.0344) | 94% ($0.0366) | 44% ($0.0777) | 47% ($0.0725) |
| duration_s | 98% (8.9 s) | 100% (8.7 s) | 67% (13.1 s) | 60% (14.6 s) |
| turns | 100% (3) | 100% (3) | 50% (6) | 50% (6) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 72% (72) | 82% (82) | 82% (82) | 82% (82) |
| agent_executability | 35% (35) | 55% (55) | 55% (55) | 72% (72) |
| verbosity_score | 88% (88) | 88% (88) | 88% (88) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |

#### ported-build (superpowers-evals)

| KPI | baseline | openspec | superpowers | ni |
|---|---|---|---|---|
| tokens_total | 100% (1 962 tok) | 40% (4 901 tok) | 54% (3 636 tok) | 🏆64% (3 084 tok) |
| cost_usd | 100% ($0.0596) | 33% ($0.1804) | 49% ($0.1228) | 🏆58% ($0.1030) |
| duration_s | 100% (15.1 s) | 30% (50.8 s) | 45% (33.6 s) | 🏆63% (23.8 s) |
| turns | 100% (5) | 50% (10) | 62% (8) | 50% (10) |
| user_turns | 100% (0) | 100% (0) | 100% (0) | 100% (0) |
| human_readability | 55% (55) | 80% (80) | 62% (62) | 🏆80% (80) |
| agent_executability | 40% (40) | 70% (70) | 55% (55) | 🏆78% (78) |
| verbosity_score | 85% (85) | 82% (82) | 80% (80) | 🏆85% (85) |
| outcome | 100% (3/3) | 100% (3/3) | 100% (3/3) | 100% (3/3) |
| indeterminate | 0/3 | 0/3 | 0/3 | 0/3 |
