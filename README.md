Steps to set up new linux machine:


## network
```
# vim /etc/systemd/networkd/20-wired.network
...
# systemctl enable --now systemd-networkd
# systemctl enable --now systemd-resolved
```

## sudo
```
# pacman -S sudo
# EDITOR=nvim
# visudo
```

## dotfiles
```
# pacman -S git openssh zsh python
# chsh -l /bin/zsh
# useradd -m -G wheel -s /bin/zsh h
```

### log in as user
```
$ ssh-keygen
```
### add ssh key to github
```
$ mkdir Git
$ cd Git
$ git clone git@github.com:jakkdl/dotfiles.git
$ cd dotfiles
$ git submodule init
```

## add dotfiles
```
$ python apply_symlinks.py
$ ./fix_links.sh
$ sudo systemctl enable --now suspend_low_bat.timer
```


## install stuff
```
$ sudo pacman -S sway swaylock swayidle polkit waybar wofi xdg-desktop-portal-wlr python-i3ipc
$ sudo pacman -S python-pipx
$ pipx install togglCli
$ sudo pacman -S firefox
```

## wireless
```
$ sudo pacman -S iwd
$ sudo systemctl enable --now iwd
```

## fonts for waybar

## pipewire

## fix zplug

## yay
```
$ cd ~/Git
$ sudo pacman -S --needed base-devel
$ git clone https://aur.archlinux.org/yay.git
$ cd yay
$ makepkg -si
```
or
```
$ cd ~/Git
$ sudo pacman -S --needed base-devel devtools
$ mkdir ~/Chroot
$ mkarchroot ~/Chroot/root base-devel
$ arch-nspawn ~/Chroot/root pacman -Syu
$ makechrootpkg -c -r ~/Chroot
$ pacman -U yay-[version].pkg.tar.zst
```

## install AUR stuff
```
$ yay -S oh-my-zsh-git
```
