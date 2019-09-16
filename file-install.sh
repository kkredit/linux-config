#!/usr/bin/env bash
source helper_scripts/source-all-helpers.sh

# Plain files
FILES_DIR=system_files
WSL_FILES_DIR=wsl/files

install -m 644 $FILES_DIR/bashrc.sh ~/.bashrc
install -m 644 $FILES_DIR/bash_aliases.sh ~/.bash_aliases
install -m 644 $FILES_DIR/bash_functions.sh ~/.bash_functions
install -m 644 $FILES_DIR/bash_prompt.sh ~/.bash_prompt
if [[ -e ~/.bash-git-prompt ]]; then
    rm ~/.bash-git-prompt
fi
ln -s $(pwd)/submodules/bash-git-prompt ~/.bash-git-prompt
install -m 644 $FILES_DIR/custom.bgptheme ~/.git-prompt-colors.sh
install -m 644 $FILES_DIR/dircolors.sh ~/.dircolors
install -m 644 $FILES_DIR/vimrc ~/.vimrc
install -m 644 $FILES_DIR/xinitrc ~/.xinitrc
install -m 644 $FILES_DIR/Xmodmap ~/.Xmodmap
install -m 644 $FILES_DIR/tmux.conf ~/.tmux.conf
install -m 644 $FILES_DIR/gerrit_functions.sh ~/.gerrit_functions.sh
install -m 644 $FILES_DIR/gitconfig ~/.gitconfig
install -m 644 $FILES_DIR/gitignore_global ~/.gitignore_global

# WSL files
if [[ $(uname -a | grep -i microsoft) ]]; then
    install -m 644 $WSL_FILES_DIR/bashrc_wsl.sh ~/.bashrc_wsl
    unix2dos -n $FILES_DIR/gitconfig config 2>/dev/null
    sed -i 's,~/.gitignore_global,C:/ProgramData/Git/gitignore_global,g' config
    mv config $(winpath2wsl 'C:/ProgramData/Git/config')
    unix2dos -n $FILES_DIR/gitignore_global $(winpath2wsl 'C:/ProgramData/Git/gitignore_global') \
        2>/dev/null
fi

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
if [[ ! -L ~/bin/graphene ]]; then
    ln -s $(pwd)/submodules/graphene ~/bin/graphene
fi

# Other
if [[ 1 == $DO_UPDATE ]]; then
    # Bat (https://github.com/sharkdp/bat)
    curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
        | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
    tar -xf bat*linux-gnu.tar.gz
    cp -r bat*linux-gnu/bat bat*linux-gnu/bat.1 bat*linux-gnu/autocomplete ~/bin/
    rm -rf bat*linux-gnu*
fi
