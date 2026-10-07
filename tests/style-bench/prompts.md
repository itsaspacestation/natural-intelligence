# Style benchmark prompts

Ten prompts for `tests/style-bench.sh` (DESIGN.md NFR7). Each section holds one `Prompt:`
line, a `Kind:` line (`explain` or `change`), and a `Facts:` list of 3 to 6 statements a
correct reply must contain. A judge call answers yes or no per fact, in any wording.
Change prompts run against a copy of `sample/` (README.md, calc.txt, notes.md); the copy
is reset before every prompt.

## P1
Prompt: Explain database connection pooling.
Kind: explain
Facts:
- The pool keeps open connections and reuses them instead of opening a new connection per request.
- Opening a connection is costly (handshake, authentication, or session setup).
- A client borrows a connection from the pool and returns it after use.
- The pool caps the number of concurrent connections (a maximum size).

## P2
Prompt: Explain idempotency in HTTP APIs.
Kind: explain
Facts:
- Repeating the same request has the same effect on the server as sending it once.
- GET, PUT, and DELETE are idempotent methods.
- POST is not idempotent by default.
- Idempotency makes retries safe (or an idempotency key makes a POST retry safe).

## P3
Prompt: Explain the CAP theorem trade-off.
Kind: explain
Facts:
- The three properties are consistency, availability, and partition tolerance.
- During a network partition a system can keep only one of consistency and availability.
- Partitions cannot be ruled out in a distributed system, so the real choice is consistency versus availability.

## P4
Prompt: What is the purpose of the TLS handshake?
Kind: explain
Facts:
- It authenticates the server through its certificate.
- It negotiates the protocol version and cipher suite.
- It establishes shared session keys for symmetric encryption of the application data.
- It completes before any application data is sent.

## P5
Prompt: What is the difference between git rebase and git merge?
Kind: explain
Facts:
- merge creates a merge commit that joins the two histories.
- rebase replays (rewrites) the commits onto the new base, giving a linear history.
- rebase changes the commit hashes of the replayed commits.
- Do not rebase commits that are already pushed or shared.

## P6
Prompt: In calc.txt rename the procedure max_value to maximum, update every reference in this project, and report what changed.
Kind: change
Facts:
- max_value was renamed to maximum.
- calc.txt was edited.
- notes.md was edited (it referenced max_value).
- A search for max_value across the project found the references (two occurrences, or no other callers).

## P7
Prompt: Add a guard to max_value in calc.txt so it returns 0 on an empty list, and report the change.
Kind: change
Facts:
- calc.txt was edited.
- max_value now returns 0 when items is empty.
- The guard checks the empty case (count(items) == 0 or equivalent) before best = items[0].

## P8
Prompt: Add a median procedure to calc.txt in the existing style, remove the median TODO from notes.md, and report both changes.
Kind: change
Facts:
- A median procedure was added to calc.txt.
- median sorts the items (or works on a sorted copy).
- For an even count, median averages the two middle values.
- The TODO line was removed from notes.md.

## P9
Prompt: Without editing any file, explain what average in calc.txt returns for an empty list and why.
Kind: change
Facts:
- average returns 0 for an empty list.
- The reason is the guard count(items) == 0 at the top of average.
- The guard avoids a division by zero in sum(items) / count(items).

## P10
Prompt: Update the Files section of README.md so it lists every procedure defined in calc.txt, and report what changed.
Kind: change
Facts:
- README.md was edited.
- The reply names the three procedures sum, average, and max_value.
- The procedures are listed in the Files section (under or next to calc.txt).
