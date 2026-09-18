#!/usr/bin/env bash
# Install the helium-private macOS overlay onto this machine.
# Does not require building Chromium. Works with the official Helium.app.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN="$HOME/.local/bin"
LAUNCH="$HOME/Library/LaunchAgents"
mkdir -p "$BIN" "$LAUNCH" "$HOME/.helium-private" "$HOME/.local/share/ublock"

install -m 755 "$ROOT/helium-privacy-lock" "$BIN/helium-privacy-lock"
install -m 755 "$ROOT/helium-privacy-install-system" "$BIN/helium-privacy-install-system"

# Fill user-specific paths into the LaunchAgent.
python3 - <<PY
from pathlib import Path
home = str(Path.home())
uid_plist = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>net.gokul.helium-privacy</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/python3</string>
    <string>{home}/.local/bin/helium-privacy-lock</string>
    <string>--weekly</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>0</integer>
    <key>Hour</key>
    <integer>10</integer>
    <key>Minute</key>
    <integer>0</integer>
  </dict>
  <key>StandardOutPath</key>
  <string>{home}/.helium-private/lock.out</string>
  <key>StandardErrorPath</key>
  <string>{home}/.helium-private/lock.err</string>
</dict>
</plist>
"""
Path.home().joinpath("Library/LaunchAgents/net.gokul.helium-privacy.plist").write_text(uid_plist)
print("wrote LaunchAgent")
PY

python3 "$BIN/helium-privacy-lock"

uid="$(id -u)"
launchctl bootout "gui/${uid}/net.gokul.helium-privacy" 2>/dev/null || true
launchctl bootstrap "gui/${uid}" "$LAUNCH/net.gokul.helium-privacy.plist"
launchctl enable "gui/${uid}/net.gokul.helium-privacy"

echo
echo "User-space lock installed. To make Helium services/AdBlock/Sparkle"
echo "unblockable from the browser UI, run (macOS password prompt):"
echo "  osascript -e 'do shell script \"$BIN/helium-privacy-install-system\" with administrator privileges'"
echo
echo "Weekly check: Sunday 10:00. Manual: python3 ~/.local/bin/helium-privacy-lock --weekly"
