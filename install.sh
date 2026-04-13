#!/bin/bash

set -e

echo "Updating system..."
sudo apt update


echo "Installing APT packages..."
valid_packages=()

for pkg in "${APT_LIST[@]}"; do
  if apt-cache show "$pkg" &>/dev/null; then
    valid_packages+=("$pkg")
  else
    echo "Skipping: $pkg (not found)"
  fi
done

sudo apt install -y "${valid_packages[@]}"

# ---------------------------
# BREW (Linuxbrew)
# ---------------------------
if command -v brew &>/dev/null; then
  echo "Installing Brew packages..."
  brew install "${BREW_LIST[@]}"
else
  echo "Homebrew not installed, skipping..."
fi

# ---------------------------
# FLATPAK
# ---------------------------
if command -v flatpak &>/dev/null; then
  echo "Installing Flatpak apps..."

  FLATPAK_APPS=(
    app.zen_browser.zen
    com.discordapp.Discord
    com.getpostman.Postman
    com.github.IsmaelMartinez.teams_for_linux
    com.github.tchx84.Flatseal
    com.obsproject.Studio
    io.dbeaver.DBeaverCommunity
    it.mijorus.smile
    md.obsidian.Obsidian
    org.mozilla.Thunderbird
    org.mozilla.firefox
    org.telegram.desktop
  )

  flatpak install -y flathub "${FLATPAK_APPS[@]}"
fi

echo "Done."
