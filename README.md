<p align="center"><img src="assets/logo.svg" alt="ni" width="300"></p>

# ni

**Never Claude alone.** You and I: Claude NI.

**ni** stands for natural intelligence, as opposed to artificial. Say it *nickel* (French: spot on, good enough) or *nice* (UK/US). Either way, it is the human staying in the loop.

ni is a Claude Code plugin, distributed through the [itsaspacestation marketplace](https://github.com/itsaspacestation/claude-marketplace). Its `skills/` folder also works as a plain skills source for Copilot CLI, Cursor, and Gemini CLI.

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

`ni:software-engineer`, `ni:tdd`, and `ni:debug` enforce plan, failing test, fix, and commit, with the root cause found before any fix. `ni:git-conventions` writes the commit and the MR description. Nothing is pushed without your go.

### 5. Claude reviews, and I judge
> /ni:code-review my branch before I open the MR.

or simply

> Review my branch before I open the MR.

`ni:code-review` checks design, tests, performance, security, and correctness, and cites every finding by file and line. You decide what to fix.

### 6. Claude reviews others, and I sign off
```
/ni:review-loop group/project
```
Reviews every MR assigned to you in a loop, posts each finding as its own discussion, and reports the links. It never approves, merges, or resolves: those stay yours.

### 7. Claude merges mine once approved
```
/ni:merge-loop group/project
```
Watches your own MRs in a loop and merges each one once it is approved, threads are resolved, and the pipeline is green. Anything blocked is reported with its reason, never forced.

### 8. Claude answers reviewers, and I approve
> Address the unresolved threads on MR !42.

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
ni injects a terse reply ruleset at session start and reminds Claude every turn, so replies stay short even after context compaction. Adapted from [caveman](https://github.com/juliusbrussee/caveman) (MIT), with two levels only.

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
| `ni:git-conventions` | Any git operation, commit messages, MR or PR descriptions |
| `ni:code-review` | Reviewing a change or answering reviewer comments, GitLab threads via glab included |
| `ni:evidence-based-analysis` | Any claim about the codebase, cited by file and line |
| `ni:bias-analysis` | Comparative studies from field reports, reviews, or statistics: bias checklist sweep with verdicts |
| `ni:skill` | Creating or editing a ni skill, agent, or command |

Run `/ni:help` inside Claude for the same list.

## Commands
User-invoked only; none loads on its own.

| Command | Does |
|---|---|
| `/ni:help` | List the ni skills |
| `/ni:terse` | Set the terse reply level |
| `/ni:review-loop` | Review MRs assigned to me in a /loop, post findings, report the links |
| `/ni:merge-loop` | Merge my approved MRs in a /loop, report merged and blocked ones |

## Agents
Subagent results land in the main context verbatim, so these three return structured one-liners instead of prose. Adapted from caveman's cavecrew (MIT).

| Agent | Use for | Returns |
|---|---|---|
| `ni:investigator` | Where is X defined, what calls Y, map this directory | `path:line - symbol - note` rows |
| `ni:builder` | Surgical edit of 1 or 2 known files | Diff receipt, or `too-big.` / `ambiguous.` |
| `ni:reviewer` | Findings-only review of a diff, branch, or file | `path:L42: severity: problem. fix.` rows |

Rule of thumb: want the result in a third of the tokens, pick ni. Want prose, pick the vanilla agent.
