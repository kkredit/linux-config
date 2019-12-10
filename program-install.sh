#!/usr/bin/env bash
source helper_scripts/source-all-helpers.sh

UBU_REL=$(lsb_release -cs)

# Update & exit
if has_arg "update"; then
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade -y
    sudo-pkg-mgr autoremove
    exit $?
fi

# Basic tools
if has_arg "basic"; then
    sudo-pkg-mgr install -y \
        vim \
        git \
        tmux \
        lynx \
        curl \
        tree \
        net-tools \
        htop \
        ncdu \
        pdfgrep \
        screen \
        repo \
        dos2unix
fi

# Other tools

if has_arg "dev"; then
    sudo-pkg-mgr install -y \
        gcc \
        g++ \
        make \
        lcov \
        libc6-dev-i386
fi

if has_arg "vscodium"; then
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | \
        sudo apt-key add -
    echo 'deb https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/repos/debs/ vscodium main' |\
        sudo tee --append /etc/apt/sources.list.d/vscodium.list
    sudo-pkg-mgr update && sudo-pkg-mgr install codium
    FILES_DIR=system_files
    cat $FILES_DIR/VSCodium/extensions.txt | xargs -n 1 codium --install-extension
fi

if has_arg "firacode"; then
    fonts_dir="${HOME}/.local/share/fonts"
    if [ ! -d "${fonts_dir}" ]; then
        echo "mkdir -p $fonts_dir"
        mkdir -p "${fonts_dir}"
    else
        echo "Found fonts dir $fonts_dir"
    fi

    for type in Bold Light Medium Regular Retina; do
        file_path="${HOME}/.local/share/fonts/FiraCode-${type}.ttf"
        file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
        if [ ! -e "${file_path}" ]; then
            echo "wget -O $file_path $file_url"
            wget -O "${file_path}" "${file_url}"
        else
            echo "Found existing file $file_path"
        fi;
    done

    echo "fc-cache -f"
    fc-cache -f

    if [[ "1" == "$WSL" ]]; then
        choco install firacode
    fi
fi

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
    echo "Now go to keyboard -> additional layout options"
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

if has_arg "rvm"; then
    sudo-pkg-mgr install -y \
        software-properties-common

    sudo apt-add-repository -y ppa:rael-gc/rvm
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y \
        rvm

    sudo usermod -a -G rvm $USER
    echo
    echo "Set 'Terminal preferences > Command' to run as a login shell"
    echo "Reboot before you use RVM"
    echo
fi

if has_arg "ruby"; then
    if [[ ! $(which rvm) ]]; then
        echo "Install RVM first"
        exit 1
    fi

    rvm install ruby-head
    rvm install $RUBY_VERSION
    rvm --default use $RUBY_VERSION
fi

if has_arg "gems"; then
    sudo-pkg-mgr install -y \
        ruby-dev \
        ruby$(ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]')-dev

    rvm @global do gem install \
        bundler \
        solargraph
fi

if has_arg "postman"; then
    sudo snap install postman
fi

if has_arg "mysql"; then
    sudo-pkg-mgr install -y \
        libmysqlclient-dev \
        mysql-workbench
fi

if has_arg "postgresql"; then
    sudo-pkg-mgr install -y \
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

if has_arg "node"; then
    sudo-pkg-mgr install npm
    curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
    sudo-pkg-mgr install -y nodejs
    sudo chown -R $USER:$(id -gn $USER) ~/.config
    sudo chown -R $USER:$(id -gn $USER) /usr/lib/node_modules/
    export NODE_PATH='/usr/lib/node_modules'
    echo "export NODE_PATH='/usr/lib/node_modules'" >> ~/.bashrc_local
    # should be able to 'npm install -g' without sudo now
fi

if has_arg "react"; then
    if [[ "" == $(which npm) ]]; then
        echo "install node first; '$0 node'"
        exit 1
    fi
    npm install -g create-react-app
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

if has_arg "drawio"; then
    URL="$(curl -s https://about.draw.io/integrations/ | grep "draw.io-amd64-*.*.*.deb" | \
           head -1 | sed -E 's,.*(https://.*draw.io-amd64-*.*.*[0-9].deb).*,\1,')"
    wget -q $URL
    sudo dpkg -i draw.io-amd64-*.*.*.deb
    sudo apt --fix-broken install -y
    rm draw.io-amd64-*.*.*.deb
fi

if has_arg "latex"; then
    sudo-pkg-mgr install -y \
        texlive-latex-extra \
        texlive-science \
        texlive-xetex \
        texlive-generic-extra \
        texlive-publishers \
        latexmk
fi

if has_arg "texstudio"; then
    if [[ "1" != "$WSL" ]]; then
        if [[ ! $(which xelatex) ]]; then
            echo "Install latex first"
            exit 1
        fi

        sudo-pkg-mgr install -y \
            texstudio
    else # Windows
        choco install texstudio
        wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe
        mv install-tl-windows.exe $WSL_DKTP/
        run_cmd $(wslpath -w $WSL_DKTP/install-tl-windows.exe)
        rm $WSL_DKTP/install-tl-windows.exe
    fi
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
    if [[ "" == "$WSL" ]]; then
        sudo-pkg-mgr install -y wireshark
        sudo dpkg-reconfigure wireshark-common
        sudo usermod -a -G wireshark $USER
        echo
        echo "Log out and back in before you use wireshark"
        echo
    else
        choco install -y winpcap wireshark
    fi
fi

if has_arg "enpass"; then
    # Enpass
    echo "deb http://repo.sinew.in/ stable main" | \
        sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y enpass
    xdg-open https://www.enpass.io/downloads/#extensions
    echo "NOTICE: Install the Firefox extension from the browser."
fi

if has_arg "signal"; then
    # Signal
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
        sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo-pkg-mgr update && sudo-pkg-mgr install signal-desktop
fi

if has_arg "sonarqube"; then
    sudo mkdir -p /opt/sonarqube
    sudo chown $USER:$USER -R /opt/sonarqube

    URL="$(curl -s https://www.sonarqube.org/downloads/ | \
           grep 'href=' | grep Community | head -1 | cut -d\" -f4)"
    wget -q $URL
    FILE=$(ls sonarqube-*.zip)
    if [[ "" == "$FILE" ]]; then
        echo "SonarQube download failed; update URL determination command"
        echo "URL: $URL"
        exit 1
    fi
    unzip $FILE -d /opt/sonarqube
    rm $FILE

    URL="$(curl -s https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/ | \
           grep 'href=' | grep Linux | rev | cut -d\" -f4 | rev)"
    wget -q $URL
    FILE=$(ls sonar-scanner-cli-*.zip)
    if [[ "" == "$FILE" ]]; then
        echo "SonarScanner download failed; update URL determination command"
        echo "URL: $URL"
        exit 1
    fi
    unzip $FILE -d /opt/sonarqube
    rm $FILE
fi

if has_arg "chrome"; then
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | \
        sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo-pkg-mgr update
    sudo-pkg-mgr install google-chrome-stable
fi

