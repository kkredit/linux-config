
# Linux-config

## Purpose

This is a collection of scripts and config files that keep my Linux environment portable and in
sync. It is mostly Ubuntu-oriented.

## Usage

To install config files to appropriate locations on the filesystem, run

```sh
./file-install.sh [update] [submodules]
```

`update` installs some programs from the web, and `submodules` option initializes or updates the
submodules. Nothing in this script requires root privileges.

To install programs, run

```sh
./program-install.sh [update | some-prog]
```

`update` runs an `apt-get update/upgrade` sequence and exits. `some-prog` causes the script to
install one or more less used or more complex program installs, such as `ruby` for an RVM
installation or `wireshark` to install the program and manage the groups. Running this script
requires root privileges.

## File Structure

- `helper_scripts/`: helper bash functions used within this repo
- `reference/`: handy template files, like a Makefile templates, a static IP interfaces template,
  etc.
- `submodules/`: cloned submodules
- `system_files/`: config files that get placed around the filesystem, like `.bashrc`, `.vimrc`,
  etc.
- `wsl/`: scripts and files that make sense only in the WSL environment

## Sharing

You are 100% free to use anything from this repo. Please contribute your tips and tricks as well.

I've considered making this more modular so that it could be easily forked and shared, but I find
that the real value is in making your config your own. Fork or copy this repo, then tear out my
content and replace it with your own as you build it up over time.
