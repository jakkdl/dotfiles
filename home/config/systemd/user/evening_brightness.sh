H=$(date +%k)

# if before 07:00 or after 21:59
if (( H < 7 || H >= 22 )); then
    # color preset 5000 k
    ddcutil --brief --noverify -d 2 setvcp 14 04 &&
    ddcutil --brief -d 1 setvcp 14 04 &&
    # brightness 20%
    ddcutil --brief --noverify -d 2 setvcp 10 20 &&
    ddcutil --brief -d 1 setvcp 10 20
else
    # color preset sRGB
    ddcutil --brief --noverify -d 2 setvcp 14 01 &&
    ddcutil --brief -d 1 setvcp 14 01 &&
    # brightness 80%
    ddcutil --brief --noverify -d 2 setvcp 10 80 &&
    ddcutil --brief -d 1 setvcp 10 80
fi

