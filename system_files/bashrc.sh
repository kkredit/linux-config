# shellcheck shell=bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

################################################################################
#                                                               default Ubuntu #

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT="%y-%m-%d %T :: "
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

################################################################################
#                                                                   customized #
export SHELL=/usr/local/bin/bash

# Source other files
function sourceIfPresent() {
	# shellcheck disable=SC1090
	[ -f "$1" ] && source "$1"
}

if [ -z "$BASH_PROFILE_LOADED" ]; then
	sourceIfPresent ~/.bash_profile
fi

sourceIfPresent /usr/share/bash-completion/completions/git
sourceIfPresent /usr/local/etc/bash_completion
sourceIfPresent /etc/bash_completion
sourceIfPresent ~/.bashrc_wsl
sourceIfPresent ~/.fzf.bash
sourceIfPresent ~/.iterm2_shell_integration.bash
sourceIfPresent ~/.shrc_common

if which starship &>/dev/null; then
	eval "$(starship init bash)"
fi

# print a quote or fortune, for fun
# if which fortune &>/dev/null && type rand_in_range &>/dev/null; then
#    PROB_ONE_IN=10
#    if [[ "1" == $(rand_in_range 1 $PROB_ONE_IN) ]]; then
#        fortune literature
#    fi
# fi
