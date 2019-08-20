# ~/.bash_functions

# git alias autocompletions; see
# https://stackoverflow.com/questions/11466991/git-aliases-command-line-autocompletion-of-branch-names
function _git_log-compact() {
    _git_log
}

function _git_read() {
    _git_show
}

function _git_url() {
    __gitcomp_direct "$(git remote show)"
}

function _git_submodule-rm() {
    __gitcomp_direct "$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')"
}

function _git_brun() {
    case "$cword" in
        2 | 4) _git_show;;
        3) __gitcomp_direct "$(printf 'lns\nsns\nread\n')";;
    esac
}

# normal functions
function title() {
    echo -ne "\033]0;$1\007"
}

function rand_in_range() {
    if [[ 2 != $# ]]; then
        echo "Usage: rand_in_range FLOOR_INCLUSIVE CEILING_INCLUSIVE"
        return 1
    else
        FLOOR=$1
        CEILING=$2
    fi
    RANGE=$(( CEILING - FLOOR + 1 ))
    RESULT=$(( (RANDOM % RANGE) + FLOOR ))
    echo $RESULT
}

# create function "cs" to "cd" and "ls" in one command
function cs() {
    new_directory="$*"
    if [ $# -eq 0 ]; then
        new_directory=${HOME}
    fi
    builtin cd "${new_directory}" && ls
}

function cgs() {
    clear && git status
}

function cls() {
    clear && ls
}

function mkcd() {
    mkdir $1 && cd $1
}

function showme() {
    set -x && $@ && set +x
}

function ruby_setup() {
    source ~/.rvm/scripts/rvm
    rvm use 2.6.0
}

function libdeps() {
    objdump -p $1 | grep NEEDED
}

function screenkill() {
    screen -X -S $1 kill
}

function screenkillall() {
    COUNT=$(screen -ls | grep Detached | wc -l)
    if [[ 0 > $COUNT ]]; then
        screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
        echo "$COUNT detached screen sessions killed"
    else
        echo "No detached screen sessions to kill"
    fi
}

function serial() {
    BAUD=115200
    if [[ $# > 0 ]]; then
        BAUD=$1
    fi
    if [[ ! -d /run/screen ]]; then
        sudo mkdir -p /run/screen
        sudo chmod 777 /run/screen
    fi

    TTYS="$(ls /dev/ttyUSB? 2> /dev/null) $(ls /dev/ttyS? 2> /dev/null)"
    for TTY in $TTYS; do
        if [[ 666 != $(stat -c %a $TTY) ]]; then
            sudo chmod 666 $TTY
        fi
        echo "Trying $TTY"
        stty -F $TTY &> /dev/null
        if [[ $? = 0 ]]; then
            echo "Connecting to $TTY"
            screen $TTY $BAUD
            break
        fi
    done
}

function dive() {
    docker pull wagoodman/dive
    docker run --rm -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        wagoodman/dive:latest $@
}

function git-author-rewrite() {
    if [[ $# < 2 ]]; then
        echo Usage: git-author-rewrite OLD_EMAIL NEW_EMAIL
        return 1
    fi

    git filter-branch --env-filter '

    OLD_EMAIL='"$1"'
    CORRECT_NAME="Kevin Kredit"
    CORRECT_EMAIL='"$2"'

    if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]; then
        export GIT_COMMITTER_NAME="$CORRECT_NAME"
        export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
    fi

    if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]; then
        export GIT_AUTHOR_NAME="$CORRECT_NAME"
        export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
    fi

    ' --tag-name-filter cat -- --branches --tags
}

extract () {
    if [ ! -f $1 ]; then
        echo "'$1' is not a valid file"
    else
        case $1 in
            *.tar.bz2)  tar xjf $1 ;;
            *.tar.gz)   tar xzf $1 ;;
            *.bz2)      bunzip2 $1 ;;
            *.rar)      rar x $1 ;;
            *.gz)       gunzip $1 ;;
            *.tar)      tar xf $1 ;;
            *.tbz2)     tar xjf $1 ;;
            *.tgz)      tar xzf $1 ;;
            *.zip)      unzip $1 ;;
            *.Z)        uncompress $1 ;;
            *.7z)       7z x $1 ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    fi
}

# for long running commands. Use like 'sleep 10; alert'
function alert() {

    if [[ 0 == $? ]]; then
        ALERT_TITLE="terminal"
        SUMMARY="SUCCESS"
        TERM_MSG_COLOR=$green
    else
        ALERT_TITLE="error"
        SUMMARY="SUCCESS"
        TERM_MSG_COLOR=$red
    fi

    COMMAND="$(history | tail -n1 | sed -e 's/^\s    *[0-9]\+\s*//;s/[;&|]\s*alert$//')"

    notify-send --urgency=low -i "$ALERT_TITLE" "$COMMAND"

    echo -e "$TERM_MSG_COLOR"
    echo "==============================================================================="
    echo "SUMMARY:"
    echo "$COMMAND"
    echo "==============================================================================="
    echo -e $no_color
}

function mount-img() {
    if [[ 2 != $# ]]; then
        echo "Usage: mount-img PATH/TO/IMAGE PATH/TO/MOUNT"
        return 1
    else
        IMAGE=$1
        MNTPT=$2
    fi

    echo "fdisk -l $IMAGE :"
    echo "==============================================================================="
    fdisk -l $IMAGE
    echo "==============================================================================="

    BLK_SIZE=$(fdisk -l $IMAGE | grep Units | awk '{print $8}')
    START_BLK=$(fdisk -l $IMAGE | tail -1 | awk '{print $2}')
    OFFSET=$(( BLK_SIZE * START_BLK ))

    echo
    echo "Block size = $BLK_SIZE;"
    echo "Start block = $START_BLK;"
    echo "Therefore offset = $OFFSET."
    echo "Try:"
    echo "    sudo mount -o loop,offset=$OFFSET $IMAGE $MNTPT"
    echo "or:"
    echo "    sudo mount -o loop,offset=$OFFSET $IMAGE $MNTPT -t sysfs"
}

function dtb2dts() {
    if [[ 2 != $# ]]; then
        echo "Usage: dtb2dts PATH/TO/DTB PATH/TO/DTS"
        return 1
    fi
    dtc -I dtb -O dts -o $2 $1
}

function dts2dtb() {
    if [[ 2 != $# ]]; then
        echo "Usage: dts2dtb PATH/TO/DTS PATH/TO/DTB"
        return 1
    fi
    dtc -I dts -O dtb -o $2 $1
}
