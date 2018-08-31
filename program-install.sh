#!/bin/bash

UBU_REL=$(lsb_release -cs)

# Preliminary update
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get autoremove

# Basic tools
sudo apt-get install -y \
    vim \
    git \
    tmux \
    pandoc \
    lynx \
    gcc \
    curl \
    tree

# Map /bin/sh to /bin/bash
sudo mv /bin/sh /bin/sh.bak
sudo ln -s /bin/bash /bin/sh

# Non-trivial installs; perform if called with argument
if [[ 0 < $# ]]; then

    # Docker
    sudo apt-get install -y \
        apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository \
        "deb [arch=amd64] https://download.docker.com/linux/ubuntu $UBU_REL stable"
    sudo apt-get update
    sudo apt-get install -y \
        docker-ce

    sudo groupadd docker
    sudo usermod -aG docker $USER

    # Enpass
    echo "deb http://repo.sinew.in/ stable main" | \
        sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y enpass

    # Signal
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
        sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo apt update && sudo apt install signal-desktop

fi
