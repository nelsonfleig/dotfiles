#!/usr/bin/env bash
# This script should mainly be used by GitHub Codespaces owned by Rover.com

# exit on error and print each command
set -euxo pipefail

# ~/.dotfiles ==> directory where this script is located
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[[ -e ~/.dotfiles ]] || ln -s "$DIR" ~/.dotfiles

# download and install chezmoi to ~/.local/bin
# [[ -e ~/.local/bin/chezmoi ]] || BINDIR=~/.local/bin sh -c "$(curl -fsSL get.chezmoi.io)"
# NOTE: We install Chezmoi v2.59 because >= 2.60 requires a Glibc version >= 2.32. We have 2.31 in current Ubuntu image.
curl -LO https://github.com/twpayne/chezmoi/releases/download/v2.59.0/chezmoi_2.59.0_linux_amd64.deb
sudo dpkg -i chezmoi_2.59.0_linux_amd64.deb

# Set default shell to zsh
sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

# Reset OMZ
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    rm -rf $HOME/.oh-my-zsh
    ZSH= sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install Powerlevel10K
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install OMZ Plugins
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zoxide (cd replacement)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# install tpm plugin manager for Tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# Start Zsh to trigger any setup that would run when it's first opened
/usr/bin/chezmoi init --apply $GITHUB_USER
