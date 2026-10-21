#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "The published engines require Linux x86_64." >&2
  exit 1
fi
# shellcheck source=tools/flutter_env.sh
source tools/flutter_env.sh
sdk_pin="$(python3 -c 'import json; print(json.load(open(".fvmrc"))["flutter"])')"
FLUTTER_STORAGE_BASE_URL="$FLUTTER_ENGINE_STORAGE_BASE_URL" \
  fvm install "$sdk_pin" --setup --skip-pub-get
fvm use "$sdk_pin" --force --skip-setup --skip-pub-get
sdk=.fvm/flutter_sdk
test "$(git -C "$sdk" rev-parse HEAD)" = "$sdk_pin"
test "$(cat "$sdk/bin/cache/engine.stamp")" = "$FLUTTER_PREBUILT_ENGINE_VERSION"
fvm flutter config --enable-linux-desktop --enable-windowing --no-analytics
# Shared assets come from standard storage; install the custom engines afterward.
fvm flutter precache --linux
bash tools/install_prebuilt_engines.sh "$sdk"
fvm flutter pub get
