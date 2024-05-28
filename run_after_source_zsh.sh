#!/bin/zsh

source ~/.zshrc

if [ -n "${CODESPACES}" ]; then
  git config --global user.email "nelson.fleig@rover.com"
  ([ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases")
fi


