#!/bin/zsh

# Run codespace specific commands here
if [ -n "${CODESPACES}" ]; then
  # git config --global user.email "nelson.fleig@rover.com"

  # change default shell to zsh
  sudo chsh "$(id -un)" --shell "/usr/bin/zsh"

  # copy tmux conf to $HOME to work with Codespace tmux version
  cp ~/.config/tmux/tmux.conf ~/.tmux.conf
fi

source ~/.zshrc
