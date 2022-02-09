#!/usr/bin/python3
import os
import os.path

def main():
    handle_folder('home', os.path.expanduser('~'), '.')
    handle_folder('root', os.path.expanduser('/'))

def handle_folder(folder, replace, prefix=''):
    #homedir = os.path.expanduser('~')
    #homedir = replace
    for dirpath, dirnames, filenames in os.walk(folder):
        if dirpath == folder:
            base = os.path.join(replace, prefix)
            basepath = replace
        else:
            base = os.path.join(replace, prefix + dirpath[len(folder)+1:], '')
            basepath = base


        for filename in filenames:
            #print(base + filename, os.path.join(dirpath, filename))
            path = base+filename
            real_target_path = os.path.realpath(os.path.join(dirpath, filename))
            target = os.path.relpath(real_target_path, basepath)
            if not (os.path.isfile(path) or os.path.islink(path)):
                print(f'{path} not a file')
                if folder == 'home':
                    fix(path, target)
                elif folder == 'root':
                    fix(path, real_target_path)
                continue
            elif not os.path.islink(path):
                print(f'{path} not a symlink')
                continue
            actual_target = os.readlink(path)
            if actual_target != target and actual_target != real_target_path:
                print(f'{path} incorrect target\n\t{actual_target} '
                        f'should be\n\t{target}')
                if folder == 'home':
                    fix(path, target)
                elif folder == 'root':
                    fix(path, real_target_path)

def fix(path, target):
    if 'home' not in path:
        print(target)
        print(f'run: sudo ln -s {os.path.realpath(target)} {path}')
        return
    if input(f'\tresolve? [Y/n]: ').strip() != 'n':
        if os.path.islink(path):
            os.remove(path)
        os.symlink(target, path)

if __name__ == '__main__':
    print(__file__)
    main()

