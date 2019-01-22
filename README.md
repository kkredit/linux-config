
# linux-config
A collection of scripts and config files that keep my Linux environment portable and in sync. It is
mostly Ubuntu-oriented at this point.

## Usage
`file-install.sh`:
- install config files to appropriate locations on the filesystem
- does not require `sudo` privileges
- arg `update`: initialize and/or update the submodules versions

`program-install.sh`:
- install programs I like to have
- DOES require `sudo` priveleges
- arg `update`: only perform a `apt get update/upgrade` sequence
- arg `<some name>`: perform special installation steps for more involved programs; e.g.
  - `ruby` for RVM + Ruby
  - `wireshark` for Wireshark + group management steps
- arg `all`: install all the things (probably never even a good idea)

## File Structure
```
.
├ dockerfiles
├ helper_scripts
├ reference
├ submodules
├ system_files
└ wsl
```
- `dockerfiles/`: store reference Dockerfiles along with build/install scripts
- `helper_scripts/`: store helper bash functions used within this repo
- `reference/`: store handy template files, like a basic C Makefile, a static IP address interfaces
  file, etc
- `submodules/`: submodules get loaded here
- `system_files/`: config files that get placed around the filesystem, like `.bashrc`, `.vimrc`,
  etc.
- `wsl/`: scripts and files that make sense only in the WSL environment

## WSL
I'm a fan of the Windows Subsystem for Linux (WSL), and it turns out basically all of the
configuration files and most of the programs used in actual Linux can still be used in WSL. Some
things _only_ make sense in WSL, like using [Chocolatey](https://github.com/chocolatey/choco) to
install Windows programs from bash.

## Sharing
You are 100% free to use anything from this repo. It has proven very handy for me. Always open to
additional tips and pull requests as well.
