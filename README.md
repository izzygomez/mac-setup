# macOS Setup Scripts

Scripts for setting up & maintaining a consistent macOS environment with desired apps & packages.

## Files

* `brew-installs.sh`: Script to install casks & packages from [Homebrew](https://brew.sh/). Designed to be run many times as things are added or removed. Also does optional updating & cleanup tasks.
* `casks.sh` & `packages.sh`: lists of Homebrew casks & packages to install via `brew-installs.sh`. 
* `first-time.sh`: Script intended for initialization after `./brew-installs.sh` has been run once. Designed to only be run once.

## Usage

When using for first time, run:
```shell
> ./brew-installs.sh
> ./first-time.sh
```
Afterwards, simply run:
```shell
> ./brew-installs.sh
```

## TODOs

* Consider creating script that compares list of casks to install in `brew-installs.sh` to list of applications in `/Applications` & outputs diff to console output. Use case here is to very quickly check what apps are managed via brew, & which aren't (can create some sort of "ignore" list to not print out obviously non-brew apps, e.g. "App Store", "Calculator", "Messages"), which might be useful when bootstrapping new machine.
* Revisit the need for `first-time.sh`. Specifically, seems like a convoluted use-case given that `brew-installs.sh` is something that is continually updated & re-ran as packages are added.
* Figure out how to add other parts of [jekyll installation](https://jekyllrb.com/docs/installation/macos/) in first-time.sh, e.g. running `gem install jekyll` automatically, figuring out if `sudo` is needed, etc.
  * Also, per [this](https://github.com/github/pages-gem/issues/752) & [this](https://github.com/jekyll/jekyll/issues/8523), it appears that I need to run `gem install webrick` to get everything working.
  * Also note that if gems were installed accidentally before running `source ~/.zshrc` (i.e. installed for old ruby version), then they need to be deleted to avoid some errors. Did this by running `rm -rf ~/.gem/ruby/2.6.0`.
* Consider renaming this repo to `mac-setup`. Might require searching for & updating references to this repo across all my other repos/code files.
* Consider adding `pip` installs into this directory. 
