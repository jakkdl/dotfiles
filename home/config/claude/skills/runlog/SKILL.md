---
name: runlog
description: Run a long-output command — tests, pre-commit, builds, docker, git — keeping the full output in a log while printing only the slice you want, without losing the exit code. Invoke before piping any command to tail/grep/head, and whenever a previous run's output was truncated and you need to see more of it.
---

# runlog

`runlog` is on `$PATH` (dotfiles → `~/.local/bin/runlog`). It takes a command
and a filter, both as shell strings:

```
runlog 'just test-py' 'tail -n 3'
runlog 'git add -u && pre-commit run' 'grep -vE Skipped | tail -n 6'
runlog 'just up'                                  # filter defaults to tail -n 20
```

The command's output is captured to a log, the filter is applied to that log,
and `runlog` exits with **the command's** status. Nothing else to learn — the
filter is an ordinary pipeline reading the log on stdin (`$RUNLOG` holds its
path if a filter needs the filename).

**Never write `cmd 2>&1 | tail -N` again.** That loses the exit code *and*
everything the filter dropped, so any surprise costs a second run of a suite
that took 40 seconds.

## Seeing more afterwards

The footer names the log:

```
runlog | exit 1 | 42s | 3/847 lines | /tmp/runlog-1000/20260821-135253-just-test-py.log
```

Follow up with plain tools on that path — no rerun:

```
grep -nE 'FAILED|Error' /tmp/runlog-1000/20260821-135253-just-test-py.log
tail -n 40 /tmp/runlog-1000/latest        # symlink to the newest log
```

Rerunning a suite to widen a `tail` is the exact waste this exists to stop.

## Gotchas

- Output is captured, so the command sees a pipe, not a terminal — colour and
  progress bars turn themselves off. `\r` spinners (flutter, cargo) are split
  into real lines in the log, so **no `tr '\r' '\n'` is needed**.
- Interactive commands still can't work — same as any redirect.
- `runlog 'just test-py'` doesn't match a `Bash(just test-py:*)` permission
  rule, so an allowlisted command may start prompting. Say so rather than
  dropping back to `| tail`; broadly allowlisting `Bash(runlog *)` would allow
  anything.
- Logs live in `/tmp/runlog-$UID/` (`RUNLOG_DIR`), pruned after 7 days
  (`RUNLOG_KEEP_DAYS`). They survive across sessions.
