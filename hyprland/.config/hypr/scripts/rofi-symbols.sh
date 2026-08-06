#!/bin/bash
THEME="$HOME/.config/rofi/symbols-grid.rasi"

rofimoji \
  --action copy \
  --files emojis nerd_font math \
  --selector-args="-theme $THEME"
