# shellcheck shell=bash

export SHELL=zsh
export ZSH_NAME=zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd extendedglob nomatch
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/kevinkredcompleteit/.zshrc'

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
# End of lines added by compinstall

# Source other files
function sourceIfPresent() {
    [ -f "$1" ] && source "$1"
}
sourceIfPresent ~/.fzf.zsh
sourceIfPresent ~/.shrc_common

# Znap
sourceIfPresent ~/git/linux-config/submodules/zsh-snap/znap.zsh
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting
znap eval starship "starship init zsh"
znap prompt
