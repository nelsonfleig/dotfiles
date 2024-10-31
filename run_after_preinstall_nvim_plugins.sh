#!/bin/bash

# Alias `v` to my own Neovim config in headless mode
v() {
  NVIM_APPNAME=nvim-nelson nvim --headless "$@" +qa
}


preinstall_neovim_plugins() {
  # Plugins
  v "+Lazy! sync"

  # Parsers
  # This is done automatically, but this way it will be done before Neovim (my config) is opened
  # Mostly relevant in Codespaces as it will speed up the initial experience
  v "+TSUpdateSync comment"
  v "+TSUpdateSync regex"
  v "+TSUpdateSync markdown_inline"
  v "+TSUpdateSync python"
  v "+TSUpdateSync tsx"
  v "+TSUpdateSync javascript"
  v "+TSUpdateSync typescript"
  v "+TSUpdateSync json"
  v "+TSUpdateSync bash"

  # LSPs
  v "+MasonInstall typescript-language-server pyright flake8"
}

run_on_codespaces_only() {
  if [ -n "${CODESPACES}" ]; then
    preinstall_neovim_plugins
  fi
}

run_on_codespaces_only
