#!/bin/zsh

# Run codespace and Coder specific commands here
if [ -n "${CODESPACES:-}" ] || [ -n "${CODER_WORKSPACE_OWNER_NAME:-}" ]; then
  # install tmux plugins
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi
