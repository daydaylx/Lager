#!/usr/bin/env bash
set -euo pipefail

FLUTTER=/home/d/flutter/bin/flutter

bash scripts/check_repo_hygiene.sh
"$FLUTTER" analyze
"$FLUTTER" test
"$FLUTTER" build apk --debug
