#!/bin/zsh

source ./utils/style.sh

packages_to_install=(
    'bat'
    'chruby' # from https://jekyllrb.com/docs/installation/macos/
    'emacs'
    'eza'
    'fastfetch' # finally found out the the thing all of r/unixporn uses (used to use `neofetch`)
    'ffmpeg'
    'gh'
    'git'
    'git-delta' # nice tool for better git diffs
    'gnupg'
    'go'
    'grep'
    'htop'
    'imagemagick'
    'ipfs'
    'ipython'
    'less'
    'libusb'
    'md5sha1sum'
    'monero'
    'mosh'
    'node'
    # Java.
    # Per [1], note that following command should be run after installation:
    # sudo ln -sfn $HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
    # [1] https://formulae.brew.sh/formula/openjdk
    'openjdk'
    # See https://github.com/nvm-sh/nvm for why Brew installation is not
    # recommended. Keeping this line here for posterity & to make it clear that
    # nvm should be installed via script in GitHub repo.
    # 'nvm'
    'poetry'
    'powerlevel10k' # https://github.com/romkatv/powerlevel10k
    'pre-commit'
    'pyenv'
    'ruby-install' # from https://jekyllrb.com/docs/installation/macos/
    'rustup'       # from https://www.rust-lang.org/tools/install
    'shfmt'
    'spek' # https://github.com/alexkay/spek, nice audio spectrum analyzer
    'solidity'
    'source-highlight'
    'tidy-html5'
    'tmux'
    'tree'
    'wget'
    'withgraphite/tap/graphite' # https://graphite.dev/
    'yarn'
    'yt-dlp' # replaces now deprecated (per brew.sh) youtube-dl
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
)

# Source local-specific packages if the file exists
if [ -f "$(dirname "$0")/local/local-packages.sh" ]; then
    echo
    echo $BOLD"Loading local packages..."$END
    source "$(dirname "$0")/local/local-packages.sh"
    # Add local packages to the main array
    if [ -n "${local_packages_to_install[*]}" ]; then
        packages_to_install+=("${local_packages_to_install[@]}")
        echo $ICON_CHECK$BOLD" Added local packages: "$END$DIM${local_packages_to_install[*]}$END
    else
        echo $ICON_ERROR$BOLD$RED" \`local_packages_to_install\` is empty or not set"$END
    fi
fi

# Source and process local-specific package exclusions if the file exists
if [ -f "$(dirname "$0")/local/local-exclude-packages.sh" ]; then
    echo
    echo $BOLD"Loading local package exclusions..."$END
    source "$(dirname "$0")/local/local-exclude-packages.sh"

    # Filter out excluded packages using array operations
    if [ -n "${local_exclude_packages[*]}" ]; then
        for exclude_package in "${local_exclude_packages[@]}"; do
            packages_to_install=("${packages_to_install[@]/$exclude_package/}")
        done
        # Remove empty elements from the array
        packages_to_install=("${packages_to_install[@]/#/}")
        echo $ICON_CHECK$BOLD" Excluded local packages: "$END$DIM${local_exclude_packages[*]}$END
    else
        echo $ICON_ERROR$BOLD$RED" \`local_exclude_packages\` is empty or not set"$END
    fi
fi
