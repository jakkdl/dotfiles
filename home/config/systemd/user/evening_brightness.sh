#!/usr/bin/bash

# get the current hour
H=$(date +%k)

# My Dell monitor gives verification errors, but it works if I pass it --noverify
DISPLAY_ONE="DELL U2412M"
#    Feature: 14 (Select color preset)
#       Values:
#          04: 5000 K
#          05: 6500 K
#          06: 7500 K
#          08: 9300 K
#          09: 10000 K
#          0b: User 1
#          0c: User 2
DISPLAY_TWO="BenQG2222HDL"
#    Feature: 14 (Select color preset)
#       Values:
#          01: sRGB
#          04: 5000 K
#          05: 6500 K
#          08: 9300 K
#          0b: User 1

# VCP Features:
#    Feature: 10 (Brightness)
#    Feature: 08 (Restore color defaults)
#    Feature: 14 (Select color preset)

# if before 07:00 or after 21:59
if (( H < 7 || H >= 22 )); then
    # color preset (feature 14) 5000 k
    ddcutil --brief --model "$DISPLAY_ONE" setvcp 14 04 --noverify
    ddcutil --brief --model "$DISPLAY_TWO" setvcp 14 04
    # brightness (feature 10) 20%
    ddcutil --brief --model "$DISPLAY_ONE" setvcp 10 20 --noverify
    ddcutil --brief --model "$DISPLAY_TWO" setvcp 10 20
else
    # restore color defaults (feature 08)
    ddcutil --brief --model "$DISPLAY_ONE" setvcp 08 01 --noverify
    ddcutil --brief --model "$DISPLAY_TWO" setvcp 08 01
    # brightness (feature 10) 80%
    ddcutil --brief --model "$DISPLAY_ONE" setvcp 10 80 --noverify
    ddcutil --brief --model "$DISPLAY_TWO" setvcp 10 80
fi

