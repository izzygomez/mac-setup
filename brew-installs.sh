#!/bin/zsh
################################################################################
#             ___   ___   ____  _
#            | |_) | |_) | |_  \ \    /
#            |_|_) |_| \ |_|__  \_\/\/
#     _   _      __  _____   __    _     _     __
#    | | | |\ | ( (`  | |   / /\  | |   | |   ( (`
#    |_| |_| \| _)_)  |_|  /_/--\ |_|__ |_|__ _)_)
#
################################################################################
# Usage Instructions
################################################################################
#
# Run this script:
# `./brew-installs.sh`
#
################################################################################
# Other useful notes
################################################################################
#
# See https://docs.brew.sh/Manpage for full documentation on Brew commands.
#
# See https://zsh.sourceforge.io/Doc/Release for a ZSH scripting manual.
#
# Note the following terminology equivalencies:
# - "Homebrew" = "Brew"
# - "formula" = "package"
# - "cask" = "GUI app"
#
# To enumerate list of packages (with descriptions) that have been installed,
# run the following command (https://apple.stackexchange.com/a/154750):
# `brew leaves --installed-on-request | xargs -n1 brew desc --eval-all`
#
# List all Brew packages:
# `brew list --formula`
#
# List all Brew casks:
# `brew list --cask`
#
# If Brew seems broken, a combination of the following commands may help:
# `brew doctor`
# `brew update-reset` <- note: fetches & resets Brew & all tap repos. this
#                        will destroy any changes (committed or uncommitted).
#
# To remove all packages & casks installed by Brew, run the following commands:
# `brew remove --force $(brew list --formula)`
# `brew remove --cask --force $(brew list --cask)`
# This could be useful for "resetting" a setup & re-installing them immediately
# after by running this script. (see https://apple.stackexchange.com/a/339096)
#
################################################################################

# Resolve the mac-setup repo directory (even when invoked via symlink)
MAC_SETUP_DIR="${0:A:h}"
source "$MAC_SETUP_DIR/utils/style.sh"

### Check that Brew is installed
if ! command -v brew &>/dev/null; then
    echo $ICON_ERROR$BOLD$RED" Brew is not installed, see https://brew.sh/"$END
    exit 1
fi

### Require an interactive terminal
# brew only prompts for confirmation when both stdin & stdout are ttys, so
# piping either one would run every upgrade unattended. The menu below also
# needs a controlling terminal for its `read -s`.
if [[ ! -t 0 || ! -t 1 ]]; then
    echo $ICON_ERROR$BOLD$RED" This script requires an interactive terminal."$END
    exit 1
fi

echo $GREEN$BOLD'
             ___   ___   ____  _
            | |_) | |_) | |_  \ \    /
            |_|_) |_| \ |_|__  \_\/\/
     _   _      __  _____   __    _     _     __
    | | | |\ | ( (`  | |   / /\  | |   | |   ( (`
    |_| |_| \| _)_)  |_|  /_/--\ |_|__ |_|__ _)_)

'$END
echo $DIM"This script can update Brew, upgrade existing casks"
echo "& packages, uninstall locally-excluded casks & packages,"
echo "install new casks & packages, check installed casks &"
echo "packages lists, & cleanup Brew."$END
echo
echo "Select an action to perform (default = 1):"$BOLD
echo $GREEN"1)"$END$BOLD" Do everything"$END
echo $GREEN"2)"$END$BOLD" Update Brew"$END
echo $GREEN"3)"$END$BOLD" Upgrade all casks & packages"$END
echo $GREEN"4)"$END$BOLD" Uninstall locally-excluded casks & packages"$END
echo $GREEN"5)"$END$BOLD" Install casks & packages"$END
echo $GREEN"6)"$END$BOLD" Check installed casks & packages"$END
echo $GREEN"7)"$END$BOLD" Cleanup Brew"$END
echo $GREEN"0)"$END$BOLD" Exit"$END
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
    echo $GREEN$BOLD"Doing everything..."$END
    update_brew=y
    upgrade_casks=y
    upgrade_packages=y
    uninstall_excluded=y
    install_casks=y
    check_casks=y
    install_packages=y
    check_packages=y
    cleanup_brew=y
    ;;
2) update_brew=y ;;
3)
    upgrade_casks=y
    upgrade_packages=y
    ;;
4) uninstall_excluded=y ;;
5)
    install_casks=y
    install_packages=y
    ;;
6)
    check_casks=y
    check_packages=y
    ;;
7) cleanup_brew=y ;;
0)
    echo
    echo $GREEN$BOLD"Exiting..."$END
    exit 0
    ;;
*)
    echo
    echo $ICON_ERROR$BOLD$RED" Invalid choice. Exiting."$END
    exit 1
    ;;
esac

### Import casks & packages
echo
echo $BOLD"First, importing cask & package lists..."$END
source "$MAC_SETUP_DIR/casks.sh"
source "$MAC_SETUP_DIR/packages.sh"

### Trust third-party taps
# Homebrew won't load formulae from non-official taps until they're trusted (see
# https://docs.brew.sh/Tap-Trust). Trusting is idempotent & works even before the
# tap exists, so this just runs every time. Add a line here if `packages.sh` or
# `casks.sh` ever gains another tap-qualified entry.
echo
echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew trust --formula withgraphite/tap/graphite"$END
brew trust --formula withgraphite/tap/graphite

### Update Brew
if [[ $update_brew == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Updating Brew..."$END
    echo
    echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew update"$END
    echo
    brew update
fi

### Upgrade all casks & packages
# We invoke `brew upgrade --cask` / `brew upgrade --formula` with no explicit
# names so brew's own ask-mode prompt fires (passing explicit names causes brew
# to skip the confirmation prompt). We track what actually upgraded by diffing
# the outdated list before & after, which feeds the post-operation summary.
casks_upgraded=()
packages_upgraded=()
if [[ $upgrade_casks == y || $upgrade_packages == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Upgrading all casks & packages..."$END
fi

if [[ $upgrade_casks == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Listing casks in need of upgrading..."$END
    echo
    echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew outdated --cask"$END
    outdated_before=$(brew outdated --cask)

    if [[ -z $outdated_before ]]; then
        echo
        echo $ICON_CHECK$BOLD" No outdated casks to upgrade."$END
    else
        echo "$outdated_before"
        echo
        echo $BOLD"Upgrading outdated casks..."$END
        echo
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew upgrade --cask"$END
        brew upgrade --cask

        # brew exits non-zero both when the prompt is declined & on a genuine
        # failure, so determine what happened by diffing the outdated list
        # before & after rather than by checking the exit code.
        # ${(f)x} splits x on newlines; ${a:|b} is "elements of a not in b".
        outdated_after=$(brew outdated --cask)
        before_list=(${(f)outdated_before})
        after_list=(${(f)outdated_after})
        casks_upgraded=(${before_list:|after_list})

        echo
        if [[ ${#casks_upgraded[@]} -eq 0 ]]; then
            echo $ICON_WARN$YELLOW$BOLD" No casks were upgraded."$END
        else
            echo $ICON_CHECK$BOLD" Upgraded casks: "$CYAN${casks_upgraded[*]}$END
        fi
    fi
fi

if [[ $upgrade_packages == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Listing packages in need of upgrading..."$END
    echo
    echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew outdated --formula"$END
    outdated_before=$(brew outdated --formula)

    if [[ -z $outdated_before ]]; then
        echo
        echo $ICON_CHECK$BOLD" No outdated packages to upgrade."$END
    else
        echo "$outdated_before"
        echo
        echo $BOLD"Upgrading outdated packages..."$END
        echo
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew upgrade --formula"$END
        brew upgrade --formula

        # brew exits non-zero both when the prompt is declined & on a genuine
        # failure, so determine what happened by diffing the outdated list
        # before & after rather than by checking the exit code.
        # ${(f)x} splits x on newlines; ${a:|b} is "elements of a not in b".
        outdated_after=$(brew outdated --formula)
        before_list=(${(f)outdated_before})
        after_list=(${(f)outdated_after})
        packages_upgraded=(${before_list:|after_list})

        echo
        if [[ ${#packages_upgraded[@]} -eq 0 ]]; then
            echo $ICON_WARN$YELLOW$BOLD" No packages were upgraded."$END
        else
            echo $ICON_CHECK$BOLD" Upgraded packages: "$CYAN${packages_upgraded[*]}$END
        fi
    fi
fi

### Uninstall locally-excluded casks & packages
excluded_casks_to_uninstall=()
excluded_packages_to_uninstall=()
if [[ $uninstall_excluded == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Uninstalling locally-excluded casks & packages..."$END

    # Handle excluded casks
    if [ -f "$MAC_SETUP_DIR/local/local-exclude-casks.sh" ]; then
        source "$MAC_SETUP_DIR/local/local-exclude-casks.sh"
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
    if [ -f "$MAC_SETUP_DIR/local/local-exclude-packages.sh" ]; then
        source "$MAC_SETUP_DIR/local/local-exclude-packages.sh"
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
        echo $ICON_WARN$YELLOW$BOLD" Found locally-excluded casks that are currently installed: "$CYAN${excluded_casks_to_uninstall[*]}$END
        echo
        echo $BOLD"Uninstalling locally-excluded casks..."$END

        for uninstall_cask in "${excluded_casks_to_uninstall[@]}"; do
            echo
            echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew uninstall --cask "$uninstall_cask$END
            brew uninstall --cask $uninstall_cask
        done

        echo
        echo $ICON_CHECK$BOLD" Uninstalled locally-excluded casks: "$CYAN${excluded_casks_to_uninstall[*]}$END
    fi

    # Uninstall excluded packages
    if [[ ${#excluded_packages_to_uninstall[@]} -gt 0 ]]; then
        echo
        echo $ICON_WARN$YELLOW$BOLD" Found locally-excluded packages that are currently installed: "$CYAN${excluded_packages_to_uninstall[*]}$END
        echo
        echo $BOLD"Uninstalling locally-excluded packages..."$END

        for uninstall_package in "${excluded_packages_to_uninstall[@]}"; do
            echo
            echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew uninstall "$uninstall_package$END
            brew uninstall $uninstall_package
        done

        echo
        echo $ICON_CHECK$BOLD" Uninstalled locally-excluded packages: "$CYAN${excluded_packages_to_uninstall[*]}$END
    fi

    # Summary message
    if [[ ${#excluded_casks_to_uninstall[@]} -eq 0 && ${#excluded_packages_to_uninstall[@]} -eq 0 ]]; then
        echo
        echo $ICON_CHECK$BOLD" No locally-excluded casks or packages found to uninstall."$END
    fi
fi

### Install casks & packages
casks_already_installed=()
casks_to_be_installed=()
casks_installed=()
packages_already_installed=()
packages_to_be_installed=()
packages_installed=()
if [[ $install_casks == y || $install_packages == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Installing casks & packages..."$END
fi

if [[ $install_casks == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Checking Brew casks to install..."$END

    # First pass: determine which casks need to be installed
    for c in ${casks_to_install[@]}; do
        if [[ -d "$(brew --caskroom)/$c" ]]; then
            casks_already_installed+=($c)
        else
            casks_to_be_installed+=($c)
        fi
    done

    echo
    echo $BOLD"Already installed casks: "$END$DIM${casks_already_installed[*]}$END

    if [[ ${#casks_to_be_installed[@]} -eq 0 ]]; then
        echo
        echo $ICON_CHECK$BOLD" No new casks to install."$END
    else
        echo
        echo $BOLD"Casks to be installed: "$END$CYAN${casks_to_be_installed[*]}$END
        echo
        echo $BOLD"Installing Brew casks..."$END
        echo
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew install --cask "${casks_to_be_installed[*]}$END
        if brew install --cask ${casks_to_be_installed[@]}; then
            casks_installed=(${casks_to_be_installed[@]})
            echo
            echo $ICON_CHECK$BOLD" Newly installed casks: "$CYAN${casks_installed[*]}$END
        fi
    fi
fi

if [[ $install_packages == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Checking Brew packages to install..."$END

    # First pass: determine which packages need to be installed
    brew_formula_list=$(brew list --formula)
    for p in ${packages_to_install[@]}; do
        if echo "$brew_formula_list" | grep -q "^${p##*/}$"; then
            packages_already_installed+=($p)
        else
            packages_to_be_installed+=($p)
        fi
    done

    echo
    echo $BOLD"Already installed packages: "$END$DIM${packages_already_installed[*]}$END

    if [[ ${#packages_to_be_installed[@]} -eq 0 ]]; then
        echo
        echo $ICON_CHECK$BOLD" No new packages to install."$END
    else
        echo
        echo $BOLD"Packages to be installed: "$END$CYAN${packages_to_be_installed[*]}$END
        echo
        echo $BOLD"Installing Brew packages..."$END
        echo
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew install "${packages_to_be_installed[*]}$END
        if brew install ${packages_to_be_installed[@]}; then
            packages_installed=(${packages_to_be_installed[@]})
            echo
            echo $ICON_CHECK$BOLD" Newly installed packages: "$CYAN${packages_installed[*]}$END
        fi
    fi
fi

### Check installed casks & packages
if [[ $check_casks == y || $check_packages == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Checking installed casks & packages..."$END
fi

if [[ $check_casks == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Checking Brew casks..."$END

    brew_list_cask=($(brew list --cask))

    # Check for installed casks not in install list
    installed_casks_not_in_install_list=()
    for c in ${brew_list_cask[@]}; do
        if [[ ! ${casks_to_install[@]} =~ $c ]]; then
            installed_casks_not_in_install_list+=($c)
        fi
    done
    if [[ -z $installed_casks_not_in_install_list ]]; then
        echo
        echo $ICON_CHECK$BOLD" All installed casks are in install list."$END
    else
        echo
        echo $ICON_WARN$YELLOW$BOLD" Some casks have been installed locally that are not reflected in install list."$END
        echo $YELLOW$BOLD"Consider adding to 'casks.sh' or uninstalling locally: "$CYAN"brew uninstall --cask "${installed_casks_not_in_install_list[@]}$END
    fi

    # Check for casks in install list that are not installed
    casks_in_install_list_not_installed=()
    for c in ${casks_to_install[@]}; do
        if [[ ! ${brew_list_cask[@]} =~ $c ]]; then
            casks_in_install_list_not_installed+=($c)
        fi
    done
    if [[ -z $casks_in_install_list_not_installed ]]; then
        echo
        echo $ICON_CHECK$BOLD" All casks in install list are installed."$END
    else
        echo
        echo $ICON_WARN$YELLOW$BOLD" Some casks in install list are not installed: "$CYAN${casks_in_install_list_not_installed[@]}$END
    fi
fi

if [[ $check_packages == y ]]; then
    echo
    echo $LIGHT_SEPARATOR
    echo
    echo $BOLD"Checking Brew packages..."$END
    brew_leaves=($(brew leaves --installed-on-request))

    # Check for installed packages not in install list
    installed_packages_not_in_install_list=()
    for p in ${brew_leaves[@]}; do
        if [[ ! ${packages_to_install[@]} =~ $p ]]; then
            installed_packages_not_in_install_list+=($p)
        fi
    done
    if [[ -z $installed_packages_not_in_install_list ]]; then
        echo
        echo $ICON_CHECK$BOLD" All installed packages are in install list."$END
    else
        echo
        echo $ICON_WARN$YELLOW$BOLD" Some packages have been installed locally that are not reflected in install list."$END
        echo $YELLOW$BOLD"Consider adding to 'packages.sh' or uninstalling locally: "$CYAN"brew uninstall "${installed_packages_not_in_install_list[@]}$END
    fi

    # Check for packages in install list that are not installed
    brew_formula_list=($(brew list --formula))
    packages_in_install_list_not_installed=()
    for p in ${packages_to_install[@]}; do
        if [[ ! ${brew_formula_list[@]} =~ ${p##*/} ]]; then
            packages_in_install_list_not_installed+=($p)
        fi
    done
    if [[ -z $packages_in_install_list_not_installed ]]; then
        echo
        echo $ICON_CHECK$BOLD" All packages in install list are installed."$END
    else
        echo
        echo $ICON_WARN$YELLOW$BOLD" Some packages in install list are not installed: "$CYAN${packages_in_install_list_not_installed[@]}$END
    fi
fi

### Cleanup Brew
if [[ $cleanup_brew == y ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $GREEN$BOLD"Cleaning up Brew..."$END
    echo
    echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew autoremove"$END
    brew autoremove
    echo
    echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew cleanup --prune=all -s"$END
    brew cleanup --prune=all -s
fi

### Post-operation message
# Only show if something was actually installed, uninstalled, or upgraded
if [[ ${#casks_installed[@]} -gt 0 ||
    ${#packages_installed[@]} -gt 0 ||
    ${#excluded_casks_to_uninstall[@]} -gt 0 ||
    ${#excluded_packages_to_uninstall[@]} -gt 0 ||
    ${#casks_upgraded[@]} -gt 0 ||
    ${#packages_upgraded[@]} -gt 0 ]]; then
    echo
    echo $BOLD_SEPARATOR
    echo
    echo $BOLD"Installed/uninstalled/upgraded casks or packages: "$END"Scroll up & read console output since there might be post-install/uninstall/upgrade steps printed to stdout."
fi

echo
echo $BOLD_SEPARATOR
echo
echo $ICON_CHECK$BOLD" Done!"$END

exit 0
