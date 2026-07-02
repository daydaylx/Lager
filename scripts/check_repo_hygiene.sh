#!/usr/bin/env bash
# Repo-Hygiene-Check gegen typische Agentenfehler.
# Läuft lokal und in der CI (.github/workflows/flutter-ci.yml).
# Weitere Fallen (stabile Enum-Namen, eindeutige Activity-IDs) sind über
# `flutter test` (persistence_stability_test.dart, default_activities_test.dart)
# und android_backup_test.dart abgesichert.
#
# Exit-Code != 0 bei Verstoß. Fehlernamen sind verständlich gehalten.
set -euo pipefail

cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

status=0

fail() {
  echo "::error::$1"
  status=1
}

# --- 1. Relative Imports innerhalb von lib/ -------------------------------
# lib/ darf kein `import 'package:berichtsheft_merker/...'` enthalten.
mapfile -t pkg_imports < <(grep -rnE "^import 'package:berichtsheft_merker/" lib/ 2>/dev/null || true)
if [ "${#pkg_imports[@]}" -gt 0 ]; then
  fail "In lib/ müssen Imports relativ sein (siehe AGENTS.md 'Codierungs-Patterns'). Gefundene absolute Imports:"
  printf '  %s\n' "${pkg_imports[@]}"
fi

# --- 2. Keine Keystore-/Secret-Dateien committet --------------------------
# key.properties und *.jks/*.keystore sind ignoriert und dürfen nie ins Repo.
mapfile -t secret_files < <(git ls-files 2>/dev/null | grep -iE '(^|/)key\.properties$|\.jks$|\.keystore$|\.keystore\.properties$' || true)
if [ "${#secret_files[@]}" -gt 0 ]; then
  fail "Keystore-/Secret-Dateien dürfen nicht committet werden (siehe README 'Android-Release'). Gefunden:"
  printf '  %s\n' "${secret_files[@]}"
fi

# --- 3. Android-Backup bleibt deaktiviert ---------------------------------
# Schnelle Textprüfung als Frühindikator; die verbindliche Assertion läuft im
# Dart-Test (android_backup_test.dart). allowBackup darf nicht auf true stehen.
if grep -qE 'android:allowBackup="true"' android/app/src/main/AndroidManifest.xml 2>/dev/null; then
  fail "android:allowBackup steht auf true — lokale Daten würden ins Cloud-Backup/Transfer wandern (PRIVACY_CONTEXT.md)."
fi

# --- Ergebnis -------------------------------------------------------------
if [ "$status" -ne 0 ]; then
  echo
  echo "Repo-Hygiene-Check fehlgeschlagen."
  exit "$status"
fi

echo "Repo-Hygiene-Check: OK (relative Imports, keine Secrets, Backup deaktiviert)."
