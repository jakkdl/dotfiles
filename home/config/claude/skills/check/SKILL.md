---
name: check
description: Stage, run pre-commit, and run the test suite in one command, from anywhere in the repo, keeping the full output in a log and the exit status intact. Use instead of hand-writing `git add -u && pre-commit run 2>&1 | grep ... ; just test-py 2>&1 | tail -3`, and before any commit or push.
---

# check

`check` is on `$PATH` (dotfiles → `~/.local/bin/check`). It runs, from the
worktree root:

1. `git add -u` — pre-commit only sees staged files
2. `pre-commit run` — and if the hooks rewrote files, restages and reruns once
3. the tests — `just test-py` by default

all inside one [`runlog`](../runlog/SKILL.md), so the full output is on disk and
the exit status is the real one.

```
check                                  # the default: add -u, pre-commit, just test-py
check --no-tests                       # pre-commit only
check pytest clairos/tests/test_x.py   # that instead of just test-py
check just test-flutter-widget
git add changelog.d/thing.fixed.md && check    # new file: name it
```

No `cd` prefix is needed, and there is no filter to invent.

## What it prints

Everything passed — the tail of the suite output plus the summary line, which is
always printed so "no tests ran" can never look like "everything passed":

```
======================= 465 passed, 1 xfailed in 39.35s ========================
--- check: pre-commit=0 tests=0
runlog | exit 0 | 41s | 3/57 lines | /tmp/runlog-1000/20260826-142755-check.log
```

Something failed — the tail of *each* failing part, so a hook failure is never
buried under test output:

```
hard fail................................................................Failed
- hook id: hard-fail
- exit code: 1
HOOK ERROR: thing is wrong at line 4
--- check: tests
FAILED tests/test_seed.py::test_seed_defaults
--- check: pre-commit=1 tests=1
runlog | exit 1 | 44s | 12/210 lines | /tmp/runlog-1000/...log
```

`--- check: hooks rewrote files; restaging and rerunning` appears when a
formatter changed something — worth noticing, the diff moved under you.

To see more, use the log path from the footer. Never rerun the suite to widen a
filter.

## Gotchas

- It stages. Reverting a scratch edit afterwards needs `git checkout HEAD --
  <file>`, not `git checkout -- <file>`, which would restore the staged copy.
- There is no `git add -A` option, on purpose — it sweeps scratch files into the
  commit. Name new files (`git add path && check`), or glob them.
- The tests run even when pre-commit fails, so one run reports both.
- It never silently skips the tests. A justfile with no `test-py` recipe is an
  error (exit 2, "name the tests instead"), not a quiet pass. The recipe list
  comes from `just --summary`, so parameters like `test-py *flags:` are fine.
- A repo with no justfile at all runs pre-commit only, and the summary line says
  `(no justfile, pre-commit only)` — that line is always printed.
