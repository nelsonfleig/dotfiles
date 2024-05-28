#!/bin/zsh

if [ -n "${CODESPACES}" ]; then
  git config --global user.email "nelson.fleig@rover.com"
  [ -f ~/.bash_aliases ] && source ~/.bash_aliases
fi

source ~/.zshrc
