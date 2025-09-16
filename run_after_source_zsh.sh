#!/bin/zsh

# Run codespace specific commands here
if [ -n "${CODESPACES}" ]; then
  # install tmux plugins
  ~/.config/tmux/plugins/tpm/bin/install_plugins
  
  # tmux version in Codespace require's the config file to be in $HOME
  cp ~/.config/tmux/tmux.conf ~/.tmux.conf
fi
