#!/usr/bin/env bash

bw-unlock() {
    local session

    if [[ "$(uname)" == "Darwin" ]]; then
        session=$(security find-generic-password -s "bw_session" -a "$USER" -w 2>/dev/null)
    else
        session=$(secret-tool lookup service bw_session account "$USER" 2>/dev/null)
    fi

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

        if [[ "$(uname)" == "Darwin" ]]; then
            security add-generic-password -s "bw_session" -a "$USER" -w "$session" -U
        else
            echo -n "$session" | secret-tool store --label="Bitwarden Session" service bw_session account "$USER"
        fi
        echo "✅ Bitwarden unlocked. Session stored in keyring."
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
