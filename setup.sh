#!/usr/bin/env bash
# This script should mainly be used by GitHub Codespaces

# exit on error and print each command
set -euxo pipefail

# ~/.dotfiles ==> directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e ~/.dotfiles ]] || ln -s "$DIR" ~/.dotfiles

# download and install chezmoi to ~/.local/bin
[[ -e ~/.local/bin/chezmoi ]] || BINDIR=~/.local/bin sh -c "$(curl -fsSL get.chezmoi.io)"

# Set default shell to zsh
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

# Reset OMZ
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf $HOME/.oh-my-zsh
    ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10K
$(git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k)

# Start Zsh to trigger any setup that would run when it's first opened
~/.local/bin/chezmoi --source ~/.dotfiles init --apply --verbose
