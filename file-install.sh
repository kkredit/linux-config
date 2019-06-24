#!/usr/bin/env bash
source helper_scripts/has-arg.sh

# Plain files
FILES_DIR=system_files

install -m 644 $FILES_DIR/bashrc ~/.bashrc
install -m 644 $FILES_DIR/bash_aliases ~/.bash_aliases
install -m 644 $FILES_DIR/bash_prompt ~/.bash_prompt
if [[ -e ~/.bash-git-prompt ]]; then
    rm ~/.bash-git-prompt
fi
ln -s $(pwd)/submodules/bash-git-prompt ~/.bash-git-prompt
install -m 644 $FILES_DIR/custom.bgptheme ~/.git-prompt-colors.sh
install -m 644 $FILES_DIR/vimrc ~/.vimrc
install -m 644 $FILES_DIR/xinitrc ~/.xinitrc
install -m 644 $FILES_DIR/Xmodmap ~/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf ~/.tmux.conf
install -m 644 $FILES_DIR/gerrit_functions.sh ~/.gerrit_functions.sh
install -m 644 $FILES_DIR/gitconfig ~/.gitconfig
install -m 644 $FILES_DIR/gitignore_global ~/.gitignore_global

# Submodules files
DO_UPDATE=0
if [[ 0 == $(find submodules/ -type f | wc -l) ]]; then
    git submodule init
    git submodule update --init --force --remote &> /dev/null
    DO_UPDATE=1
elif has_arg "update"; then
    git submodule update --init --force --remote &> /dev/null
    DO_UPDATE=1
fi

mkdir -p ~/bin
printf 'y\ny\nn\n' | ./submodules/fzf/install &> /dev/null
install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
cp -r submodules/diff-so-fancy/lib ~/bin/
install -m 755 submodules/git-log-compact/git-log-compact \
    ~/bin/git-log-compact
install -m 755 submodules/tldr/tldr ~/bin/tldr
if [[ 1 == $DO_UPDATE ]]; then
    pushd submodules/autojump > /dev/null
    ./install.py > /dev/null
    popd > /dev/null
fi
