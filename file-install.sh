#!/bin/bash

FILES_DIR=system-files

install -m 644 $FILES_DIR/bashrc $HOME/.bashrc
install -m 644 $FILES_DIR/vimrc $HOME/.vimrc
install -m 644 $FILES_DIR/xinitrc $HOME/.xinitrc
install -m 644 $FILES_DIR/Xmodmap $HOME/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf $HOME/.tmux.conf

if [ ! -f $HOME/.gerritrc ]; then
    #install -m 644 $FILES_DIR/gerritrc $HOME/.gerritrc
    echo .gerritrc not installed by default
fi

if [ ! -f $HOME/.gitconfig ]; then
    install -m 644 $FILES_DIR/gitconfig $HOME/.gitconfig
fi

PROG_FILES=( \
    git-log-compact \
    lan-ip \
    )

for FILE in "${PROG_FILES[@]}"; do
    sudo install -m 755 $FILES_DIR/$FILE /usr/local/bin/$FILE
    sudo chown $USER:$USER /usr/local/bin/$FILE
done
