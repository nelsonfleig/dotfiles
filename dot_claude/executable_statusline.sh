#!/bin/sh
# Claude Code status line: the org's line, with the git branch prepended.
#
# /etc/claude-code/managed-settings.json points Claude Code at
# /etc/claude-code/statusline-command.sh, and that script's first act is to `exec`
# $HOME/.claude/statusline.sh when it exists. That delegation is the org's own
# override hook -- which is why merely creating this file replaces the whole status
# line, context bar and cost included.
#
# So this cannot simply call the org script: it would exec straight back into here.
# Instead it invokes the org script with HOME pointing at a path that does not
# exist, so the `[ -f "$HOME/.claude/statusline.sh" ]` test fails, the delegation
# falls through, and the org's own rendering runs. Nothing is copied, so their
# changes to the bar, cost, effort or model display flow through untouched.
set -eu

ORG=/etc/claude-code/statusline-command.sh

input=$(cat)

# The branch belongs to the session's directory, not to wherever this script runs.
if command -v jq >/dev/null 2>&1; then
  dir=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // ""')
else
  dir=$(printf '%s' "$input" | sed -n 's/.*"current_dir"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
fi
[ -n "$dir" ] || dir=$PWD

# Detached HEAD has no symbolic ref, so fall back to the short commit.
branch=$(git -C "$dir" symbolic-ref --quiet --short HEAD 2>/dev/null ||
  git -C "$dir" rev-parse --short HEAD 2>/dev/null || true)
if [ -n "$branch" ] && ! git -C "$dir" diff --quiet --ignore-submodules HEAD 2>/dev/null; then
  branch="$branch*"
fi

prefix=""
if [ -n "$branch" ]; then
  # Bright black, so the branch sits behind the org's line instead of competing.
  prefix=$(printf '\033[90m%s\033[0m | ' "$branch")
fi

body=""
if [ -x "$ORG" ]; then
  body=$(printf '%s' "$input" | HOME=/nonexistent bash "$ORG" 2>/dev/null || true)
fi

# No org script (a personal laptop) or it failed: render enough to stay useful.
if [ -z "$body" ]; then
  if command -v jq >/dev/null 2>&1; then
    model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
  else
    model=$(printf '%s' "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  fi
  body=$(basename "$dir")
  if [ -n "$model" ]; then
    body="$body | $model"
  fi
fi

printf '%s%s\n' "$prefix" "$body"
