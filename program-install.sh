#!/usr/bin/env bash

cd "$(dirname "$0")" || exit

# shellcheck disable=SC1091
source helper_scripts/local-helpers.sh

if ! $MAC; then
  UBU_REL=$(lsb_release -cs)
fi

## Install tools or packages in functions
## Functions are called at the end

# Update & exit
function install_update {
  if $MAC; then
    brew upgrade
  else
    set -e
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade -y
    sudo-pkg-mgr autoremove
    $WSL || sudo snap refresh
  fi
}

# Basic tools
function install_basic {
  if $MAC; then
    [ -f ~/.dircolors ] || git clone https://github.com/gibbling666/dircolors.git ~/.dircolors
    brew install \
      bash \
      grep \
      coreutils \
      dos2unix \
      gnu-sed \
      wget \
      vim \
      neovim \
      git \
      git-absorb \
      tmux \
      lynx \
      tree \
      htop \
      ncdu \
      shellcheck \
      shfmt \
      starship \
      ripgrep \
      autojump \
      asdf \
      alacritty \
      ghostty
    brew install --cask iterm2 amethyst
    echo "$(brew --prefix)/bin/bash" | sudo tee -a /private/etc/shells
    sudo chpass -s "$(brew --prefix)/bin/bash" "$(whoami)"
  else
    sudo-pkg-mgr install -y \
      vim \
      git \
      cmake \
      # git-absorb \
      tmux \
      lynx \
      curl \
      tree \
      net-tools \
      htop \
      ncdu \
      pdfgrep \
      screen \
      dos2unix \
      inotify-tools \
      shellcheck \
      shfmt \
      exa \
      ripgrep \
      gnome-tweaks \
      autojump \
      entr \
      unzip \
      ghostty

    # sudo add-apt-repository ppa:neovim-ppa/stable -y
    # sudo apt update
    # sudo-pkg-mgr install -y \
      # neovim
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
    chmod u+x nvim.appimage
    mv nvim.appimage ~/bin/nvim

    which starship &>/dev/null || sh -c "$(curl -fsSL https://starship.rs/install.sh)"
  fi
}

# Other tools

function install_dev {
  if $MAC; then
    brew install \
      gh \
      pre-commit \
      gcc \
      make \
      cmake \
      lcov \
      jq \
      tfsec \
      scc
  else
    sudo-pkg-mgr install -y \
      gh \
      gcc \
      g++ \
      make \
      lcov \
      libc6-dev-i386 \
      jq
    if which pip3 &>/dev/null; then
      pip3 install pre-commit jc
    fi
    sudo snap install \
      scc
  fi
}

function install_graphite {
  if $MAC; then
    brew install withgraphite/tap/graphite
    gt completion >> ~/.zsh/_gt
  fi
}

function install_utilities {
  if [[ $(which cargo) ]]; then
    cargo install \
      pipe-rename \
      procs \
      shy \
      zellij \
      exa
    cargo install --git https://github.com/jez/barchart.git
  fi

  if $MAC; then
    brew install bat fd
  else
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
}

function install_cheat {
  curl https://cht.sh/:cht.sh > ~/bin/cht.sh
  chmod +x ~/bin/cht.sh
}

function install_silicon {
  sudo-pkg-mgr install expat
  sudo-pkg-mgr install libxml2-dev
  sudo-pkg-mgr install pkg-config libasound2-dev libssl-dev cmake libfreetype6-dev libexpat1-dev \
    libxcb-composite0-dev
  cargo install silicon
}

function install_gitsecrets {
  wget -q https://raw.githubusercontent.com/awslabs/git-secrets/master/git-secrets
  install -m 755 git-secrets ~/bin
  rm git-secrets
}

if has_arg "vscode"; then
    if $MAC; then
        brew install --cask visual-studio-code
    else
        snap install code --classic
    fi
    code --install-extension < system_files/VSCode/extensions.txt
fi

function install_fonts {
  if $MAC; then
    fonts_dir="${HOME}/Library/Fonts"
  else
    fonts_dir="${HOME}/.local/share/fonts"
  fi
  mkdir -p "${fonts_dir}"

  # Nerd fonts
  for font in FiraCode Hack; do
    file_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/${font}.zip"
    echo "wget  ${file_url} -O ${font}.zip"
    wget "${file_url}" -O "${font}.zip"
    unzip ${font}.zip -d $font
    for otf in "$font"/*.?tf; do
      cp "$otf" "$fonts_dir"/
    done
    rm -rf $font ${font}.zip
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
  fi

  if $WSL; then
    choco install firacode
    echo "Download and install ArgVu from https://github.com/christianvoigt/argdown/raw/master/packages/ArgVu/ArgVuSansMono-Regular-8.2.otf"
  fi
}

function install_git {
  if ! $MAC; then
    # This adds a new remote repo that hosts more up-to-date versions of git
    sudo add-apt-repository ppa:git-core/ppa
    sudo-pkg-mgr update && sudo-pkg-mgr upgrade git -y

    # Install git-extras
    sudo-pkg-mgr install -y git-extras
    sudo rm "$(which git-alias)" # My 'alias' alias is better!
  fi
}

function install_writing {
  sudo-pkg-mgr install -y \
    aspell \
    aiksaurus \
    python3-proselint \
    pandoc \
    vale
  }

function install_pandoc {
  URL="https://github.com$(curl -Ls https://github.com/jgm/pandoc/releases/latest | grep -m1 "amd64.deb" | cut -d\" -f2)"
  wget -q --show-progress "$URL"
  sudo dpkg -i pandoc-*-amd64.deb
  rm pandoc-*-amd64.deb
}

function install_keys {
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
}

function install_bash {
  # Map /bin/sh to /bin/bash
  if [[ ! -f /bin/sh.bak ]]; then
    sudo mv /bin/sh /bin/sh.bak
    sudo ln -s /bin/bash /bin/sh
  fi
}

function install_zsh {
  if $MAC; then
    brew install zsh
  else
    sudo-pkg-mgr install zsh
  fi

  # Download git completion files
  mkdir -p ~/.zsh
  curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
  curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh

  if [[ "zsh" != "$SHELL" ]]; then
    which zsh | sudo tee -a /etc/shells
    chsh -s "$(which zsh)"
  fi
}

function install_rvm {
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
}

function install_ruby {
  if [[ ! $(which rvm) ]]; then
    echo "Install RVM first"
    exit 1
  fi

  rvm install ruby-head
  rvm install "$RUBY_VERSION"
  rvm --default use "$RUBY_VERSION"
}

function install_gems {
  sudo-pkg-mgr install -y \
    ruby-dev \
    ruby"$(ruby -e 'puts RUBY_VERSION[/\d+\.\d+/]')"-dev

  rvm @global 'do' gem install \
    bundler \
    solargraph
  }

function install_postman {
  sudo snap install postman
}

function install_mysql {
  sudo-pkg-mgr install -y \
    libmysqlclient-dev \
    mysql-workbench
}

function install_postgresql {
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
}

function install_node {
  if $MAC; then
    brew install node
  else
    sudo-pkg-mgr install npm
    curl -sL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo-pkg-mgr install -y nodejs
    sudo chown -R "$USER":"$(id -gn "$USER")" ~/.config
    sudo chown -R "$USER":"$(id -gn "$USER")" /usr/lib/node_modules/
    export NODE_PATH='/usr/lib/node_modules'
    echo "export NODE_PATH='/usr/lib/node_modules'" >> ~/.profile
    # should be able to 'npm install -g' without sudo now
    sudo-pkg-mgr autoremove -y
  fi
}

function install_react {
  if [[ "" == $(which npm) ]]; then
    echo "install node first; '$0 node'"
    exit 1
  fi
  npm install -g create-react-app
}

function install_yarn {
  if $MAC; then
    brew install yarn
  else
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | \
      sudo tee /etc/apt/sources.list.d/yarn.list
    if which nvm &>/dev/null; then
      sudo apt update && sudo apt install --no-install-recommends yarn
    else
      sudo apt update && sudo apt install yarn
    fi
  fi
  yarn global add yarn-completions
}

function install_argdown {
  if [[ "" == $(which npm) ]]; then
    echo "install node first; '$0 node'"
    exit 1
  fi
  # Should not need sudo
  sudo npm install -g @argdown/cli
}

function install_golang {
  if $MAC; then
    brew install go
  else
    local URL FILE INST_DIR
    URL="https://go.dev/$(curl -s https://go.dev/dl/ | grep "linux-amd64.tar.gz" | head -1 | cut -d\" -f4)"
    FILE="$(echo "$URL" | rev | cut -d/ -f1 | rev)"
    INST_DIR=/usr/local

    echo "Downloading $URL..."
    wget -q --show-progress "$URL"
    echo "Untarring $FILE into $INST_DIR..."
    sudo tar -C $INST_DIR -xzf "$FILE"
    rm "$FILE"
  fi

  if echo "$PATH" | grep -q "go/bin"; then
    echo "Adding $INST_DIR/go/bin to ~/.profile..."
    echo "export PATH=\$PATH:$INST_DIR/go/bin" >> ~/.profile
    echo "Run 'export PATH=\$PATH:$INST_DIR/go/bin'"
    export PATH=$PATH:$INST_DIR/go/bin
    local GOPATH
    GOPATH=$(go env GOPATH)
    echo "Adding $GOPATH/bin to ~/.profile..."
    echo "export PATH=\$PATH:$GOPATH/bin" >> ~/.profile
    echo "Run 'export PATH=\$PATH:$GOPATH/bin'"
    export PATH=$PATH:$GOPATH/bin
  fi

  go install golang.org/x/tools/cmd/goimports@latest
  go install github.com/golobby/repl@latest
  go install github.com/golobby/repl@latest
  if $MAC; then
    brew install golang-migrate
  fi
  git clone https://github.com/ryboe/q "$(go env GOPATH)"/src/q
}

function install_haskell {
  sudo-pkg-mgr install haskell-platform
  # Stack is a package manager for Haskell, but installation is broken :(
  #curl -sSL https://get.haskellstack.org/ | sh
}

function install_rust {
  sudo-pkg-mgr install build-essential
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

function install_clojure {
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
}

function install_python {
  if $MAC; then
    brew install python@latest
  else
    sudo add-apt-repository ppa:deadsnakes/ppa
    sudo apt update
    sudo-pkg-mgr install python3-pip python-is-python3 python3-venv

    # Virtual environments: see https://realpython.com/python-virtual-environments-a-primer/
    pip install --user \
      virtualenv \
      virtualenvwrapper
    echo "source \$(which virtualenvwrapper.sh)" >> ~/.profile
  fi

  curl -sSL https://install.python-poetry.org | python3 -
  poetry completions bash >> ~/.bash_completion
  mkdir -p ~/.zfunc
  poetry completions zsh > ~/.zfunc/_poetry
}

function install_grip {
  if [[ "" == $(which pip) ]]; then
    echo "install python pip first; '$0 python'"
    exit 1
  fi
  pip install --user grip
}

function install_drawio {
  URL="$(curl -s https://about.draw.io/integrations/ | grep "draw.io-amd64-*.*.*.deb" | \
       head -1 | sed -E 's,.*(https://.*draw.io-amd64-*.*.*[0-9].deb).*,\1,')"
  wget -q --show-progress "$URL"
  sudo dpkg -i draw.io-amd64-*.*.*.deb
  sudo apt --fix-broken install -y
  rm draw.io-amd64-*.*.*.deb
}

function install_latex {
  sudo-pkg-mgr install -y \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-science \
    texlive-xetex \
    texlive-publishers \
    latexmk
    #texlive-generic-extra
  }

function install_texstudio {
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
}

function install_docker {
  if $MAC; then
    brew install --cask docker # docker desktop and docker cli
    brew install docker-compose
  else
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
}

function install_wireshark {
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
}

function install_enpass {
  if $MAC; then
    brew install --cask enpass
  else
    echo "deb http://repo.sinew.in/ stable main" | \
      sudo tee /etc/apt/sources.list.d/enpass.list > /dev/null
    wget -O - https://dl.sinew.in/keys/enpass-linux.key | sudo apt-key add -
    sudo-pkg-mgr update
    sudo-pkg-mgr install -y enpass
    xdg-open https://www.enpass.io/downloads/#extensions
    echo "NOTICE: Install the Firefox extension from the browser."
  fi
}

function install_signal {
  if $MAC; then
    brew install --cask signal
  else
    curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | \
      sudo tee -a /etc/apt/sources.list.d/signal-xenial.list > /dev/null
    sudo-pkg-mgr update && sudo-pkg-mgr install signal-desktop
  fi
}

function install_sonarqube {
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
}

function install_chrome {
  if $MAC; then
    brew install --cask google-chrome
  else
    wget -q --show-progress -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' | \
      sudo tee /etc/apt/sources.list.d/google-chrome.list
    sudo-pkg-mgr update
    sudo-pkg-mgr install google-chrome-stable
  fi
}

function install_glow {
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
}

function install_awscli {
  if $MAC; then
    brew install awscli
  else
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    UPDATE=$(which aws &>/dev/null && echo '--update' || echo '')
    sudo ./aws/install "$UPDATE"
    aws --version
    rm -r awscliv2.zip aws
  fi
}

function install_awseb {
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
}

function install_awssam {
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
}

function install_elm {
  curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
  gunzip elm.gz
  chmod +x elm
  mv elm ~/bin
  elm --help
  if which yarn &>/dev/null; then
    yarn global add create-elm-app elm-format elm-test elm-analyse
  fi
}

function install_slacknzoom {
  if $MAC; then
    brew install --cask slack
    brew install --cask zoom
  else
    sudo snap install slack --classic

    wget https://zoom.us/client/latest/zoom_amd64.deb
    sudo apt install ./zoom_amd64.deb
    rm ./zoom_amd64.deb
  fi
}

function install_tlaplus {
  function install_getpathfor {
    echo "https://github.com/$(
      curl -s https://github.com/tlaplus/tlaplus/releases \
        | grep "$1" -m1 \
        | cut -d\" -f2
    )"
  }

  if $MAC; then
    curl "$(getpathfor macosx)" -o "TLAToolbox.zip"
    unzip "TLAToolbox.zip"
  else
    curl "$(getpathfor linux)" -o "TLAToolbox.zip"
    unzip "TLAToolbox.zip"
  fi

  # TODO FIXME: broken!
  curl "$(getpathfor tla2tools)" -o ~/bin/lib/tla2tools.jar
}

## Special function: setup on a new machine
function install_setup {
  install_update
  install_enpass
  install_git
  install_basic
  install_python
  install_rust
  install_node
  install_yarn
  install_golang
  install_dev
  install_utilities
  install_fonts
  install_zsh
}

## Call specified functions
for FUNC in $(declare -F | cut -d' ' -f3); do
  if has_arg "${FUNC/install_/}"; then
    eval "$FUNC"
  fi
done
