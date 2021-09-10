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
    unix2dos -n $FILES_DIR/gitignore_global "$(wslpath 'C:/ProgramData/Git/gitignore_global')" \
        2>/dev/null
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
install -m 755 submodules/tldr/tldr ~/bin/tldr
if $DO_UPDATE; then
    pushd submodules/autojump > /dev/null || true
    ./install.py > /dev/null
    popd > /dev/null || true
fi
install -m 644 submodules/rails_completion/rails.bash ~/.rails.bash
install -m 644 submodules/forgit/forgit.plugin.sh ~/.forgit.plugin.sh
install -m 755 submodules/git-heatmap/git-heatmap ~/bin/

# VSCodium
if has_arg "codium" && [[ $(which codium) ]]; then
    if $MAC; then
        VSC_CONF_DIR=~/Library/Application\ Support/VSCodium/User
    else
        VSC_CONF_DIR=~/.config/VSCodium/User
    fi
    RUN_VSC=codium
    function INST_FILE() { install -m 644 "$@"; }
    function GET_FILE() { install -m 644 "$@"; }
    if $WSL; then
        VSC_CONF_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/VSCodium/User"
        RUN_VSC='run_cmd codium'
        function INST_FILE() { unix2dos -n "$1" "$2" 2>/dev/null; }
        function GET_FILE() { dos2unix -n "$1" "$2" 2>/dev/null; chmod 644 "$2"; }
    fi
    mkdir -p "$VSC_CONF_DIR"
    for FILE in keybindings.json settings.json; do
        if [[ ! -f "$VSC_CONF_DIR"/$FILE ]]; then
            INST_FILE $FILES_DIR/VSCodium/$FILE "$VSC_CONF_DIR"/$FILE
        elif [[ "" != "$(diff --strip-trailing-cr "$VSC_CONF_DIR"/$FILE \
                                                  $FILES_DIR/VSCodium/$FILE)" ]]
        then
            if [[ $(stat -c %Y "$VSC_CONF_DIR"/$FILE) < \
                  $(stat -c %Y system_files/VSCodium/$FILE) ]]
            then
                INST_FILE $FILES_DIR/VSCodium/$FILE "$VSC_CONF_DIR"/$FILE
            else
                GET_FILE "$VSC_CONF_DIR"/$FILE $FILES_DIR/VSCodium/$FILE
                echo "Local VSCodium $FILE settings newer than tracked. Settings copied here."
            fi
        fi
    done
    if ! $WSL; then
        EXTENSIONS=$($RUN_VSC --list-extensions | grep -v simple-vim | sed 's/\r//g')
        if [[ "$EXTENSIONS" != "$(cat $FILES_DIR/VSCodium/extensions.txt)" ]]
        then
            echo "$EXTENSIONS" > $FILES_DIR/VSCodium/extensions.txt
            echo "Local VSCodium extensions different than tracked. List updated here."
            echo "Determine desired list of extensions and run"
            echo "    cat system_files/VSCodium/extensions.txt | "
            echo "        xargs -n 1 -I {} bash -c \"$RUN_VSC --install-extension \\\$1\" _ {}"
        fi
    fi
fi
