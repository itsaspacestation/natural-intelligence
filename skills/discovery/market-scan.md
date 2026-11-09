# Market scan

Reference for step 3 of the [`discovery`](SKILL.md) workflow.

## Scope the landscape first

1. Name the user's job in one sentence: the progress they want, not the feature.
2. Search the job in the end user's own words before any technical query. A
   solution-shaped query ("competitor of X", "<feature> API") only returns your
   own solution category; a job-shaped query ("buy a building plot") surfaces the
   adjacent players the user actually reaches for first.
3. List the players: direct competitors, adjacent products, open source, internal
   tools, and the current workaround. The workaround is what the target user
   really does today, found in step 2 — never the manual version of your own
   solution.
4. Pick 2 to 4 players worth depth. Note the rest in one line each.

The brief's Market section opens with that full player list, rejected players
included, before the comparison table. The list is the proof that steps 2 and 3
ran; a brief without it is incomplete, not concise.

Not: "Kelfoncier competitors parcel PLU filter" → three parcel-screening tools,
and the dominant listings portal never appears.
Yes: "find a building plot to buy" → listings portals surface, and the workaround
column reads "browse listings", not "check each parcel by hand".

## Where to browse

- Competitor sites: pricing pages, changelogs, and docs say more than homepages
- Review sites (G2, Capterra, Trustpilot): read the negative reviews for unmet needs
- Open source: registries and GitHub for libraries that already solve the job
- Community: forum threads and support tickets where users describe workarounds

Conflicting reviews or field reports get the
[`bias-analysis`](../bias-analysis/SKILL.md) checklist before they count as evidence.

## Comparison table

Compare by job completion, never by feature checklist. One row per step of the
user's job, one column per player.

| Job step | Player A | Player B | Open source C | Do nothing |
|---|---|---|---|---|
| <step> | how well, with source | ... | ... | current workaround cost |

Score each cell in words (`full`, `partial`, `absent`), each with a source URL.
A feature nobody's job needs stays out of the table.

Not: a 40-row feature matrix with ticks.
Yes: six job steps showing every player leaves step 4 manual.

## Reading the result

- **Whitespace**: a job step every player leaves `partial` or `absent` is the
  opportunity. Name it in the brief.
- **Parity trap**: if the scan only proves others have the feature, that is value
  risk `open`, not a reason to build.
- **Buy or integrate**: a player covering the job at acceptable cost makes
  "integrate" the default candidate; building needs a stated edge over it.
