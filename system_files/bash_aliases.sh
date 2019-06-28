# ~/.bash_aliases

alias ls="ls $COLOR_AUTO -F"
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep="grep $COLOR_AUTO"
alias dos2unixr='find . -type f -exec dos2unix {} \;'
alias unix2dosr='find . -type f -exec unix2dos {} \;'
alias tm=tmux
alias cat='bat --plain'
alias preview="fzf --preview 'bat --color \"always\" {}'"
alias www='python3 -m http.server --bind localhost --cgi 8000'
alias sshkeygen='ssh-keygen -t rsa'
alias sshkeyinstall='ssh-copy-id -i ~/.ssh/id_rsa.pub'
alias g='git'
alias s="echo $?"
alias c='clear'
alias krep='grep -rniIs'
alias findf='find . -type f -iname'
alias findd='find . -type d -iname'
alias findl='find . -type l -iname'
alias dd='dd status=progress'
alias recent='ls -lct $(find . -type f -iname "*") | less'
alias mdv='grip -b'
alias mde='grip --export'
alias usage=ncdu
alias whatsmyip='printf "$(curl -s ipecho.net/plain)\n"'
alias wan-ip='whatsmyip'
alias lan-ip="hostname -I | awk '{print $1}'"
alias sai='sudo apt-get install'

