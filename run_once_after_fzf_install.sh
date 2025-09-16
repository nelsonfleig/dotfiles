#!/bin/bash

if [[ "$(uname)" == "Linux" ]]; then
  # fzf (required by zoxide)
  if [ -d "$HOME/.fzf" ]; then
    rm -rf $HOME/.fzf
  fi
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi
