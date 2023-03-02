#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source helper_scripts/local-helpers.sh

# Plain files
FILES_DIR=system_files
WSL_FILES_DIR=wsl

install -m 644 $FILES_DIR/bashrc.sh ~/.bashrc
install -m 644 $FILES_DIR/bash_profile.sh ~/.bash_profile
install -m 644 $FILES_DIR/zprofile.zsh ~/.zprofile
install -m 644 $FILES_DIR/bash_aliases.sh ~/.bash_aliases
sed -i "s,REPO_DIR,$(pwd),g" ~/.bash_aliases
install -m 644 $FILES_DIR/bash_functions.sh ~/.bash_functions
install -m 644 $FILES_DIR/shrc_common.sh ~/.shrc_common
install -m 644 $FILES_DIR/zshrc.zsh ~/.zshrc
mkdir -p ~/.config
install -m 644 $FILES_DIR/starship.toml ~/.config/starship.toml
! $MAC || touch ~/.hushlogin
install -m 644 $FILES_DIR/dircolors.sh ~/.dircolors
install -m 644 $FILES_DIR/vimrc ~/.vimrc
mkdir -p ~/.config/nvim
install -m 644 $FILES_DIR/nvim_init.lua ~/.config/nvim/init.lua
mkdir -p ~/.config/alacritty
install -m 644 $FILES_DIR/alacritty.yml ~/.config/alacritty/alacritty.yml
if ! $MAC; then
  sed -i 's/decorations: buttonless/decorations: full/' ~/.config/alacritty/alacritty.yml
  sed -i 's/size: 13/size: 11/' ~/.config/alacritty/alacritty.yml
fi
mkdir -p ~/.config/zellij
install -m 644 $FILES_DIR/zellij_config.kdl ~/.config/zellij/config.kdl
install -m 644 $FILES_DIR/zellij_layout.kdl ~/.config/zellij/layout.kdl
install -m 644 $FILES_DIR/zellij_layout_full.kdl ~/.config/zellij/layout_full.kdl
install -m 644 $FILES_DIR/xinitrc ~/.xinitrc
install -m 644 $FILES_DIR/Xmodmap ~/.Xmodmap
install -m 644 $FILES_DIR/gerrit_functions.sh ~/.gerrit_functions.sh
install -m 644 $FILES_DIR/gitconfig ~/.gitconfig
install -m 644 $FILES_DIR/gitignore_global ~/.gitignore_global
install -m 644 $FILES_DIR/ripgreprc ~/.ripgreprc

# WSL files
if $WSL; then
  install -m 644 $WSL_FILES_DIR/bashrc_wsl.sh ~/.bashrc_wsl
  unix2dos -n $FILES_DIR/gitconfig_windows "$(wslpath 'C:/ProgramData/Git/config')" 2>/dev/null
  unix2dos -n $FILES_DIR/gitignore_global "$(wslpath 'C:/ProgramData/Git/gitignore_global')" 2>/dev/null
fi

if has_arg "dconf"; then
  echo "To generate dconf dump: 'dconf dump / > system_files/dconf_ubuntu.dump'"
  echo "To load dconf dump: 'dconf load / < system_files/dconf_ubuntu.dump'"
fi

# Submodules files
if has_arg "submodules" || [[ 0 == $(find submodules/ -type f | wc -l) ]]; then
  git submodule init
  git submodule update --init --force --remote
fi

mkdir -p ~/bin

printf 'y\ny\nn\n' | ./submodules/fzf/install &> /dev/null
install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
cp -r submodules/diff-so-fancy/lib ~/bin/
install -m 755 submodules/git-log-compact/git-log-compact \
    ~/bin/git-log-compact
install -m 755 submodules/tldr-sh-client/tldr ~/bin/tldr

# Install Entr
if has_arg "entr"; then
  pushd submodules/entr > /dev/null || true
  ./configure
  make test
  make install
  popd > /dev/null || true
fi

# Install Alacritty
if has_arg "alacritty"; then
  if ! which cargo &>/dev/null; then
    echo "!! Must install Rust to install Alacritty (with ligatures)"
    exit 1
  fi

  pushd submodules/alacritty-ligature > /dev/null || true
  if $MAC; then
    make app
    sudo cp -r target/release/osx/Alacritty.app /Applications/
  else
    sudo apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
    cargo build --release
    cp target/release/alacritty ~/bin
    if ! $WSL; then
      # Install desktop shortcut
      sudo cp target/release/alacritty /usr/local/bin # or anywhere else in $PATH
      sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
      sudo desktop-file-install extra/linux/Alacritty.desktop
      sudo update-desktop-database
    fi
  fi
  if ! infocmp alacritty &>/dev/null; then
    sudo tic -xe alacritty,alacritty-direct extra/alacritty.info
  fi
  popd > /dev/null || true

fi
