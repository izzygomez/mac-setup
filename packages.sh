packages_to_install=(
    'chruby' # from https://jekyllrb.com/docs/installation/macos/
    'emacs'
    'fastfetch'  # finally found out the the thing all of r/unixporn uses (used to use `neofetch`)
    'ffmpeg'
    'gh'
    'git'
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
    # See https://github.com/nvm-sh/nvm for why Homebrew installation is not
    # recommended. Keeping this line here for posterity & to make it clear that
    # nvm should be installed via script in GitHub repo.
    # 'nvm'
    'poetry'
    'pre-commit'
    'pure' # https://github.com/sindresorhus/pure
    'pyenv'
    'ruby-install' # from https://jekyllrb.com/docs/installation/macos/
    'rustup' # from https://www.rust-lang.org/tools/install
    'shfmt'
    'spek' # https://github.com/alexkay/spek, nice audio spectrum analyzer
    'solidity'
    'source-highlight'
    'tidy-html5'
    'tmux'
    'tree'
    'wget'
    'yarn'
    'yt-dlp'  # replaces now deprecated (per brew.sh) youtube-dl
    'zsh-autosuggestions'
    'zsh-syntax-highlighting'
)
