#!/usr/bin/env bash

set -euo pipefail

ENGINE_REMOTE="${ENGINE_REMOTE:-origin}"
ENGINE_REF="${1:-master}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(git -C "$script_dir/.." rev-parse --show-toplevel)"
ENGINE_REPO="${ENGINE_REPO:-$(dirname -- "$repo_root")/flutter-gtk4}"
feature_branch="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD)" || {
  echo "Check out a branch before syncing." >&2
  exit 1
}
git check-ref-format --branch "$UPSTREAM_BRANCH" >/dev/null
old_base="$(git -C "$repo_root" rev-parse --verify "refs/heads/$UPSTREAM_BRANCH")"
if ! git -C "$repo_root" merge-base --is-ancestor "$old_base" HEAD; then
  echo "$feature_branch is not based on $UPSTREAM_BRANCH; rebase it explicitly first." >&2
  exit 1
fi

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

echo "Importing subtree split $split_commit from Flutter $source_ref"
git -C "$repo_root" fetch "$ENGINE_REPO" "$split_commit"
if ! git -C "$repo_root" merge-base --is-ancestor "$old_base" "$split_commit"; then
  echo "Refusing to rewrite $UPSTREAM_BRANCH: it must contain only upstream subtree history." >&2
  exit 1
fi

if [[ "$feature_branch" == "$UPSTREAM_BRANCH" ]]; then
  git -C "$repo_root" merge --ff-only "$split_commit"
else
  # Git refuses this if the upstream branch is checked out in another worktree.
  git -C "$repo_root" branch -f "$UPSTREAM_BRANCH" "$split_commit"
  git -C "$repo_root" rebase --onto "$UPSTREAM_BRANCH" "$old_base"
fi
