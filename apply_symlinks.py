#!/usr/bin/python3
"""Checks that all files in the root and home directories have symlinks on the system,
and prompts to create or warns about missing them"""
import os
import os.path

def main(interactive = True):
    """do all the stuffs"""
    commands = handle_folder('root', os.path.expanduser('/'), interactive)
    commands += handle_folder('home', os.path.expanduser('~'), interactive, '.')
    commands.append(check_submodules())
    if not commands:
        print("all symlinks OK")
        return

    with open("fix_links.sh", "w") as file:
        file.write('\n'.join(commands))

def check_submodules():
    """check for submodules"""
    if not os.path.isfile('vim-plug/plug.vim'):
        return "git submodule init && git submodule update\n"
    return ""

def handle_folder(folder, replace, interactive, prefix=''):
    """returns a list of commands needed to fix all errors"""
    assert folder in ('home', 'root')
    commands = []
    #homedir = os.path.expanduser('~')
    #homedir = replace
    for dirpath, _dirnames, filenames in os.walk(folder):
        if dirpath == folder:
            base = os.path.join(replace, prefix)
            basepath = replace
        else:
            base = os.path.join(replace, prefix + dirpath[len(folder)+1:], '')
            basepath = base


        for filename in filenames:
            path = base+filename
            real_target_path = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.relpath(real_target_path, basepath)
            pref_target = real_target_path if folder == 'root' else target

            if folder == 'root' and os.access(real_target_path, os.W_OK):
                print(f"WARNING: dangerous write access {os.path.join(dirpath+path)}")
                commands.append(f"sudo chown root:root {real_target_path}")

            if not (os.path.isfile(path) or os.path.islink(path)):
                print(f'{path} missing')
                commands.append(fix(path, pref_target, interactive))
                continue

            if not os.path.islink(path):
                print(f'{path} not a symlink, inspect with diff')
                continue

            actual_target = os.readlink(path)
            if actual_target not in (target, real_target_path):
                print(f'{path} incorrect target\n\t{actual_target} '
                        f'should be\n\t{pref_target}')
                commands.append(fix(path, pref_target, interactive))
    return commands

def fix(path, target, interactive):
    """fix, or suggest how to fix, an incorrect symlink"""
    if 'home' not in path:
        # print(target)
        return f'sudo ln -s {os.path.realpath(target)} {path}'

    if not interactive:
        if not os.path.isdir(os.path.dirname(path)):
            res = f"mkdir {os.path.dirname(path)}\n"
        else:
            res = ""
        return res + f"ln -s {target} {path}"

    if "n" not in input("\tresolve? [Y/n]: "):
        if os.path.islink(path):
            os.remove(path)
        if not os.path.isdir(os.path.dirname(path)):
            print(f'creating directory {os.path.dirname(path)}')
            os.makedirs(os.path.dirname(path))
        os.symlink(target, path)
        return ""

if __name__ == '__main__':
    #print(__file__)
    main()
