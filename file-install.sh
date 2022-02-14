#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source helper_scripts/local-helpers.sh

# Plain files
FILES_DIR=system_files
WSL_FILES_DIR=wsl

install -m 644 $FILES_DIR/zshrc.zsh ~/.zshrc
install -m 644 $FILES_DIR/bashrc.sh ~/.bashrc
install -m 644 $FILES_DIR/bash_profile.sh ~/.bash_profile
install -m 644 $FILES_DIR/bash_aliases.sh ~/.bash_aliases
install -m 644 $FILES_DIR/bash_functions.sh ~/.bash_functions
mkdir -p ~/.config
install -m 644 $FILES_DIR/starship.toml ~/.config/starship.toml
! $MAC || touch ~/.hushlogin
install -m 644 $FILES_DIR/dircolors.sh ~/.dircolors
install -m 644 $FILES_DIR/vimrc ~/.vimrc
mkdir -p ~/.config/nvim
install -m 644 $FILES_DIR/init.vim ~/.config/nvim/init.vim
mkdir -p ~/.config/alacritty
install -m 644 $FILES_DIR/alacritty.yml ~/.config/alacritty/alacritty.yml
mkdir -p ~/.config/zellij
install -m 644 $FILES_DIR/zellij.yaml ~/.config/zellij/config.yaml
install -m 644 $FILES_DIR/coc-settings.nvim.json ~/.config/nvim/coc-settings.json
install -m 644 $FILES_DIR/xinitrc ~/.xinitrc
install -m 644 $FILES_DIR/Xmodmap ~/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf ~/.tmux.conf
install -m 644 $FILES_DIR/gerrit_functions.sh ~/.gerrit_functions.sh
install -m 644 $FILES_DIR/gitconfig ~/.gitconfig
install -m 644 $FILES_DIR/gitignore_global ~/.gitignore_global
install -m 644 $FILES_DIR/unibeautifyrc.json ~/.unibeautifyrc.json
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

  pushd submodules/autojump > /dev/null || true
  ./install.py > /dev/null
  popd > /dev/null || true
fi

mkdir -p ~/bin

printf 'y\ny\nn\n' | ./submodules/fzf/install &> /dev/null
install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
cp -r submodules/diff-so-fancy/lib ~/bin/
install -m 755 submodules/git-log-compact/git-log-compact \
    ~/bin/git-log-compact
install -m 755 submodules/tldr-sh-client/tldr ~/bin/tldr

# Install Alacritty
if has_arg "alacritty"; then
  if ! which cargo &>/dev/null; then
    echo "!! Must install Rust to install Alacritty (with ligatures)"
    exit 1
  fi

  pushd submodules/alacritty-ligature > /dev/null || true
  if $MAC; then
    make app
    cp -r target/release/osx/Alacritty.app /Applications/
  else
    apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
    cargo build --release
  fi
  popd > /dev/null || true
fi
