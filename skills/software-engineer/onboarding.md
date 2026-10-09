# Project onboarding

Run this checklist once per project per session, before any build, test, or lint
command. The project's own files are the source of truth for its commands; the
[`software-engineer`](SKILL.md) skill makes this pass the first step of every task.

## Checklist

1. **Host**: operating system, shell in use, architecture. Decides which command forms
   apply and whether the project's toolchain can run here at all.
2. **Project stack**: languages, frameworks, runtime versions. Read the marker files at
   the repo root and in subprojects, version pin files, manifests, and the README.
3. **Target platform**: where the software runs: operating systems, architectures,
   containers, cloud or device targets. Read build configuration, container files,
   deployment descriptors, and the CI matrix. Decides which variants matter and which
   tests can run locally.
4. **Package manager and build system**: read lock files and committed wrappers or
   runners. Choose exactly one manager; never recommend switching.
5. **CI pipeline**: read the pipeline definition first. It is the authoritative list of
   build, test, lint, format, and coverage commands, their order, the environment
   variables and services they need, and the platforms the project claims to support.
   Reproduce those commands locally in the same order.
6. **Repository conventions**: Makefile or justfile targets, project CLAUDE.md,
   CONTRIBUTING, editor configuration, pre-commit configuration. These override tool
   defaults.
7. **Test and coverage tooling**: framework, runner, coverage reporter, where reports
   land. Prefer the machine-readable format the toolchain already emits.
8. **Variant selection**: when one language has several runtimes, toolchain
   generations, or frameworks, decide from the project files which one applies, then
   check the host can run it. If it cannot, say so and stop; never substitute another
   toolchain.
9. **Command form**: prefer the committed wrapper or runner over a global binary. One
   command per line, no shell syntax; per-shell lines only where the invocation differs
   (see the table below). Run the whole suite, not only the changed project. After each
   edit run the cheapest check the toolchain offers.
10. **Trace**: in the task's final report, say which source gave each command.

## Shell rules

Snippets in skills are shell-neutral: one command per line, flags only, no shell
syntax. Banned inside fenced blocks: `$(`, `${`, `<<`, `export`, `&&`, `||`,
`2>/dev/null`, pipes to `sort`, `uniq`, `grep`, `awk`, `sed`, or `xargs`, the
home-directory tilde shortcut, the Unix temp root, Windows executable suffixes, and
`sudo`. Where the shells differ, show each form on its own line:

<!-- shell-table -->
| Need | bash | PowerShell | cmd |
|---|---|---|---|
| Run a committed wrapper | `./name` | `.\name.bat` or `.\name.cmd` | `name.bat` |
| Home directory | `$HOME` | `$env:USERPROFILE` | `%USERPROFILE%` |
| Temp directory | `$TMPDIR` or `/tmp` | `$env:TEMP` | `%TEMP%` |
| Quote a literal argument | single quotes | single quotes | double quotes |
| Path separator | `/` | `\` or `/` | `\` |
| Read a file into a flag | `--flag=@file` or `--input file` | same | same |

Use the interpreter name the project's own files use (CI pipeline, wrapper, lock file,
Makefile). When no file names one, probe once with the plain name and once with the
host's suffixed name, keep the one that answers, and write that exact name into every
verify command you record. Prefer the project's committed runner or launcher, and run
tools through the interpreter's module flag rather than a bare tool on PATH.

## Coverage

Produce the machine-readable coverage report the toolchain emits natively. Read it to
list the uncovered lines and branches in the touched area.
