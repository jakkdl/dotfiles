#!/bin/sh

setxkbmap dvorak
setxkbmap -option terminate:ctrl_alt_bksp
if [ $HOSTNAME = "chlorine" ]; then
    xmodmap .config/xmodmap/chlorine
fi

xbindkeys -f .config/xbindkeys.conf

xrdb -merge .Xresources

xset s off

herbstluftwm
