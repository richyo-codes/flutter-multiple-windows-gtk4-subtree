#!/usr/bin/env bash
set -euo pipefail
# shellcheck source=tools/flutter_env.sh
source "$(dirname "$0")/flutter_env.sh"
FLUTTER_SDK_SHA="$(python3 -c 'import json; print(json.load(open(".fvmrc"))["flutter"])')"
variant="${1:?Usage: $0 gtk4|gtk3}"
case "$variant" in
  gtk4) bundle=build/linux-gtk4/x64/release/bundle; expected=libgtk-4.so; forbidden=libgtk-3.so ;;
  gtk3) bundle=build/linux/x64/release/bundle; expected=libgtk-3.so; forbidden=libgtk-4.so ;;
  *) echo "Unsupported GTK variant: $variant" >&2; exit 1 ;;
esac
version="${ARTIFACT_VERSION:-$(git describe --always --tags --dirty)}"
# Tags may include slashes, but artifact filenames must stay in dist.
version="${version//\//-}"
name="multiple-windows-linux-x64-$variant-$version"
linkage="$(ldd "$bundle/multiple_windows")"
printf '%s\n' "$linkage"
if ! grep -Fq "$expected" <<< "$linkage" ||
   grep -Eq "$forbidden|not found" <<< "$linkage"; then
  echo "Wrong GTK linkage or missing runtime dependency" >&2
  exit 1
fi
cp LICENSE "$bundle/"
printf 'App commit: %s\nFlutter commit: %s\nEngine artifacts: %s\nGTK: %s\nMode: release\nEntry point: lib/main.dart\n' \
  "$(git rev-parse HEAD)" "${FLUTTER_SDK_SHA:?}" \
  "${FLUTTER_PREBUILT_ENGINE_VERSION:?}" "$variant" > "$bundle/BUILD_INFO.txt"
mkdir -p dist
tar -czf "dist/$name.tar.gz" -C "$bundle" .
(cd dist && sha256sum "$name.tar.gz" > "$name.tar.gz.sha256")
