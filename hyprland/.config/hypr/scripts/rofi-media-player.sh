#!/bin/bash
THEME="$HOME/.config/rofi/media_dashboard.rasi"
SOCKET="/tmp/mpvsocket"
MUSIC_DIR="$HOME/Music"

# Helper function to send commands to MPV IPC Socket
mpv_cmd() {
  if [ -S "$SOCKET" ]; then
    echo "$1" | socat - "$SOCKET" 2>/dev/null
  fi
}

# Fetch current playing title
get_current_track() {
  TITLE=$(echo '{"command": ["get_property", "media-title"]}' | socat - "$SOCKET" 2>/dev/null | python3 -c 'import sys, json; data=json.load(sys.stdin); print(data.get("data", ""))' 2>/dev/null)
  if [ -z "$TITLE" ]; then
    echo "Nothing Playing"
  else
    echo "$TITLE"
  fi
}

# Fetch MPV active playlist items
get_playlist_items() {
  echo '{"command": ["get_property", "playlist"]}' | socat - "$SOCKET" 2>/dev/null | python3 -c '
import sys, json
try:
    data = json.load(sys.stdin).get("data", [])
    for idx, item in enumerate(data):
        current = "▸ " if item.get("current") else "  "
        title = item.get("title") or item.get("filename", "Unknown Track")
        print(f"{current}[{idx}] {title}")
except Exception:
    pass
'
}

# Main Interactive Control Loop
while true; do
  CURRENT_TRACK=$(get_current_track)

  # 1. Controls Header
  CONTROLS=$(
    cat <<EOF
󰎈 NOW PLAYING: $CURRENT_TRACK
----------------------------------------
󰏤 Play / Pause
󰓛 Next Track
󰓔 Previous Track
󰝝 Volume Up (+5%)
󰝞 Volume Down (-5%)
󰅁 Seek Forward (+10s)
󰅀 Seek Backward (-10s)
󰒮 View Active MPV Playlist
󰅖 Stop / Quit MPV
----------------------------------------
EOF
  )

  # 2. Local Songs List from ~/Music
  SONGS=$(find "$MUSIC_DIR" -type f \( -name "*.mp3" -o -name "*.flac" -o -name "*.m4a" -o -name "*.wav" -o -name "*.ogg" -o -name "*.m3u" \) | sort | sed "s|$MUSIC_DIR/|🎵 |")

  # Combine Controls and Songs in Rofi
  ALL_MENU=$(printf "%s\n%s" "$CONTROLS" "$SONGS")
  CHOICE=$(echo "$ALL_MENU" | rofi -dmenu -i -p "󰎈 Media Player" -theme "$THEME")

  # Exit loop on ESC
  [ -z "$CHOICE" ] && break

  case "$CHOICE" in
  *"Play / Pause"*)
    mpv_cmd '{"command": ["cycle", "pause"]}'
    ;;
  *"Next Track"*)
    mpv_cmd '{"command": ["playlist-next"]}'
    ;;
  *"Previous Track"*)
    mpv_cmd '{"command": ["playlist-prev"]}'
    ;;
  *"Volume Up"*)
    mpv_cmd '{"command": ["add", "volume", 5]}'
    ;;
  *"Volume Down"*)
    mpv_cmd '{"command": ["add", "volume", -5]}'
    ;;
  *"Seek Forward"*)
    mpv_cmd '{"command": ["seek", 10]}'
    ;;
  *"Seek Backward"*)
    mpv_cmd '{"command": ["seek", -10]}'
    ;;
  *"View Active MPV Playlist"*)
    TRACKS=$(get_playlist_items)
    if [ -n "$TRACKS" ]; then
      SELECTED_TRACK=$(echo "$TRACKS" | rofi -dmenu -i -p "󰒮 Active Playlist" -theme "$THEME")
      if [ -n "$SELECTED_TRACK" ]; then
        INDEX=$(echo "$SELECTED_TRACK" | grep -oP '\[\K[0-9]+(?=\])')
        if [ -n "$INDEX" ]; then
          mpv_cmd "{\"command\": [\"set_property\", \"playlist-pos\", $INDEX]}"
        fi
      fi
    fi
    ;;
  *"Stop / Quit MPV"*)
    pkill mpv
    rm -f "$SOCKET"
    break
    ;;
  🎵*)
    # Play clicked song directly from ~/Music
    FILE_NAME=$(echo "$CHOICE" | sed 's/🎵 //')
    FULL_PATH="$MUSIC_DIR/$FILE_NAME"
    pkill mpv
    sleep 0.2
    mpv --input-ipc-server="$SOCKET" "$FULL_PATH" &
    ;;
  *)
    ;;
  esac
done
