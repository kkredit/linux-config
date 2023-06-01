# shellcheck shell=bash

export SHELL=$(which zsh)
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
zstyle :compinstall filename "$HOME/.zshrc"

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)
fpath+=~/.zfunc

autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit
# End of lines added by compinstall

# Source other files
function sourceIfPresent() {
    [ -f "$1" ] && source "$1"
}
sourceIfPresent ~/.shrc_common

# Starship
eval $(starship init zsh)
# these don't seem to work
#znap eval starship "starship init zsh"
#znap prompt

# Znap
if [ -f ~/git/linux-config/submodules/zsh-snap/znap.zsh ]; then
  source ~/git/linux-config/submodules/zsh-snap/znap.zsh

  znap source zsh-users/zsh-autosuggestions
  function zvm_config {
    ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
    ZVM_VI_ESCAPE_BINDKEY=jk
  }
  function zvm_after_init() {
    sourceIfPresent ~/.fzf.zsh
    # must be last, so do in the "after" hook of the last thing
    znap source zsh-users/zsh-syntax-highlighting
  }
  znap source jeffreytse/zsh-vi-mode
fi
