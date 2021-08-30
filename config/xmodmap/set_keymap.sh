#!/bin/bash
if [ -z "$HOSTNAME" ]; then
    HOSTNAME=$HOST
fi

if [ "$HOSTNAME" = "chlorine" ]; then
    setxkbmap dvorak
    xmodmap ~/.config/xmodmap/chlorine
elif [ "$HOSTNAME" = "sulfur" ]; then
    xmodmap ~/.config/xmodmap/software_remapping_teck.xmodmap
fi
