# ni-bench run 20261007-191900: ni 1.8.0 versus ni 2.0.0 candidate

Source: `ni-bench` worktree `compare-ni-2`, `.reports/run-20261007-191900/` (full matrix,
7 scenarios × 2 arms × 3 trials, 6.50 USD, not partial, 0 indeterminate, every postcheck
green). Arms: `ni` = 1.8.0 from the marketplace (hook terse level full); `ni2` =
2.0.0+local.e97097b through `--plugin-dir`, output style `ni:lite`. Analysis produced by
a read-only agent from REPORT.md, matrix.json, per-trial judge input and output,
postchecks, and the per-turn tool traces.

## KPI medians, ni2 versus ni

Resource rows: negative is better. Judge rows: positive is better.

| Scenario | tokens_total | cost_usd | duration_s | turns | plan_words | machine_words | readability | executability | verbosity | outcome |
|---|---|---|---|---|---|---|---|---|---|---|
| plan-easy | 2386→2084 (−13%) | 0.1090→0.0827 (−24%) | 20.5→17.5 (−15%) | 9→7 (−22%) | 585→461 (−21%) | 0→0 | 88→88 | 87→88 | 85→88 | 3/3 |
| plan-complex | 20755→25702 (+24%) | 0.4303→0.4759 (+11%) | 160.5→175.8 (+10%) | 10→16 (+60%) | 2733→3359 (+23%) | 2316→3362 (+45%) | 88→90 | 90→92 | 72→72 | 3/3 |
| debug-easy | 692→664 (−4%) | 0.0662→0.0644 (−3%) | 10.5→10.4 | 7→7 | | | 85→80 | 72→65 | 90→90 | 3/3 |
| debug-complex | 1161→1042 (−10%) | 0.0782→0.0754 (−4%) | 15.2→17.5 (+15%) | 7→7 | | | 88→88 | 80→80 | 90→88 | 3/3 |
| build-small | 2756→2345 (−15%) | 0.1186→0.0999 (−16%) | 24.1→20.3 (−16%) | 13→11 (−15%) | | | 88→88 | 85→85 | 82→85 | 3/3 |
| ported-debug | 932→1012 (+9%) | 0.0707→0.0707 | 12.0→13.5 (+13%) | 6→6 | | | 82→85 | 72→72 | 88→88 | 3/3 |
| ported-build | 3501→3509 | 0.1106→0.1169 (+6%) | 25.7→26.3 (+2%) | 10→14 (+40%) | | | 80→80 | 78→78 | 85→85 | 3/3 |

`tokens_total` sums `input_tokens + output_tokens` of the CLI JSON, so it is in effect
output tokens; cache reads (100k to 324k per trial) are in `cost_usd` only.

NFR8 verdict on the published scenarios: not met. ported-build cost +6%, turns +40%;
ported-debug tokens +9%, duration +13%. plan-complex regresses on every resource KPI.

## Judge reasons where ni2 scored lower

- debug-easy (readability −5, executability −7): the judge's reason is the same sentence
  on both arms, "the transcript only shows the final message, not the tool calls, so the
  reproduction and verification are claimed rather than visible". Tool traces are
  identical across arms. Within-arm spread (ni2 executability 60/72/65) equals the
  cross-arm gap. The only textual difference: ni2 fences the three-line evidence block
  in 3/3 trials, ni in 0/3. Judge noise at n=3.
- ported-build ni2 trial-02: "PLAN.md's verify command (`python`) won't run in this
  environment". Root cause below.
- plan-complex: ni2 scores higher on readability and executability in 2 of 3 trials;
  shared negatives on both arms (process scaffolding, STRIDE).

## Root causes in ni 2.0.0

1. [onboarding.md](../../../skills/software-engineer/onboarding.md) lines 68 to 69 and the banned list: "call an
   interpreter by its plain name, never with a version suffix". The bench base image has
   only `python3`. ni2 ran `python -m pytest`, failed, retried with `python3`: one extra
   turn in ported-build trials 02 and 03, plan-easy trial 01, build-small trials 01 to
   03. ni2 wrote `python -m pytest` as the verify command in PLAN.md (ported-build
   trial 02) and 14 to 16 times in plan-complex TASKS.md (ni: 0 to 5), so those verify
   commands do not run on that host. Confidence high.
2. [preflight.md](../../../skills/plan/templates/preflight.md) link lint uses `git grep`, which sees tracked
   files only: ni2 ran `git add -N docs CLAUDE.md` in the user's repository (index side
   effect) plus one turn (plan-complex trials 01 and 03), and copied the three-line
   per-shell lint block verbatim into the generated PREFLIGHT.md (machine_words +45%).
   1.8.0 used a plain `grep -rPn`. Confidence high.
3. [complex-plan.md](../../../skills/plan/complex-plan.md) lines 110 to 113: the `mkdir -p` snippet became "the
   Write tool creates missing folders"; with heredocs banned, ni2 wrote one Write per
   workspace file (7 to 8 Write calls) where ni used 3 to 6 Bash heredocs: turns 16 vs
   10 in plan-complex. Causal link inferred from traces. Confidence medium.
4. [lite.md](../../../output-styles/lite.md) line 33 "expand an uncommon acronym once": ni2 expanded SKU,
   present in the user's prompt, and wrongly ("stock keeper unit"). Confidence medium.
5. [lite.md](../../../output-styles/lite.md) line 26 fenced-block rule plus [debug/SKILL.md](../../../skills/debug/SKILL.md)
   evidence block: fenced in ni2, not in ni; co-occurs with the only judge drop; not
   separable at n=3. Confidence low.
6. ported-debug +9% tokens: identical tool calls, longer final reply (1001/657/991 chars
   vs 744/660/736). `ni:lite` keeps full sentences where the ni arm ran terse level full
   with fragments. Operating points differ by configuration; a `ni:full` arm would be
   the like-for-like comparison.

## Bench artefacts (ni-bench, not the plugin)

- `harness/runner.py` line 356: a resumed `claude -p` reports cumulative
  `total_cost_usd`, `num_turns`, and usage; the runner sums turns again. plan-complex
  ni2 trial 02 reports 1.0877 USD, real about 0.57. Inflates one trial, not the median.
- `harness/simulator.py` line 33: the `approve|approval` regex fired on a status line
  ("ADR approval: all four ADRs have status proposed") and injected a user turn plus a
  second subject invocation (plan-complex ni2 trial 02). ni wrote "ratify", no match.
- `harness/judge.py` lines 152 to 163: the judge never sees tool calls, so all 18 debug
  trials on both arms get "asserted rather than shown" on executability.
- `arms/Dockerfile.base`: no `python` shim, only `python3`; the interpreter-name rule
  was tested on an unrepresentative host.

## Ranked improvements

Plugin: 1 interpreter rule (high), 2 link lint (high), 3 plan file writing (medium),
4 acronym rule (medium), 5 evidence block fence (low). Bench: cost summing on resume
(high), simulator regex (high), judge tool trace (high that it removes the shared
penalty), python shim (medium). Accept as judge noise: debug-easy judge KPIs,
debug-complex trial 02, debug-complex duration; re-run at n ≥ 5 after the fixes.

## Run 2: 20261008-183033, same candidate, full matrix again

Same arms and labels (ni 1.8.0, ni2 2.0.0+local.e97097b), 42 trials, 6.00 USD, not
partial, 0 indeterminate, outcome 3/3 everywhere. No plugin fix applied between the
runs, so run 2 measures run-to-run variance.

| Scenario | tokens | cost | duration | turns | readability | executability | verbosity |
|---|---|---|---|---|---|---|---|
| ported-build | 3354→3104 (−7%) | 0.1203→0.1124 (−7%) | 30.6→26.7 (−13%) | 13→13 | 80→80 | 78→78 | 82→85 |
| ported-debug | 944→1031 (+9%) | 0.0723→0.0715 (−1%) | 15.1→16.4 (+9%) | 6→6 | 80→85 | 72→72 | 88→88 |
| plan-complex | 18158→21832 (+20%) | 0.4129→0.4392 (+6%) | 125.7→153.6 (+22%) | 10→15 (+50%) | 90→88 | 90→90 | 72→72 |
| plan-easy | 2068→2273 (+10%) | 0.0925→0.0913 (−1%) | 20.3→20.4 | 7→7 | 88→88 | 88→87 | 88→88 |
| debug-easy | 660→643 (−3%) | 0.0666→0.0649 (−3%) | 16.9→11.8 (−30%) | 7→7 | 85→85 | 70→60 | 90→88 |
| debug-complex | 1130→1189 (+5%) | 0.0783→0.0786 | 17.8→16.2 (−9%) | 7→8 (+14%) | 88→85 | 80→80 | 88→85 |
| build-small | 2339→2355 (+1%) | 0.1014→0.1048 (+3%) | 21.0→22.9 (+9%) | 12→12 | 85→82 | 80→80 | 85→82 |

Reading against run 1:
- Stable across both runs (real effects): plan-complex tokens, duration, and turns
  (+20% to +24%, +50% to +60%); ported-debug tokens +9% (reply length under `ni:lite`
  full sentences versus terse level full fragments); debug-easy executability −7 to
  −10 (the fenced evidence block is the only textual difference, so task 17 is
  justified, not only noise).
- Flipped sign between runs (noise at n=3): ported-build (cost +6% then −7%, turns +40%
  then equal), plan-easy (tokens −13% then +10%), build-small (−15% then +1%).
- NFR8 on the published scenarios after run 2: ported-build green; ported-debug tokens
  +9% red in both runs. Tasks 14 to 17 target the stable effects; the ported-debug gap
  is a style operating point (lite versus full) and task 19 adds a `ni:full` arm
  reading to decide whether the README publishes lite, full, or both.

## Run 3: 20261008-204737, candidate after the Session 3 fixes

ni2 = 2.0.0+local.ca1014d (fixes 8f575eb, 2a49681, 05728d8, ca1014d), ni-bench at
96c4102 (last-turn cost on resume, approval regex on requests, `python` shim in the
base image). Full matrix, 42 trials, 7.09 USD, not partial, outcome 3/3 everywhere.

| Scenario | tokens | cost | duration | turns | readability | executability | verbosity |
|---|---|---|---|---|---|---|---|
| ported-build | 3208→3292 (+3%) | 0.1062→0.1101 (+4%) | 23.8→26.8 (+13%) | 11→11 | 80→80 | 76→78 | 85→85 |
| ported-debug | 966→1034 (+7%) | 0.0728→0.0716 (−2%) | 12.1→12.0 (−1%) | 6→6 | 80→82 | 62→72 | 88→88 |
| plan-complex | 18281→20750 (+14%) | 0.4030→0.4357 (+8%) | 123.1→142.3 (+16%) | 13→14 (+8%) | 88→88 | 90→90 | 72→72 |
| plan-easy | 2227→2227 | 0.0988→0.0873 (−12%) | 21.1→19.0 (−10%) | 7→7 | 88→85 | 86→85 | 85→85 |
| debug-easy | 651→685 (+5%) | 0.0662→0.0658 (−1%) | 9.7→10.0 (+3%) | 7→7 | 85→82 | 70→65 | 90→85 |
| debug-complex | 1087→946 (−13%) | 0.0730→0.0697 (−5%) | 12.9→11.7 (−9%) | 6→6 | 88→85 | 80→80 | 90→88 |
| build-small | 2371→2466 (+4%) | 0.1010→0.1004 (−1%) | 20.7→20.3 (−2%) | 10→10 | 82→88 | 80→85 | 80→85 |

Against runs 1 and 2: plan-complex turns went from +50% to +60% down to +8% (the
link-lint and file-writing fixes), tokens from +20% to +24% down to +14%; ported-build
turns from +40% or equal to equal; ported-debug tokens +7% (was +9% twice), the
lite-versus-full operating point. NFR8 on the published scenarios: ported-build
duration +13% and ported-debug tokens +7% remain above the 5% threshold; every judge
KPI equal or better. Per-trial reading follows in the next section.

### Run 3 per-trial reading

Fix checks over the 42 run 3 traces:
- Interpreter retry: 0 retries. ni2 uses the plain name in 10 trials (the base image
  now has the shim). Verify commands recorded as `python -m pytest` in ported-build
  PLAN.md 3/3 and plan-complex TASKS.md 0/13/12: correct on the shim host, the probed
  name is not written back as the rule asks. Portability risk, no run 3 cost.
- `git add` in plan trials: 0. ni2 ran `git grep --untracked` 3/3.
- plan-complex tool calls: ni Write 4/6/0, Bash 5/5/6, turns 13/16/11; ni2 Write 5/7/8,
  Bash 4/4/2, turns 12/15/14. Turn gap +50% to +60% → +8%.
- Acronym expansions in ni2 replies: 0 of 21. Fenced evidence block in debug replies:
  ni2 0/9, ni 1/9.
- Simulator turns: none in 42 trials; the approval regex held on "Approve the plan
  commit:" (plan-complex ni2 03). No trial resumed, so the cost-on-resume fix is
  untested by run 3.

Remaining stable gaps:
- plan-complex tokens +14%, duration +16%: duration tracks output tokens (6.7 ms per
  token both arms). Two of three ni2 trials drafted PREFLIGHT.md with Write (370 and
  394 words of output) where all ni trials copied the template with one `sed`
  substitution; one link-lint fix round; one extra ADR (median 3 vs 2). The task 16
  sentence "draft the small files (ADRs under 40 lines, PREFLIGHT.md) in the same
  turn" caused the drafting; Phase 4c still says copy. About 60% of the gap.
- ported-debug tokens +7%: identical tool calls and turns; ni2 replies add a 3 to 5
  bullet bold-labelled list before the three evidence lines (reply chars 804/950/703
  vs 683/720/661), from the lite rules "full sentences" and "list for parallel
  items" against terse level full fragments. Judge prefers ni2 (readability +2,
  executability +10).
- ported-build duration +13%: sign flips across runs (+2%, −13%, +12%); the median
  trial has fewer output tokens than ni and longer API latency. Noise. One contributor:
  ni2 wrote an ADR in 2/3 trials (ni 1/3), judge "a PLAN.md plus an ADR that the task
  did not need".
- debug-easy executability −5: within-arm spread 8 points, identical judge sentence
  on all six trials ("transcript shows no tool calls"). Noise.

NFR8 verdict, run 3, published scenarios: pass on every KPI except ported-build
duration (+12.6%, noise) and ported-debug tokens (+7.0%, style operating point). A
`ni:full` arm is estimated to bring ported-debug within 5% (style bench: full is 8%
fewer output tokens and 31% fewer chars than lite; the ni2 reply excess is 6% to 32%
chars). Medium confidence.

README-ready tables (run 3, ni-bench 96c4102, ni2 2.0.0+local.ca1014d, n=3):

ported-build

| KPI | ni 1.8.0 | ni 2.0.0 |
|---|---|---|
| tokens_total | 100% (3 208 tok) | 97% (3 292 tok) |
| cost_usd | 100% ($0.1062) | 96% ($0.1101) |
| duration_s | 100% (23.8 s) | 89% (26.8 s) |
| turns | 100% (11) | 100% (11) |
| human_readability | 80% (80) | 80% (80) |
| agent_executability | 76% (76) | 78% (78) |
| verbosity_score | 85% (85) | 85% (85) |
| outcome | 100% (3/3) | 100% (3/3) |

ported-debug

| KPI | ni 1.8.0 | ni 2.0.0 |
|---|---|---|
| tokens_total | 100% (966 tok) | 93% (1 034 tok) |
| cost_usd | 98% ($0.0728) | 100% ($0.0716) |
| duration_s | 99% (12.1 s) | 100% (12.0 s) |
| turns | 100% (6) | 100% (6) |
| human_readability | 80% (80) | 82% (82) |
| agent_executability | 62% (62) | 72% (72) |
| verbosity_score | 88% (88) | 88% (88) |
| outcome | 100% (3/3) | 100% (3/3) |

Next steps ranked: (1) plan skill: PREFLIGHT.md is copied with one substitution, never
drafted; drop it from the "draft the small files" sentence (high). (2) debug skill:
the summary is prose plus the three lines, no labelled list, or publish the `ni:full`
reading (medium). (3) small-plan ADR trigger wording, ported-build wrote an ADR the
task did not need (low). (4) write the probed interpreter name into verify commands
(medium, portability). Bench: `ni:full` arm; judge tool-trace visibility; the
cost-on-resume fix needs a two-turn trial to be exercised. Accept as noise:
ported-build duration, debug-easy executability, plan-easy and build-small.

## Run 4 (run-20261009-120453, ni2 = 2.0.0+local.801a5b9, ni:full)

| Scenario | Readability ni→ni2 | Executability ni→ni2 |
|---|---|---|
| plan-easy | 88→85 | 86→82 |
| debug-easy | 82→85 | 70→62 |
| debug-complex | 88→85 | 80→70 |
| ported-build | 80→80 | 78→72 |
| build-small | 80→85 | 72→80 |
| ported-debug | 82→85 | 70→72 |
| plan-complex | 88→90 | 90→90 |

- plan-easy: task 20 cut plans to 4–6 tasks and dropped function names. The one plan that kept them scored 88/87.
- debug-complex: task 21's two-or-three-sentence cap dropped test file names and why the existing tests missed the bug.
- debug-easy, ported-build: judge noise; the judge sees no tool calls, both arms get the same "only asserted" reason.
- `ni:full` is not the cause. Fixes in task 23.
