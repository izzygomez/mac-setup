# macOS Setup Scripts

Scripts for setting up & maintaining a consistent macOS environment with desired apps & packages.

## Overview

- `brew-installs.sh`: Script to install casks & packages from [Brew](https://brew.sh/). Designed to be run many times as things are added or removed. Also does optional updating & cleanup tasks.
- `casks.sh` & `packages.sh`: lists of Brew casks & packages to install via `brew-installs.sh`.
  - `local/`: optional machine-specific overrides (see `local/README.md`).
- `first-time.sh`: Script intended for initialization after `./brew-installs.sh` has been run once. Designed to only be run once.

## Usage

This script assumes that [Brew](https://brew.sh/) is installed — install via curl command at website.

When using for first time, run:

```shell
./brew-installs.sh
./first-time.sh
```

Afterwards, simply run:

```shell
./brew-installs.sh
```

## Pre-commit

This repo uses [`pre-commit`](https://pre-commit.com/) to automatically format & lint files before they are committed, & also as part of the required checks before a PR can be merged via [pre-commit.ci](https://pre-commit.ci/). See `.pre-commit-config.yaml` for configuration details.

<details>
<summary><h2>TODOs</h2></summary>

- Consider creating script that compares list of casks to install in `brew-installs.sh` to list of applications in `/Applications` & outputs diff to console output. Use case here is to very quickly check what apps are managed via brew, & which aren't (can create some sort of "ignore" list to not print out obviously non-brew apps, e.g. "App Store", "Calculator", "Messages"), which might be useful when bootstrapping new machine.
- Revisit the need for `first-time.sh`. Specifically, seems like a convoluted use-case given that `brew-installs.sh` is something that is continually updated & re-ran as packages are added.
- Figure out how to add other parts of [jekyll installation](https://jekyllrb.com/docs/installation/macos/) in first-time.sh, e.g. running `gem install jekyll` automatically, figuring out if `sudo` is needed, etc.
  - Also, per [this](https://github.com/github/pages-gem/issues/752) & [this](https://github.com/jekyll/jekyll/issues/8523), it appears that I need to run `gem install webrick` to get everything working.
  - Also note that if gems were installed accidentally before running `source ~/.zshrc` (i.e. installed for old ruby version), then they need to be deleted to avoid some errors. Did this by running `rm -rf ~/.gem/ruby/2.6.0`.
- Consider adding `pip` installs into this directory.
- Automate the creation of `~/iCloudDrive` symlink: `ln -s ~/Library/Mobile\ Documents/com\~apple\~CloudDocs ~/iCloudDrive`
- Consider adding `shellcheck` linter to `.pre-commit-config.yaml`, [see here](https://github.com/izzygomez/strava/blob/ce24dd98ce0807816d33c858506f2c87e8a6bb0e/.pre-commit-config.yaml#L52-L56) for an example.
</details>
