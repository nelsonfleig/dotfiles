#!/usr/bin/env bash
# This script should mainly be used by GitHub Codespaces owned by Rover.com

# exit on error and print each command
set -euxo pipefail

# ~/.dotfiles ==> directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e ~/.dotfiles ]] || ln -s "$DIR" ~/.dotfiles

# Fetch the latest release tag for a GitHub repo. Authenticated when a token is
# present: the anonymous API allows 60 requests/hour/IP, and an empty result here
# would make the download below save a 404 body and abort the whole setup under
# `set -e` -- before chezmoi has applied anything.
latest_release() {
  local repo="$1" tag auth=()
  [[ -n "${GITHUB_TOKEN:-}" ]] && auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
  tag=$(curl -s "${auth[@]}" "https://api.github.com/repos/${repo}/releases/latest" |
    \grep -Po '"tag_name": *"v?\K[^"]*' || true)
  [[ -n "$tag" ]] || { echo "could not resolve latest release for $repo" >&2; return 1; }
  echo "$tag"
}

# download and install chezmoi to ~/.local/bin
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin

# Set default shell to zsh
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

# Reset OMZ
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf $HOME/.oh-my-zsh
    ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Clone a git repo only when its target directory is absent, so re-running this
# script does not abort on "destination path already exists" under `set -e`.
clone_once() {
  local url="$1" dest="$2"
  shift 2
  [ -d "$dest" ] || git clone "$@" "$url" "$dest"
}

# Install Powerlevel10K
clone_once https://github.com/romkatv/powerlevel10k.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" --depth=1

# Install OMZ Plugins
# zsh-autosuggestions
clone_once https://github.com/zsh-users/zsh-autosuggestions \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
# zsh-syntax-highlighting
clone_once https://github.com/zsh-users/zsh-syntax-highlighting.git \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# zoxide (cd replacement)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# install tpm plugin manager for Tmux
clone_once https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Downloads land in a temp dir rather than the repo root, which used to leave
# lazygit/tree-sitter build artifacts sitting untracked in the dotfiles clone.
BUILD_DIR="$(mktemp -d)"
trap 'rm -rf "$BUILD_DIR"' EXIT

# install lazygit
LAZYGIT_VERSION="$(latest_release jesseduffield/lazygit)"
curl -fLo "$BUILD_DIR/lazygit.tar.gz" "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf "$BUILD_DIR/lazygit.tar.gz" -C "$BUILD_DIR" lazygit
sudo install "$BUILD_DIR/lazygit" -D -t /usr/local/bin/

# Install tree-sitter-cli (pre-built binary, required by Neovim tree-sitter)
TS_VERSION="$(latest_release tree-sitter/tree-sitter)"
curl -fLo "$BUILD_DIR/tree-sitter.gz" "https://github.com/tree-sitter/tree-sitter/releases/download/v${TS_VERSION}/tree-sitter-linux-x64.gz"
gunzip "$BUILD_DIR/tree-sitter.gz"
chmod +x "$BUILD_DIR/tree-sitter"
sudo install "$BUILD_DIR/tree-sitter" /usr/local/bin/

# Install LSP servers for Claude Code
npm i -g pyright
npm i -g typescript-language-server typescript

# Apply the dotfiles. This also runs the run_after_* hooks, one of which sets up
# the personal research wiki -- see run_after_wiki_setup.sh.
$HOME/.local/bin/chezmoi init --apply $GITHUB_USER
