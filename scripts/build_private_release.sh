#!/usr/bin/env bash
# Baut eine private signierte Release-APK mit aktivierter
# OpenRouter-Nachbearbeitung aus config/openrouter.private.json.
#
# WICHTIG: Die resultierende APK enthält den API-Key als
# Compile-Time-Konstante. Sie darf niemals veröffentlicht oder
# weitergegeben werden (siehe docs/CURRENT_STATUS.md).
set -euo pipefail

cd "$(dirname "$0")/.."

TOOLING_DIR="$PWD/.tooling"
JAVA_HOME="${JAVA_HOME:-$TOOLING_DIR/jdk-17}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$TOOLING_DIR/android-sdk}}"
ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
ANDROID_USER_HOME="${ANDROID_USER_HOME:-$TOOLING_DIR/android-user-home}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$TOOLING_DIR/gradle-home}"
PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export JAVA_HOME ANDROID_SDK_ROOT ANDROID_HOME ANDROID_USER_HOME GRADLE_USER_HOME PATH

CONFIG="config/openrouter.private.json"
if [ ! -f "$CONFIG" ]; then
  echo "Fehler: $CONFIG fehlt. Ohne private Konfiguration wird kein Key-Build erstellt." >&2
  exit 1
fi

OR_ENABLED="$(python3 -c "import json;print(str(json.load(open('$CONFIG'))['OPENROUTER_ENABLED']).lower())")"
OR_MODEL="$(python3 -c "import json;print(json.load(open('$CONFIG'))['OPENROUTER_MODEL_ID'])")"
OR_KEY="$(python3 -c "import json;print(json.load(open('$CONFIG'))['OPENROUTER_API_KEY'])")"

if [ "$OR_ENABLED" != "true" ] || [ -z "$OR_MODEL" ] || [ -z "$OR_KEY" ]; then
  echo "Fehler: $CONFIG ist unvollständig oder deaktiviert." >&2
  exit 1
fi

FLUTTER_BIN="${FLUTTER_BIN:-$PWD/.tooling/flutter/bin/flutter}"
if [[ ! -x "$FLUTTER_BIN" ]]; then
  echo "Fehler: Flutter SDK nicht gefunden oder nicht ausführbar: $FLUTTER_BIN" >&2
  exit 127
fi

exec "$FLUTTER_BIN" build apk --release \
  --dart-define=OPENROUTER_ENABLED="$OR_ENABLED" \
  --dart-define=OPENROUTER_MODEL_ID="$OR_MODEL" \
  --dart-define=OPENROUTER_API_KEY="$OR_KEY"
