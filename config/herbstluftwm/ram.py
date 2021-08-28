#!/usr/bin/python3
import math

def main():
    meminfo = {}
    with open('/proc/meminfo') as f:
        for line in f:
            key = line.split(':')[0]
            val = int(line.split()[1])
            meminfo[key] = val
    memused = ((meminfo['MemTotal'] - meminfo['MemAvailable'])
            / meminfo['MemTotal'])
    percent = math.ceil(memused * 100)
    if percent > 85:
        color = '#ff0000' # red
    elif percent > 80:
        color = '#ffa500' # orange
    elif percent > 60:
        color = '#ffff00' # yellow?
    else:
        color = '#00ff00' # green / hc window_border_active_color
    return f'ram\t^fg({color})RAM {str(percent)}%'

if __name__ == '__main__':
    print(main())
