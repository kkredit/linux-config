#!/bin/bash

install -m 644 bashrc $HOME/.bashrc
install -m 644 vimrc $HOME/.vimrc
install -m 644 xinitrc $HOME/.xinitrc
install -m 644 Xmodmap $HOME/.Xmodmap

if [ ! -f $HOME/.gerritrc ]; then
    #install -m 644 gerritrc $HOME/.gerritrc
    echo .gerritrc not installed by default
fi

if [ ! -f $HOME/.gitconfig ]; then
    install -m 644 gitconfig $HOME/.gitconfig
fi

sudo install -m 755 git-log-compact /usr/local/bin/git-log-compact
