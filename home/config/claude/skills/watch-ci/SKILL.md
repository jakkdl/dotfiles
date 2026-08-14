---
name: watch-ci
description: Wait for a pull request's CI checks to conclude and report the result, dumping the failing step's log for anything that failed. Invoke when asked to watch CI, wait for the build, or check whether the checks passed on a PR — and after any push where the result matters.
---

# watch-ci

Run the bundled script once, in the background, and end the turn:

```
Bash (run_in_background: true): ~/.config/claude/skills/watch-ci/scripts/watch_ci.sh <pr-number>
```

The PR number is optional — with none it resolves the PR for the current branch.
The script blocks until every check concludes, prints the table, and for each
failing check dumps the last 40 lines of the step that actually failed, so the
result usually contains the diagnosis already.

**Do not** poll `gh` in a loop yourself, write an ad-hoc watcher, or schedule
wakeups alongside it. Improvised watchers are the flakiness this replaces, and a
wakeup racing the script produces two half-answers.

## Exit codes

| code | meaning |
| --- | --- |
| 0 | every check passed |
| 1 | usage error, `gh` missing, or an unexpected failure — the last line names the line number |
| 2 | the PR was closed or merged while watching |
| 3 | timed out with checks still pending (`WATCH_CI_TIMEOUT_SECS` raises the 40 min default) |
| 4 | checks concluded and at least one failed; the logs are in the output |

An empty output file means the script never started — that is a launch problem,
not a CI result. Every other path prints something, including the failures.

## When it comes back

- **Green:** say so and move on. Do not re-run it to be sure.
- **Failures:** diagnose from the dumped log. Fix as NEW commits — never amend or
  force-push anything already pushed — then push and run the script again. The
  work is not done until the checks are green.
- **Timeout:** report it with what was still pending. Do not silently re-run: a
  job stuck for 40 minutes is usually a runner problem, and starting a second
  watcher hides it.
- **Flake:** if a check fails for a reason unrelated to the diff, say that
  plainly rather than asserting the branch is fine, and re-run that job with
  `gh run rerun --failed <run-id>`.
