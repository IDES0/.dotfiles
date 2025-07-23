#!/bin/bash

# Check if this is a status check
if [[ "$1" == "status" ]]; then
    if pgrep -x "caffeinate" > /dev/null; then
        # Caffeine is active
        sketchybar --set "$NAME" icon.string="" icon.color=0xff00ff00
    else
        # Caffeine is not active
        sketchybar --set "$NAME" icon.string="" icon.color=0xffff007c
    fi
    exit 0
fi

# Handle click - toggle caffeine
if pgrep -x "caffeinate" > /dev/null; then
    # Caffeine is active, kill it
    pkill -x "caffeinate"
    sketchybar --set "$NAME" icon.string="" icon.color=0xffff007c
else
    # Caffeine is not active, start it
    caffeinate -i &
    sketchybar --set "$NAME" icon.string="" icon.color=0xff00ff00
fi 