#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOOLING_DIR="$SCRIPT_DIR/../.tooling"
FLUTTER_BIN="${FLUTTER_BIN:-$TOOLING_DIR/flutter/bin/flutter}"
JAVA_HOME="${JAVA_HOME:-$TOOLING_DIR/jdk-17}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$TOOLING_DIR/android-sdk}}"
ANDROID_HOME="${ANDROID_HOME:-$ANDROID_SDK_ROOT}"
ANDROID_USER_HOME="${ANDROID_USER_HOME:-$TOOLING_DIR/android-user-home}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-$TOOLING_DIR/gradle-home}"
PATH="$JAVA_HOME/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export JAVA_HOME ANDROID_SDK_ROOT ANDROID_HOME ANDROID_USER_HOME GRADLE_USER_HOME PATH

if [[ ! -x "$FLUTTER_BIN" ]]; then
  printf 'Flutter SDK not found or not executable: %s\n' "$FLUTTER_BIN" >&2
  exit 127
fi

"$FLUTTER_BIN" analyze
"$FLUTTER_BIN" test
"$FLUTTER_BIN" build apk --debug
