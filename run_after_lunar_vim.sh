#!/bin/bash

# Lunarvim install functions
install_lunarvim()
{
  if [ ! -d "$HOME/.local/share/lunarvim/lvim" ]; then
    yes | LV_BRANCH='release-1.4/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.4/neovim-0.9/utils/installer/install.sh)
  fi
}

maintain_lunarvim_plugins()
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
  $lvim --headless "+MasonInstall pyright flake8" +qa
}

run_on_linux_only() {
  if [[ "$(uname)" == "Linux" ]]; then
    install_lunarvim
    maintain_lunarvim_plugins
  fi
}

run_on_linux_only
