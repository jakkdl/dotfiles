#!/usr/bin/env python
import subprocess
import sys
import asyncio
from i3ipc.aio import Connection

# Font Awesome brands where they exist; Font Awesome has no Teams icon, so
# that one is the Material Design glyph shipped by nerd fonts, and no icon
# font has a Beeper logo, so it gets the generic FA comments icon.
ICONS = {
    "firefox": "",
    "chromium": "",
    "spotify": "",
    "teams": "\U000f02bb",
    "steam": "",
    "signal": "",
    "discord": "",
    "beeper": "",
}


def iconify(name: str) -> str:
    """Swap a known app name for its icon, if an installed font can render it."""
    icon = ICONS.get(name.lower())
    if icon is None:
        return name
    codepoint = f"{ord(icon):x}"
    res = subprocess.run(
        ["fc-list", f":charset={codepoint}"], stdout=subprocess.PIPE, text=True
    )
    if not res.stdout.strip():
        subprocess.run(
            [
                "notify-send",
                "--urgency=critical",
                "rename_workspace",
                f"No installed font has the {name} icon (U+{codepoint.upper()})",
            ]
        )
        return name
    return icon


async def main():
    # the sway binding pipes the wofi prompt's output to our stdin
    name = iconify(sys.stdin.read().strip())
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
        new_name += " " + name

    await ipc.command(f'rename workspace to "{new_name}"')


if __name__ == "__main__":
    asyncio.run(main())
