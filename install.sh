#!/usr/bin/env bash

# stow dotfiles
stow -R bash
stow -R config

if [ "$(uname -s)" = "Darwin" ]; then
    stow -R macos
fi

if [ "$(uname -s)" = "Linux" ]; then
    stow -R linux
fi
