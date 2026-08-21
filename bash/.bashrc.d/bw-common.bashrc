#!/usr/bin/env bash

_bw_get_session() {
    if [[ "$(uname)" == "Darwin" ]]; then
        security find-generic-password -s "bw_session" -a "$USER" -w 2>/dev/null
    else
        secret-tool lookup service bw_session account "$USER" 2>/dev/null
    fi
}

_bw_store_session() {
    local session="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        security add-generic-password -s "bw_session" -a "$USER" -w "$session" -U
    else
        echo -n "$session" | secret-tool store --label="Bitwarden Session" service bw_session account "$USER"
    fi
}

_bw_check_deps() {
    local missing=()
    command -v bw &>/dev/null || missing+=(bw)
    command -v jq &>/dev/null || missing+=(jq)
    if [[ "$(uname)" != "Darwin" ]]; then
        command -v secret-tool &>/dev/null || missing+=(secret-tool)
    fi
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing required commands: ${missing[*]}" >&2
        return 1
    fi
}
