#!/usr/bin/env bash

# Locations
KC_DIR=$HOME/.kube/configs
mkdir -p "$KC_DIR"

TMP_KUBECONFIGS_DIR=$HOME/.kube/configs/.tmp/$$
mkdir -p "$TMP_KUBECONFIGS_DIR"

LAST_KC_FILE=$KC_DIR/last_kubeconfig
touch "$LAST_KC_FILE"

# KUBECONFIG
function kc {
  while true; do
    case $1 in
    "")
      find "$KC_DIR" -type f -name "config.yaml"
      break
      ;;

    --)
      # use last kubeconfig (redo source last one)
      last_kc="$(cat "$LAST_KC_FILE")"
      if [ -z "$last_kc" ]; then
        echo >&2 "Error: no last kubeconfig path found in file '$LAST_KC_FILE'"
        return 1
      fi

      if ! config="$(_kc_find "$last_kc")"; then
        echo "$config"
        return 1
      fi

      export KUBECONFIG="$config"
      printf "Cluster '%s' activated\nKUBECONFIG at %s\n" "$last_kc" "$KUBECONFIG"
      break
      ;;

    -*)
      echo "Flag does not exits." && return 1
      ;;

    *)
      name="$1"
      # [[ "$name" == *.yaml ]] || name="$name.yaml"

      if ! config="$(_kc_find "$1")"; then
        echo "$config"
        return 1
      fi

      echo -n "$name" >"$LAST_KC_FILE"
      export KUBECONFIG="$config"

      printf "Cluster '%s' activated\nKUBECONFIG at %s\n" "$name" "$KUBECONFIG"
      break
      ;;
    esac
  done
}

function _kc_find {
  config="$(find "$KC_DIR/$1" -type f -name "config.yaml" 2>/dev/null)"
  if [ -z "$config" ]; then
    echo "Error: No kubeconfig exists for env '$1'"
    return 1
  fi

  echo "$config"
}

function _kc_completion {
  local cur
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"

  # Find all directories containing config.yaml
  local dirs
  dirs=$(find "$HOME/.kube/configs" -type f -name config.yaml -print0 | xargs -0 -r dirname | xargs -r basename -a | sort -u)

  # Generate completions
  mapfile -t COMPREPLY < <(compgen -W "$dirs" -- "$cur")
}

# completion for kc
complete -F _kc_completion kc

# clone active kubeconfig or use one via 'kc'
# just read the current kubeconfig and paste it to a temporary one
function ckc {
  local result

  [ -z "$1" ] || kc "$1"

  # shellcheck disable=SC2002
  if [ -s "$KUBECONFIG" ]; then
    result="$(cat "$KUBECONFIG" | _skc)"
  else
    echo "Error: KUBECONFIG is empty or does not exist" >&2
    return 1
  fi

  if [ -n "$result" ]; then
    eval "$result"
    echo "KUBECONFIG at $KUBECONFIG"
  fi
}

# completion for ckc
complete -F _kc_completion ckc

# source/save kubeconfig (either passed via stdin or pasteboard)
# if $1 is empty, copy kubeconfig to temp dir under $KC_DIR
# if $1 is set, save kubeconfig under $KC_DIR/$1[.yaml]
function skc {
  local result
  result="$(_skc "$1")"

  if [ -n "$result" ]; then
    eval "$result"
    echo "KUBECONFIG at $KUBECONFIG"
  fi
}

function _skc {
  local save_kc=no
  local KC_PATH
  if [ -n "$1" ]; then
    save_kc=yes
    case "$1" in
    *.yaml | *.yml)
      KC_PATH="${1%.*}.yaml"
      ;;
    *)
      KC_PATH="$1.yaml"
      ;;
    esac
  else
    [ -d "$TMP_KUBECONFIGS_DIR" ] || mkdir -p "$TMP_KUBECONFIGS_DIR"
    KC_PATH="$(mktemp -p "$TMP_KUBECONFIGS_DIR" kubeconfig_tmp_$$_XXXXX)"
  fi

  local dir
  dir="$(dirname "$KC_PATH")"
  if ! [ -d "$dir" ]; then
    mkdir -p "$dir"
  fi

  if [ -p /dev/stdin ]; then
    cat >"$KC_PATH"
  else
    if [ "$(uname -s)" = "Darwin" ]; then
      pbpaste >"$KC_PATH"
    elif [ "$(uname -s)" = "Linux" ]; then
      wl-paste >"$KC_PATH"
    else
      echo "Unsupported operating system"
      return 1
    fi
  fi

  # test copied content
  if ! KUBECONFIG=$KC_PATH kubectl config get-clusters >/dev/null; then
    rm "$KC_PATH"
    return 1
  fi

  if [ $save_kc != yes ]; then
    echo "export KUBECONFIG=\"$KC_PATH\""
  fi
}

# delete temporary kubeconfigs on shell exit
trap 'rm -rf "$TMP_KUBECONFIGS_DIR"' EXIT
