#!/bin/sh
# Claude Code status line: git branch, directory, model.
# Claude Code feeds this script a JSON blob on stdin and renders its stdout.
set -eu

input=$(cat)

if command -v jq >/dev/null 2>&1; then
  dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
  model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
else
  dir=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  model=$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi
[ -n "$dir" ] || dir=$PWD

# Detached HEAD has no symbolic ref, so fall back to the short commit.
branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null ||
  git -C "$dir" rev-parse --short HEAD 2>/dev/null || true)
if [ -n "$branch" ] && ! git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  branch="$branch*"
fi

out=""
if [ -n "$branch" ]; then
  out=" $branch | "
fi
out="$out$(basename "$dir")"
if [ -n "$model" ]; then
  out="$out | $model"
fi
printf '%s\n' "$out"
