#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source helper_scripts/local-helpers.sh

if ! $MAC; then
    UBU_REL=$(lsb_release -cs)
fi

# Update & exit
if has_arg "update"; then
    set -e
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade -y
    sudo-pkg-mgr autoremove
    $WSL || sudo snap refresh
fi

# Basic tools
if has_arg "basic"; then
    if $MAC; then
        [ -f ~/.dircolors ] || git clone https://github.com/gibbling666/dircolors.git ~/.dircolors
        brew install \
            grep \
            coreutils \
            vim \
            neovim \
            git \
            tmux \
            lynx \
            tree \
            htop \
            ncdu \
            shellcheck
        brew install --cash iterm2
    else
        sudo-pkg-mgr install -y \
            vim \
            neovim \
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
            dos2unix \
            python \
            inotify-tools \
            shellcheck
    fi
fi

# Other tools

if has_arg "dev"; then
    sudo-pkg-mgr install -y \
        gcc \
        g++ \
        make \
        lcov \
        libc6-dev-i386 \
        jq
fi

if has_arg "utilities"; then
    if [[ $(which cargo) ]]; then
        cargo install \
          exa \
          watchexec \
          pipe-rename \
          procs \
          shy
    fi

    # Bat (https://github.com/sharkdp/bat)
    curl -s https://api.github.com/repos/sharkdp/bat/releases/latest \
        | grep "browser_download_url.*x86_64-unknown-linux-gnu.tar.gz" \
        | cut -d : -f 2,3 \
        | tr -d \" \
        | wget -qi -
    tar -xf bat*linux-gnu.tar.gz
    cp -r bat*linux-gnu/bat bat*linux-gnu/bat.1 bat*linux-gnu/autocomplete ~/bin/
    rm -rf bat*linux-gnu*

    # Fd (https://github.com/sharkdp/fd)
    # NOTE: Can use officially maintained package with Ubuntu 19+
    #sudo apt install fd-find
    URL="https://github.com$(curl -Ls https://github.com/sharkdp/fd/releases/latest |
                               grep -m 1 "x86_64-unknown-linux-gnu.tar.gz" | cut -d\" -f2)"
    wget -q "$URL"
    tar -xf fd*linux-gnu.tar.gz
    cp -r fd*linux-gnu/fd fd*linux-gnu/fd.1 fd*linux-gnu/autocomplete ~/bin/
    rm -rf fd*linux-gnu*
fi

if has_arg "cheat"; then
    curl https://cht.sh/:cht.sh > ~/bin/cht.sh
    chmod +x ~/bin/cht.sh
fi

if has_arg "silicon"; then
    sudo-pkg-mgr install expat
    sudo-pkg-mgr install libxml2-dev
    sudo-pkg-mgr install pkg-config libasound2-dev libssl-dev cmake libfreetype6-dev libexpat1-dev \
        libxcb-composite0-dev
    cargo install silicon
fi

if has_arg "vscodium"; then
    if $MAC; then
        brew install --cask vscodium
    else
        snap install codium --classic
    fi
    FILES_DIR=system_files
    codium --install-extension < $FILES_DIR/VSCodium/extensions.txt
fi

if has_arg "gitsecrets"; then
    wget -q https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets
    install -m 755 git-secrets ~/bin
    rm git-secrets
fi

if has_arg "fonts"; then
    fonts_dir="${HOME}/.local/share/fonts"
    if [ ! -d "${fonts_dir}" ]; then
        echo "mkdir -p $fonts_dir"
        mkdir -p "${fonts_dir}"
    else
        echo "Found fonts dir $fonts_dir"
    fi

    # Firacode
    for type in Bold Light Medium Regular Retina; do
        file_path="${HOME}/.local/share/fonts/FiraCode-${type}.ttf"
        file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
        if [ ! -e "${file_path}" ]; then
            echo "wget -O $file_path $file_url"
            wget -O "${file_path}" "${file_url}"
        else
            echo "Found existing file $file_path"
        fi
    done

    # ArgVu
    file_path="${HOME}/.local/share/fonts/ArgVuSansMono-Regular-8.2.otf"
    file_url="https://github.com/christianvoigt/argdown/raw/master/packages/ArgVu/ArgVuSansMono-Regular-8.2.otf"
    if [ ! -e "${file_path}" ]; then
        echo "wget -O $file_path $file_url"
        wget -O "${file_path}" "${file_url}"
    else
        echo "Found existing file $file_path"
    fi

    if ! $MAC; then
        echo "fc-cache -f"
        fc-cache -f
    else
        brew tap homebrew/cask-fonts
        brew install --cask \
            font-fira-code \
            font-fira-mono \
            font-fira-sans
    fi

    if $WSL; then
        choco install firacode
        echo "Download and install ArgVu from https://github.com/christianvoigt/argdown/raw/master/packages/ArgVu/ArgVuSansMono-Regular-8.2.otf"
    fi
fi

if has_arg "git"; then
    # This adds a new remote repo that hosts more up-to-date versions of git
    sudo add-apt-repository ppa:git-core/ppa
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade git -y

    # Install git-extras
    sudo-pkg-mgr install -y git-extras
    sudo rm "$(which git-alias)" # My 'alias' alias is better!
fi

if has_arg "writing"; then
    sudo-pkg-mgr install -y \
        aspell \
        aiksaurus \
        python3-proselint \
        pandoc
fi

if has_arg "pandoc"; then
    URL="https://github.com$(curl -Ls https://github.com/jgm/pandoc/releases/latest | grep -m1 "amd64.deb" | \
                                cut -d\" -f2)"
    wget -q --show-progress "$URL"
    sudo dpkg -i pandoc-*-amd64.deb
    rm pandoc-*-amd64.deb
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

    sudo usermod -a -G rvm "$USER"
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
    rvm install "$RUBY_VERSION"
    rvm --default use "$RUBY_VERSION"
fi

if has_arg "gems"; then
    sudo-pkg-mgr install -y \
        ruby-dev \
        ruby"$(ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]')"-dev

    rvm @global 'do' gem install \
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
    curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
    sudo-pkg-mgr install -y nodejs
    sudo chown -R "$USER":"$(id -gn "$USER")" ~/.config
    sudo chown -R "$USER":"$(id -gn "$USER")" /usr/lib/node_modules/
    export NODE_PATH='/usr/lib/node_modules'
    echo "export NODE_PATH='/usr/lib/node_modules'" >> ~/.profile
    # should be able to 'npm install -g' without sudo now
fi

if has_arg "react"; then
    if [[ "" == $(which npm) ]]; then
        echo "install node first; '$0 node'"
        exit 1
    fi
    npm install -g create-react-app
fi

if has_arg "yarn"; then
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
        sudo tee /etc/apt/sources.list.d/yarn.list
    if which nvm &>/dev/null; then
        sudo apt update && sudo apt install --no-install-recommends yarn
    else
        sudo apt update && sudo apt install yarn
    fi
fi

if has_arg "argdown"; then
    if [[ "" == $(which npm) ]]; then
        echo "install node first; '$0 node'"
        exit 1
    fi
    # Should not need sudo
    sudo npm install -g @argdown/cli
fi

if has_arg "golang"; then
    URL="$(curl -s https://golang.org/dl/ | grep "linux-amd64.tar.gz" | head -1 | cut -d\" -f4)"
    FILE="$(echo "$URL" | rev | cut -d/ -f1 | rev)"
    INST_DIR=/usr/local

    echo "Downloading $URL..."
    wget -q --show-progress "$URL"
    echo "Untarring $FILE into $INST_DIR..."
    sudo tar -C $INST_DIR -xzf "$FILE"
    rm "$FILE"

    if echo "$PATH" | grep -v "go/bin" &>/dev/null; then
        echo "Adding $INST_DIR/go/bin to ~/.profile..."
        echo "export PATH=\$PATH:$INST_DIR/go/bin" >> ~/.profile
        echo "Run 'export PATH=\$PATH:$INST_DIR/go/bin'"
    fi
fi

if has_arg "haskell"; then
    sudo-pkg-mgr install haskell-platform
    # Stack is a package manager for Haskell, but installation is broken :(
    #curl -sSL https://get.haskellstack.org/ | sh
fi

if has_arg "rust"; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

if has_arg "clojure"; then
    sudo apt-get install -y \
        curl \
        rlwrap

    wget -q https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein
    chmod +x lein
    mv lein ~/bin/

    which java || sudo apt-get install -y default-jdk

    curl -O https://download.clojure.org/install/linux-install-1.10.1.536.sh
    chmod +x linux-install-1.10.1.536.sh
    sudo ./linux-install-1.10.1.536.sh
    rm ./linux-install-1.10.1.536.sh
fi

if has_arg "python"; then
    sudo-pkg-mgr install python3-pip

    # Virtual environments: see https://realpython.com/python-virtual-environments-a-primer/
    pip install --user \
        virtualenv \
        virtualenvwrapper
    echo "source virtualenvwrapper.sh" >> ~/.profile
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
    wget -q --show-progress "$URL"
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
    if $WSL; then
        if [[ ! $(which xelatex) ]]; then
            echo "Install latex first"
            exit 1
        fi

        sudo-pkg-mgr install -y \
            texstudio
    else # Windows
        choco install texstudio
        wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-windows.exe
        mv install-tl-windows.exe "$WSL_DKTP"/
        run_cmd "$(wslpath -w "$WSL_DKTP"/install-tl-windows.exe)"
        rm "$WSL_DKTP"/install-tl-windows.exe
    fi
fi

if has_arg "docker"; then
    # Docker
    sudo-pkg-mgr install -y \
        apt-transport-https ca-certificates curl software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    APT_REPO="https://download.docker.com/linux/ubuntu"
    if ! apt-cache policy | grep -q "$APT_REPO"; then
        sudo add-apt-repository "deb [arch=amd64] $APT_REPO $UBU_REL stable"
    fi
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y \
        docker-ce

    # Docker installation process should create group 'docker'
    # sudo groupadd docker
    sudo usermod -aG docker "$USER"

    # Docker Compose
    URL="https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)"
    sudo curl -L "$URL" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

if has_arg "wireshark"; then
    # Wireshark
    if $WSL; then
        sudo-pkg-mgr install -y wireshark
        sudo dpkg-reconfigure wireshark-common
        sudo usermod -a -G wireshark "$USER"
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
    sudo chown "$USER":"$USER" -R /opt/sonarqube

    URL="$(curl -s https://www.sonarqube.org/downloads/ | \
           grep 'href=' | grep Community | head -1 | cut -d\" -f4)"
    wget -q --show-progress "$URL"
    FILE=$(ls sonarqube-*.zip)
    if [[ "" == "$FILE" ]]; then
        echo "SonarQube download failed; update URL determination command"
        echo "URL: $URL"
        exit 1
    fi
    unzip "$FILE" -d /opt/sonarqube
    rm "$FILE"

    URL="$(curl -s https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/ | \
           grep 'href=' | grep Linux | rev | cut -d\" -f4 | rev)"
    wget -q --show-progress "$URL"
    FILE=$(ls sonar-scanner-cli-*.zip)
    if [[ "" == "$FILE" ]]; then
        echo "SonarScanner download failed; update URL determination command"
        echo "URL: $URL"
        exit 1
    fi
    unzip "$FILE" -d /opt/sonarqube
    rm "$FILE"
fi

if has_arg "chrome"; then
    wget -q --show-progress -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | \
        sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo-pkg-mgr update
    sudo-pkg-mgr install google-chrome-stable
fi

if has_arg "glow"; then
    URL="https://github.com$(curl -s https://github.com/charmbracelet/glow/releases | \
           grep linux_amd64.deb | head -1 | cut -d\" -f2)"
    wget -q --show-progress "$URL"
    FILE=$(ls glow_*_linux_amd64.deb)
    if [[ "" == "$FILE" ]]; then
        echo "Glow package download failed; update URL determination command"
        echo "URL: $URL"
        exit 1
    fi
    sudo dpkg -i "$FILE"
    rm "$FILE"
fi

if has_arg "awscli"; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    UPDATE=$(which aws &>/dev/null && echo '--update' || echo '')
    sudo ./aws/install "$UPDATE"
    aws --version
    rm -r awscliv2.zip aws
fi

if has_arg "awseb" || has_arg "elastic_beanstalk"; then
    sudo-pkg-mgr install -y \
        build-essential zlib1g-dev libssl-dev libncurses-dev \
        libffi-dev libsqlite3-dev libreadline-dev libbz2-dev
    git clone https://github.com/aws/aws-elastic-beanstalk-cli-setup.git
    ./aws-elastic-beanstalk-cli-setup/scripts/bundled_installer
    rm -rf ./aws-elastic-beanstalk-cli-setup
    if ! grep -q "ebcli" ~/.profile; then
        # shellcheck disable=SC2016
        echo 'export PATH="~/.ebcli-virtual-env/executables:$PATH"' >> ~/.profile
        echo 'Execute "source ~/.profile" to use eb.'
    fi
fi

if has_arg "awssam" || has_arg "aws_sam"; then
    if ! which docker &>/dev/null; then
        echo "The AWS SAM CLI requires Docker. See"
        echo "https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html"
        exit 1
    fi
    wget -q --show-progress "https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip"
    sha256sum aws-sam-cli-linux-x86_64.zip

    echo "Does the above SHA256 hash match the value expected according to the release notes?"
    echo "https://github.com/aws/aws-sam-cli/releases/latest"
    echo "[enter to continue, Ctrl-C to quit...]"
    read -rs

    unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
    sudo ./sam-installation/install
    sam --version
    rm -rf sam-installation aws-sam-cli-linux-x86_64.zip
fi

if has_arg "elm"; then
    curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
    gunzip elm.gz
    chmod +x elm
    mv elm ~/bin
    elm --help
    if which yarn &>/dev/null; then
        yarn global add create-elm-app elm-format elm-test elm-analyse
    fi
fi
