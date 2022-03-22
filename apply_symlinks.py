#!/usr/bin/python3
"""Checks that all files in the root and home directories have symlinks on the system,
and prompts to create or warns about missing them"""
import os
import os.path

def main(interactive = True):
    """do all the stuffs"""
    if any([
            handle_folder('home', os.path.expanduser('~'), interactive, '.'),
            handle_folder('root', os.path.expanduser('/'), interactive),
            check_submodules()
            ]):
        print("all symlinks OK")

def check_submodules():
    """check for submodules"""
    if not os.path.isfile('vim-plug/plug.vim'):
        print('run submodule init && submodule update')
        return True
    return False

def handle_folder(folder, replace, interactive, prefix=''):
    """returns the number of uncorrected errors"""
    assert folder in ('home', 'root')
    errors = 0
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
                print(f"WARNING: dangerous write access, execute:\n"
                        f"sudo chown root:root {path}")
            if not (os.path.isfile(path) or os.path.islink(path)):
                print(f'{path} not a file')
                errors += fix(path, pref_target, interactive)
                continue
            elif not os.path.islink(path):
                print(f'{path} not a symlink')
                errors += 1
                continue

            actual_target = os.readlink(path)
            if actual_target not in (target, real_target_path):
                print(f'{path} incorrect target\n\t{actual_target} '
                        f'should be\n\t{pref_target}')
                errors += fix(path, pref_target, interactive)
    return errors

def fix(path, target, interactive):
    """fix, or suggest how to fix, an incorrect symlink"""
    if 'home' not in path:
        print(target)
        print(f'run: sudo ln -s {os.path.realpath(target)} {path}')
        return 1
    if not interactive:
        return 1
    if "n" not in input("\tresolve? [Y/n]: "):
        if os.path.islink(path):
            os.remove(path)
        if not os.path.isdir(os.path.dirname(path)):
            print(f'creating directory {os.path.dirname(path)}')
            os.makedirs(os.path.dirname(path))
        os.symlink(target, path)
        return 0
    return 1

if __name__ == '__main__':
    print(__file__)
    main()
