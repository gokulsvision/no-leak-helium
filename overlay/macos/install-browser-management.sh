#!/usr/bin/env bash
# Helium-only tab budget + nightly site-cache policy.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FEAT="$ROOT/features/browser-management"
if [[ ! -d "$FEAT/extension" ]]; then
  # overlay-only checkout: feature copied next to this script
  FEAT="$(cd "$(dirname "$0")" && pwd)/browser-management"
fi
HOST_SRC="$FEAT/native/bms-host"
SHARE="$HOME/.local/share/no-leak-helium/browser-management"
HOST_DST="$SHARE/bms-host"
EXT_ID="occkalmjgdilhnphpbjopodjkpppcddj"
HOST_NAME="com.browsermanagement.system"
HELIUM_NM="$HOME/Library/Application Support/net.imput.helium/NativeMessagingHosts"
HELIUM_EXT="$HOME/Library/Application Support/net.imput.helium/Default/Extensions/$EXT_ID/1.4.0_1"
APP_SUPPORT="$HOME/Library/Application Support/Browser Management System"

mkdir -p "$SHARE" "$(dirname "$HOST_DST")" "$HELIUM_NM" "$APP_SUPPORT"
cp "$HOST_SRC" "$HOST_DST"
chmod +x "$HOST_DST"
rsync -a --delete "$FEAT/extension/" "$SHARE/extension/"
mkdir -p "$HELIUM_EXT"
rsync -a --delete "$FEAT/extension/" "$HELIUM_EXT/"

cat > "$HELIUM_NM/$HOST_NAME.json" <<EOF
{
  "name": "$HOST_NAME",
  "description": "No Leak Helium RAM helper",
  "path": "$HOST_DST",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$EXT_ID/"
  ]
}
EOF

cp "$FEAT/scripts/clear-site-cache.py" "$SHARE/clear-site-cache.py"
chmod +x "$SHARE/clear-site-cache.py"
if [[ ! -f "$APP_SUPPORT/POLICY.md" ]]; then
  cp "$FEAT/POLICY.md" "$APP_SUPPORT/POLICY.md"
fi

PLIST_DST="$HOME/Library/LaunchAgents/com.browsermanagement.cache.plist"
sed -e "s|CACHE_SCRIPT|$SHARE/clear-site-cache.py|g" \
    -e "s|HOME|$HOME|g" \
    "$FEAT/scripts/com.browsermanagement.cache.plist" > "$PLIST_DST"

UID_NUM="$(id -u)"
launchctl bootout "gui/$UID_NUM/com.browsermanagement.cache" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_DST"
launchctl enable "gui/$UID_NUM/com.browsermanagement.cache"

echo "Tab budget installed for Helium only (extension id $EXT_ID)."
echo "Policy: $APP_SUPPORT/POLICY.md"
