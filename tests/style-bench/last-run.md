# Style bench, last run

Date: 2026-10-07T16:07Z
Model: sonnet (judge: haiku)
Claude Code: 2.1.292 (Claude Code)
Styles: default concise ni:lite ni:full
Prompts: 1 2 3 4 5 6 7 8 9 10
MAX_THINKING_TOKENS: 0

| style | output tokens | reply chars | facts kept | words |
|---|---|---|---|---|
| default | 5301 | 9553 | 36/36 (100%) | 1506 |
| concise | 5202 | 9440 | 36/36 (100%) | 1503 |
| ni:lite | 3414 | 4381 | 35/36 (97%) | 714 |
| ni:full | 3701 | 3642 | 36/36 (100%) | 564 |

## Per prompt

| style | prompt | output tokens | reply chars | facts kept | words | judge |
|---|---|---|---|---|---|---|
| default | P1 | 780 | 2188 | 4/4 | 325 | kept: 4/4 |
| default | P2 | 871 | 2297 | 4/4 | 387 | kept: 4/4 |
| default | P3 | 509 | 1567 | 3/3 | 251 | kept: 3/3 |
| default | P4 | 296 | 886 | 4/4 | 125 | kept: 4/4 |
| default | P5 | 163 | 497 | 4/4 | 79 | kept: 4/4 |
| default | P6 | 884 | 407 | 4/4 | 57 | kept: 4/4 |
| default | P7 | 378 | 362 | 3/3 | 53 | kept: 3/3 |
| default | P8 | 706 | 524 | 4/4 | 85 | kept: 4/4 |
| default | P9 | 253 | 493 | 3/3 | 89 | kept: 3/3 |
| default | P10 | 461 | 332 | 3/3 | 55 | kept: 3/3 |
| concise | P1 | 762 | 2079 | 4/4 | 312 | kept: 4/4 |
| concise | P2 | 783 | 2085 | 4/4 | 347 | kept: 4/4 |
| concise | P3 | 572 | 1752 | 3/3 | 277 | kept: 3/3 |
| concise | P4 | 251 | 754 | 4/4 | 107 | kept: 4/4 |
| concise | P5 | 229 | 719 | 4/4 | 119 | kept: 4/4 |
| concise | P6 | 701 | 307 | 4/4 | 45 | kept: 4/4 |
| concise | P7 | 404 | 277 | 3/3 | 48 | kept: 3/3 |
| concise | P8 | 702 | 590 | 4/4 | 103 | kept: 4/4 |
| concise | P9 | 304 | 435 | 3/3 | 76 | kept: 3/3 |
| concise | P10 | 494 | 442 | 3/3 | 69 | kept: 3/3 |
| ni:lite | P1 | 161 | 557 | 4/4 | 93 | kept: 4/4 |
| ni:lite | P2 | 370 | 602 | 3/4 | 104 | kept: 3/4;;- GET, PUT, and DELETE are idempotent methods. (Reply states GET, PUT, DELETE are idempotent; also mentions HEAD, OPTIONS, PATCH but core three are c |
| ni:lite | P3 | 198 | 663 | 3/3 | 104 | kept: 3/3 |
| ni:lite | P4 | 144 | 444 | 4/4 | 69 | kept: 4/4;The reply keeps all four facts. |
| ni:lite | P5 | 146 | 483 | 4/4 | 78 | kept: 4/4 |
| ni:lite | P6 | 736 | 392 | 4/4 | 54 | kept: 4/4 |
| ni:lite | P7 | 329 | 237 | 3/3 | 41 | kept: 3/3 |
| ni:lite | P8 | 701 | 409 | 4/4 | 74 | kept: 4/4 |
| ni:lite | P9 | 189 | 330 | 3/3 | 60 | kept: 3/3 |
| ni:lite | P10 | 440 | 264 | 3/3 | 37 | kept: 3/3 |
| ni:full | P1 | 391 | 484 | 4/4 | 78 | kept: 4/4 |
| ni:full | P2 | 343 | 449 | 4/4 | 65 | kept: 4/4 |
| ni:full | P3 | 288 | 593 | 3/3 | 94 | kept: 3/3 |
| ni:full | P4 | 92 | 306 | 4/4 | 43 | kept: 4/4 |
| ni:full | P5 | 202 | 323 | 4/4 | 52 | kept: 4/4 |
| ni:full | P6 | 825 | 309 | 4/4 | 43 | kept: 4/4 |
| ni:full | P7 | 311 | 186 | 3/3 | 29 | kept: 3/3 |
| ni:full | P8 | 609 | 343 | 4/4 | 53 | kept: 4/4 |
| ni:full | P9 | 159 | 275 | 3/3 | 52 | kept: 3/3 |
| ni:full | P10 | 481 | 374 | 3/3 | 55 | kept: 3/3;(All three facts are stated: README.md was edited; sum, average, and max_value are named; procedures are listed in the Files section under calc.txt.) |
