#!/bin/bash

# Toggles our own caffeinate process. We track it by PID so we never
# touch caffeinate processes started by other apps.

PIDFILE="${TMPDIR:-/tmp}/sketchybar_caffeine.pid"
ITEM="${NAME:-apple}"
ON_ICON=""
OFF_ICON=""
ON_COLOR=0xff00ff00
OFF_COLOR=0xff00d4ff

is_active() {
    [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

render() {
    if is_active; then
        sketchybar --set "$ITEM" icon.string="$ON_ICON" icon.color=$ON_COLOR
    else
        sketchybar --set "$ITEM" icon.string="$OFF_ICON" icon.color=$OFF_COLOR
    fi
}

if [[ "$1" != "status" ]]; then
    if is_active; then
        kill "$(cat "$PIDFILE")" 2>/dev/null
        rm -f "$PIDFILE"
    else
        nohup caffeinate -i >/dev/null 2>&1 &
        echo $! > "$PIDFILE"
    fi
fi

render
