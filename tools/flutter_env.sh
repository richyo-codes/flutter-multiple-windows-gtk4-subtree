#!/usr/bin/env bash
# Source this before direct FVM commands. Public, matching engine artifacts.
export FLUTTER_PREBUILT_ENGINE_VERSION=cfd38c9e1e8de9965d24ad412cf70550ec3310f3
export FLUTTER_STORAGE_BASE_URL=https://pub-79a02b1963fb4da6b5e4e4816e8b7146.r2.dev
# The explicit Linux archive installer uses the same mirror as Flutter itself.
export FLUTTER_ENGINE_STORAGE_BASE_URL="$FLUTTER_STORAGE_BASE_URL"
