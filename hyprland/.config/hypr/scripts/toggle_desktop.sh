#!/bin/bash

STATE_FILE="/tmp/hypr_last_workspace"
TARGET_WORKSPACE=10

# جلب رقم الـ workspace الحالية
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')

if [ "$CURRENT_WORKSPACE" -eq "$TARGET_WORKSPACE" ]; then
  # إذا كنا في workspace 10، نرجع للـ workspace السابقة
  if [ -f "$STATE_FILE" ]; then
    PREV_WORKSPACE=$(cat "$STATE_FILE")
    hyprctl dispatch "workspace($PREV_WORKSPACE)"
  else
    hyprctl dispatch "workspace(1)"
  fi
else
  # حفظ الـ workspace الحالية والانتقال إلى 10
  echo "$CURRENT_WORKSPACE" >"$STATE_FILE"
  hyprctl dispatch "workspace($TARGET_WORKSPACE)"
fi
