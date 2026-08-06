#!/bin/bash
tmp_dir="/tmp/cliphist"
rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

theme_path="$HOME/.config/rofi/clipboard.rasi"

cliphist list | awk -v tmp="$tmp_dir" '
/binary data/ {
    id = $1
    img = tmp "/" id ".png"
    system("cliphist decode " id " > " img)
    print id "\t󰋩  [ Image Snapshot ]\0icon\x1f" img
    next
}
{ print }
' | rofi -dmenu -i -p "Clipboard" -theme "$theme_path" | cliphist decode | wl-copy
