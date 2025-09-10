#!/usr/bin/env nu
# wl: set a random wallpaper from ~/pic/wl or ~/pic/black using swww
# Usage: wl

# best-effort initialize swww (ignore if already running)
^swww init | ignore

# Collect candidate images; shuffle and pick the first
let pics = (ls ...(glob ~/pic/{wl,black}/**/*) | where type == file | get name)
if ($pics | length) == 0 { exit 1 }
let pick = ($pics | shuffle | first)

# Apply wallpaper with a smooth transition
^swww img --transition-fps 240 $pick
