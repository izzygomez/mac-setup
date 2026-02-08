#!/bin/zsh

MAC_SETUP_DIR="${0:A:h}"
source "$MAC_SETUP_DIR/utils/style.sh"

casks_to_install=(
    'alfred'
    'anki'
    'bitwarden'
    'chatgpt'
    'claude'
    'claude-code'
    'contexts'
    'cursor'
    'discord'
    'docker-desktop'
    'firefox'
    'flux-app'
    'github'
    'google-chrome'
    'google-drive'
    'iterm2'
    'karabiner-elements'
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
    'steam'
    'telegram'
    'tor-browser'
    'transmission'
    'trezor-bridge-app'
    'trezor-suite'
    'vanilla'
    'visual-studio-code'
    'vlc'
    'vnc-viewer'
    'yubico-authenticator' # replaced now-deprecated 'yubico-yubikey-manager'
    'zoom'
)

# Source local-specific casks if the file exists
if [ -f "$MAC_SETUP_DIR/local/local-casks.sh" ]; then
    echo
    echo $BOLD"Loading local casks..."$END
    source "$MAC_SETUP_DIR/local/local-casks.sh"
    # Add local casks to the main array
    if [ -n "${local_casks_to_install[*]}" ]; then
        casks_to_install+=("${local_casks_to_install[@]}")
        echo $ICON_CHECK$BOLD" Added local casks: "$END$DIM${local_casks_to_install[*]}$END
    else
        echo $ICON_ERROR$BOLD$RED" \`local_casks_to_install\` is empty or not set"$END
    fi
fi

# Source and process local-specific cask exclusions if the file exists
if [ -f "$MAC_SETUP_DIR/local/local-exclude-casks.sh" ]; then
    echo
    echo $BOLD"Loading local cask exclusions..."$END
    source "$MAC_SETUP_DIR/local/local-exclude-casks.sh"

    # Filter out excluded casks using array operations
    if [ -n "${local_exclude_casks[*]}" ]; then
        for exclude_cask in "${local_exclude_casks[@]}"; do
            casks_to_install=("${casks_to_install[@]/$exclude_cask/}")
        done
        # Remove empty elements from the array
        casks_to_install=("${casks_to_install[@]/#/}")
        echo $ICON_CHECK$BOLD" Excluded local casks: "$END$DIM${local_exclude_casks[*]}$END
    else
        echo $ICON_ERROR$BOLD$RED" \`local_exclude_casks\` is empty or not set"$END
    fi
fi

echo
echo $BOLD"Final cask list: "$END$DIM${casks_to_install[*]}$END
