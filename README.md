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
# pacman -S sudo neovim
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
$ sudo pacman -S sway swaylock swayidle polkit waybar wofi xdg-desktop-portal-wlr python-i3ipc mako swaybg
$ sudo pacman -S python-pipx
$ yay -S python-togglcli
$ sudo pacman -S foot firefox
$ sudo pacman -S starship ttf-firacode-nerd
$ sudo pacman -S sheldon
$ sudo pacman -S moreutils  # ts
$ sudo pacman -S swaync  # notifications
$ sudo pacman -S pacman-contrib  # paccache, pacman hook
$ sudo pacman -S acpi # suspend-low-bat hook
$ sudo pacman -S tree-sitter-cli # neovim plugin dep
```

## wireless
```
$ sudo pacman -S iwd
$ sudo systemctl enable --now iwd
```

## fonts for waybar

## pipewire
```
$ sudo pacman -s pipewire pipewire-pules wireplumber pipewire-audio pipewire-alsa pipewire-jack
```

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
...
```

## moar stuff

install wl-clipboard
    xdg-utils: for content type inference in wl-copy (?)

expect - for unbuffer, for man alias
```
sudo pacman -S xdg-utils # xdg-open, content type inference in wl-copy
sudo pacman -S brightnessctl
```

noto-fonts-emoji (emoji picker, etc)
ttf-fonts-awesome (waybar)



dark-mode switching
sudo pacman -S xdg-desktop-portal-gtk

# create screenshot dir. Should maybe be somewhere
mkdir ~/Media/pictures/screenshot

## DNS
systemd-resolved requires symlinking /etc/resolv.conf for applications that have it hard-coded (e.g. go)
```
sudo ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

## LLM
```
sudo pacman -S libnotify jq
```
