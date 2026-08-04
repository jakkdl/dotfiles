#!/usr/bin/python
# Pinned to the system interpreter, NOT `env python`, for the same reason as
# sway-session: an activated venv shadows `python` and won't have i3ipc.
"""Start work on a new PR/project from a sway binding.

Prompts for a name with wofi, takes the lowest free numbered workspace,
renames it to "<num> <name>", and opens a terminal in ~/Git/clairos that runs
`newpr <name>` (the zsh function: branch + worktree + venv) and then claude.

The command is handed to the shell via the zshrc SWAY_RESTORE_CMD hook, so it
runs in a normal interactive zsh: the function is defined, the command lands
in history, and the shell stays open if newpr or claude fails.
"""

from __future__ import annotations

import asyncio
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from i3ipc.aio import Connection

REPO = Path.home() / "Git/clairos"


def prompt_name() -> str:
    res = subprocess.run(
        ["wofi", "--dmenu", "--hide-scroll", "--lines=1", "--prompt=new PR:"],
        stdout=subprocess.PIPE,
        text=True,
        check=False,
    )
    return res.stdout.strip()


async def main() -> int:
    name = sys.argv[1] if len(sys.argv) > 1 else prompt_name()
    if not name:  # cancelled
        return 0
    name = name.replace(" ", "_")
    if not re.fullmatch(r"[A-Za-z0-9._-]+", name):
        subprocess.run(["alert", "newpr", f"invalid name: {name!r}"], check=False)
        return 1

    ipc = await Connection().connect()
    nums = {w.num for w in await ipc.get_workspaces()}
    num = next(n for n in range(1, 100) if n not in nums)
    await ipc.command(f"workspace number {num}")
    await ipc.command(f'rename workspace to "{num} {name}"')

    env = dict(os.environ)
    env["SWAY_RESTORE_CMD"] = f"newpr {name} && claude"
    # single-use claim file so foot ctrl+shift+n clones don't rerun the command
    tokdir = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "sway-restore-once"
    tokdir.mkdir(parents=True, exist_ok=True)
    fd, tok = tempfile.mkstemp(dir=tokdir)
    os.close(fd)
    env["SWAY_RESTORE_ONCE"] = tok
    subprocess.Popen(
        ["foot", "-D", str(REPO)],
        env=env,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        start_new_session=True,
    )
    return 0


if __name__ == "__main__":
    sys.exit(asyncio.run(main()))
