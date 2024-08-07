#!/usr/bin/env bash
# shellcheck disable=SC1090

export PATH="/opt/homebrew/bin:$PATH"
eval "$("$(brew --prefix)"/bin/brew shellenv)"

# shellcheck disable=SC1091
if [[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
  source "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"
fi

# Get the aliases and functions
if [ -f "$HOME/.bashrc" ]; then
  # shellcheck disable=SC1091
  source "$HOME/.bashrc"
fi
# User specific environment and startup programs
