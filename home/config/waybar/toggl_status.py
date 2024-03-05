#!/usr/bin/env python3
import logging
import os
import time
import json
from datetime import datetime
from pathlib import Path
# requires togglCli
# install with `pip install togglCli` or `poetry add togglCli`

from toggl import api  # type: ignore
#all_clients = api.Client.objects.all()
#for client in all_clients:
    #print(client, client.name)

LogPath = Path.home() / '.local' / 'share' / 'waybar'
LogPath.mkdir(exist_ok=True)
LogPath /= f'toggl_status_{os.getpid()}.log'
logging.basicConfig(filename=LogPath, encoding='utf-8', level=logging.DEBUG, format='%(asctime)s %(message)s')

def get_current_entry_status() -> str:
    res = []
    current_entry = api.TimeEntry.objects.current()
    if current_entry is None:
        return json.dumps({"text": "", "alt": "stop", "class": "stop"})

    if hasattr(current_entry, "project") and current_entry.project.name:
        res.append(f"@{current_entry.project.name}")
    for tag in getattr(current_entry, "tags", ()):
        res.append(f"#{tag}")
    duration = time.time() + current_entry.duration
    res.append(f"{duration / 3600:.1f}h")

    total = get_total_time_today()
    if abs(total - duration) > 1200:
        res.append(f"| {total / 3600:.1f}h")

    return json.dumps({"text": " ".join(res), "alt": "start", "class": "start"})

def get_total_time_today() -> float:
    today = datetime.now().date()
    total = 0.0
    for entry in api.TimeEntry.objects.all():
        if entry.start.date() == today:
            total += entry.duration
    return time.time() + total


if __name__ == '__main__':
    logging.info("started")
    try:
        print(get_current_entry_status())
        logging.info("succesful")
    except BaseException as error:
        logging.info(f"error: {error}")

