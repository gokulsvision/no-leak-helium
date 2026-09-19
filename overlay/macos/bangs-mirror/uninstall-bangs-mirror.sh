#!/usr/bin/env bash
# Remove the loopback bang-list mirror and restore privacy-lock defaults.
# The real Helium services domain remains sinkholed; bangs fetch goes back to
# Helium's default (services disabled -> no bang list).
set -euo pipefail

SHARE="$HOME/.local/share/no-leak-helium/bangs-mirror"
LAUNCH="$HOME/Library/LaunchAgents"
FLAG="$HOME/.no-leak-helium/bangs-mirror.installed"
BIN="$HOME/.local/bin"
PLIST_NAME="net.gokul.helium-bangs-mirror"

UID_NUM="$(id -u)"
launchctl bootout "gui/$UID_NUM/$PLIST_NAME" 2>/dev/null || true
rm -f "$LAUNCH/$PLIST_NAME.plist" "$FLAG"
rm -rf "$SHARE"

if [[ -x "$BIN/helium-privacy-lock" ]]; then
  python3 "$BIN/helium-privacy-lock" || true
fi

echo "bangs mirror removed"
echo "If Helium was running, close it and re-run: python3 $BIN/helium-privacy-lock"