#!/bin/bash

# Only check Spotify
PLAYER="Spotify"
APP_SCRIPT='
if application "Spotify" is running then
  tell application "Spotify"
    if player state is playing then
      set trackName to name of current track
      set artistName to artist of current track
      return trackName & " — " & artistName
    end if
  end tell
end if
return ""
'

INFO=$(osascript -e "$APP_SCRIPT")

if [[ -n "$INFO" ]]; then
  sketchybar --set "$NAME" label="$INFO"
else
  sketchybar --set "$NAME" label="Not Playing"
fi

# Handle click
if [[ "$1" == "mouse.clicked" ]]; then
  open -a "Spotify"
fi