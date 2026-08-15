#!/usr/bin/env bash
# Baut eine private signierte Release-APK mit aktivierter
# OpenRouter-Nachbearbeitung aus config/openrouter.private.json.
#
# WICHTIG: Die resultierende APK enthält den API-Key als
# Compile-Time-Konstante. Sie darf niemals veröffentlicht oder
# weitergegeben werden (siehe docs/CURRENT_STATUS.md).
set -euo pipefail

cd "$(dirname "$0")/.."

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

exec /home/d/flutter/bin/flutter build apk --release \
  --dart-define=OPENROUTER_ENABLED="$OR_ENABLED" \
  --dart-define=OPENROUTER_MODEL_ID="$OR_MODEL" \
  --dart-define=OPENROUTER_API_KEY="$OR_KEY"
