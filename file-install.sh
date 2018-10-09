#!/bin/bash

# Plain files
FILES_DIR=system-files

install -m 644 $FILES_DIR/bashrc ~/.bashrc
install -m 644 $FILES_DIR/bash_aliases ~/.bash_aliases
install -m 644 $FILES_DIR/vimrc ~/.vimrc
install -m 644 $FILES_DIR/xinitrc ~/.xinitrc
install -m 644 $FILES_DIR/Xmodmap ~/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf ~/.tmux.conf

if [ ! -f ~/.gerritrc ]; then
    install -m 644 $FILES_DIR/gerritrc ~/.gerritrc
fi

if [ ! -f ~/.gitconfig ]; then
    install -m 644 $FILES_DIR/gitconfig ~/.gitconfig
fi

# Program files
PROG_FILES=( \
    lan-ip \
    wan-ip \
    git-author-rewrite.sh \
    )

mkdir -p ~/bin
for FILE in "${PROG_FILES[@]}"; do
    install -m 755 $FILES_DIR/$FILE ~/bin/$FILE
done

# Submodules files
if [ ! -d submodules ]; then
    git submodule init
    git submodule update --init --force --remote
fi
git submodule update &> /dev/null

printf 'y\ny\nn\n' | ./submodules/fzf/install &> /dev/null
install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
cp -r submodules/diff-so-fancy/lib ~/bin/
install -m 755 submodules/git-log-compact/git-log-compact \
    ~/bin/git-log-compact
