#!/usr/bin/python3
import math

SELBG = '#9fbc00'

def main():
    meminfo = {}
    with open('/sys/class/power_supply/BAT0/charge_now') as f:
        charge_now = int(f.read())
    with open('/sys/class/power_supply/BAT0/charge_full') as f:
        charge_full = int(f.read())
    with open('/sys/class/power_supply/BAT0/status') as f:
        status = f.read().strip()

    percent = math.ceil(charge_now / charge_full * 100)
    if percent > 95:
        color = '#00ff00' # green
    elif percent > 80:
        color = '#ffff00' # yellow?
    elif percent > 40:
        color = '#ffa500' # orange
    else:
        color = '#ff0000' # red

    charging = '+' if status == 'Charging' else ''

    if status in ('Charging', 'Full') and percent > 90:
        return f'battery\t'

    return f'battery\t^fg({color})BAT {charging}{str(percent)}% ^fg({SELBG})| '

if __name__ == '__main__':
    print(main())
