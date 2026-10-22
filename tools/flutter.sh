#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Keep the engine override on every invocation, not just during installation.
# shellcheck source=tools/flutter_env.sh
source tools/flutter_env.sh
exec fvm flutter "$@"
