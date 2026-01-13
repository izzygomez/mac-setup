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

source ./utils/style.sh

### Check that Brew is installed
if ! command -v brew &>/dev/null; then
    echo $ICON_ERROR$RED" Brew is not installed, see https://brew.sh/"$END
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
echo $DIM"This script can update Brew, upgrade existing casks"
echo "& packages, uninstall locally-excluded casks & packages,"
echo "install new casks & packages, check installed casks &"
echo "packages lists, & cleanup Brew."$END
echo
echo "Select an action to perform (default = 1):"$BOLD
echo "1) Do everything"
echo "2) Update Brew"
echo "3) Upgrade all casks & packages"
echo "4) Uninstall locally-excluded casks & packages"
echo "5) Install casks & packages"
echo "6) Check installed casks & packages"
echo "7) Cleanup Brew"
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
    echo $BOLD"✨ Did nothing ✨"$END
    exit 0
    ;;
*)
    echo
    echo $ICON_ERROR$RED" Invalid choice. Exiting."$END
    exit 1
    ;;
esac

### Check if HOMEBREW_ASK is set
# If install or upgrade operations are selected but HOMEBREW_ASK is not set,
# warn the user that commands will run without confirmation prompts.
if [[ $install_casks == y || $install_packages == y || $upgrade_casks == y || $upgrade_packages == y ]]; then
    if [[ $HOMEBREW_ASK != 1 ]]; then
        echo
        echo $ICON_WARN$YELLOW$BOLD" Warning: HOMEBREW_ASK is not set."$END
        echo $BOLD"Install & upgrade commands will run without asking for confirmation."$END
        echo
        echo -n "Continue anyway? [y/N]: "
        read -s -k 1 confirm
        # If Enter is pressed, `confirm` is a newline/empty string, so we default to "N".
        if [[ -z $confirm || $confirm == $'\n' ]]; then
            confirm="N"
        fi
        echo $confirm
        if [[ ! $confirm =~ ^[Yy]$ ]]; then
            echo
            echo $BOLD"Exiting. Set HOMEBREW_ASK=1 before running this script if you want confirmation prompts."$END
            exit 0
        fi
    fi
fi

### Import casks & packages
echo
echo $BOLD"First, importing cask & package lists..."$END
source ./casks.sh
source ./packages.sh

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
# Note on HOMEBREW_ASK behavior (as of Jan 2026):
# The docs say HOMEBREW_ASK only affects formula commands, but it actually works
# for cask upgrades IF you pass cask names: `brew upgrade --cask a b c`.
# However, `brew upgrade --cask` (no args) or `brew upgrade --cask --ask` does
# NOT prompt for confirmation — it just runs. This seems like a bug.
#
# To work around this, we capture the outdated casks list first & pass them
# explicitly. This gives us the HOMEBREW_ASK confirmation w/o a manual prompt.
#
# If brew fixes this in the future & `brew upgrade --cask` respects HOMEBREW_ASK
# on its own, we can simplify this to just run `brew upgrade --cask` directly
# (similar to how the packages section works below).
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
    outdated_output=$(brew outdated --cask)

    if [[ -z $outdated_output ]]; then
        echo
        echo $ICON_CHECK$BOLD" No outdated casks to upgrade."$END
    else
        echo "$outdated_output"
        echo
        echo $BOLD"Upgrading outdated casks..."$END
        echo
        # Convert newline-separated string to array for proper argument passing.
        # We need an array so each cask becomes a separate argument to brew.
        outdated_casks=()
        while read -r cask; do        # read one line at a time into $cask
            outdated_casks+=("$cask") # append $cask to array
        done <<<"$outdated_output"    # feed $outdated_output as stdin to while loop
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew upgrade --cask ${outdated_casks[*]}"$END
        if brew upgrade --cask "${outdated_casks[@]}"; then
            casks_upgraded=(${outdated_casks[@]})
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
    outdated_output=$(brew outdated --formula)

    if [[ -z $outdated_output ]]; then
        echo
        echo $ICON_CHECK$BOLD" No outdated packages to upgrade."$END
    else
        echo "$outdated_output"
        echo
        echo $BOLD"Upgrading outdated packages..."$END
        echo
        # Convert newline-separated string to array for proper argument passing.
        # We need an array so each package becomes a separate argument to brew.
        outdated_packages=()
        while read -r pkg; do           # read one line at a time into $pkg
            outdated_packages+=("$pkg") # append $pkg to array
        done <<<"$outdated_output"      # feed $outdated_output as stdin to while loop
        echo $BOLD$TAB$ICON_ARROW" running "$PURPLE"brew upgrade --formula ${outdated_packages[*]}"$END
        if brew upgrade --formula "${outdated_packages[@]}"; then
            packages_upgraded=(${outdated_packages[@]})
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
# TODO document these sections some more, e.g. still need to figure out how
# to download python/ruby/etc & install correctly/not-manually
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
        echo $YELLOW$BOLD"Consider adding to install list or uninstalling locally (brew uninstall --cask \$cask): "$CYAN${installed_casks_not_in_install_list[@]}$END
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
        echo $YELLOW$BOLD"Consider adding to install list or uninstalling locally (brew uninstall \$package): "$CYAN${installed_packages_not_in_install_list[@]}$END
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
    echo $BOLD"Installed/uninstalled/upgraded casks or packages:"$END
    echo
    echo $BOLD"Scroll up & read console output since there might be post-install/uninstall/upgrade steps printed to stdout."$END
fi

echo
echo $BOLD_SEPARATOR
echo
echo $ICON_CHECK$BOLD" Done!"$END

exit 0
