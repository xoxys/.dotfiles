# .bash_profile
export PATH="/opt/homebrew/bin:$PATH"
eval "$($(brew --prefix)/bin/brew shellenv)"

[[ -r "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh" ]] && . "$HOMEBREW_PREFIX/etc/profile.d/bash_completion.sh"

# Get the aliases and functions
[ -f ~/.bashrc ] && . ~/.bashrc

# User specific environment and startup programs
