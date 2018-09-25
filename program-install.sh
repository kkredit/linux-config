#!/bin/bash

UBU_REL=$(lsb_release -cs)
ARGS=$(echo "$@" | tr '[:upper:]' '[:lower:]')

has_arg() {
    if [[ 1 = $(echo $ARGS | grep "all" | wc -l) ]]; then
        true
    elif [[ 1 = $(echo $ARGS | grep $1 | wc -l) ]]; then
        true
    else
        false
    fi
}

# Preliminary update
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove

if has_arg "update"; then
    # update only; exit
    exit $?
fi

# Basic tools
sudo apt-get install -y \
    vim \
    git \
    tmux \
    pandoc \
    lynx \
    gcc \
    curl \
    tree \
    net-tools \
    tldr \
    pdfgrep

# Google repo
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/usr/bin/repo
chmod a+x ~/usr/bin/repo

# Map /bin/sh to /bin/bash
sudo mv /bin/sh /bin/sh.bak
sudo ln -s /bin/bash /bin/sh

if has_arg "bat"; then
    echo "Download latest amd64 package from opened page and exit Firefox"
    firefox https://github.com/sharkdp/bat/releases
    sudo dpkg -i ~/Downloads/bat_*_amd64.deb
    rm ~/Downloads/bat_*_amd64.deb
fi

if has_arg "docker"; then
    # Docker
    sudo apt-get install -y \
        apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    APT_REPO="https://download.docker.com/linux/ubuntu"
    if [[ 0 = $(apt-cache policy | grep "$APT_REPO" | wc -l) ]]; then
        sudo add-apt-repository "deb [arch=amd64] $APT_REPO $UBU_REL stable"
    fi
    sudo apt-get update
    sudo apt-get install -y \
        docker-ce

    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

if has_arg "enpass"; then
    # Enpass
    echo "deb http://repo.sinew.in/ stable main" | \
        sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y enpass
fi

if has_arg "signal"; then
    # Signal
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
        sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo apt update && sudo apt install signal-desktop
fi

if has_arg "pigdin"; then
    # Pigdin w/Facebook chat plugin
    sudo apt-get install -y \
        libcanberra-gtk-module:i386 \
        pigdin
    curl -s http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_$(lsb_release -rs)/Release.key | \
        sudo apt-key add -
    sudo apt update && sudo apt install purple-facebook
fi

