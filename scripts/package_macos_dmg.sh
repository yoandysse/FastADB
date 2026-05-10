#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <path-to-FastADB.app> <output-dmg>" >&2
  exit 64
fi

APP_PATH="$1"
DMG_PATH="$2"
APP_NAME="FastADB"
VOLUME_NAME="FastADB"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App bundle not found: $APP_PATH" >&2
  exit 66
fi

WORK_DIR="$(mktemp -d)"
STAGING_DIR="$WORK_DIR/$VOLUME_NAME"
RW_DMG="$WORK_DIR/$VOLUME_NAME-rw.dmg"

cleanup() {
  hdiutil detach "/Volumes/$VOLUME_NAME" -quiet >/dev/null 2>&1 || true
  rm -rf "$WORK_DIR"
}
trap cleanup EXIT

mkdir -p "$STAGING_DIR"
ditto "$APP_PATH" "$STAGING_DIR/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/Applications"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -fsargs "-c c=64,a=16,e=16" \
  -format UDRW \
  -size 220m \
  "$RW_DMG" >/dev/null

DEVICE="$(hdiutil attach "$RW_DMG" -readwrite -noverify -noautoopen | awk '/Apple_HFS/ {print $1}')"

osascript <<'APPLESCRIPT'
tell application "Finder"
  tell disk "FastADB"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 120, 720, 440}
    set theViewOptions to the icon view options of container window
    set arrangement of theViewOptions to not arranged
    set icon size of theViewOptions to 96
    set position of item "FastADB.app" of container window to {160, 150}
    try
      set position of item "Applications" of container window to {360, 150}
    on error
      try
        set position of item "Aplicaciones" of container window to {360, 150}
      end try
    end try
    update without registering applications
    delay 1
    close
  end tell
end tell
APPLESCRIPT

sync
hdiutil detach "$DEVICE" -quiet

mkdir -p "$(dirname "$DMG_PATH")"
rm -f "$DMG_PATH"
hdiutil convert "$RW_DMG" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH" >/dev/null

echo "Created $DMG_PATH"
