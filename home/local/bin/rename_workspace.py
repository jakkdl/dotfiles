#!/usr/bin/env python
import subprocess
import asyncio
import argparse
from i3ipc.aio import Connection

async def main():
    # get name from wofi
    res = subprocess.run(['wofi', '--dmenu', '--hide-scroll', '--lines=1'], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    name = res.stdout.strip()
    print(name)


    ipc = await Connection().connect()
    workspaces = await ipc.get_workspaces()
    workspace = None
    for workspace in workspaces:
        print(workspace)
        if workspace.focused:
            break

    if workspace is None:
        print("did not found focused workspace")
        return

    if workspace.num < 0:
        workspace.num = 0

    new_name = str(workspace.num)
    if name:
        new_name += ' ' + name

    await ipc.command(f'rename workspace to "{new_name}"')


if __name__ == '__main__':
    asyncio.run(main())
