#!/bin/bash

# Alias `v` to my own Neovim config in headless mode
v() {
  NVIM_APPNAME=nvim-nelson nvim
  # If you want to preinstall on a different nvim config
  # NVIM_APPNAME=nvim-nelson nvim --headless "$@" +qa
}


preinstall_neovim_plugins() {
  # Install plugins and parsers in headless mode
  v --headless "+Lazy! sync" -c "TSUpdateSync" +qa
  # Commented while testing the above command 
  # v "+Lazy! sync"
}

run_on_codespaces_only() {
  if [ -n "${CODESPACES}" ]; then
    preinstall_neovim_plugins
  fi
}

run_on_codespaces_only
