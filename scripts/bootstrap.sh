#!/usr/bin/env bash
set -euo pipefail

echo "==> flutter create (android, ios, web)"
flutter create . --platforms=android,ios,web

# --- ANDROID ---
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  echo "==> Patching AndroidManifest permissions"
  PERMS='
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
    <!-- For older devices: -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  '
  if ! grep -q 'android.permission.RECORD_AUDIO' "$MANIFEST"; then
    awk -v perms="$PERMS" '
      BEGIN{inserted=0}
      /<manifest/ && inserted==0 { print; print perms; inserted=1; next }
      { print }
    ' "$MANIFEST" > "$MANIFEST.tmp" && mv "$MANIFEST.tmp" "$MANIFEST"
  fi
fi

# --- iOS ---
PLIST="ios/Runner/Info.plist"
if [ -f "$PLIST" ]; then
  echo "==> Patching iOS Info.plist"
  if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
    PB="/usr/libexec/PlistBuddy"
    add_key() {
      KEY="$1"; TYPE="$2"; VAL="$3"
      if ! $PB -c "Print :$KEY" "$PLIST" >/dev/null 2>&1; then
        $PB -c "Add :$KEY $TYPE $VAL" "$PLIST"
      fi
    }
    add_key "NSMicrophoneUsageDescription" "string" "This app uses the microphone to record Prashna audio."
    add_key "NSCameraUsageDescription" "string" "This app uses the camera to record Pooja video."
    add_key "NSPhotoLibraryAddUsageDescription" "string" "Allows saving and picking media."
  else
    if ! grep -q 'NSMicrophoneUsageDescription' "$PLIST"; then
      sed -i.bak $'s#</dict>#  <key>NSMicrophoneUsageDescription</key>\
  <string>This app uses the microphone to record Prashna audio.</string>\
  <key>NSCameraUsageDescription</key>\
  <string>This app uses the camera to record Pooja video.</string>\
  <key>NSPhotoLibraryAddUsageDescription</key>\
  <string>Allows saving and picking media.</string>\
</dict>#' "$PLIST"
    fi
  fi
fi

echo "==> Done. Run: flutter run -d chrome | -d android | -d ios"
