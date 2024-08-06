#!/usr/bin/env bash
# shellcheck disable=SC1090

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
export HISTCONTROL=ignoreboth

if ! [[ "$PATH" =~ $HOME/.local/bin:$HOME/bin: ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

export GOPATH=$HOME/Devel/golang
PATH=$PATH:$GOPATH/bin:$GOROOT/bin:$HOME/.tfenv/bin

PATH="$PATH:${KREW_ROOT:-$HOME/.krew}/bin"

export PATH

GPG_TTY="$(tty)"
export GPG_TTY

eval "$(direnv hook bash)"
eval "$(starship init bash)"

complete -C $HOME/.local/bin/mc mc
complete -C $HOME/.local/bin/vault vault
complete -C /usr/bin/vault vault
complete -C $HOME/.local/bin/tofu tofu

while IFS= read -r -d '' file; do
  source "$file"
done < <(find -L "$HOME/.bashrc.d" -type f -name \*.bashrc -print0)

alias_completion
