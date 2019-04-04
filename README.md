
# Purpose
This is a collection of scripts and config files that keep my Linux environment portable and in
sync. It is mostly Ubuntu-oriented.

# Usage
To install config files to appropriate locations on the filesystem, run
```sh
./file-install.sh [update]
```
The `update` option initializes or updates the submodules. Nothing in this script requires root
privileges.

To install programs, run
```sh
./program-install.sh [update | all | some-prog]
```
The `update` option causes it to quit after to an `apt update/upgrade` sequence. `all` or
`some-prog` causes the script to install one or more less used or more complex program installs,
such as `ruby` for an RVM installation or `Wireshark` to install the program and manage the groups.
Running this script requires root privileges.

# File Structure
- `dockerfiles/`: store reference Dockerfiles along with build/install scripts
- `helper_scripts/`: store helper bash functions used within this repo
- `reference/`: store handy template files, like a basic C Makefile, a static IP address interfaces
  file, etc
- `submodules/`: submodules get loaded here
- `system_files/`: config files that get placed around the filesystem, like `.bashrc`, `.vimrc`,
  etc.
- `wsl/`: scripts and files that make sense only in the WSL environment

# Sharing
You are 100% free to use anything from this repo. It has proven very handy for me. Always open to
additional tips and pull requests as well.

# Wishlist
- Separate the mechanism from the content so that this becomes more modular, and improvements easily
  shared
