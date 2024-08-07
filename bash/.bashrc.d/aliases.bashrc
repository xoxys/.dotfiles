#!/usr/bin/env bash
# shellcheck disable=SC1090

## os
alias ls='ls -Gh --color=auto'
alias ll='ls -l'
alias la='ls -la'

## kubectl
alias k='kubectl'
alias kd='k -n default'
alias ks='k -n kube-system'
alias kf='k -n flux-system'
alias km='k -n monitoring'
alias pkc='echo $KUBECONFIG'
alias ukc='unset KUBECONFIG'
alias catkc='cat ${KUBECONFIG:-$HOME/.kube/config}'
source <(kubectl completion bash)
complete -F __start_kubectl k
