#!/usr/bin/env bash
# Set up the personal research wiki (Karpathy LLM Wiki pattern).
#
# This is a chezmoi `run_after_` hook, so chezmoi runs it at the end of every
# `chezmoi apply` / `chezmoi init --apply`. That ordering is the point: chezmoi
# manages dot_claude/settings.json -> ~/.claude/settings.json, so wiki hooks
# merged in before the apply would be overwritten by it. Making it a hook rather
# than a call at the end of setup.sh means chezmoi enforces the ordering instead
# of a comment in setup.sh.
#
# Note this only fires reliably on a fresh `chezmoi init --apply`. A later
# `chezmoi apply` stops to ask about ~/.claude/settings.json, because this script
# and Claude Code itself both write keys chezmoi's source copy does not have, so
# chezmoi sees the target as externally modified. Re-run this script by hand
# instead of reaching for `chezmoi apply --force`, which would drop those keys.
#
# Also safe to run standalone, to activate changes without a container rebuild:
#
#   bash ~/.dotfiles/run_after_wiki_setup.sh
#
# Every step is idempotent, and it always exits 0 — a failure here must not fail
# `chezmoi apply`, which setup.sh runs under `set -e`.

set -uo pipefail

# Codespaces only: /workspaces does not exist on a personal machine, and a
# `chezmoi apply` there must not try to clone a wiki into it.
if [ -z "${CODESPACES:-}" ]; then
  exit 0
fi

# chezmoi extracts scripts to a temp file before running them, so BASH_SOURCE
# does not point at the dotfiles clone. setup.sh symlinks it to ~/.dotfiles; fall
# back to BASH_SOURCE for a standalone run from a checkout without that symlink.
if [ -d "$HOME/.dotfiles" ]; then
  DOTFILES_DIR="$(cd -P "$HOME/.dotfiles" && pwd)"
else
  DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
CLAUDE_SETTINGS=~/.claude/settings.json
WIKI=/workspaces/wiki

mkdir -p ~/.claude
[ -f "$CLAUDE_SETTINGS" ] || echo '{}' > "$CLAUDE_SETTINGS"

# Point a repo's URL-scoped github.com credential helper at exactly one helper.
#
# The key must be URL-scoped: ~/.gitconfig sets
# credential.https://github.com.helper to `gh auth git-credential`, and a
# URL-scoped helper always beats a generic one, so writing plain
# credential.helper here would be silently ignored.
#
# --unset-all before adding, not `config <key> ""`: that form fails with "cannot
# overwrite multiple values" as soon as the key holds more than one value, which
# is exactly the state a previous run leaves behind. This form is idempotent, so
# re-running never accumulates duplicate helpers. The empty first value resets
# the inherited list so the global `gh` helper is not consulted -- it must not be,
# since it hands back the roverdotcom-scoped token, which cannot write a personal
# repo.
set_cred_helper() {
  local repo="$1" helper="$2"
  git -C "$repo" config --unset-all credential.https://github.com.helper 2>/dev/null || true
  git -C "$repo" config --add credential.https://github.com.helper ""
  git -C "$repo" config --add credential.https://github.com.helper "$helper"
}

# The wiki is a separate private repo so it can also be cloned outside this
# codespace; this clone is the codespace-side copy.
#
# Auth needs the WIKI_REPO_TOKEN Codespaces secret (fine-grained PAT on
# nelsonfleig/llm-wiki, Contents: read+write). The codespace's own GITHUB_TOKEN
# cannot reach personal repos — it is scoped to the roverdotcom repos listed in
# web/.devcontainer/devcontainer.json.
echo "Setting up research wiki..."

# The credential helper reads the token from the environment at call time, so the
# PAT is never written to .git/config or ~/.git-credentials.
WIKI_CRED_HELPER='!f() { echo username=x-access-token; echo "password=$WIKI_REPO_TOKEN"; }; f'

if [ -z "${WIKI_REPO_TOKEN:-}" ]; then
  echo "WIKI_REPO_TOKEN not set — skipping wiki setup. Add it at https://github.com/settings/codespaces and restart." >&2
else
  if [ ! -d "$WIKI/.git" ]; then
    git -c credential.https://github.com.helper= \
        -c credential.https://github.com.helper="$WIKI_CRED_HELPER" \
        clone https://github.com/nelsonfleig/llm-wiki "$WIKI" || \
      echo "wiki clone failed — check the PAT's Contents permission." >&2
  fi

  if [ -d "$WIKI/.git" ]; then
    set_cred_helper "$WIKI" "$WIKI_CRED_HELPER"
    timeout 10s git -C "$WIKI" pull --rebase --autostash --quiet || true

    # Skill symlinked out of the wiki repo, so the procedures are versioned with
    # the wiki they operate on.
    mkdir -p ~/.claude/skills
    rm -rf "$HOME/.claude/skills/llm-wiki"
    ln -s "$WIKI/.claude/skills/llm-wiki" "$HOME/.claude/skills/llm-wiki"

    # Load the wiki schema into every session in the web repo only.
    # CLAUDE.local.md is already gitignored by web (.gitignore), so this leaves no
    # diff in the shared repo. The import resolves outside the working directory,
    # so Claude Code asks for approval the first time — accept it once.
    if [ -d /workspaces/web ] && ! grep -q '@/workspaces/wiki/WIKI.md' /workspaces/web/CLAUDE.local.md 2>/dev/null; then
      printf '# Personal\n\n@/workspaces/wiki/WIKI.md\n' >> /workspaces/web/CLAUDE.local.md
    fi

    # SessionStart pulls the wiki and reports its state; Stop commits and pushes
    # any changes. Merged with jq so model/enabledPlugins/marketplaces survive,
    # and filtered first so re-running this script does not duplicate the entries.
    if command -v jq >/dev/null 2>&1; then
      jq '.hooks.SessionStart = ((.hooks.SessionStart // []) | map(select(.hooks[0].command != "/workspaces/wiki/bin/wiki-session-start.sh")) + [{hooks:[{type:"command",command:"/workspaces/wiki/bin/wiki-session-start.sh"}]}])
        | .hooks.Stop = ((.hooks.Stop // []) | map(select(.hooks[0].command != "/workspaces/wiki/bin/wiki-sync.sh")) + [{hooks:[{type:"command",command:"/workspaces/wiki/bin/wiki-sync.sh"}]}])' \
        "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" && mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
    else
      echo "jq not found — wiki hooks not registered in $CLAUDE_SETTINGS." >&2
    fi

    echo "Research wiki ready at $WIKI."
  fi
fi

# Make this dotfiles clone pushable. Codespaces clones it with the codespace's
# own GITHUB_TOKEN, which is scoped to the roverdotcom repos in
# web/.devcontainer/devcontainer.json and cannot write a personal repo, so
# commits here fail to push without a PAT.
echo "Configuring dotfiles push auth..."
DOTFILES_CRED_HELPER='!f() { echo username=x-access-token; echo "password=$DOTFILES_REPO_TOKEN"; }; f'
if [ -z "${DOTFILES_REPO_TOKEN:-}" ]; then
  echo "DOTFILES_REPO_TOKEN not set — dotfiles pushes will fail. Add it at https://github.com/settings/codespaces and restart." >&2
else
  set_cred_helper "$DOTFILES_DIR" "$DOTFILES_CRED_HELPER"
  echo "dotfiles repo ready to push at $DOTFILES_DIR."
fi

exit 0
