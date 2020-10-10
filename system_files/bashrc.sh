# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

################################################################################
#                                                               default Ubuntu #

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

################################################################################
#                                                                   customized #

# Enable color support
if [ -x /usr/bin/dircolors ]; then
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

# Source other files
function sourceIfPresent() {
    [ -f $1 ] && source $1
}

sourceIfPresent ~/.bash_aliases
sourceIfPresent /usr/share/bash-completion/completions/git
sourceIfPresent ~/.bash_functions
sourceIfPresent ~/.bash_prompt
sourceIfPresent ~/.bashrc_local
sourceIfPresent ~/.bashrc_wsl
sourceIfPresent ~/.gerrit_functions.sh
sourceIfPresent ~/.fzf.bash
sourceIfPresent ~/.autojump/etc/profile.d/autojump.sh
sourceIfPresent ~/.forgit.plugin.sh

# Unbind ctrl-t from fzf-file-widget; used instead as tmux meta key
bind -r '\C-t'

# Set environment variables
PATH=$PATH:~/bin
[ -d ~/.yarn/bin ] && PATH=$PATH:~/.yarn/bin || true
export FZF_DEFAULT_OPTS="--bind='ctrl-o:execute(vim {})+abort'" # ctrl-o opens file in vim
export WSL=$(uname -a | grep -i microsoft &>/dev/null && echo 'true' || echo 'false')
export EDITOR=/usr/bin/vim
which bat &>/dev/null && export MANPAGER="sh -c 'col -bx | bat -l man -p'" || true

# print a quote or fortune, for fun
# if which fortune &>/dev/null && type rand_in_range &>/dev/null; then
#    PROB_ONE_IN=10
#    if [[ "1" == $(rand_in_range 1 $PROB_ONE_IN) ]]; then
#        fortune literature
#    fi
# fi
