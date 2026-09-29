#!/usr/bin/python
# Pinned to the system interpreter, NOT `env python`, for the same reason as
# newpr_workspace: pr_done runs inside a worktree venv, which shadows `python`
# with an interpreter that doesn't have i3ipc.
"""Pop a workspace: wait for it to empty, then shift the higher ones down one.

`pr_done` starts this detached right before it closes its shell, so it outlives
the terminal it came from. It waits for the workspace to lose its last window,
then renames every higher-numbered workspace down by one. A sway rename keeps
the workspace's windows and output, so nothing has to be moved.

The workspace defaults to the focused one, read at startup while the terminal
that launched us is still up.

Nothing happens unless the workspace really empties: a workspace still holding
a window when the timeout runs out is left alone, gap and all. That one is a
normal outcome and stays quiet; everything else that goes wrong is reported
with `alert`, since by then there is no terminal left to print to.
"""

from __future__ import annotations

import asyncio
import re
import subprocess
import sys
import time

try:
    from i3ipc.aio import Connection
    from i3ipc.replies import WorkspaceReply
except ImportError as exc:
    subprocess.run(["alert", "pop_workspace", f"no i3ipc: {exc}"], check=False)
    raise SystemExit(1) from exc

# generous: we only have to outlast the terminal's own teardown
TIMEOUT = 10.0
POLL = 0.15


def alert(body: str) -> None:
    """Report a failure; there is no terminal left to print to."""
    subprocess.run(["alert", "pop_workspace", body], check=False)


def quote(name: str) -> str:
    """Quote a workspace name for the sway command parser."""
    escaped = name.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def renumbered(name: str, num: int) -> str:
    """Workspace name with its leading number replaced by `num`."""
    return re.sub(r"^\d+", str(num), name, count=1)


def rename(name: str, num: int) -> str:
    """Command moving the workspace called `name` to `num`."""
    return f"rename workspace {quote(name)} to {quote(renumbered(name, num))}"


def vacate(workspaces: list[WorkspaceReply], stuck: WorkspaceReply) -> str:
    """Command that frees the number of the emptied workspace `stuck`.

    sway drops an empty workspace only once its output shows another one, and
    an output always shows something, so one sitting alone on a second screen
    is not dropped by merely focusing elsewhere. Another workspace from that
    same output takes its place: the next one up, so a pop still lands on the
    workspace that inherits the number, or the nearest one below when this was
    the highest there.

    When that output has nothing else to show, the workspace keeps the screen
    and moves above every other one instead. The renumbering that follows
    treats it like any other workspace above the gap and pulls it back down
    into the number the shift frees at the top.
    """
    here = [w for w in workspaces if w.output == stuck.output and w.num != stuck.num]
    if not here:
        return rename(stuck.name, max(w.num for w in workspaces) + 1)
    up = above(here, stuck.num)
    target = up[0] if up else max(here, key=lambda w: w.num)
    return f"workspace number {target.num}"


async def window_count(ipc: Connection, num: int) -> int | None:
    """Windows on workspace `num`, or None if there is no such workspace."""
    tree = await ipc.get_tree()
    for workspace in tree.workspaces():
        if workspace.num == num:
            return len(workspace.nodes) + len(workspace.floating_nodes)
    return None


async def wait_until_empty(ipc: Connection, num: int) -> bool:
    """Wait for workspace `num` to hold nothing. False if it never does.

    Polls rather than subscribing, since the workspace can equally well end up
    empty or gone: sway destroys an empty workspace as soon as it loses focus.
    """
    deadline = time.monotonic() + TIMEOUT
    while True:
        count = await window_count(ipc, num)
        if not count:
            return True
        if time.monotonic() >= deadline:
            return False
        await asyncio.sleep(POLL)


def above(workspaces: list[WorkspaceReply], num: int) -> list[WorkspaceReply]:
    """Workspaces numbered above `num`, lowest first."""
    return sorted((w for w in workspaces if w.num > num), key=lambda w: w.num)


async def main() -> int:
    ipc = await Connection().connect()

    if len(sys.argv) > 1:
        num = int(sys.argv[1])
    else:
        num = next((w.num for w in await ipc.get_workspaces() if w.focused), -1)
    if num < 1:
        alert(f"not a numbered workspace: {num}")
        return 1

    if not await wait_until_empty(ipc, num):
        return 0

    workspaces = await ipc.get_workspaces()
    if not above(workspaces, num):
        return 0

    if stuck := next((w for w in workspaces if w.num == num), None):
        # sway hands out duplicate numbers without complaining, so the number
        # has to be free before anything is renamed into it.
        await ipc.command(vacate(workspaces, stuck))
        workspaces = await ipc.get_workspaces()
        if any(w.num == num for w in workspaces):
            alert(f"workspace {num} is still around, not renumbering")
            return 1

    # Ascending, so each workspace moves into a number the previous one just
    # left; sway applies the whole chain in order.
    renames = [rename(w.name, w.num - 1) for w in above(workspaces, num)]
    replies = await ipc.command("; ".join(renames))
    if failed := [r for r in replies if not r.success]:
        alert("; ".join(getattr(r, "error", None) or "rename failed" for r in failed))
        return 1
    return 0


if __name__ == "__main__":
    try:
        sys.exit(asyncio.run(main()))
    except Exception as exc:
        alert(f"{type(exc).__name__}: {exc}")
        sys.exit(1)
