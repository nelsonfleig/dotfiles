#!/bin/zsh

# Run codespace specific commands here
if [ -n "${CODESPACES}" ]; then
  # git config --global user.email "nelson.fleig@rover.com"

  # change default shell to zsh
  sudo chsh "$(id -un)" --shell "/usr/bin/zsh"
fi

source ~/.zshrc
tmux source-file ~/.config/tmux/tmux.conf

