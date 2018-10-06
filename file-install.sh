#!/bin/bash

# Plain files
FILES_DIR=system-files

install -m 644 $FILES_DIR/bashrc $HOME/.bashrc
install -m 644 $FILES_DIR/vimrc $HOME/.vimrc
install -m 644 $FILES_DIR/xinitrc $HOME/.xinitrc
install -m 644 $FILES_DIR/Xmodmap $HOME/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf $HOME/.tmux.conf

if [ ! -f $HOME/.gerritrc ]; then
    #install -m 644 $FILES_DIR/gerritrc $HOME/.gerritrc
    echo ".gerritrc not installed by default"
fi

if [ ! -f $HOME/.gitconfig ]; then
    install -m 644 $FILES_DIR/gitconfig $HOME/.gitconfig
fi

# Program files
PROG_FILES=( \
    lan-ip \
    wan-ip \
    )

mkdir -p $HOME/bin
for FILE in "${PROG_FILES[@]}"; do
    install -m 755 $FILES_DIR/$FILE $HOME/bin/$FILE
done

# Submodules files
if [ ! -d submodules ]; then
    git submodule init
fi
git submodule update

printf 'y\ny\nn\n' | ./submodules/fzf/install
install -m 755 submodules/diff-so-fancy/diff-so-fancy $HOME/bin/diff-so-fancy
install -m 755 submodules/git-log-compact/git-log-compact \
    $HOME/bin/git-log-compact
