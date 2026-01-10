# Local Configuration Files

This directory contains example configuration files to specify additional packages, casks, & exclusions that are specific to a local environment. This might be useful, for example, for work machines that might have additional packages or casks but that both shouldn't be installed on personal machines nor be publically shared.

## Files

- `local-casks.sh.example`: Define additional Brew casks to install locally
- `local-packages.sh.example`: Define additional Brew packages to install locally
- `local-exclude-casks.sh.example`: Define Brew casks to exclude from installation locally
- `local-exclude-packages.sh.example`: Define Brew packages to exclude from installation locally

## Usage

1. Copy the example files you want to use, removing the `.example` extension:

   ```bash
   cd mac-setup/local/
   cp examples/local-casks.sh.example local-casks.sh
   ```

2. Edit the copied files to add your local customizations

3. The `casks.sh` & `packages.sh` scripts will automatically source these files if they exist.

## Note

Non-example script files will be ignored via `.gitignore`. The `.example` files serve as templates.
