#!/bin/zsh

################################################################################
# Usage Instructions
################################################################################
#
# Run this script:
# `./brew_installs.sh`
#
# Upgrade existing packages (already run by this script):
# `brew upgrade`
#
# Upgrade existing casks:
# `brew upgrade --cask`
#
################################################################################
# Other useful commands
################################################################################
#
# To enumerate list of packages (with descriptions) that have been installed,
# run the following command (https://apple.stackexchange.com/a/154750):
#
# `brew leaves --installed-on-request | xargs -n1 brew desc`
#
# List all brew formula:
# `brew list --formula`
#
# List all brew casks:
# `brew list --cask`
#
# To remove all formula installed by Homebrew, run the following command:
# `brew remove --force $(brew list --formula)`
# This could be useful for "resetting" a setup by removing packages &
# re-installing them immediately after by running this script. (see
# https://apple.stackexchange.com/a/339096)
#
################################################################################

# TODO consider adding colors to my `echo` commands

echo 'First, updating & upgrading Homebrew...\n'
# updates brew
echo 'running: brew update\n'
brew update
# list packages in need of upgrading
echo 'running: brew outdated\n'
brew outdated
# upgrade packages
echo 'running: brew upgrade\n'
brew upgrade

# For a full list, see https://formulae.brew.sh/cask/
casks_to_install=(
    'alfred'
    'anki'
    'atom'
    'authy'
    'beardedspice' # https://beardedspice.github.io/
    'beekeeper-studio'
    'contexts'
    'discord'
    'dropbox'
    'expressvpn'
    'firefox'
    'flux'
    'freedom'
    'google-chrome'
    'google-drive'
    'iterm2'
    'kyokan-bob'
    'lastpass'
    'musescore'
    'rectangle'
    'rescuetime'
    'rocket'
    'slack'
    'spotify'
    'steam'
    'telegram'
    'tor-browser'
    'transmission'
    'trezor-bridge'
    'trezor-suite'
    'visual-studio-code'
    'vlc'
)

packages_to_install=(
    'chruby' # from https://jekyllrb.com/docs/installation/macos/
    'emacs'
    'ffmpeg'
    'gh'
    'git'
    'grep'
    'htop'
    'imagemagick'
    'libusb'
    'mosh'
    'pre-commit'
    'ruby-install' # from https://jekyllrb.com/docs/installation/macos/
    'source-highlight'
    'thefuck'
    'tmux'
    'tree'
    'wget'
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
    # TODO put this into own branch; consider moving into seperate package list?
    #########################################
    # Izzy's Yuzu MBP User Configuration
    #########################################
    'nvm'
    'skeema/tap/skeema'
    'solidity'
    'sqlc'
    'yarn'

)

# TODO document these sections some more, e.g. still need to figure out how
# to download python/ruby/etc & install correctly/not-manually
echo '================================================================================'
echo '================================================================================'
echo 'Installing Homebrew casks...\n'
for cask in ${casks_to_install[@]}; do
    echo 'running: brew install --cask' $cask '\n'
    brew install --cask $cask
    echo '\ndone!\n'
done

echo '================================================================================'
echo '================================================================================'
echo 'Installing Homebrew packages...\n'
for package in ${packages_to_install[@]}; do
    echo 'running: brew install' $package '\n'
    brew install $package
    echo '\ndone!\n'
done

echo '================================================================================'
echo '================================================================================'

echo 'Scroll up & read output above, as there might be post-install steps'
