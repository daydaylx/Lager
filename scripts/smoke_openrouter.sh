#!/usr/bin/env bash
# Führt den OpenRouter-Live-Smoke-Test (test/openrouter_live_smoke_test.dart)
# mit den Werten aus config/openrouter.private.json aus.
# Prüft real: Endpoint, Modell-ID, ZDR-/Provider-Parameter, Antwortformat.
set -euo pipefail

cd "$(dirname "$0")/.."

CONFIG="config/openrouter.private.json"
if [ ! -f "$CONFIG" ]; then
  echo "Fehler: $CONFIG fehlt." >&2
  exit 1
fi

OR_ENABLED="$(python3 -c "import json;print(str(json.load(open('$CONFIG'))['OPENROUTER_ENABLED']).lower())")"
OR_MODEL="$(python3 -c "import json;print(json.load(open('$CONFIG'))['OPENROUTER_MODEL_ID'])")"
OR_KEY="$(python3 -c "import json;print(json.load(open('$CONFIG'))['OPENROUTER_API_KEY'])")"

TEST_FILE="${1:-test/openrouter_live_smoke_test.dart}"

exec /home/d/flutter/bin/flutter test "$TEST_FILE" \
  --dart-define=OPENROUTER_ENABLED="$OR_ENABLED" \
  --dart-define=OPENROUTER_MODEL_ID="$OR_MODEL" \
  --dart-define=OPENROUTER_API_KEY="$OR_KEY"
