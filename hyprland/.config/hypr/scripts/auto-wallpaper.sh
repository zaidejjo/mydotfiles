#!/bin/bash

WALLPAPER_DIR="$HOME/.config/ml4w/wallpapers"
DAY_WALLPAPER="$WALLPAPER_DIR/nice-blue-background.png"
NIGHT_WALLPAPER="$WALLPAPER_DIR/nice-blood-background.png"

HOUR=$(date +%H)

if [ "$HOUR" -ge 6 ] && [ "$HOUR" -lt 18 ]; then
  CURRENT_WALLPAPER="$DAY_WALLPAPER"
else
  CURRENT_WALLPAPER="$NIGHT_WALLPAPER"
fi

awww img "$CURRENT_WALLPAPER" --transition-type outer --transition-fps 60
