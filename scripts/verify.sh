#!/usr/bin/env bash
set -euo pipefail

FLUTTER=/home/d/flutter/bin/flutter

"$FLUTTER" analyze
"$FLUTTER" test
"$FLUTTER" build apk --debug
