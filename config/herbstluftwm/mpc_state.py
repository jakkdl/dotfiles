#!/usr/bin/python3
import mpd # type: ignore # pip install python-mpd2

def main():
    color = '#00ff00' # green / hc window_border_active_color
    client = mpd.MPDClient()
    client.timeout = 10
    client.idletimeout = None
    client.connect("localhost", 6600)

    client.idle('player')
    if client.status()['state'] == 'play':
        return f'mpc_state\t^fg({color})> '
        #return f'mpc_state\t^fg({color}\u23F5 '
    else:
        return f'mpc_state\t^fg({color})II '

if __name__ == '__main__':
    print(main())
