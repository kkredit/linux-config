
# Chocolatey
[Chocolatey](https://chocolatey.org/) is a package manager for Windows. This set of scripts is
intended to automate new Windows program installs using Chocolatey. A collection of available
packages is available [here](https://chocolatey.org/packages).

# Usage
- To add programs to be installed, modify the list in `packages.txt`.
- To install `choco` and the listed packages, run `./win-program-install.sh`.
- To perform a one-off choco command in an admin command prompt, run `./choco.sh your args`
