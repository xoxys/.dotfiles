#!/usr/bin/env bash
# shellcheck disable=SC1090

#User specific environment
export GOBIN=$HOME/go/bin

PATH="/usr/local/bin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/gnu-tar/libexec/gnubin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"
PATH="$HOMEBREW_PREFIX/opt/gzip/bin:$PATH"
PATH="$GOBIN:$PATH"
PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

if ! [[ "$PATH" =~ $HOME/.local/bin:$HOME/bin: ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export PATH=$PATH

# gardenctl
# shellcheck disable=SC2155
[ -n "$GCTL_SESSION_ID" ] || [ -n "$TERM_SESSION_ID" ] || export GCTL_SESSION_ID=$(uuidgen)

export BASH_SILENCE_DEPRECATION_WARNING=1
export CLICOLOR=1
export HISTCONTROL=ignoreboth
export TENV_AUTO_INSTALL=true

GPG_TTY="$(tty)"
export GPG_TTY

eval "$(direnv hook bash)"
eval "$(starship init bash)"

source <(kubectl completion bash)
source <(gardenctl completion bash)
source <(crane completion bash)
source <(openstack complete)

# User specific aliases and functions
while IFS= read -r -d '' file; do
    source "$file"
done <   <(find -L "$HOME/.bashrc.d" -type f -name \*.bashrc -print0)

alias_completion
