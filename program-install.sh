#!/usr/bin/env bash
source helper_scripts/has-arg.sh
source helper_scripts/install.sh

UBU_REL=$(lsb_release -cs)

# Preliminary update
sudo-pkg-mgr update && sudo-pkg-mgr upgrade -y
sudo-pkg-mgr autoremove

if has_arg "update"; then
    # update only; exit
    exit $?
fi

# Basic tools
sudo-pkg-mgr install -y \
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
    ncdu \
    pdfgrep \
    screen \
    repo \
    dos2unix

if has_arg "git"; then
    # This adds a new remote repo that hosts more up-to-date versions of git
    sudo add-apt-repository ppa:git-core/ppa
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade git -y
fi

if has_arg "writing"; then
    sudo-pkg-mgr install -y \
        aspell \
        aiksaurus \
        python3-proselint \
        pandoc
fi

if has_arg "keys"; then
    sudo-pkg-mgr install -y \
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
fi

if has_arg "postgresql"; then
    sudo-pkg-mgr install -y
        libpq-dev \
        postgresql-client-common \
        postgresql-client \
        postgresql
    echo "If running with Ruby on Rails, do a"
    echo "  \"gem install pg -v '1.1.4' --source 'https://rubygems.org'\""
    echo
    echo "To run, do"
    echo "  \"sudo service postgresql start\""
    echo "  \"sudo -u postgres psql -c \"ALTER USER postgres PASSWORD 'postgres';\""
    echo "  <do stuff>"
    echo "  \"sudo service postgresql stop\""
    echo "To test, do"
    echo "  \"psql -p 5432 -h localhost -U postgres\""
fi

if has_arg "react"; then
    sudo-pkg-mgr install npm
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
    sudo-pkg-mgr install -y nodejs
    sudo npm install -g create-react-app
fi

if has_arg "python"; then
    sudo-pkg-mgr install python-pip

    # Virtual environments: see https://realpython.com/python-virtual-environments-a-primer/
    pip install --user \
        virtualenv \
        virtualenvwrapper
    echo "source virtualenvwrapper.sh" >> ~/.bashrc_local
fi

if has_arg "grip"; then
    if [[ "" == $(which pip) ]]; then
        echo "install python pip first; '$0 python'"
        exit 1
    fi
    pip install --user grip
fi

if has_arg "latex"; then
    sudo-pkg-mgr install -y \
        texstudio \
        texlive-latex-extra \
        texlive-science # for IEEE papers
fi

if has_arg "docker"; then
    # Docker
    sudo-pkg-mgr install -y \
        apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    APT_REPO="https://download.docker.com/linux/ubuntu"
    if [[ 0 = $(apt-cache policy | grep "$APT_REPO" | wc -l) ]]; then
        sudo add-apt-repository "deb [arch=amd64] $APT_REPO $UBU_REL stable"
    fi
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y \
        docker-ce

    sudo groupadd docker
    sudo usermod -aG docker $USER
fi

if has_arg "wireshark"; then
    # Wireshark
    sudo-pkg-mgr install -y wireshark
    sudo dpkg-reconfigure wireshark-common
    sudo usermod -a -G wireshark $USER
fi

if has_arg "enpass"; then
    # Enpass
    echo "deb http://repo.sinew.in/ stable main" | \
        sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y enpass
fi

if has_arg "signal"; then
    # Signal
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
        sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo-pkg-mgr update && sudo-pkg-mgr install signal-desktop
fi

if has_arg "pigdin"; then
    # Pigdin w/Facebook chat plugin
    sudo-pkg-mgr install -y \
        libcanberra-gtk-module:i386 \
        pigdin
    curl -s http://download.opensuse.org/repositories/home:/jgeboski/xUbuntu_$(lsb_release -rs)/Release.key | \
        sudo apt-key add -
    sudo-pkg-mgr update && sudo-pkg-mgr install purple-facebook
fi

