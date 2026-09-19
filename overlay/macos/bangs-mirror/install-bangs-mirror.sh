#!/usr/bin/env bash
# Install the loopback bang-list mirror for No Leak Helium.
#
# What this does:
#   1. Copies the mirror server + bundled bangs.json into ~/.local/share/no-leak-helium/
#   2. Verifies the bundled manifest sha256 against the pinned checksum
#   3. Installs a LaunchAgent so the mirror runs at every login (loopback only)
#   4. Sets helium.services.origin_override=http://127.0.0.1:<port> and
#      helium.services.bangs=true via the privacy lock, so the bang loader
#      fetches from the local mirror and never from services.helium.imput.net
#
# The real Helium services domain stays sinkholed in /etc/hosts and
# helium.services.enabled stays false for every other service.
set -euo pipefail

MIRROR_DIR="$(cd "$(dirname "$0")" && pwd)"
PORT="${BANGS_MIRROR_PORT:-8317}"
MANIFEST_SHA256="4e43515474a503eae40b5e1878b8448b5d1162d21738acf159937105db548e59"

SHARE="$HOME/.local/share/no-leak-helium/bangs-mirror"
BIN="$HOME/.local/bin"
LAUNCH="$HOME/Library/LaunchAgents"
FLAG="$HOME/.no-leak-helium/bangs-mirror.installed"
BANG_SRC="$MIRROR_DIR/bangs.json"
BANG_DST="$SHARE/bangs.json"

if [[ ! -f "$BANG_SRC" ]]; then
  echo "error: missing $BANG_SRC (bundle bangs.json next to this script first)" >&2
  exit 1
fi

mkdir -p "$SHARE" "$BIN" "$LAUNCH" "$(dirname "$FLAG")"

install -m 755 "$MIRROR_DIR/bangs-mirror.py" "$SHARE/bangs-mirror.py"
install -m 644 "$BANG_SRC" "$BANG_DST"

# Pin the manifest. If it drifts from the committed checksum, refuse to serve it.
actual="$(shasum -a 256 "$BANG_DST" | awk '{print $1}')"
if [[ "$actual" != "$MANIFEST_SHA256" ]]; then
  echo "error: bangs.json sha256 mismatch" >&2
  echo "  expected $MANIFEST_SHA256" >&2
  echo "  actual   $actual" >&2
  exit 1
fi

# LaunchAgent: start mirror at login, keep it alive (repo template + sed fill,
# same pattern as install-browser-management.sh).
UID_NUM="$(id -u)"
PLIST_NAME="net.gokul.helium-bangs-mirror"
PLIST_DST="$LAUNCH/$PLIST_NAME.plist"
sed -e "s|SCRIPT_PATH|$SHARE/bangs-mirror.py|g" \
    -e "s|PORT|$PORT|g" \
    -e "s|MANIFEST|$BANG_DST|g" \
    -e "s|HOME|$HOME|g" \
    "$MIRROR_DIR/$PLIST_NAME.plist" > "$PLIST_DST"

launchctl bootout "gui/$UID_NUM/$PLIST_NAME" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_DST"
launchctl enable "gui/$UID_NUM/$PLIST_NAME"
launchctl start "gui/$UID_NUM/$PLIST_NAME" 2>/dev/null || true

# Wait for the mirror to answer, then smoke-test the exact route Helium fetches.
ok=0
for _ in 1 2 3 4 5; do
  if curl -fsS "http://127.0.0.1:$PORT/bangs.json" -o /dev/null 2>/dev/null; then
    ok=1
    break
  fi
  sleep 1
done
if [[ "$ok" != 1 ]]; then
  echo "error: mirror did not answer on 127.0.0.1:$PORT" >&2
  echo "  logs: $HOME/.no-leak-helium/bangs-mirror.err" >&2
  exit 1
fi

# Record install; the privacy lock keys off this flag.
echo "port=$PORT" > "$FLAG"
echo "manifest=$BANG_DST" >> "$FLAG"
echo "sha256=$MANIFEST_SHA256" >> "$FLAG"

# Re-apply the privacy lock so origin_override + bangs pref take effect.
# (Prefs patch is skipped while Helium is open; run again when it is closed.)
if [[ -x "$BIN/helium-privacy-lock" ]]; then
  python3 "$BIN/helium-privacy-lock" || true
fi

echo "bangs mirror installed (loopback :$PORT)"
echo "  manifest: $BANG_DST"
echo "  origin_override + helium.services.bangs set by helium-privacy-lock"
echo "If Helium was running, close it and re-run: python3 $BIN/helium-privacy-lock"