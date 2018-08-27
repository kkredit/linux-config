#!/bin/bash

FILES_DIR=system-files

install -m 644 $FILES_DIR/bashrc $HOME/.bashrc
install -m 644 $FILES_DIR/vimrc $HOME/.vimrc
install -m 644 $FILES_DIR/xinitrc $HOME/.xinitrc
install -m 644 $FILES_DIR/Xmodmap $HOME/.Xmodmap

if [ ! -f $HOME/.gerritrc ]; then
    #install -m 644 $FILES_DIR/gerritrc $HOME/.gerritrc
    echo .gerritrc not installed by default
fi

if [ ! -f $HOME/.gitconfig ]; then
    install -m 644 $FILES_DIR/gitconfig $HOME/.gitconfig
fi

sudo install -m 755 $FILES_DIR/git-log-compact /usr/local/bin/git-log-compact
sudo chown $USER:$USER /usr/local/bin/git-log-compact
