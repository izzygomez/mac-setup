#!/bin/zsh

# Usage Instructions
# ./brew_installs.sh
#   - run this script
#
# brew upgrade --cask
#   - upgrade existing casks

# For a full list, see https://formulae.brew.sh/cask/
casks_to_install=(
    'anki'
    'atom'
    'authy'
    'betterdiscord-installer'
    'dropbox'
    'expressvpn'
    'firefox'
    'flux'
    'google-chrome'
    'google-drive'
    'iterm2'
    'keybase'  # delete this? seems to not be working
    'kyokan-bob'
    'lastpass'
    'musescore'
    'rectangle'
    'rescuetime'
    'rocket'
    'spotify'
    'steam'
    'tor-browser'
    'transmission'
    'trezor-bridge'
    'trezor-suite'
    'visual-studio-code'
    'vlc'
)

# TODO figure out what to run to enumerate this list
packages_to_install=(
    'emacs'
    'ffmpeg'
    'git'
    'gh'
    'htop'
    'imagemagick'
    'libusb'
    'mosh'
    'source-highlight'
    'tmux'
    'wget'
    'zsh-syntax-highlighting'
)

# TODO document this
echo 'Installing Homebrew casks...\n'
for cask in ${casks_to_install[@]}; do
    echo 'running: brew install --cask' $cask '\n'
    brew install --cask $cask
    # echo '..where the magic *would* happen..'
    echo '\ndone!\n'
done

# TODO document this
# note: still need to figure out how to download python & ruby
echo '================================================================================'
echo '================================================================================'
echo 'Installing Homebrew packages...\n'
for package in ${packages_to_install[@]}; do
    echo 'running: brew install' $package '\n'
    brew install $package
    # echo '..where the magic *would* happen..'
    echo '\ndone!\n'
done

echo '================================================================================'
echo '================================================================================'

echo 'TODO write out message indicating there might be post-install steps based on output above.'
