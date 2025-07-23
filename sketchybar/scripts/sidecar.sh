#!/bin/bash

# Check if this is a status check
if [[ "$1" == "status" ]]; then
    if system_profiler SPDisplaysDataType | grep -q "Sidecar"; then
        # Sidecar is active
        sketchybar --set "$NAME" icon.string="📱" icon.color=0xff00ff00
    else
        # Sidecar is not active
        sketchybar --set "$NAME" icon.string="📱" icon.color=0xffff007c
    fi
    exit 0
fi

# Simplest approach: just open System Settings
if system_profiler SPDisplaysDataType | grep -q "Sidecar"; then
    # Sidecar is active, try to disconnect
    pkill -f "Sidecar" 2>/dev/null || true
    pkill -f "SidecarAgent" 2>/dev/null || true
    sudo pkill -f "Sidecar" 2>/dev/null || true
    
    sketchybar --set "$NAME" icon.string="📱" icon.color=0xffff007c
else
    # Sidecar is not active, open System Settings
    open -a "System Settings"
fi 