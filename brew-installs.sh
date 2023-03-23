#!/bin/zsh

# ZSH scripting manual: https://zsh.sourceforge.io/Doc/Release/

################################################################################
# Usage Instructions
################################################################################
#
# Run this script:
# `./brew-installs.sh`
#
#
################################################################################
# Other useful commands
################################################################################
#
# See https://docs.brew.sh/Manpage for full documentation on Homebrew commands.
#
# To enumerate list of packages (with descriptions) that have been installed,
# run the following command (https://apple.stackexchange.com/a/154750):
#
# `brew leaves --installed-on-request | xargs -n1 brew desc --eval-all`
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
    'go'
    'grep'
    'htop'
    'imagemagick'
    'libusb'
    'mosh'
    'node'
    'nvm'
    'poetry'
    'pre-commit'
    'pyenv'
    'ruby-install' # from https://jekyllrb.com/docs/installation/macos/
    'solidity'
    'source-highlight'
    'thefuck'
    'tmux'
    'tree'
    'wget'
    'yarn'
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
)

PURPLE="\033[95m"
CYAN="\033[96m"
DARKCYAN="\033[36m"
BLUE="\033[94m"
GREEN="\033[92m"
YELLOW="\033[93m"
RED="\033[91m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
END="\033[0m"

### Check that Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo $RED"Homebrew is not installed, see https://brew.sh/"$END
    exit 1
fi

echo -n $GREEN
echo '
             ___   ___   ____  _
            | |_) | |_) | |_  \ \    /
            |_|_) |_| \ |_|__  \_\/\/
     _   _      __  _____   __    _     _     __
    | | | |\ | ( (`  | |   / /\  | |   | |   ( (`
    |_| |_| \| _)_)  |_|  /_/--\ |_|__ |_|__ _)_)

'
echo -n $END

### Prompt user for actions to take
echo -n $BOLD'\t'
if read -rqs "update_homebrew?Update Homebrew? [y/N]: "; then
    echo $END$GREEN$update_homebrew$END
else
    echo $END$RED$update_homebrew$END
fi
echo -n $BOLD'\t'
if read -qs "upgrade_packages?Upgrade casks & packages? [y/N]: "; then
    echo $END$GREEN$upgrade_packages$END
else
    echo $END$RED$upgrade_packages$END
fi
echo -n $BOLD'\t'
if read -qs "install_casks?Install casks? [y/N]: "; then
    echo $END$GREEN$install_casks$END
else
    echo $END$RED$install_casks$END
fi
echo -n $BOLD'\t'
if read -qs "install_packages?Install packages? [y/N]: "; then
    echo $END$GREEN$install_packages$END
else
    echo $END$RED$install_packages$END
fi
echo -n $BOLD'\t'
if read -rqs "cleanup_homebrew?Cleanup Homebrew? [y/N]: "; then
    echo $END$GREEN$cleanup_homebrew$END
else
    echo $END$RED$cleanup_homebrew$END
fi


if [[ $update_homebrew != y && $upgrade_packages != y && $install_casks != y && $install_packages != y && $cleanup_homebrew != y ]]
then
    echo '\n\t✨ Did nothing ✨'
    exit 0
fi

LINE_SEPARATOR=$BOLD'\n--------------------------------------------------------------------------------\n'$END

### Update Homebrew
if [[ $update_homebrew = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Updating Homebrew...\n'$END
    echo $BOLD'\trunning '$PURPLE'brew update\n'$END
    brew update
fi

### Upgrade packages
if [[ $upgrade_packages = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Listing packages in need of upgrading...\n'$END
    echo $BOLD'\trunning '$PURPLE'brew outdated\n'$END
    brew outdated

    echo $GREEN$BOLD$UNDERLINE'Upgrading packages...\n'$END
    echo $BOLD'\trunning '$PURPLE'brew upgrade\n'$END
    brew upgrade
fi

### Install casks
# TODO document these sections some more, e.g. still need to figure out how
# to download python/ruby/etc & install correctly/not-manually
cask=""
casks_already_installed=()
casks_installed=()
install_cask() {
    if brew list --cask $cask &> /dev/null; then
        casks_already_installed+=( $cask )
    else
	echo $BOLD'\trunning '$PURPLE'brew install --cask '$cask'\n'$END
	brew install --cask $cask
	echo -n '\n'
	casks_installed+=( $cask )
    fi
}
if [[ $install_casks = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Installing Homebrew casks...\n'$END
    for c in ${casks_to_install[@]}; do
	cask=$c
	install_cask
    done

    echo $BOLD'Already installed casks: '$END${casks_already_installed[*]}'\n'
    echo $BOLD'Newly installed casks: '$END${casks_installed[*]}
fi

### Install packages
package=""
packages_already_installed=()
packages_installed=()
install_package() {
    if brew list $package &> /dev/null; then
	packages_already_installed+=( $package )
    else
	echo $BOLD'\trunning '$PURPLE'brew install '$package'\n'$END
	brew install $package
	echo -n '\n'
	packages_installed+=( $package )
    fi
}
if [[ $install_packages = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Installing Homebrew packages...\n'$END
    for p in ${packages_to_install[@]}; do
	package=$p
	install_package
    done

    echo $BOLD'Already installed packages: '$END${packages_already_installed[*]}'\n'
    echo $BOLD'Newly installed packages: '$END${packages_installed[*]}
fi

### Cleanup Homebrew (see https://docs.brew.sh/Manpage)
if [[ $cleanup_homebrew = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Cleaning up Homebrew...\n'$END

    echo $BOLD'\trunning '$PURPLE'brew autoremove\n'$END
    brew autoremove

    echo $BOLD'\n\trunning '$PURPLE'brew cleanup --prune=all -s\n'$END
    brew cleanup --prune=all -s
fi

### Post-install messsage
if [[ $install_casks = y || $install_packages = y ]]; then
    echo $LINE_SEPARATOR
    echo $GREEN$BOLD$UNDERLINE'Installed casks and/or packages:\n\n'$END$BOLD'Scroll up & read console output since there might be post-install steps.'$END
fi

exit 0
