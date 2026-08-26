#!/usr/bin/env bash
# watch_ci.sh [pr-number] — block until every CI check on the PR concludes, print
# the result table, and for each failure dump the tail of the step that failed.
#
# With no argument it resolves the PR for the current branch. Run it once, in the
# background: the deterministic waiting lives here, the judgment about what a
# failure means lives in the session that spawned it.
#
# Exit codes:
#   0  every check passed
#   1  usage error, gh missing, or an unexpected failure (the last line says where)
#   2  the PR was closed or merged while watching
#   3  timed out with checks still pending
#   4  checks concluded and at least one failed — the logs are in the output
set -euo pipefail

# A background watcher that dies silently leaves an empty output file, which is
# indistinguishable from one that never started. Every exit path says something.
trap 'echo "watch_ci: unexpected failure at line $LINENO (exit $?)"; exit 1' ERR

TIMEOUT_SECS="${WATCH_CI_TIMEOUT_SECS:-2400}"  # 40 min; the slowest job here is ~3 min
POLL_SECS="${WATCH_CI_POLL_SECS:-30}"
deadline=$(( SECONDS + TIMEOUT_SECS ))

# Diagnostics go to stdout, not stderr: under run_in_background a stderr-only
# message is invisible when the failure needs diagnosing later.
die() { echo "watch_ci: $*"; exit 1; }
command -v gh >/dev/null 2>&1 || die "gh not found"
command -v jq >/dev/null 2>&1 || die "jq not found"

# gh states its reason on stderr and nowhere else: an expired token, a 502, a
# rate limit and a genuine 404 all exit non-zero with empty stdout and differ
# only in that message. Keep it, so a watcher that gives up says which of those
# happened rather than asserting the one cause the caller can act on.
GH_ERR_FILE="$(mktemp)"
trap 'rm -f "$GH_ERR_FILE"' EXIT

gh_run() { gh "$@" 2>"$GH_ERR_FILE"; }

gh_err() { # the last gh_run failure's stderr, flattened onto one line
    local err
    err="$(tr -s '[:space:]' ' ' <"$GH_ERR_FILE")"
    err="${err# }"
    echo "${err% }"
}

PR="${1:-}"
if [[ -z "$PR" ]]; then
    PR="$(gh_run pr view --json number --jq .number)" \
        || die "no PR number given, and resolving one for the current branch failed: $(gh_err)"
fi

# gh resolves the repo from the working directory, so a watcher started from the
# wrong checkout silently watches a PR of that number in some other repo - or
# waits forever for one that does not exist there. Pin it once, up front, and
# fail immediately if the PR is not in it.
REPO="$(gh_run repo view --json nameWithOwner --jq .nameWithOwner)" \
    || die "could not resolve a GitHub repo here: $(gh_err)"
gh_run pr view "$PR" --repo "$REPO" --json number >/dev/null \
    || die "cannot read PR #$PR in $REPO: $(gh_err) — if that PR exists, this is the wrong checkout"

echo "watch_ci: watching checks on $REPO#$PR (timeout ${TIMEOUT_SECS}s, poll ${POLL_SECS}s)"

polls=0
heartbeat() { # heartbeat <status> — a waiting watcher and a wedged one look the
             # same in a background output file unless the waiting one says so.
    polls=$(( polls + 1 ))
    if (( polls % 10 == 0 )); then
        echo "watch_ci: ${SECONDS}s elapsed, $1"
    fi
}

guard() { # guard <what-we-are-waiting-for> — timeout and closed-PR check, then sleep
    if (( SECONDS >= deadline )); then
        echo "watch_ci: timed out after ${TIMEOUT_SECS}s waiting for $1 on #$PR"
        echo "watch_ci: last seen ->"
        gh pr checks "$PR" --repo "$REPO" 2>&1 || true
        exit 3
    fi
    # An unreadable state keeps the watch going — the PR is far more likely still
    # open than closed — but the reason is printed, because "waiting" that is
    # really "cannot see the PR any more" is worth knowing before the timeout.
    local state
    if ! state="$(gh_run pr view "$PR" --repo "$REPO" --json state --jq .state)"; then
        echo "watch_ci: could not read the state of #$PR, still waiting: $(gh_err)"
        state=UNKNOWN
    fi
    if [[ "$state" != "OPEN" && "$state" != "UNKNOWN" ]]; then
        echo "watch_ci: #$PR is $state, stopping the watch."
        exit 2
    fi
    sleep "$POLL_SECS"
}

# `gh pr checks --json` exits 8 while anything is still pending, which means keep
# waiting. Every other failure exits 1 — including "no checks reported on the
# branch", normal in the seconds after a push — so the exit code alone cannot
# tell a workflow that has not registered yet from a revoked token, and only the
# message can. It is printed, and repeats are suppressed: at one poll every
# POLL_SECS the same line would otherwise fill the log for the whole timeout.
#
# The JSON form is used rather than the table because the table is for humans and
# its columns are not a stable contract.
checks=""
last_why=""
while :; do
    rc=0
    checks="$(gh_run pr checks "$PR" --repo "$REPO" --json name,state,bucket,link)" || rc=$?
    if (( rc != 0 && rc != 8 )); then
        why="$(gh_err)"
        if [[ "$why" != "$last_why" ]]; then
            echo "watch_ci: no check data yet: $why"
            last_why="$why"
        fi
        checks=""
    fi
    pending="?"
    if [[ -n "$checks" ]] && jq -e 'length > 0' <<<"$checks" >/dev/null 2>&1; then
        pending="$(jq -r '[.[] | select(.bucket == "pending")] | length' <<<"$checks")"
        if [[ "$pending" == "0" ]]; then
            break
        fi
    fi
    heartbeat "$([[ "$pending" == "?" ]] && echo "no checks registered yet" || echo "$pending still pending")"
    guard "checks to conclude"
done

failed="$(jq -r '[.[] | select(.bucket == "fail")]' <<<"$checks")"
n_failed="$(jq -r 'length' <<<"$failed")"

if [[ "$n_failed" == "0" ]]; then
    echo "=== CI on $REPO#$PR: all green ==="
    gh pr checks "$PR" --repo "$REPO" 2>&1 || true
    exit 0
fi

echo "=== CI on $REPO#$PR: $n_failed failing ==="
gh pr checks "$PR" --repo "$REPO" 2>&1 || true
echo

# The log of the step that actually failed is the first thing anyone wants, and
# fetching it here means the session does not have to go hunting for run ids.
while IFS=$'\t' read -r name link; do
    [[ -n "$name" ]] || continue
    echo "=== failing step: $name ==="
    run="${link#*/runs/}"; run="${run%%/*}"
    job="${link##*/job/}"; job="${job%%[!0-9]*}"
    if [[ -n "$run" && -n "$job" ]]; then
        # Everything from "Post job cleanup" on is teardown that runs after the
        # failure, so a plain tail buries the cause under git-config chatter.
        gh run view "$run" --repo "$REPO" --job "$job" --log-failed 2>&1 \
            | sed '/Post job cleanup/q' | tail -n 40 \
            || echo "(could not fetch the log)"
    else
        echo "(no job link to fetch a log from: $link)"
    fi
    echo
done < <(jq -r '.[] | "\(.name)\t\(.link)"' <<<"$failed")

exit 4
