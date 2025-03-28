# shellcheck disable=SC2148
# ~/.bash_aliases

alias rc='source ~/.bashrc'

# This is broken as of nvim 0.11.0. I don't really use it though.
# alias nvim='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
# alias nvr='nvr --servername /tmp/nvimsocket'

alias V='nvim $(find * -type f | fzf)'
if which nvim &>/dev/null; then
  alias vim=nvim
  alias vi=nvim
fi
alias vr='nvim ~/.vimrc'
alias rmswap='rm -rf ~/.local/state/nvim/swap/*'
if $MAC; then
  if which ggrep &>/dev/null; then
    alias grep="ggrep \$COLOR_AUTO"
    alias dircolors=gdircolors
    alias sed=gsed
    alias echo=gecho
  fi
else
  alias grep="grep \$COLOR_AUTO"
fi
alias p=pwd
if which exa &>/dev/null; then
  alias ls='exa -F'
  alias ll='exa -alFh'
  alias cat='bat --plain'
fi
alias cpv='rsync -ah --info=progress2'
alias tcn='mv --force -t ~/.local/share/Trash '
alias dos2unixr='find . -type f -exec dos2unix {} \;'
alias unix2dosr='find . -type f -exec unix2dos {} \;'
alias tm=tmux
alias preview="fzf --preview 'bat --color \"always\" {}'"
# REPO_DIR gets expanded during install
alias files='python3 REPO_DIR/submodules/PathPicker/src/process_input.py'
alias prevcmd='history | tail -1 | cut -d" " -f4-'
alias www='python3 -m http.server --bind localhost --cgi 8000'
alias sshkeygen='ssh-keygen -t rsa'
alias sshkeyinstall='ssh-copy-id -i ~/.ssh/id_rsa.pub'
alias g='git'
alias gg='gt'
alias s="echo \$?"
alias c='clear -x'
alias y='yarn'
complete -F _cd d
alias findf='find . -type f -iname 2>/dev/null'
alias findd='find . -type d -iname 2>/dev/null'
alias findl='find . -type l -iname 2>/dev/null'
alias child_dirs='find . -type d -path "./*" -prune'
alias dd='dd status=progress'
alias recent='ls -lct $(find . -type f -iname "*") | bat --plain -'
alias mdv='grip -b'
alias mde='grip --export'
alias md2html='grip --export'
alias usage=ncdu
alias whatsmyip='printf "$(curl -s ipecho.net/plain)\n"'
alias wan-ip='whatsmyip'
# shellcheck disable=SC2142
alias lan-ip=$'hostname -I | awk \'{print $1}\''
# shellcheck disable=SC2142
alias whatisthis='echo "This is $0 -$-" #'
alias sai='sudo apt-get install'
alias nowhitespace=$'sed -i \'s/[[:space:]]*$//\''
alias nws=nowhitespace
alias explorer='nautilus .'
alias txt2env='mkenvimage'
alias dsf='git diff --no-index --color'
alias strip_term_codes="sed 's/\x1B\[[0-9;]\+[A-Za-z]//g'"
alias t='clear -x; tree -C | less -R'
alias ports='sudo lsof -i -P -n'
alias listen='sudo lsof -i -P -n | grep LISTEN'
alias ch=cht.sh
alias z=zellij
alias zt='zellij action new-tab --layout ~/.config/zellij/layout_full.kdl'
alias killjobs='for JOB in $(jobs | cut -d[ -f2 | cut -d] -f1); do kill "%$JOB"; done'
alias tf=terraform
