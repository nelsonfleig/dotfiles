#!/bin/zsh

# Run codespace specific commands here
if [ -n "${CODESPACES}" ]; then
  # install tmux plugins
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi
