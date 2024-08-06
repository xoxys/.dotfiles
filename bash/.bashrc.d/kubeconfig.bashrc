#!/usr/bin/env bash

# Locations
KC_DIR=$HOME/.kube/configs
mkdir -p "$KC_DIR"

TMP_KUBECONFIGS_DIR=$HOME/.kube/configs/.tmp/$$
mkdir -p "$TMP_KUBECONFIGS_DIR"

LAST_KC_FILE=$KC_DIR/last_kubeconfig
SAVED_KC_FILE=$KC_DIR/saved_kubeconfig
touch "$LAST_KC_FILE"
touch "$SAVED_KC_FILE"

# KUBECONFIG
function kc {
  local save_kc=no
  while true ; do
    case $1 in
    "")
      find "$KC_DIR" -type f -name "config.yaml"
      break
      ;;

    --)
      # use last kubeconfig (redo source last one)
      last_kc="$(cat "$LAST_KC_FILE")"
      if [ -z "$last_kc" ] ; then
        >&2 echo "Error: no last kubeconfig path found in file '$LAST_KC_FILE'"
        return 1
      fi

      export KUBECONFIG="$KC_DIR/$last_kc"
      echo "Cluster '$last_kc' activated. KUBECONFIG at $KUBECONFIG"
      break
      ;;

    -)
      # use saved kubeconfig
      saved_kc="$(cat "$SAVED_KC_FILE")"
      if [ -z "$saved_kc" ] ; then
        >&2 echo "Error: no saved kubeconfig path found in file '$SAVED_KC_FILE'"
        return 1
      fi

      export KUBECONFIG="$KC_DIR/$saved_kc"
      echo "Cluster '$saved_kc' activated. KUBECONFIG at $KUBECONFIG"
      break
      ;;

    -s)
      save_kc=yes
      shift
      ;;

    -*)
      echo "Flag does not exits." && return 1
      ;;

    *)
      name="$1"
      # [[ "$name" == *.yaml ]] || name="$name.yaml"

      config="$(find "$KC_DIR/$name" -type f -name "config.yaml" 2>/dev/null)"
      if [ -z "$config" ] ; then
        echo "Error: No kubeconfig exists for env '$name'"
        return 1
      fi

      [ "$save_kc" = yes ] && echo -n "$name" > "$SAVED_KC_FILE"
      echo -n "$config" > "$LAST_KC_FILE"
      export KUBECONFIG="$config"
      echo "Cluster '$name' activated. KUBECONFIG at $KUBECONFIG"
      break;
      ;;
    esac
  done
}

function _kc_completion {
    local cur base_dir
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    base_dir="$HOME/.kube/configs"

    # Find all directories containing config.yaml
    local dirs
    dirs=$(find "$base_dir" -type f -name config.yaml -print0 | xargs -0 dirname | xargs basename -a | sort -u)

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

  if [ -n "$result" ] ; then
    eval "$result"
    echo "KUBECONFIG at $KUBECONFIG"
  fi
}

function _skc {
  local save_kc=no
  local KC_PATH=
  if [ -n "$1" ] ; then
    save_kc=yes
    case "$1" in
      *.yaml | *.yml)
        KC_PATH="$KC_DIR/${1%.*}.yaml"
      ;;
      *)
        KC_PATH="$KC_DIR/$1.yaml"
      ;;
    esac
  else
    [ -d "$TMP_KUBECONFIGS_DIR" ] || mkdir -p "$TMP_KUBECONFIGS_DIR"
    KC_PATH="$(mktemp -p "$TMP_KUBECONFIGS_DIR" kubeconfig_tmp_$$_XXXXX)"
  fi

  local dir
  dir="$(dirname "$KC_PATH")"
  if ! [ -d "$dir" ] ; then
    mkdir -p "$dir"
  fi

  if [ -p /dev/stdin ]; then
    cat > "$KC_PATH"
  else
    pbpaste > "$KC_PATH"
  fi

  # test copied content
  if ! KUBECONFIG=$KC_PATH kubectl config get-clusters > /dev/null ; then
    rm "$KC_PATH"
    return 1
  fi

  if [ $save_kc != yes ] ; then
    echo "export KUBECONFIG=\"$KC_PATH\""
  fi
}

# delete temporary kubeconfigs on shell exit
trap 'rm -rf "$TMP_KUBECONFIGS_DIR"' EXIT
