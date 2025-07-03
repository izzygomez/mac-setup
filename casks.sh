#!/bin/zsh

casks_to_install=(
    'alfred'
    'anki'
    'bitwarden'
    'chatgpt'
    'claude'
    'contexts'
    'cursor'
    'discord'
    'firefox'
    'flux-app'
    'github'
    'google-chrome'
    'google-drive'
    'iterm2'
    'keybase'
    'maccy'
    'monero-wallet'
    'mullvad-vpn'
    'musescore'
    'ngrok'
    'notion'
    'raspberry-pi-imager'
    'rectangle'
    'rocket'
    'samsung-magician'
    'slack'
    'sonos'
    'spotify'
    'stats'
    'steam'
    'telegram'
    'tor-browser'
    'transmission'
    'trezor-bridge-app'
    'trezor-suite'
    'visual-studio-code'
    'vlc'
    'vnc-viewer'
    'yubico-yubikey-manager'
    'zoom'
)

# Source local-specific casks if the file exists
if [ -f "$(dirname "$0")/local/local-casks.sh" ]; then
    echo "\n📦 Loading local casks..."
    source "$(dirname "$0")/local/local-casks.sh"
    # Add local casks to the main array
    if [ -n "${local_casks_to_install[*]}" ]; then
        echo "➕ Adding local casks: ${local_casks_to_install[*]}"
        casks_to_install+=("${local_casks_to_install[@]}")
    fi
fi

# Source and process local-specific cask exclusions if the file exists
if [ -f "$(dirname "$0")/local/local-exclude-casks.sh" ]; then
    echo "\n🚫 Loading cask exclusions..."
    source "$(dirname "$0")/local/local-exclude-casks.sh"

    # Filter out excluded casks using array operations
    if [ -n "${local_exclude_casks[*]}" ]; then
        echo "➖ Excluding casks: ${local_exclude_casks[*]}"
        for exclude_cask in "${local_exclude_casks[@]}"; do
            casks_to_install=("${casks_to_install[@]/$exclude_cask/}")
        done
        # Remove empty elements from the array
        casks_to_install=("${casks_to_install[@]/#/}")
    fi
fi
