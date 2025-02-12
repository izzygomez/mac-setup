#!/bin/zsh

################################################################################
# Usage Instructions
################################################################################
#
# Run this script:
# `./brew-installs.sh`
#
################################################################################
# Other useful commands
################################################################################
#
# See https://docs.brew.sh/Manpage for full documentation on Homebrew commands.
#
# See https://zsh.sourceforge.io/Doc/Release for a ZSH scripting manual.
#
# To enumerate list of packages (with descriptions) that have been installed,
# run the following command (https://apple.stackexchange.com/a/154750):
# `brew leaves --installed-on-request | xargs -n1 brew desc --eval-all`
#
# List all brew formulae:
# `brew list --formulae`
#
# List all brew casks:
# `brew list --cask`
#
# To remove all formulae & casks installed by Homebrew, run the following
# commands:
# `brew remove --force $(brew list --formulae)`
# `brew remove --cask --force $(brew list --cask)`
# This could be useful for "resetting" a setup  & re-installing them immediately
# after by running this script. (see https://apple.stackexchange.com/a/339096)
#
################################################################################

# Import casks & packages
source ./casks.sh
source ./packages.sh

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
if ! command -v brew &>/dev/null; then
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
echo 'This script can update Homebrew, upgrade existing casks'
echo '& packages, install new casks & packages, check installed'
echo 'casks & packages lists, & cleanup Homebrew.\n'

# Display menu options
echo "Select an action to perform (default = 0):"$BOLD

echo "1) Do everything"
echo "2) Update Homebrew"
echo "3) Upgrade all casks & packages"
echo "4) Install casks & packages"
echo "5) Check installed casks & packages"
echo "6) Cleanup Homebrew"
echo "0) Exit"
echo -n "\nEnter your choice: "$END

read -s -k 1 choice # -s: silent mode, -k 1: read only one character
# If Enter is pressed, `choice` is a newline/empty string, so we default to "0"
if [[ -z "$choice" || "$choice" == $'\n' ]]; then
    choice="0"
fi
# Print the choice to stdout. Necessary bc of -s flag on read, but explicitly
# don't want to echo back characters until after checking that it's not a
# newline to keep consistent prompt formatting.
echo $choice

case $choice in
    1) echo "\nDoing everything..."; update_homebrew=y; upgrade_everything=y; install_casks=y; check_casks=y; install_packages=y; check_packages=y; cleanup_homebrew=y;;
    2) update_homebrew=y;;
    3) upgrade_everything=y;;
    4) install_casks=y; install_packages=y;;
    5) check_casks=y; check_packages=y;;
    6) cleanup_homebrew=y;;
    0) echo "\n✨ Did nothing ✨"; exit 0;;
    *) echo "\nInvalid choice. Exiting.\n✨ Did nothing ✨"; exit 1;;
esac

LINE_SEPARATOR=$BOLD'\n--------------------------------------------------------------------------------\n'$END

### Update Homebrew
if [[ $update_homebrew = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Updating Homebrew...\n'$END
    echo $BOLD'\trunning '$PURPLE'brew update\n'$END
    brew update
fi

### Upgrade everything
if [[ $upgrade_everything = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Listing casks & packages in need of upgrading...\n'$END
    echo $BOLD'\trunning '$PURPLE'brew outdated\n'$END
    brew outdated

    echo $GREEN$BOLD$UNDERLINE'\nUpgrading outdated casks & packages...\n'$END
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
    # Doing this because `brew list --cask` is too slow.
    if [[ -d "$(brew --caskroom)/$cask" ]]; then
        casks_already_installed+=($cask)
    else
        echo $BOLD'\trunning '$PURPLE'brew install --cask '$cask'\n'$END
        brew install --cask $cask
        echo -n '\n'
        casks_installed+=($cask)
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
    if [[ $#casks_installed = 0 ]]; then
        echo $BOLD'No new casks installed.\n'
    else
        echo $BOLD'Newly installed casks: '$END${casks_installed[*]}'\n'
    fi
fi

### Check casks
if [[ $check_casks = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Checking Homebrew casks...\n'$END

    brew_list_cask=($(brew list --cask))
    installed_casks_not_in_install_list=()
    for c in ${brew_list_cask[@]}; do
        if [[ ! "${casks_to_install[@]}" =~ "$c" ]]; then
            installed_casks_not_in_install_list+=($c)
        fi
    done
    if [[ -z "$installed_casks_not_in_install_list" ]]; then
        echo $BOLD"All installed casks are in install list."$END
    else
        echo $RED$BOLD"Some casks have been installed locally that are not reflected in install list. \nConsider adding to install list or uninstalling locally (brew uninstall --cask \$cask): "$END${installed_casks_not_in_install_list[@]}
    fi
fi

### Install packages
package=""
packages_already_installed=()
packages_installed=()
install_package() {
    # Doing this because `brew list` is too slow.
    if [[ -d "$(brew --cellar)/$package" ]]; then
        packages_already_installed+=($package)
    else
        echo $BOLD'\trunning '$PURPLE'brew install '$package'\n'$END
        brew install $package
        echo -n '\n'
        packages_installed+=($package)
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
    if [[ $#packages_installed = 0 ]]; then
        echo $BOLD'No new packages installed.\n'
    else
        echo $BOLD'Newly installed packages: '$END${packages_installed[*]}'\n'
    fi
fi

### Check packages
if [[ $check_packages = y ]]; then
    echo $LINE_SEPARATOR

    echo $GREEN$BOLD$UNDERLINE'Checking Homebrew packages...\n'$END

    brew_leaves=($(brew leaves --installed-on-request))
    installed_packages_not_in_install_list=()
    for p in ${brew_leaves[@]}; do
        if [[ ! "${packages_to_install[@]}" =~ "$p" ]]; then
            installed_packages_not_in_install_list+=($p)
        fi
    done
    if [[ -z "$installed_packages_not_in_install_list" ]]; then
        echo $BOLD"All installed packages are in install list."$END
    else
        echo $RED$BOLD"Some packages have been installed locally that are not reflected in install list. \nConsider adding to install list or uninstalling locally (brew uninstall \$package): "$END${installed_packages_not_in_install_list[@]}
    fi
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
    echo $GREEN$BOLD$UNDERLINE'Installed casks or packages:\n\n'$END$BOLD'Scroll up & read console output since there might be post-install steps printed to stdout.'$END
fi

exit 0
