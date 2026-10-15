#!/usr/bin/env bash
# watch_merge.sh [pr-number | pr-url] [--since <UTC ISO-8601>] — block until the
# PR is merged, closed, has merge conflicts, or gets a new comment, and say which.
#
# With no PR it resolves the PR for the current branch; a PR URL also names the
# repo, so it works from any directory. Comments count
# from --since, default now; posts carrying the Claude Code footer are skipped,
# so the watcher is not woken by the bot's review or an agent's own reply. Run
# it once, in the background, under `busy wait`: what it waits on is a person,
# not work, so the workspace tints must not show it as running.
#
# Exit codes:
#   0  the PR was merged
#   1  usage error, gh/jq missing, or an unexpected failure (the last line says where)
#   2  the PR was closed without being merged
#   3  timed out with the PR still open
#   4  the PR has merge conflicts with its base — it cannot merge until resolved
#   5  a new comment or review — printed, with the --since to resume from
set -euo pipefail

# A background watcher that dies silently leaves an empty output file, which is
# indistinguishable from one that never started. Every exit path says something.
trap 'echo "watch_merge: unexpected failure at line $LINENO (exit $?)"; exit 1' ERR
trap 'echo "watch_merge: killed by SIGTERM after ${SECONDS}s (${polls:-0} polls)"; exit 143' TERM
trap 'echo "watch_merge: killed by SIGHUP after ${SECONDS}s (${polls:-0} polls)"; exit 129' HUP
trap 'echo "watch_merge: interrupted (SIGINT) after ${SECONDS}s (${polls:-0} polls)"; exit 130' INT

TIMEOUT_SECS="${WATCH_MERGE_TIMEOUT_SECS:-604800}"  # a week; merging waits on a person
POLL_SECS="${WATCH_MERGE_POLL_SECS:-60}"
HEARTBEAT_POLLS="${WATCH_MERGE_HEARTBEAT_POLLS:-60}"  # about hourly at the default poll
deadline=$(( SECONDS + TIMEOUT_SECS ))

# Diagnostics go to stdout, not stderr: under run_in_background a stderr-only
# message is invisible when the failure needs diagnosing later.
die() { echo "watch_merge: $*"; exit 1; }
command -v gh >/dev/null 2>&1 || die "gh not found"
command -v jq >/dev/null 2>&1 || die "jq not found"

# gh states its reason on stderr and nowhere else: an expired token, a 502 and a
# genuine 404 all exit non-zero with empty stdout and differ only in that
# message, so it is kept for whatever gets printed.
GH_ERR_FILE="$(mktemp)"
trap 'rm -f "$GH_ERR_FILE"' EXIT

gh_run() { gh "$@" 2>"$GH_ERR_FILE"; }

gh_err() { # the last gh_run failure's stderr, flattened onto one line
    local err
    err="$(tr -s '[:space:]' ' ' <"$GH_ERR_FILE")"
    err="${err# }"
    echo "${err% }"
}

PR=""
REPO=""
TARGET=""  # the PR as given, for the resume line
SINCE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
while (( $# )); do
    case "$1" in
        --since) [[ -n "${2:-}" ]] || die "--since needs a timestamp"; SINCE="$2"; shift 2 ;;
        *)
            if [[ "$1" =~ ^https://github\.com/([^/]+/[^/]+)/pull/([0-9]+)/?$ ]]; then
                REPO="${BASH_REMATCH[1]}"; PR="${BASH_REMATCH[2]}"
            elif [[ "$1" =~ ^[0-9]+$ ]]; then
                PR="$1"
            else
                die "usage: watch_merge.sh [pr-number | pr-url] [--since <UTC ISO-8601>]"
            fi
            TARGET="$1"; shift ;;
    esac
done
if [[ -z "$PR" ]]; then
    PR="$(gh_run pr view --json number --jq .number)" \
        || die "no PR number given, and resolving one for the current branch failed: $(gh_err)"
    TARGET="$PR"
fi

# gh resolves the repo from the working directory, so a watcher started from the
# wrong checkout silently watches a PR of that number in some other repo. Pin it
# once, up front, and fail at once if the PR is not in it.
if [[ -z "$REPO" ]]; then
    REPO="$(gh_run repo view --json nameWithOwner --jq .nameWithOwner)" \
        || die "could not resolve a GitHub repo here: $(gh_err)"
fi
title="$(gh_run pr view "$PR" --repo "$REPO" --json title --jq .title)" \
    || die "cannot read PR #$PR in $REPO: $(gh_err) — if that PR exists, this is the wrong checkout"

echo "watch_merge: waiting for $REPO#$PR \"$title\" to be merged, or for comments since $SINCE (timeout ${TIMEOUT_SECS}s, poll ${POLL_SECS}s)"

polls=0
last_why=""
while :; do
    # One read for the state and what to report once it changes. A failed read
    # keeps the watch going, since the PR is far more likely still open than
    # not; the reason is printed once per change of reason, not once per poll.
    if pr_json="$(gh_run pr view "$PR" --repo "$REPO" \
        --json state,mergedAt,mergedBy,mergeCommit,closedAt,mergeable,baseRefName,comments,reviews)"; then
        # Not tab-separated: tab is whitespace to read, so empty fields would
        # collapse and shift the rest left.
        info="$(jq -r '[.state, (.mergedAt // ""), (.mergedBy.login // ""), (.mergeCommit.oid // "" | .[0:12]), (.closedAt // ""), (.mergeable // ""), .baseRefName] | join("|")' \
            <<<"$pr_json")"
        IFS='|' read -r state merged_at merged_by commit closed_at mergeable base <<<"$info"
        last_why=""
        case "$state" in
            MERGED)
                echo "=== $REPO#$PR merged by ${merged_by:-?} at $merged_at, merge commit ${commit:-?} ==="
                exit 0
                ;;
            CLOSED)
                echo "=== $REPO#$PR closed without merging at $closed_at ==="
                exit 2
                ;;
        esac
        # A review with only inline comments has an empty body but still counts:
        # the comments themselves hang off it.
        new="$(jq --arg since "$SINCE" '
            [(.comments[] | {who: .author.login, at: .createdAt, body}),
             (.reviews[] | {who: .author.login, at: .submittedAt, body})]
            | map(select(.at != null and .at > $since
                         and (.body | contains("Generated with [Claude Code]") | not)))
            | sort_by(.at)' <<<"$pr_json")"
        if [[ "$(jq length <<<"$new")" != 0 ]]; then
            echo "=== new comments on $REPO#$PR ==="
            jq -r '.[] | "--- \(.who) at \(.at) ---\n\(if .body == "" then "(inline review comments only — read them on the PR)" else .body end)\n"' <<<"$new"
            echo "watch_merge: resume with: watch_merge.sh $TARGET --since $(jq -r '.[-1].at' <<<"$new")"
            exit 5
        fi
        # GitHub works mergeability out lazily after the base moves, so a poll
        # can read UNKNOWN; only CONFLICTING is acted on, and the next poll
        # catches up.
        if [[ "$mergeable" == "CONFLICTING" ]]; then
            echo "=== $REPO#$PR has merge conflicts with $base ==="
            echo "watch_merge: resume with: watch_merge.sh $TARGET --since $SINCE"
            exit 4
        fi
    else
        why="$(gh_err)"
        if [[ "$why" != "$last_why" ]]; then
            echo "watch_merge: could not read #$PR, still waiting: $why"
            last_why="$why"
        fi
    fi

    polls=$(( polls + 1 ))
    if (( polls % HEARTBEAT_POLLS == 0 )); then
        echo "watch_merge: ${SECONDS}s elapsed, #$PR still open"
    fi
    if (( SECONDS >= deadline )); then
        echo "watch_merge: timed out after ${TIMEOUT_SECS}s with $REPO#$PR still open"
        exit 3
    fi
    # In the background and waited on, so a signal's trap runs at once rather
    # than after the rest of the poll interval.
    sleep "$POLL_SECS" &
    wait $!
done
