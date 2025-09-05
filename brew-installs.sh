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

echo $GREEN'
             ___   ___   ____  _
            | |_) | |_) | |_  \ \    /
            |_|_) |_| \ |_|__  \_\/\/
     _   _      __  _____   __    _     _     __
    | | | |\ | ( (`  | |   / /\  | |   | |   ( (`
    |_| |_| \| _)_)  |_|  /_/--\ |_|__ |_|__ _)_)

'$END
echo "This script can update Homebrew, upgrade existing casks"
echo "& packages, uninstall locally-excluded casks & packages,"
echo "install new casks & packages, check installed casks &"
echo "packages lists, & cleanup Homebrew."
echo
echo "Select an action to perform (default = 1):"$BOLD
echo "1) Do everything"
echo "2) Update Homebrew"
echo "3) Upgrade all casks & packages"
echo "4) Uninstall locally-excluded casks & packages"
echo "5) Install casks & packages"
echo "6) Check installed casks & packages"
echo "7) Cleanup Homebrew"
echo "0) Exit"
echo
echo -n "Enter your choice: "$END

read -s -k 1 choice # -s: silent mode, -k 1: read only one character
# If Enter is pressed, `choice` is a newline/empty string, so we default to "1"
if [[ -z $choice || $choice == $'\n' ]]; then
    choice="1"
fi
# Print the choice to stdout. Necessary bc of -s flag on read, but explicitly
# don't want to echo back characters until after checking that it's not a
# newline to keep consistent prompt formatting.
echo $choice

case $choice in
1)
    echo
    echo $GREEN"Doing everything..."$END
    update_homebrew=y
    upgrade_everything=y
    uninstall_excluded=y
    install_casks=y
    check_casks=y
    install_packages=y
    check_packages=y
    cleanup_homebrew=y
    ;;
2) update_homebrew=y ;;
3) upgrade_everything=y ;;
4) uninstall_excluded=y ;;
5)
    install_casks=y
    install_packages=y
    ;;
6)
    check_casks=y
    check_packages=y
    ;;
7) cleanup_homebrew=y ;;
0)
    echo
    echo $GREEN"✨ Did nothing ✨"$END
    exit 0
    ;;
*)
    echo
    echo $RED"Invalid choice. Exiting."$END
    exit 1
    ;;
esac

LINE_SEPARATOR=$BOLD"--------------------------------------------------------------------------------"$END

# Import casks & packages
echo
echo $LINE_SEPARATOR
echo
echo $GREEN$BOLD$UNDERLINE"Importing cask & package lists..."$END
source ./casks.sh
source ./packages.sh

### Update Homebrew
if [[ $update_homebrew == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Updating Homebrew..."$END
    echo
    echo $BOLD"\t> running "$PURPLE"brew update"$END
    brew update
fi

### Upgrade everything
if [[ $upgrade_everything == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Listing casks & packages in need of upgrading..."$END
    echo
    echo $BOLD"\t> running "$PURPLE"brew outdated"$END
    brew outdated
    echo
    echo $GREEN$BOLD$UNDERLINE"Upgrading outdated casks & packages..."$END
    echo
    echo $BOLD"\t> running "$PURPLE"brew upgrade"$END
    brew upgrade
fi

### Uninstall locally-excluded casks & packages
if [[ $uninstall_excluded == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Checking for locally-excluded casks & packages to uninstall..."$END

    # Handle excluded casks
    excluded_casks_to_uninstall=()
    if [ -f "./local/local-exclude-casks.sh" ]; then
        source ./local/local-exclude-casks.sh
        if [ -n "${local_exclude_casks[*]}" ]; then
            echo
            echo $BOLD"Checking locally-excluded casks..."$END
            for exclude_cask in "${local_exclude_casks[@]}"; do
                # Check if the excluded cask is currently installed
                if [[ -d "$(brew --caskroom)/$exclude_cask" ]]; then
                    excluded_casks_to_uninstall+=($exclude_cask)
                fi
            done
        fi
    fi

    # Handle excluded packages
    excluded_packages_to_uninstall=()
    if [ -f "./local/local-exclude-packages.sh" ]; then
        source ./local/local-exclude-packages.sh
        if [ -n "${local_exclude_packages[*]}" ]; then
            echo
            echo $BOLD"Checking locally-excluded packages..."$END
            for exclude_package in "${local_exclude_packages[@]}"; do
                # Check if the excluded package is currently installed
                if brew list --formula | grep -q "^${exclude_package}$"; then
                    excluded_packages_to_uninstall+=($exclude_package)
                fi
            done
        fi
    fi

    # Uninstall excluded casks
    if [[ ${#excluded_casks_to_uninstall[@]} -gt 0 ]]; then
        echo
        echo $YELLOW$BOLD"Found locally-excluded casks that are currently installed: "${excluded_casks_to_uninstall[*]}$END
        echo
        echo $RED$BOLD"Uninstalling locally-excluded casks..."$END

        for uninstall_cask in "${excluded_casks_to_uninstall[@]}"; do
            echo
            echo $BOLD"\t> running "$PURPLE"brew uninstall --cask "$uninstall_cask$END
            brew uninstall --cask $uninstall_cask
        done

        echo
        echo $BOLD"Uninstalled locally-excluded casks: "$END${excluded_casks_to_uninstall[*]}
    fi

    # Uninstall excluded packages
    if [[ ${#excluded_packages_to_uninstall[@]} -gt 0 ]]; then
        echo
        echo $YELLOW$BOLD"Found locally-excluded packages that are currently installed: "${excluded_packages_to_uninstall[*]}$END
        echo $RED$BOLD"Uninstalling locally-excluded packages..."$END

        for uninstall_package in "${excluded_packages_to_uninstall[@]}"; do
            echo
            echo $BOLD"\t> running "$PURPLE"brew uninstall "$uninstall_package$END
            brew uninstall $uninstall_package
        done

        echo
        echo $BOLD"Uninstalled locally-excluded packages: "$END${excluded_packages_to_uninstall[*]}
    fi

    # Summary message
    if [[ ${#excluded_casks_to_uninstall[@]} -eq 0 && ${#excluded_packages_to_uninstall[@]} -eq 0 ]]; then
        echo
        echo $BOLD"No locally-excluded casks or packages found to uninstall."$END
    fi
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
        echo
        echo $BOLD"\t> running "$PURPLE"brew install --cask "$cask$END
        brew install --cask $cask
        casks_installed+=($cask)
    fi
}
if [[ $install_casks == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Installing Homebrew casks..."$END
    for c in ${casks_to_install[@]}; do
        cask=$c
        install_cask
    done

    echo
    echo $BOLD"Already installed casks: "$END${casks_already_installed[*]}
    if [[ $#casks_installed == 0 ]]; then
        echo
        echo $BOLD"No new casks installed."$END
    else
        echo
        echo $BOLD"Newly installed casks: "$END${casks_installed[*]}
    fi
fi

### Check casks
if [[ $check_casks == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Checking Homebrew casks..."$END

    brew_list_cask=($(brew list --cask))
    installed_casks_not_in_install_list=()
    for c in ${brew_list_cask[@]}; do
        if [[ ! ${casks_to_install[@]} =~ $c ]]; then
            installed_casks_not_in_install_list+=($c)
        fi
    done
    if [[ -z $installed_casks_not_in_install_list ]]; then
        echo
        echo $BOLD"All installed casks are in install list."$END
    else
        echo
        echo $RED$BOLD"Some casks have been installed locally that are not reflected in install list."$END
        echo $RED$BOLD"Consider adding to install list or uninstalling locally (brew uninstall --cask \$cask): "$END${installed_casks_not_in_install_list[@]}
    fi
fi

### Install packages
package=""
packages_already_installed=()
packages_installed=()
install_package() {
    if brew list --formula | grep -q "^${package##*/}$"; then
        packages_already_installed+=($package)
    else
        echo
        echo $BOLD"\t> running "$PURPLE"brew install "$package$END
        brew install $package
        packages_installed+=($package)
    fi
}
if [[ $install_packages == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Installing Homebrew packages..."$END
    for p in ${packages_to_install[@]}; do
        package=$p
        install_package
    done
    echo
    echo $BOLD"Already installed packages: "$END${packages_already_installed[*]}
    if [[ $#packages_installed == 0 ]]; then
        echo
        echo $BOLD"No new packages installed."$END
    else
        echo
        echo $BOLD"Newly installed packages: "$END${packages_installed[*]}
    fi
fi

### Check packages
if [[ $check_packages == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Checking Homebrew packages..."$END
    brew_leaves=($(brew leaves --installed-on-request))
    installed_packages_not_in_install_list=()
    for p in ${brew_leaves[@]}; do
        if [[ ! ${packages_to_install[@]} =~ $p ]]; then
            installed_packages_not_in_install_list+=($p)
        fi
    done
    if [[ -z $installed_packages_not_in_install_list ]]; then
        echo
        echo $BOLD"All installed packages are in install list."$END
    else
        echo
        echo $RED$BOLD"Some packages have been installed locally that are not reflected in install list."$END
        echo $RED$BOLD"Consider adding to install list or uninstalling locally (brew uninstall \$package): "$END${installed_packages_not_in_install_list[@]}
    fi
fi

### Cleanup Homebrew (see https://docs.brew.sh/Manpage)
if [[ $cleanup_homebrew == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Cleaning up Homebrew..."$END
    echo
    echo $BOLD"\t> running "$PURPLE"brew autoremove"$END
    brew autoremove
    echo
    echo $BOLD"\t> running "$PURPLE"brew cleanup --prune=all -s"$END
    brew cleanup --prune=all -s
fi

### Post-install messsage
if [[ $install_casks == y || $install_packages == y || $uninstall_excluded == y ]]; then
    echo
    echo $LINE_SEPARATOR
    echo
    echo $GREEN$BOLD$UNDERLINE"Installed/uninstalled casks or packages:"$END
    echo
    echo $BOLD"Scroll up & read console output since there might be post-install/uninstall steps printed to stdout."$END
fi

exit 0
