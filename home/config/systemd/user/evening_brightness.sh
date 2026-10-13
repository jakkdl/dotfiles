#!/usr/bin/bash

# Dim/warm the displays in the evening, restore them during the day.
#
# Every connected display is looked up by its EDID model name and handed to the
# profile for that model, so unplugging a monitor or plugging an old one back in
# needs no changes here. Models with no profile are reported and skipped.

read -r H M < <(date '+%-H %-M')

# The evening change fades in over FADE minutes from 22:00; the timer fires
# every minute of that window and each run sets the value for the current
# minute, so a boot or resume partway through lands in the right place.
# fade: 0 = day, FADE = full evening.
FADE=30
if (( H >= 22 )); then
    fade=$(( (H - 22) * 60 + M ))
    (( fade > FADE )) && fade=$FADE
elif (( H < 7 )); then
    fade=$FADE
else
    fade=0
fi
evening=$(( fade > 0 ))

# value between $1 (day) and $2 (evening) for the current fade position
lerp() {
    echo $(( $1 + ($2 - $1) * fade / FADE ))
}

# Failed writes, reported together at the end.
failures=()

# Right after resume the monitor answers DDC/CI reads before it reliably
# accepts writes, so retry a failed write a few times before giving up.
set_vcp() {
    local model="$1"; shift
    for _ in 1 2 3 4 5; do
        ddcutil --brief --model "$model" setvcp "$@" && return
        sleep 2
    done
    failures+=("$model: setvcp $*")
}

# --- display profiles ------------------------------------------------------

# LG 27UN880 ("LG HDR 4K", GSM/30544).
#
# Stays in HDR picture mode, and fades brightness and colour temperature within
# it: preset 14 User 1 (0x0B) honours the RGB gains even in HDR, though the OSD
# greys colour temperature out there. Lowering green and blue warms the image.
#
# Picture mode lives on feature 15, which is not in the MCCS spec and which the
# monitor mis-advertises: its capability string claims the legal values are
# (01 06 11 13 14 15 18 19 28 29 48), but the modes actually report and accept
# 0x0B (Custom) and 0x27 (HDR). ddcutil refuses to write feature codes it has
# no metadata for, so the real definition lives in a user-defined feature file:
#     ~/.local/share/ddcutil/GSM-LG_HDR_4K-30544.mccs
# Without that file this fails with "Unrecognized VCP feature code".
profile_lg_hdr_4k() {
    local model="$1"
    set_vcp "$model" 15 0x27
    # brightness (feature 10), green (18) and blue (1A) gain
    set_vcp "$model" 10 "$(lerp 58 10)"
    set_vcp "$model" 18 "$(lerp 50 42)"
    set_vcp "$model" 1A "$(lerp 50 30)"
    # Color preset goes last: any gain write, even of an unchanged value,
    # switches the preset to User 1, like adjusting RGB in the OSD does.
    if (( evening )); then
        set_vcp "$model" 14 0x0B
    else
        # 6500 k
        set_vcp "$model" 14 0x05
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
        set_vcp "$model" 14 04 --noverify
        set_vcp "$model" 10 20 --noverify
    else
        # restore color defaults (feature 08), brightness 80%
        set_vcp "$model" 08 01 --noverify
        set_vcp "$model" 10 80 --noverify
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
        set_vcp "$model" 14 04
        set_vcp "$model" 10 20
    else
        set_vcp "$model" 08 01
        set_vcp "$model" 10 80
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

if (( ${#failures[@]} )); then
    printf 'evening_brightness: failed: %s\n' "${failures[@]}" >&2
    # not on the user manager's PATH
    "$HOME/.local/bin/alert" "evening_brightness failed" "$(printf '%s\n' "${failures[@]}")"
    exit 1
fi
