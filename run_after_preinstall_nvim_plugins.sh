#!/bin/bash

# Alias `v` to my own Neovim config in headless mode
v() {
  nvim --headless "$@" +qa

  # If you want to preinstall on a different nvim config
  # NVIM_APPNAME=nvim-nelson nvim --headless "$@" +qa
}


preinstall_neovim_plugins() {
  # Install plugins and parsers in headless mode
  NVIM_APPNAME=nvim-nelson nvim --headless "+Lazy! sync" -c "TSUpdate" +qa
  # Commented while testing the above command 
  # v "+Lazy! sync"
}

run_on_remote_only() {
  if [ -n "${CODESPACES:-}" ] || [ -n "${CODER_WORKSPACE_OWNER_NAME:-}" ]; then
    preinstall_neovim_plugins
  fi
}

run_on_remote_only
