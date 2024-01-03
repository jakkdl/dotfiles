#!/usr/bin/python3
"""Checks that all files in the root and home directories have symlinks on the system,
and prompts to create or warns about missing them"""
import difflib
import os
import os.path
from shutil import copyfile, move
from typing import Literal

FIXFILE = "fix_links.sh"


def main() -> None:
    """do all the stuffs"""
    symlink_files("home", os.path.expanduser("~"), ".")
    commands = copy_folder_contents("root", "/")
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


def check_submodules() -> list[str]:
    """check for submodules"""
    if not os.path.isfile("vim-plug/plug.vim"):
        return ["git submodule init && git submodule update\n"]
    return []


def copy_folder_contents(folder: str, replace: str) -> list[str]:
    """checks if file contents differ, returns list of commands needed to rectify"""
    commands = []
    for dirpath, _dirnames, filenames in os.walk(folder):
        # root/ -> /
        # root/dir/ -> /dir/
        base = os.path.join(replace, dirpath[len(folder) + 1 :], "")
        # basepath = base

        for filename in filenames:
            remove = False
            path = base + filename
            abstarget = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.join(dirpath, filename)

            if not os.access(base, mode=os.R_OK):
                print(f'No permissions to check {path}')
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
    return commands


def diff_files(path: str, target: str) -> Literal["y"] | Literal["n"] | Literal["r"]:
    """check file contents, prompt whether to overwrite.
    returns 'y' if it should be overwritten"""
    # check if read rights
    path_content = []
    target_content = []
    #with open(path, encoding="utf-8") as file:
    #    path_content = file.readlines()
    #with open(target, encoding="utf-8") as file:
    #    target_content = file.readlines()
    try:
        with open(path, encoding='utf-8') as file:
            path_content = file.readlines()
        with open(target, encoding='utf-8') as file:
            target_content = file.readlines()
    except PermissionError:
        res = input(f'No permission to view {path}, overwrite? [Y/n] ')
        if res.lower() == "n":
            return "n"
    diff = list(difflib.context_diff(path_content, target_content))
    if not diff:
        return "n"

    print(
        f"{path} content differs. The former is on system, the latter in Git.\n"
        "`+` means it's in git and not in system."
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


def symlink_files(folder: str, replace: str, prefix: str = "") -> None:
    """symlink user-writable files."""
    for dirpath, _, filenames in os.walk(folder):
        if dirpath == folder:
            # home/ -> ~/.
            base = os.path.join(replace, prefix)
            basepath = replace
        else:
            # home/dir/ -> ~/.dir/
            base = os.path.join(replace, prefix + dirpath[len(folder) + 1 :], "")
            basepath = base

        for filename in filenames:
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
                        os.symlink(target, path)
                        continue
                    case _:
                        raise ValueError("must be y, n or r")

            elif not os.path.islink(path):
                match diff_files(path, real_target_path):
                    case "n":
                        continue
                    case "r":
                        os.remove(target)
                        move(path, target)
                        os.symlink(target, path)
                    case "y":
                        os.remove(path)
                        os.symlink(target, path)

            elif actual_target := os.readlink(path) not in (target, real_target_path):
                print(
                    f"{path} incorrect target\n\t{actual_target} "
                    f"should be\n\t{target}"
                )


def fix(path: str, target: str) -> None:
    """fix, or suggest how to fix, an incorrect symlink"""

    response = input("\tresolve? [Y/n/r[everse]]: ")

    if "r" in response:
        os.remove(target)
        copyfile(path, target)

    elif "n" not in response:
        if os.path.islink(path):
            os.remove(path)
        if not os.path.isdir(os.path.dirname(path)):
            print(f"creating directory {os.path.dirname(path)}")
            os.makedirs(os.path.dirname(path))
        os.symlink(target, path)


if __name__ == "__main__":
    # print(__file__)
    main()
