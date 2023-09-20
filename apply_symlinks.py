#!/usr/bin/python3
"""Checks that all files in the root and home directories have symlinks on the system,
and prompts to create or warns about missing them"""
import difflib
import os
import os.path
from shutil import copyfile, move
from typing import Literal

FIXFILE = "fix_links.sh"


def main(interactive=True):
    """do all the stuffs"""
    commands = copy_folder_contents("root", "/", interactive)
    commands += symlink_files("home", os.path.expanduser("~"), interactive, ".")
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


def check_submodules():
    """check for submodules"""
    if not os.path.isfile("vim-plug/plug.vim"):
        return ["git submodule init && git submodule update\n"]
    return []


def copy_folder_contents(folder, replace, interactive):
    """checks if file contents differ, returns list of commands needed to rectify"""
    remove = False
    commands = []
    for dirpath, _dirnames, filenames in os.walk(folder):
        # root/ -> /
        # root/dir/ -> /dir/
        base = os.path.join(replace, dirpath[len(folder) + 1 :], "")
        # basepath = base

        for filename in filenames:
            path = base + filename
            abstarget = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.join(dirpath, filename)

            if not (os.path.isfile(path) or os.path.islink(path)):
                print(f"{path} missing")

            elif os.path.islink(path):
                actual_target = os.readlink(path)
                if actual_target == abstarget:
                    print(f"{path} dangerous symlink")
                    remove = True
                else:
                    print(f"{path} symlinked to {actual_target}")
                    continue

            else:
                match diff_files(path, target, interactive):
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


def diff_files(path, target, interactive) -> Literal["y"] | Literal["n"] | Literal["r"]:
    """check file contents, if interactive prompt for overwrite.
    returns 'y' if it should be overwritten"""
    # check if read rights
    path_content = []
    target_content = []
    with open(path, encoding="utf-8") as file:
        path_content = file.readlines()
    with open(target, encoding="utf-8") as file:
        target_content = file.readlines()
    diff = list(difflib.context_diff(path_content, target_content))
    if not diff:
        return "n"

    print(
        f"{path} content differs. The former is on system, the latter in Git. `-` means it's on system and not in git."
    )
    print("".join(diff))
    if not interactive:
        return "n"

    match input("overwrite? [Y/n/r[everse]] ").lower():
        case ""|"y":
            return "y"
        case "n":
            return "n"
        case "r":
            return "r"
        case _:
            raise ValueError("must be y, n or r")
    raise ValueError("must be y, n or r")


def symlink_files(folder, replace, interactive, prefix=""):
    """symlink user-writable files. If not interactive returns list of commands needed to rectify"""
    commands = []
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

            if not os.path.isfile(path):
                print(f"{path} missing")
                match input("overwrite? [Y/n "):
                    case "n":
                        continue
                    case x if x.lower() in "y":
                        os.makedirs(os.path.dirname(path))
                        os.symlink(target, path)
                        continue
                    case _:
                        raise ValueError("must be y, n or r")

            elif not os.path.islink(path):
                match diff_files(path, real_target_path, interactive):
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
                commands.append(fix(path, target, interactive))
    return commands


def fix(path, target, interactive) -> list[str]:
    """fix, or suggest how to fix, an incorrect symlink"""

    if not interactive:
        if not os.path.isdir(os.path.dirname(path)):
            res = [f"mkdir {os.path.dirname(path)}"]
        else:
            res = []
        return res + [f"ln -s {target} {path}"]

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
    return []


if __name__ == "__main__":
    # print(__file__)
    main()
