#!/bin/sh
acpi -b | awk -F'[,:%]' '{print $3, $2}' | {
	read -r capacity status

	if [ "$status" = Discharging -a "$capacity" -lt 15 ]; then
		logger "Critical battery threshold"
		systemctl suspend
	fi
}
