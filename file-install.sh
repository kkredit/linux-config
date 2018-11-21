#!/bin/bash

# Determine if WSL
WSL=0
if [[ $(uname -a | grep Microsoft | wc -l) > 0 ]]; then
    WSL=1
fi

# Plain files
FILES_DIR=system-files
WSL_DIR=system-files-wsl

install -m 644 $FILES_DIR/bashrc ~/.bashrc
install -m 644 $FILES_DIR/bash_aliases ~/.bash_aliases
install -m 644 $FILES_DIR/bash_prompt ~/.bash_prompt
if [[ -e ~/.bash-git-prompt ]]; then
    rm ~/.bash-git-prompt
fi;
ln -s $(pwd)/submodules/bash-git-prompt ~/.bash-git-prompt
if [[ $WSL ]]; then
    install -m 644 $WSL_DIR/custom.bgptheme ~/.git-prompt-colors.sh
else
    install -m 644 $FILES_DIR/custom.bgptheme ~/.git-prompt-colors.sh
fi
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
fi
git submodule update --init --force --remote &> /dev/null

printf 'y\ny\nn\n' | ./submodules/fzf/install &> /dev/null
install -m 755 submodules/diff-so-fancy/diff-so-fancy ~/bin/diff-so-fancy
cp -r submodules/diff-so-fancy/lib ~/bin/
install -m 755 submodules/git-log-compact/git-log-compact \
    ~/bin/git-log-compact
