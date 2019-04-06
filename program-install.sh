#!/bin/bash
source helper_scripts/has-arg.sh

UBU_REL=$(lsb_release -cs)

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
    lynx \
    gcc \
    make \
    curl \
    tree \
    net-tools \
    htop \
    pdfgrep \
    screen \
    repo \
    dos2unix

if has_arg "writing"; then
    sudo apt-get install -y \
        aspell \
        aiksaurus \
        python3-proselint \
        pandoc
fi

if has_arg "keys"; then
    sudo apt-get install -y \
        gnome-tweak-tool
    gnome-tweaks &
    echo
    echo "Now got to keyboard -> additional layout options"
    echo
    echo "For pointer speed, do something like"
    echo "  xinput list; xinput list-props \"Your touchpad\";"
    echo "  xinput set-prop \"Your touchpad\" \"Accel setting\""
    echo "see also https://superuser.com/questions/229839/reduce-laptop-touch-pad-sensitivity-in-ubuntu"
fi

if has_arg "bash"; then
    # Map /bin/sh to /bin/bash
    if [[ ! -f /bin/sh.bak ]]; then
        sudo mv /bin/sh /bin/sh.bak
        sudo ln -s /bin/bash /bin/sh
    fi
fi

if has_arg "bat"; then
    # Bat (https://github.com/sharkdp/bat)
    curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
        | grep "browser_download_url.*amd64.deb" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
    sudo dpkg -i bat_*amd64.deb
    rm bat*
fi

if has_arg "ruby"; then
    curl -sSL https://get.rvm.io | bash -s -- --ignore-dotfiles
    echo "rvm_autoupdate_flag=2" >> ~/.rvmrc
    source $HOME/.rvm/scripts/rvm

    rvm install ruby-head
    RUBY_VER=2.6.0
    rvm install $RUBY_VER
    rvm use $RUBY_VER
    echo "source $HOME/.rvm/scripts/rvm" >> ~/.bashrc_local
    echo "rvm use $RUBY_VER" >> ~/.bashrc_local
fi

if has_arg "react"; then
    sudo apt install npm
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
    sudo apt-get install -y nodejs
    sudo npm install -g create-react-app
fi

if has_arg "python"; then
    sudo apt install python-pip

    # Virtual environments: see https://realpython.com/python-virtual-environments-a-primer/
    pip install --user \
        virtualenv \
        virtualenvwrapper
    echo "source virtualenvwrapper.sh" >> ~/.bashrc_local
fi

if has_arg "latex"; then
    sudo apt install -y \
        texstudio \
        texlive-latex-extra \
        texlive-science # for IEEE papers
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

if has_arg "wireshark"; then
    # Wireshark
    sudo apt-get install -y wireshark
    sudo dpkg-reconfigure wireshark-common
    sudo usermod -a -G wireshark $USER
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

