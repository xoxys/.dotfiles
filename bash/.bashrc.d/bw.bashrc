#!/usr/bin/env bash
# shellcheck disable=SC1090

_bw_found=0
for _bw_path in \
    "${BASH_SOURCE[0]%/*}/bw-common.bashrc" \
    "$HOME/.bashrc.d/bw-common.bashrc" \
    "$HOME/.dotfiles/bash/.bashrc.d/bw-common.bashrc"; do
    if [[ -f "$_bw_path" ]]; then
        source "$_bw_path"
        _bw_found=1
        break
    fi
done
unset _bw_path
if [[ "$_bw_found" -eq 0 ]]; then
    echo "bw-common.bashrc not found" >&2
fi
unset _bw_found

bw-unlock() {
    _bw_check_deps || return 1
    local session
    session=$(_bw_get_session)

    if [ -n "$session" ] && BW_SESSION="$session" bw unlock --check &>/dev/null; then
        echo "✅ Bitwarden is already unlocked."
        export BW_SESSION="$session"
    else
        echo "🔒 Vault is locked. Please enter your master password:"
        session=$(bw unlock --raw)

        if [ -z "$session" ]; then
            echo "❌ Failed to unlock Bitwarden."
            return 1
        fi

        if _bw_store_session "$session"; then
            echo "✅ Bitwarden unlocked. Session stored in keyring."
        else
            echo "⚠️ Bitwarden unlocked, but could not store session in keyring." >&2
        fi
        export BW_SESSION="$session"
    fi

    echo "🔄 Syncing latest secrets from Vaultwarden..."
    if bw sync >/dev/null 2>&1; then
        echo "✅ Vault synced successfully."
    else
        echo "⚠️ Sync failed (Offline?). Using local cache."
    fi

    command -v direnv &> /dev/null && direnv reload
}
