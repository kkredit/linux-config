#!/bin/bash

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
    gcc

# Map /bin/sh to /bin/bash
sudo mv /bin/sh /bin/sh.bak
sudo ln -s /bin/bash /bin/sh

# Docker
sudo apt-get install -y \
    apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y \
    docker-ce

sudo groupadd docker
sudo usermod -aG docker $USER
