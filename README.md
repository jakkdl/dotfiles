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


## sway session save/restore

`~/.local/bin/sway-session` snapshots all workspaces (layout, programs, terminal
cwds, nvim sessions, per-terminal history) and restores them on next login.
Wired through the sway config plus one system unit:

- saved before every suspend via `swayidle`'s `before-sleep` (covers idle,
  low-battery and manual suspend), and on sway exit via `$mod+Ctrl+Shift+q`;
- saved on poweroff/reboot by `sway-session-save.service`'s `ExecStop`;
  `session-.scope.d/sway-session-save.conf` orders every login session scope
  before it, so it stops (and saves) while sway is still running. Enable once:
  `sudo systemctl enable --now sway-session-save.service`;
- restored once per login via `exec sway-session-restore` in the sway config;
- per-terminal history is captured by a `zshaddhistory` hook in `.zshrc`.

Snapshots are kept (last 10) under `$XDG_STATE_HOME/sway-session/states/`.
Manual use: `sway-session list`, `sway-session restore [<timestamp>|N] --force`.
Logs in `$XDG_STATE_HOME/sway-session/{save,restore}.log`.

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
$ sudo pacman -S sway-contrib # grimshot
$ uv tool install --editable ~/Git/busy  # waybar workspace tints, its own repo
```

## earlyoom
```
$ sudo pacman -S earlyoom systembus-notify
$ sudo systemctl enable --now earlyoom
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
otf-font-awesome (waybar icons)



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

## catching a hung shutdown

If shutdown sits on the console printing `task X blocked for more than N
seconds`, the name in that line is the culprit but the kernel log dies with the
machine. Two files make it recoverable: `/etc/default/grub.d/pstore.cfg`
turns on EFI pstore and `/etc/sysctl.d/90-sysrq.conf` enables the SysRq dump
and reboot keys. After `apply_symlinks.py`:
```
$ sudo grub-mkconfig -o /boot/grub/grub.cfg
$ sudo systemctl enable systemd-pstore.service
$ sudo sysctl --system
```
At the next hang press Alt+SysRq+w (dump blocked tasks with stack traces),
then Alt+SysRq+c (panic, which saves the log to EFI variables and reboots).
The log is under `/var/lib/systemd/pstore/` after boot. Alt+SysRq+s, u, b
is the sync, remount read-only, reboot sequence when you just want out.
