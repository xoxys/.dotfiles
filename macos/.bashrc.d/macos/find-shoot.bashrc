# shellcheck shell=bash
# Helper function and autocompletion for finding Gardener shoot IDs

find-shoot() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: find-shoot <garden-name> <shoot-name-or-wildcard>" >&2
    return 1
  fi

  if ! gardenctl target --garden "$1" >/dev/null; then
    echo "Error: Failed to target garden '$1'." >&2
    return 1
  fi

  eval "$(gardenctl kubectl-env bash)"

  # Query all shoots and use Bash pattern matching to support wildcards
  kubectl get shoots -A -o custom-columns="NAME:.metadata.name,ID:.status.technicalID" --no-headers |
    while read -r name id; do
      # shellcheck disable=SC2254
      case "$name" in
      $2) echo "$id" ;;
      esac
    done

  # Clean up the exported variable from the eval step
  unset KUBECONFIG
}

_find_shoot_completion() {
  local cur config_file gardens

  cur="${COMP_WORDS[COMP_CWORD]}"
  config_file="$HOME/.garden/gardenctl-v2.yaml"

  if [ "$COMP_CWORD" -eq 1 ] && [ -f "$config_file" ]; then
    gardens=$(awk -F':' '/^[[:space:]]*-[[:space:]]+identity:/ || /^[[:space:]]+name:/ {print $2}' "$config_file" 2>/dev/null | tr -d " \"'")
    mapfile -t COMPREPLY < <(compgen -W "${gardens}" -- "${cur}")
  fi
}

complete -F _find_shoot_completion find-shoot
