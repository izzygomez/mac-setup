# Laptop Setup

Scripts related to setting up & maintaining an OSX environment with desired apps & packages.

## Files

* `brew_installs.sh`: Script to install casks & packages from [Homebrew](https://brew.sh/). Designed to be run many times through lifetime of dev environment as things are added or removed.
* `first_time.sh`: Script intended for initialization after `./brew_installs.sh` has been run once. Designed to only be run once.

## Instructions

When using for first time, run:
```shell
chmod +x ./brew_installs.sh
chmod +x ./first_time.sh
./brew_installs.sh
./first_time.sh
```
Afterwards, simply run:
```
./brew_installs.sh
```

## TODOs

* Revisit the need for `first_time.sh`. Specifically, seems like a convoluted use-case given that `brew_installs.sh` is something that is continually updated & re-ran as packages are added.
* Look into making it so that deleted casks/packages are removed when `brew_installs.sh` is run next time.
* Figure out how to add other parts of [jekyll installation](https://jekyllrb.com/docs/installation/macos/) in first_time.sh, e.g. running `gem install jekyll` automatically, figuring out if `sudo` is needed, etc.
  * Also, per [this](https://github.com/github/pages-gem/issues/752) & [this](https://github.com/jekyll/jekyll/issues/8523), it appears that I need to run `gem install webrick` to get everything working.
  * Also note that if gems were installed accidentally before running `source ~/.zshrc` (i.e. installed for old ruby version), then they need to be deleted to avoid some errors. Did this by running `rm -rf ~/.gem/ruby/2.6.0`.
