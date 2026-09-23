#!/usr/bin/python3
"""Checks that all files in the root and home directories have symlinks on the system,
and prompts to create or warns about missing them"""

import difflib
import os
import os.path
import subprocess
from shutil import copyfile, move, which
from typing import Literal

FIXFILE = "fix_links.sh"
# copying a unit file or drop-in here means systemd needs to re-read them
SYSTEMD_UNIT_DIR = "/etc/systemd/system/"
# same, for the per-user manager; these get symlinked rather than copied
SYSTEMD_USER_DIR = os.path.expanduser("~/.config/systemd/user/")
SYSTEMD_USER_SRC = "home/config/systemd/user"
# what counts as a unit in there, as opposed to a drop-in or a stray file
UNIT_SUFFIXES = (".service", ".timer", ".socket", ".target", ".mount", ".path")


def main() -> None:
    """do all the stuffs"""
    commands = symlink_files("home", os.path.expanduser("~"), ".")
    commands += copy_folder_contents("root", "/")
    commands += check_units("root" + SYSTEMD_UNIT_DIR)
    commands += check_units(SYSTEMD_USER_SRC, user=True)
    commands += check_submodules()

    if not commands:
        print("all symlinks OK")
        if os.path.isfile("fix_links.sh"):
            os.remove("fix_links.sh")
        return

    with open("fix_links.sh", "w", encoding="utf-8") as file:
        file.write(" &&\n".join(commands))
    os.chmod(FIXFILE, 0o755)
    print("run fix_links.sh")


def check_units(folder: str, user: bool = False) -> list[str]:
    """prompt to enable any unit we ship that has an [Install] section but is
    not enabled on the system. Runs regardless of whether the file was copied
    or symlinked, since a unit already in place can still be sitting there
    disabled. `user` picks the per-user manager, which needs no sudo."""
    if not which("systemctl"):
        return []
    systemctl = ["systemctl", "--user"] if user else ["systemctl"]
    prefix = "systemctl --user" if user else "sudo systemctl"
    commands = []
    units = sorted(f for f in os.listdir(folder) if f.endswith(UNIT_SUFFIXES))
    for filename in units:
        stem, suffix = os.path.splitext(filename)
        # a timer is what you enable; its service is pulled in by the timer
        if suffix == ".service" and stem + ".timer" in units:
            continue
        with open(os.path.join(folder, filename), encoding="utf-8") as file:
            if "[Install]" not in file.read():
                continue
        state = subprocess.run(
            systemctl + ["is-enabled", filename],
            capture_output=True,
            text=True,
            check=False,
        ).stdout.strip()
        if state == "enabled":
            continue
        print(f"{filename} is {state or 'unknown'}")
        if input("enable --now? [Y/n] ").lower() == "n":
            continue
        commands.append(f"{prefix} enable --now {filename}")
    return commands


def check_submodules() -> list[str]:
    """check for submodules"""
    if not os.path.isfile("vim-plug/plug.vim"):
        return ["git submodule init && git submodule update\n"]
    return []


def copy_folder_contents(folder: str, replace: str) -> list[str]:
    """checks if file contents differ, returns list of commands needed to rectify"""
    commands = []
    needs_daemon_reload = False
    for dirpath, dirnames, filenames in os.walk(folder):
        if "__pycache__" in dirnames:
            dirnames.remove("__pycache__")
        # root/ -> /
        # root/dir/ -> /dir/
        base = os.path.join(replace, dirpath[len(folder) + 1 :], "")
        # basepath = base

        for filename in filenames:
            if filename.endswith(".pyc"):
                continue
            remove = False
            path = base + filename
            abstarget = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.join(dirpath, filename)

            if dir_missing(base):
                print(f"{path} missing (directory {base} does not exist)")
                if input("copy? [Y/n] ").lower() == "n":
                    continue
                mkdir = f"sudo mkdir -p {base}"
                if mkdir not in commands:
                    commands.append(mkdir)
            elif not os.access(base, mode=os.R_OK):
                print(f"No permissions to check {path}")
                continue
            elif not (os.path.isfile(path) or os.path.islink(path)):
                print(f"{path} missing")
                if input("copy? [Y/n] ").lower() == "n":
                    continue

            elif os.path.islink(path):
                actual_target = os.readlink(path)
                if actual_target == abstarget:
                    print(f"{path} dangerous symlink")
                    remove = True
                else:
                    print(f"{path} symlinked to {actual_target}")
                    continue

            else:
                match diff_files(path, target):
                    case "n":
                        continue
                    case "y":
                        remove = True
                    case "r":
                        commands.append(f"cp -iv {path} {target}")
                        continue
                    case _:
                        raise ValueError("unknown value")
            if remove:
                commands.append(f"sudo rm -iv {path}")
            commands.append(f"sudo cp -iv {target} {path}")
            if path.startswith(SYSTEMD_UNIT_DIR):
                needs_daemon_reload = True
    if needs_daemon_reload:
        commands.append("sudo systemctl daemon-reload")
    return commands


def dir_missing(path: str) -> bool:
    """whether path does not exist. Unlike `not os.path.isdir(path)`, a path
    that can't be stat'ed because a parent isn't searchable is not missing."""
    try:
        os.stat(path)
    except FileNotFoundError:
        return True
    except PermissionError:
        pass
    return False


def diff_files(
    path: str, target: str, ask_identical: bool = False
) -> Literal["y"] | Literal["n"] | Literal["r"]:
    """check file contents, prompt whether to overwrite.
    returns 'y' if it should be overwritten"""
    # check if read rights
    path_content = []
    target_content = []
    # with open(path, encoding="utf-8") as file:
    #    path_content = file.readlines()
    # with open(target, encoding="utf-8") as file:
    #    target_content = file.readlines()
    try:
        with open(path, encoding="utf-8") as file:
            path_content = file.readlines()
        with open(target, encoding="utf-8") as file:
            target_content = file.readlines()
    except PermissionError:
        res = input(f"No permission to view {path}, overwrite? [Y/n] ")
        if res.lower() == "n":
            return "n"
    diff = list(difflib.unified_diff(path_content, target_content))
    if not diff and not ask_identical:
        return "n"

    if not diff and ask_identical:
        print(f"{path} has no file diff, create symlink?\n")
    else:
        print(
            f"{path} content differs. The former is on system, the latter in Git.\n"
            "`+` means it's in git and not in system.\n"
            "`-` means it's on system and not in git."
        )
        print("".join(diff))

    match input("overwrite? [Y/n/r[everse]] ").lower():
        case "" | "y":
            return "y"
        case "n":
            return "n"
        case "r":
            return "r"
        case _:
            raise ValueError("must be y, n or r")
    raise ValueError("must be y, n or r")


def link(target: str, path: str) -> bool:
    """create a symlink, reporting whether it landed in the user unit dir"""
    os.symlink(target, path)
    return path.startswith(SYSTEMD_USER_DIR)


def symlink_files(folder: str, replace: str, prefix: str = "") -> list[str]:
    """symlink user-writable files, returning commands needed to rectify."""
    needs_daemon_reload = False
    for dirpath, dirnames, filenames in os.walk(folder):
        if "__pycache__" in dirnames:
            dirnames.remove("__pycache__")
        if dirpath == folder:
            # home/ -> ~/.
            base = os.path.join(replace, prefix)
            basepath = replace
        else:
            # home/dir/ -> ~/.dir/
            base = os.path.join(replace, prefix + dirpath[len(folder) + 1 :], "")
            basepath = base

        for filename in filenames:
            if filename.endswith(".pyc"):
                continue
            path = base + filename
            real_target_path = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.relpath(real_target_path, basepath)
            if not os.path.isfile(path) and not os.path.islink(path):
                print(f"{path} missing")
                match input("create symlink? [Y/n] "):
                    case "n":
                        continue
                    case x if x.lower() in "y":
                        os.makedirs(os.path.dirname(path), exist_ok=True)
                        needs_daemon_reload |= link(target, path)
                        continue
                    case _:
                        raise ValueError("must be y, n or r")

            elif not os.path.islink(path):
                match diff_files(path, real_target_path, ask_identical=True):
                    case "n":
                        continue
                    case "r":
                        os.remove(real_target_path)
                        move(path, real_target_path)
                        needs_daemon_reload |= link(target, path)
                    case "y":
                        os.remove(path)
                        needs_daemon_reload |= link(target, path)

            elif os.path.realpath(path) != real_target_path:
                print(
                    f"{path} incorrect target\n\t{os.readlink(path)} should be\n\t{target}"
                )
                needs_daemon_reload |= fix(path, target, real_target_path)

    if needs_daemon_reload:
        return ["systemctl --user daemon-reload"]
    return []


def fix(path: str, target: str, real_target_path: str) -> bool:
    """fix, or suggest how to fix, an incorrect symlink.

    `path` is the file on the system, `real_target_path` the file in this repo,
    and `target` the relative text the symlink at `path` should hold. Returns
    whether the resulting symlink landed in the user unit dir."""

    response = input("\tresolve? [Y/n/r[everse]]: ")

    if "r" in response:
        # what's on the system wins: take it into the repo, then repoint
        if os.path.exists(path):
            os.remove(real_target_path)
            copyfile(path, real_target_path)
        else:
            print("\tdangling, nothing to copy back; relinking instead")
        os.remove(path)
        return link(target, path)

    if "n" not in response:
        if os.path.islink(path):
            os.remove(path)
        if not os.path.isdir(os.path.dirname(path)):
            print(f"creating directory {os.path.dirname(path)}")
            os.makedirs(os.path.dirname(path))
        return link(target, path)

    return False


if __name__ == "__main__":
    # print(__file__)
    main()
