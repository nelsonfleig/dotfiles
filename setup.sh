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
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# Install OMZ Plugins
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Start Zsh to trigger any setup that would run when it's first opened
~/.local/bin/chezmoi --source ~/.dotfiles init --apply

# zoxide (cd replacement)
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# fzf (required by zoxide)
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

# Source .zshrc
source ~/.zshrc

# Lunarvim install functions
install_lunarvim() {
  if [ ! -d "$HOME/.local/share/lunarvim/lvim" ]; then
    yes | LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
  fi
}

maintain_lunarvim_plugins ()
{
  lvim=$HOME/.local/bin/lvim
  $lvim --headless "+Lazy! sync" +qa

  # Plugins
  $lvim --headless "+Lazy! sync" +qa

  # Parsers
  # This is done automatically, but this way it will be done before LunarVim is opened
  # Mostly relevant in Codespaces as it will speed up the initial experience
  $lvim --headless "+TSUpdateSync comment" +qa
  $lvim --headless "+TSUpdateSync regex" +qa
  $lvim --headless "+TSUpdateSync markdown_inline" +qa
  $lvim --headless "+TSUpdateSync python" +qa
  $lvim --headless "+TSUpdateSync tsx" +qa
  $lvim --headless "+TSUpdateSync javascript" +qa
  $lvim --headless "+TSUpdateSync typescript" +qa
  $lvim --headless "+TSUpdateSync json" +qa
  $lvim --headless "+TSUpdateSync bash" +qa
}

install_lunarvim
maintain_lunarvim_plugins