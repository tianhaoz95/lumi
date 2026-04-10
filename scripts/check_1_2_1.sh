#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MISSING=0
check(){
  if [ ! -e "$ROOT/$1" ]; then
    echo "MISSING: $1"
    MISSING=1
  else
    echo "OK: $1"
  fi
}

check "lib/main.dart"
check "lib/core/app.dart"
check "lib/core/theme.dart"
check "lib/features/auth/appwrite_service.dart"
check "lib/features/home/home.dart"
check "lib/features/dashboard/dashboard.dart"
check "lib/features/settings/settings.dart"
check "lib/shared/widgets/widgets.dart"
check "lib/shared/bridge/bridge.dart"

if [ "$MISSING" -eq 1 ]; then
  echo "One or more files missing"
  exit 2
fi

echo "All Phase 1.2.1 files present"
exit 0
