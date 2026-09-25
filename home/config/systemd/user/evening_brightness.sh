#!/usr/bin/bash

# Dim/warm the displays in the evening, restore them during the day.
#
# Every connected display is looked up by its EDID model name and handed to the
# profile for that model, so unplugging a monitor or plugging an old one back in
# needs no changes here. Models with no profile are reported and skipped.

# get the current hour
H=$(date +%k)

# evening: before 07:00 or after 21:59
if (( H < 7 || H >= 22 )); then
    evening=1
else
    evening=0
fi

# --- display profiles ------------------------------------------------------

# LG 27UN880 ("LG HDR 4K", GSM/30544).
#
# Picture mode lives on feature 15, which is not in the MCCS spec and which the
# monitor mis-advertises: its capability string claims the legal values are
# (01 06 11 13 14 15 18 19 28 29 48), but the modes actually report and accept
# 0x0B (Custom) and 0x27 (HDR). ddcutil refuses to write feature codes it has
# no metadata for, so the real definition lives in a user-defined feature file:
#     ~/.local/share/ddcutil/GSM-LG_HDR_4K-30544.mccs
# Without that file this fails with "Unrecognized VCP feature code".
#
# Each picture mode keeps its own brightness, so switching the mode is enough;
# no separate brightness call here. Feature 14 is unused - this panel only
# offers 6500K/9300K/User 1, no warm preset.
profile_lg_hdr_4k() {
    local model="$1"
    if (( evening )); then
        ddcutil --brief --model "$model" setvcp 15 0x0B
    else
        ddcutil --brief --model "$model" setvcp 15 0x27
    fi
}

# Dell U2412M. Gives verification errors, but works if passed --noverify.
#    Feature: 14 (Select color preset)
#       Values:
#          04: 5000 K
#          05: 6500 K
#          06: 7500 K
#          08: 9300 K
#          09: 10000 K
#          0b: User 1
#          0c: User 2
profile_dell_u2412m() {
    local model="$1"
    if (( evening )); then
        # color preset (feature 14) 5000 k, brightness (feature 10) 20%
        ddcutil --brief --model "$model" setvcp 14 04 --noverify
        ddcutil --brief --model "$model" setvcp 10 20 --noverify
    else
        # restore color defaults (feature 08), brightness 80%
        ddcutil --brief --model "$model" setvcp 08 01 --noverify
        ddcutil --brief --model "$model" setvcp 10 80 --noverify
    fi
}

# BenQ G2222HDL.
#    Feature: 14 (Select color preset)
#       Values:
#          01: sRGB
#          04: 5000 K
#          05: 6500 K
#          08: 9300 K
#          0b: User 1
profile_benq_g2222hdl() {
    local model="$1"
    if (( evening )); then
        ddcutil --brief --model "$model" setvcp 14 04
        ddcutil --brief --model "$model" setvcp 10 20
    else
        ddcutil --brief --model "$model" setvcp 08 01
        ddcutil --brief --model "$model" setvcp 10 80
    fi
}

dispatch_ddc() {
    case "$1" in
        "LG HDR 4K")    profile_lg_hdr_4k "$1" ;;
        "DELL U2412M")  profile_dell_u2412m "$1" ;;
        "BenQG2222HDL") profile_benq_g2222hdl "$1" ;;
        *) echo "evening_brightness: no profile for DDC display '$1'" >&2 ;;
    esac
}

# --- main ------------------------------------------------------------------

# An OnCalendar trigger that elapsed during suspend fires as soon as we wake,
# which is before the DP links are back and DDC/CI is reachable.
for _ in $(seq 20); do
    if ddcutil --brief detect 2>/dev/null | grep -q '^Display'; then
        break
    fi
    sleep 2
done

# EDID model name of each connected DDC/CI display, one per line.
# "Monitor:  <mfg>:<model>:<serial>" -> field 3.
while IFS= read -r model; do
    [[ -n "$model" ]] && dispatch_ddc "$model"
done < <(ddcutil detect --brief 2>/dev/null | awk -F: '/^ *Monitor:/ {print $3}')

