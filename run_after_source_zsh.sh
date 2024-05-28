#!/bin/zsh

source ~/.zshrc

if [ -n "${CODESPACES}" ]; then
  git config --global user.email "nelson.fleig@rover.com"
  ([ -f ~/.bash_aliases ] && cd .. && source ~/.bash_aliases)
fi


