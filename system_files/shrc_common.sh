# shellcheck shell=bash

WSL=$(if uname -a | grep -iq microsoft; then echo 'true'; else echo 'false'; fi)
export WSL
MAC=$(if uname -a | grep -iq darwin; then echo 'true'; else echo 'false'; fi)
export MAC

# Source other files
sourceIfPresent ~/.bash_aliases
sourceIfPresent ~/.bash_functions
sourceIfPresent ~/.bashrc_local
sourceIfPresent /usr/local/etc/profile.d/autojump.sh
sourceIfPresent ~/.cargo/env

# Enable color support
if [ -x /usr/bin/dircolors ] || [ -x /usr/local/bin/gdircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    COLOR_AUTO="--color=auto"

    # colors
    black='\e[0;30m'
    red='\e[0;31m'
    green='\e[0;32m'
    yellow='\e[0;33m'
    blue='\e[0;34m'
    purple='\e[0;35m'
    cyan='\e[0;36m'
    light_grey='\e[0;37m'
    dark_grey='\e[1;30m'
    light_red='\e[1;31m'
    light_green='\e[1;32m'
    orange='\e[1;33m'
    light_blue='\e[1;34m'
    light_purple='\e[1;35m'
    light_cyan='\e[1;36m'
    white='\e[1;37m'
    no_color='\e[0m'
    nc='\e[0m'

    ALL_COLORS=(red light_red orange yellow light_green green light_cyan cyan light_blue blue \
                light_purple purple black dark_grey light_grey white no_color nc)
    function colors() {
        for COLOR in "${ALL_COLORS[@]}"; do
            echo -ne "${!COLOR}" && echo -n "${!COLOR} " && echo -e "$COLOR $nc"
        done
    }
fi

# Set environment variables
PATH=$PATH:~/bin
[ -d ~/.yarn/bin ] && PATH=$PATH:~/.yarn/bin || true
[ -d /snap/bin ] && PATH=$PATH:/snap/bin || true
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(vim {})+abort'" # ctrl-o opens file in vim
export EDITOR=nvim
which bat &>/dev/null && export MANPAGER="sh -c 'col -bx | bat -l man -p'" || true
export RIPGREP_CONFIG_PATH=~/.ripgreprc
