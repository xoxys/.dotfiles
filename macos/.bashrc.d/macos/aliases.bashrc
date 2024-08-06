#!/usr/bin/env bash

## gardenctl
alias gn=gardenctl
alias gntv='gardenctl target view -o yaml'
alias gntc='gardenctl target control-plane'
alias gntc-='gardenctl target unset control-plane'
alias gnk='eval "$(gardenctl kubectl-env bash)"'
alias gnp='eval "$(gardenctl provider-env bash)"'
complete -o default -F __start_gardenctl gn

## openstack
alias o="openstack"
alias os="o server"
alias oss="os show"
alias ov="o volume --os-volume-api-version 3.50"
alias ovs="ov show"
alias ova="ov attachment"
alias oval="ova list"
complete -o default -F _openstack o
