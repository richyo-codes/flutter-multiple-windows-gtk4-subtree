#!/usr/bin/env bash

set -euo pipefail

ENGINE_REMOTE="${ENGINE_REMOTE:-origin}"
ENGINE_REF="${1:-master}"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir/.." rev-parse --show-toplevel)"
ENGINE_REPO="${ENGINE_REPO:-$(dirname -- "$repo_root")/flutter-gtk4}"

if [[ -n "$(git -C "$repo_root" status --porcelain --untracked-files=no)" ]]; then
  echo "Refusing to sync with a dirty working tree: $repo_root" >&2
  exit 1
fi

if ! git -C "$ENGINE_REPO" rev-parse --git-dir >/dev/null 2>&1; then
  echo "Engine repository not found: $ENGINE_REPO" >&2
  exit 1
fi

echo "Fetching $ENGINE_REMOTE/$ENGINE_REF in $ENGINE_REPO"
git -C "$ENGINE_REPO" fetch "$ENGINE_REMOTE" "$ENGINE_REF"

source_ref="$(git -C "$ENGINE_REPO" rev-parse FETCH_HEAD)"
echo "Creating subtree split for examples/multiple_windows from $source_ref"
split_commit="$(git -C "$ENGINE_REPO" subtree split \
  --prefix=examples/multiple_windows "$source_ref")"

echo "Merging subtree split $split_commit"
git -C "$repo_root" fetch "$ENGINE_REPO" "$split_commit"
if ! git -C "$repo_root" merge-base HEAD FETCH_HEAD >/dev/null; then
  echo "Fetched split has no shared history; verify the subtree source." >&2
  exit 1
fi
git -C "$repo_root" merge --no-ff \
  -m "chore(sync): update multiple_windows from Flutter $source_ref" FETCH_HEAD
