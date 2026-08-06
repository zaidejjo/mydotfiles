#!/bin/bash
THEME="$HOME/.config/rofi/cheatsheet.rasi"

# --- 1. Hyprland Keybindings ---
get_hyprland_binds() {
  python3 - <<'EOF'
import re, os

filepath = os.path.expanduser("~/.config/hypr/conf/keybindings/default.lua")
if os.path.exists(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    blocks = re.findall(r'hl\.bind\s*\((.*?)\,\s*\{\s*description\s*=\s*"([^"]+)"', content, re.DOTALL)
    for key_part, desc in blocks:
        raw_key = key_part.split(',')[0].strip()
        clean_key = raw_key.replace('mainMod', 'SUPER').replace('..', '').replace('"', '').replace('\n', '').strip()
        clean_key = re.sub(r'\s+', ' ', clean_key)
        print(f"{desc:<45} ➔  {clean_key}")
EOF
}

# --- 2. Neovim Keybindings ---
get_nvim_binds() {
  python3 - <<'EOF'
import os, re

binds = set()
nvim_dir = os.path.expanduser("~/.config/nvim")

if os.path.exists(nvim_dir):
    for root, _, files in os.walk(nvim_dir):
        for file in files:
            if file.endswith(".lua"):
                path = os.path.join(root, file)
                try:
                    with open(path, "r", encoding="utf-8", errors="ignore") as f:
                        content = f.read()

                        patterns = [
                            r'\{\s*["\']([^"\']+)["\']\s*,.*desc\s*=\s*["\']([^"\']+)["\']',
                            r'desc\s*=\s*["\']([^"\']+)["\']\s*,\s*["\']([^"\']+)["\']',
                            r'keymap\.set\s*\([^,]+,\s*["\']([^"\']+)["\']\s*,.*desc\s*=\s*["\']([^"\']+)["\']',
                            r'map\s*\([^,]+,\s*["\']([^"\']+)["\']\s*,.*desc\s*=\s*["\']([^"\']+)["\']'
                        ]

                        for pat in patterns:
                            matches = re.findall(pat, content)
                            for m in matches:
                                if len(m) == 2:
                                    if len(m[0]) < len(m[1]) and not " " in m[0]:
                                        key, desc = m[0], m[1]
                                    else:
                                        desc, key = m[0], m[1]
                                    
                                    key = key.replace("<leader>", "Space ").replace("<Leader>", "Space ")
                                    binds.add(f"{desc:<45} ➔  {key}")
                except Exception:
                    pass

if binds:
    for b in sorted(binds):
        print(b)
else:
    print("No Neovim binds found")
EOF
}

# --- 3. Main Rofi Menu ---
MAIN_MENU=$(printf "󰖲 Hyprland Keybindings\n Neovim Keybindings")
CHOICE=$(echo "$MAIN_MENU" | rofi -dmenu -i -p "󰌌 Select Section" -theme "$THEME")

case "$CHOICE" in
*"Hyprland"*)
  SELECTED=$(get_hyprland_binds | rofi -dmenu -i -p "󰖲 Hyprland Binds" -theme "$THEME")
  ;;
*"Neovim"*)
  SELECTED=$(get_nvim_binds | rofi -dmenu -i -p " Neovim Binds" -theme "$THEME")
  ;;
*)
  exit 0
  ;;
esac

if [ -n "$SELECTED" ]; then
  echo -n "$SELECTED" | wl-copy
fi
