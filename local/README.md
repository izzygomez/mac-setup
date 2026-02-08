# Local Configuration Files

This directory contains machine-specific configuration files that are ignored by `.gitignore`, except for `examples/` & this `README.md`.

## Brew Overrides

The following are example configuration files to specify additional packages, casks, & exclusions that are specific to a local environment. This might be useful, for example, for work machines that might have additional packages, casks, or exclusions, but that shouldn't be installed on personal machines nor be publicly shared.

### Files

- `examples/local-casks.sh.example`: Define additional Brew casks to install locally
- `examples/local-packages.sh.example`: Define additional Brew packages to install locally
- `examples/local-exclude-casks.sh.example`: Define Brew casks to exclude from installation locally
- `examples/local-exclude-packages.sh.example`: Define Brew packages to exclude from installation locally

### Usage

1. Copy the example files you want to use, removing the `.example` extension:

   ```bash
   cd mac-setup/local/
   cp examples/local-casks.sh.example local-casks.sh
   ```

2. Edit the copied files to add your local customizations

3. The `casks.sh` & `packages.sh` scripts will automatically source these files if they exist.

## Symlinks Configuration

The `symlinks-config.sh` file stores the path to your personal code directory. This is **auto-generated** on the first run of `update-symlinks.sh` — you will be prompted to enter the directory path. To change it, edit or delete the file & re-run `update-symlinks.sh`.
