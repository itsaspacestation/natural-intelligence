# Style bench, last run

Date: 2026-10-08T18:45Z
Model: sonnet (judge: haiku)
Claude Code: 2.1.294 (Claude Code)
Styles: default concise ni:lite ni:full
Prompts: 1 2 3 4 5 6 7 8 9 10
MAX_THINKING_TOKENS: unset

| style | output tokens | reply chars | facts kept | words |
|---|---|---|---|---|
| default | 5637 | 9836 | 34/36 (94%) | 1610 |
| concise | 5215 | 9529 | 36/36 (100%) | 1523 |
| ni:lite | 3568 | 4690 | 36/36 (100%) | 746 |
| ni:full | 3292 | 3244 | 34/36 (94%) | 513 |

## Per prompt

| style | prompt | output tokens | reply chars | facts kept | words | judge |
|---|---|---|---|---|---|---|
| default | P1 | 863 | 2353 | 4/4 | 366 | kept: 4/4 |
| default | P2 | 754 | 2020 | 4/4 | 357 | kept: 4/4 |
| default | P3 | 569 | 1644 | 3/3 | 268 | kept: 3/3 |
| default | P4 | 171 | 522 | 3/4 | 78 | kept: 3/4;It completes before any application data is sent. |
| default | P5 | 455 | 1157 | 4/4 | 187 | kept: 4/4 |
| default | P6 | 834 | 324 | 3/4 | 46 | kept: 3/4;- A search for max_value across the project found the references (two occurrences, or no other callers). |
| default | P7 | 541 | 318 | 3/3 | 51 | kept: 3/3 |
| default | P8 | 738 | 676 | 4/4 | 114 | kept: 4/4 |
| default | P9 | 247 | 485 | 3/3 | 89 | kept: 3/3 |
| default | P10 | 465 | 337 | 3/3 | 54 | kept: 3/3 |
| concise | P1 | 953 | 2468 | 4/4 | 373 | kept: 4/4 |
| concise | P2 | 663 | 1795 | 4/4 | 312 | kept: 4/4 |
| concise | P3 | 539 | 1622 | 3/3 | 256 | kept: 3/3 |
| concise | P4 | 284 | 816 | 4/4 | 120 | kept: 4/4 |
| concise | P5 | 319 | 903 | 4/4 | 147 | kept: 4/4 |
| concise | P6 | 667 | 443 | 4/4 | 65 | kept: 4/4 |
| concise | P7 | 374 | 292 | 3/3 | 46 | kept: 3/3 |
| concise | P8 | 745 | 556 | 4/4 | 98 | kept: 4/4 |
| concise | P9 | 283 | 431 | 3/3 | 78 | kept: 3/3 |
| concise | P10 | 388 | 203 | 3/3 | 28 | kept: 3/3 |
| ni:lite | P1 | 179 | 591 | 4/4 | 100 | kept: 4/4 |
| ni:lite | P2 | 274 | 820 | 4/4 | 136 | kept: 4/4 |
| ni:lite | P3 | 451 | 883 | 3/3 | 131 | kept: 3/3 |
| ni:lite | P4 | 124 | 415 | 4/4 | 64 | kept: 4/4 |
| ni:lite | P5 | 132 | 430 | 4/4 | 71 | kept: 4/4 |
| ni:lite | P6 | 704 | 321 | 4/4 | 47 | kept: 4/4 |
| ni:lite | P7 | 315 | 206 | 3/3 | 33 | kept: 3/3 |
| ni:lite | P8 | 717 | 490 | 4/4 | 82 | kept: 4/4 |
| ni:lite | P9 | 218 | 230 | 3/3 | 37 | kept: 3/3 |
| ni:lite | P10 | 454 | 304 | 3/3 | 45 | kept: 3/3 |
| ni:full | P1 | 139 | 466 | 3/4 | 83 | kept: 3/4;Opening a connection is costly (handshake, authentication, or session setup). |
| ni:full | P2 | 205 | 454 | 4/4 | 69 | kept: 4/4 |
| ni:full | P3 | 281 | 464 | 3/3 | 71 | kept: 3/3 |
| ni:full | P4 | 74 | 246 | 3/4 | 35 | kept: 3/4;It completes before any application data is sent. |
| ni:full | P5 | 97 | 307 | 4/4 | 48 | kept: 4/4 |
| ni:full | P6 | 853 | 285 | 4/4 | 43 | kept: 4/4 |
| ni:full | P7 | 313 | 197 | 3/3 | 32 | kept: 3/3 |
| ni:full | P8 | 706 | 404 | 4/4 | 69 | kept: 4/4 |
| ni:full | P9 | 187 | 161 | 3/3 | 27 | kept: 3/3 |
| ni:full | P10 | 437 | 260 | 3/3 | 36 | kept: 3/3 |
