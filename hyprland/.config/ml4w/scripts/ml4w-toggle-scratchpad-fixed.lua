!/usr/bin/env lua

-- سكريبت محسّن للتعامل مع النوافذ المتعددة
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local wibox = require("wibox")
local naughty = require("naughty")

-- دالة لتبديل جميع النوافذ في مساحة العمل الحالية إلى الـ scratchpad
local function toggle_all_windows_to_scratchpad()
    local screen = awful.screen.focused()
    local workspace = screen.selected_tag
    local scratchpad_tag = screen.tags["scratchpad"] or screen.tags[#screen.tags] -- أو استخدم اسم الـ special workspace الخاص بك

    -- إذا كانت مساحة العمل الحالية هي الـ scratchpad
    if workspace == scratchpad_tag then
        -- انقل جميع النوافذ إلى مساحة العمل الرئيسية (الأولى)
        local target_tag = screen.tags[1]
        for _, c in ipairs(workspace:clients()) do
            c:move_to_tag(target_tag)
        end
        -- عد إلى مساحة العمل الرئيسية
        target_tag:view_only()
    else
        -- انقل جميع النوافذ من مساحة العمل الحالية إلى الـ scratchpad
        for _, c in ipairs(workspace:clients()) do
            c:move_to_tag(scratchpad_tag)
        end
        -- انتقل إلى الـ scratchpad
        scratchpad_tag:view_only()
    end
end

-- دالة لتبديل النافذة النشطة فقط
local function toggle_active_window_to_scratchpad()
    local screen = awful.screen.focused()
    local client = awful.client.focus.get(screen)
    if not client then return end

    local scratchpad_tag = screen.tags["scratchpad"] or screen.tags[#screen.tags]
    local current_tag = client:tags()[1]

    if current_tag == scratchpad_tag then
        -- انقل النافذة إلى مساحة العمل الرئيسية
        local target_tag = screen.tags[1]
        client:move_to_tag(target_tag)
        target_tag:view_only()
    else
        -- انقل النافذة إلى الـ scratchpad
        client:move_to_tag(scratchpad_tag)
        scratchpad_tag:view_only()
    end
end

-- اختر أي من الدالتين تريد استخدامها
toggle_all_windows_to_scratchpad()
-- أو استخدم:
-- toggle_active_window_to_scratchpad()
