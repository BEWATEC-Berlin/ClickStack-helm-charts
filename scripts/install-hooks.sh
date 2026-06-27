#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
hooks_dir="$repo_root/.githooks"
git_hooks_dir="$repo_root/.git/hooks"

if [ ! -d "$hooks_dir" ]; then
  echo "missing hooks directory: $hooks_dir" >&2
  exit 1
fi

shopt -s nullglob
hooks=("$hooks_dir"/*)
shopt -u nullglob

if [ "${#hooks[@]}" -eq 0 ]; then
  echo "no hooks found in $hooks_dir" >&2
  exit 1
fi

for hook in "${hooks[@]}"; do
  name="$(basename "$hook")"
  cp "$hook" "$git_hooks_dir/$name"
  chmod +x "$git_hooks_dir/$name"
  echo "installed $name hook at $git_hooks_dir/$name"
done
