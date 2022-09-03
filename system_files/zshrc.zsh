# shellcheck shell=bash

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kevinkredit/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Source other files
function sourceIfPresent() {
    [ -f "$1" ] && source "$1"
}
# TODO: add completion
#sourceIfPresent /usr/share/bash-completion/completions/git
#sourceIfPresent /usr/local/etc/bash_completion
#sourceIfPresent /etc/bash_completion
sourceIfPresent ~/.fzf.zsh
sourceIfPresent ~/.shrc_common

eval "$(starship init zsh)"

# Set environment variables
export SHELL=zsh
