# shellcheck disable=SC2148
# ~/.bash_functions

# patch sometimes-missing _init_completion; see
# https://gist.github.com/eparis/fd17b8fb4eb58efc2c12
if ! declare -F _init_completion >/dev/null 2>&1; then
    function _init_completion() {
        COMPREPLY=()
        _get_comp_words_by_ref cur prev words cword
    }
fi

# git alias autocompletions; see
# https://stackoverflow.com/questions/11466991/git-aliases-command-line-autocompletion-of-branch-names
function _git_log_compact() {
    _git_log
}

function _git_read() {
    _git_show
}

function _git_d() {
    _git_diff
}

function _git_s() {
    _git_show
}

function _git_onto() {
    _git_rebase
}

function _git_url() {
    __gitcomp_direct "$(git remote show)"
}

function _git_newpush() {
    __gitcomp_direct "$(git remote show)"
}

function _git_submodule_rm() {
    __gitcomp_direct "$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')"
}

function _git_brun() {
    # shellcheck disable=SC2154
    case "$cword" in
        2 | 4) _git_show;;
        3) __gitcomp_direct "$(printf 'lns\nsns\nread\n')";;
    esac
}

__git_complete g __git_main

# normal functions
function exitprint() {
    echo -e "${@:2}"
    exit "$1"
}

function ext() {
    echo "${1##*.}"
}

function ext2() {
    echo "${1#*.}"
}

function o {
    for FILE in "$@"; do
        case $1 in
            *.drawio)   drawio "$FILE" &>/dev/null & ;;
            *)          if $MAC; then open $FILE; else xdg-open "$FILE"; fi ;;
        esac
    done
}

function grepr {
    grep -rniIs "$@"
}

function krep {
    grep -rniIs -- "$*" .
}

function krepl {
    grep -rniIsl -- "$*" .
}

function krepr {
    grep -rniIs --exclude={*.drawio,*.snap} --exclude-dir={.git,db,log,tmp,vendor,coverage,node_modules,.venv,.mypy*,.tracked*,packs,packs-test,assets,build,_build,dist,elm-stuff} -- "$*" .
}
alias k=krepr

function kreprl {
    grep -rniIsl --exclude={*.drawio,*.snap} --exclude-dir={.git,db,log,tmp,vendor,coverage,node_modules,.venv,.mypy*,.tracked*,packs,packs-test,assets,build,_build,dist,elm-stuff} -- "$*" .
}

function kat() {
    if [[ $# != 1 || ! -f $1 ]]; then
        echo "Must run kat() on a single file."
        return 1
    fi
    case $1 in
        *.md) glow "$1" -p "less -r" ;;
        *)    bat "$1" ;;
    esac
}

function read_from_pipe() {
    eval "$*=''"
    local L
    while read -r L <&0; do
        eval "$*+='$L '"
    done
}

function line() {
    if (( $# < 2 )); then
        echo "Must use at least two arguments"
        return 2
    fi
    local LINE=$1
    FILES=${*:2}
    [[ "$FILES" == "-" ]] && read_from_pipe FILES
    for FILE in $FILES; do
        # shellcheck disable=SC2154
        printf "$purple%s$cyan:$green%s$cyan:$no_color " "$FILE" "$LINE"
        LEN=$(wc -l "$FILE" | awk '{print $1}')
        if (( LEN >= LINE )); then
            sed -n "${LINE}p" "$FILE"
        else
            # shellcheck disable=SC2154
            echo -e "${red}only $LEN lines$no_color"
        fi
    done
}

function recreplace() {
    (( 2 <= $# )) || return 1
    local SEP=${3:-/}
    echo "$1 $2" | grep -vq "$SEP" || return 1
    # shellcheck disable=SC2046
    sed -i "s${SEP}$1${SEP}$2${SEP}g" $(kreprl "$1")
}

function v() {
    local ARGS="$@"
    if (( 1 == $# )); then
        # if argument is filename:lineno, use +N for "goto line"
        local FILENAME="$(cut -d: -f1 <<< $1)"
        if [ ! -f "$FILENAME" ] && [ ! -d "$FILENAME" ]; then
          FILENAME="$(findf $FILENAME | head -1)"
        fi
        local LINENO="$(cut -sd: -f2 <<< $1)"
        if [[ "" != "$LINENO" ]]; then
          ARGS="+$LINENO $FILENAME"
        fi
    fi
    # shellcheck disable=SC2086
    vim $ARGS
}

function co() {
    local ARGS=""
    # if opening a file, use -g for "goto line"
    if (( 1 == $# )); then
        if [ -f "${1%%:[0-9]*}" ]; then
          ARGS="$ARGS -g"
        elif [[ "-" != "${1:0:1}" ]] && [ ! -d "$1" ]; then
          # was probably a typo, so exit. If not, just use the full 'codium'.
          echo "No such file or directory. If want to create a new file, use 'codium'."
          return 1
        fi
    fi
    # shellcheck disable=SC2086
    codium $ARGS "$@"
}

function _co() {
    # Because _codium is not defined till you try to tab complete codium, just fall back to _filedir
    if [[ $(type _codium 2>/dev/null) ]]; then
        _codium
    else
        _init_completion -s || return;
        _expand || return;
        _filedir
    fi
}
complete -F _co co

function cof() {
    FILE=$(findf "$1")
    [[ -f "$FILE" ]] || return 1
    echo "$FILE"
    codium "$FILE"
}

function code_setup_c {
    mkdir -p .vscode
    BASE_PATH=~/git/linux-config/system_files/VSCodium
    if $WSL; then
        dos2unix -n $BASE_PATH/c_cpp_properties_win.json .vscode/c_cpp_properties.json
    else
        cp $BASE_PATH/c_cpp_properties_linux.json .vscode/c_cpp_properties.json
    fi
}

function code_setup_ruby {
    gem install solargraph
    echo "NOTE : SolarGraph should be installed globally, not locally (i.e. not in the Gemfile)"
    local SG_PATH SETTING
    SG_PATH=$(command ls /home/"$USER"/.rvm/wrappers/"$(rvm current)"/solargraph 2>/dev/null)
    SETTING="\"solargraph.commandPath\": \"$SG_PATH\","
    if [ -f .vscode/settings.json ]; then
        printf "{\n  %s\n}\n" "$SETTING" >> .vscode/settings.json
        echo "NOTE : fixup .vscode/settings.json"
        codium .vscode/settings.json
    else
        mkdir -p .vscode
        printf "{\n  %s\n}\n" "$SETTING" > .vscode/settings.json
    fi
    yard gems
    yard -n
}

function finde() {
    find . -type f -iname "*.$1" 2>/dev/null
}

function title() {
    echo -ne "\033]0;$1\007"
}

function highlight() {
    GREP_COLORS="mt=01;36" grep --color=auto -i "$1\|$"
}
alias hl=highlight

function rand_in_range() {
    if (( 2 != $# )); then
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
    local new_dir="$*"
    if [[ "$*" =~ ^\.+$ ]]; then
        new_dir=${*//./.\/.}
    elif [[ "g" == "$*" ]]; then
        new_dir="$(git rev-parse --show-toplevel)"
    elif ! [ -d "$*" ]; then
      if [ -f "$*" ]; then
        new_dir="$(dirname "$*")"
      else
        local file="$(findf "$*")"
        if [ -f "$file" ]; then
          new_dir="$(dirname "$file")"
        fi
      fi
    fi
    builtin cd "$new_dir" && ls
}
alias d=cs

function cgs() {
    clear -x && git status
}

function cls() {
    clear -x && ls
}

function mkcd() {
    mkdir "$1" && (cd "$1" || true)
}

function showme() {
    set -x; eval "$@"; set +x
}

function watchdo() {
    function wait_for_modify() {
        if $MAC; then
            fswatch --event Updated "$1"
        else
            inotifywait -q -e modify "$1"
        fi
    }
    while wait_for_modify; do eval "${@:2}"; done
}

function libdeps() {
    objdump -p "$1" | grep NEEDED
}

function screenkill() {
    screen -X -S "$1" kill
}

function screenkillall() {
    COUNT=$(screen -ls | grep -c Detached)
    if (( 0 > "$COUNT" )); then
        screen -ls | grep Detached | cut -d. -f1 | awk '{print $1}' | xargs kill
        echo "$COUNT detached screen sessions killed"
    else
        echo "No detached screen sessions to kill"
    fi
}

function serial() {
    local BAUD=115200
    local DEV_NUM=1
    local OPTIND
    while getopts "hb:n:" opt; do
        case $opt in
            h) echo "Usage: serial (-b BAUD_RATE) (-n DEVICE_NUM)"; return ;;
            b) BAUD=$OPTARG ;;
            n) DEV_NUM=$OPTARG; echo "Waiting for device $OPTARG" ;;
            *) echo "Invalid option"; return 2 ;;
        esac
    done

    if ! groups | grep -q dialout; then
        sudo usermod -a -G dialout "$USER"
    fi

    if [[ ! -d /run/screen ]]; then
        sudo mkdir -p /run/screen
        sudo chmod 777 /run/screen
    fi

    # shellcheck disable=SC2012
    TTYS="$(ls /dev/ttyUSB? 2> /dev/null) \
          $(ls /dev/ttyS* | perl -e 'print sort { length($a) <=> length($b) } <>')"
    CURRENT_DEV_NUM=0
    for TTY in $TTYS; do
        echo "Trying $TTY"
        if stty -F "$TTY" &> /dev/null; then
            CURRENT_DEV_NUM=$((CURRENT_DEV_NUM + 1))
            echo "$TTY worked, current count is $CURRENT_DEV_NUM"
            if (( CURRENT_DEV_NUM == DEV_NUM )); then
                echo "Connecting to $TTY"
                screen "$TTY" "$BAUD"
                break
            fi
        fi
    done
}

function directssh() {
    # Based on
    # https://unix.stackexchange.com/questions/295238/how-to-connect-to-device-via-ssh-over-direct-ethernet-connection

    if (( $# < 1 )) || ! ip link | grep -q "$1"; then
        echo Usage: directssh IFACE_NAME
        return 1
    fi

    local IP_BASE=172.22.22
    sudo ip address replace $IP_BASE.1/24 scope link dev "$1"
    echo "================================================================"
    echo " 1. Connect the device to interface $1."
    echo " 2. Watch it acquire a DHCP address here."
    echo " 3. Ctrl-C this task to terminate DHCP and reset network config."
    echo " 4. Connect to the device via SSH in a new terminal."
    echo "================================================================"
    bash -c "sudo dnsmasq -d -C /dev/null --port=0 --domain=localdomain \
                --interface=$1 --dhcp-range=$IP_BASE.2,$IP_BASE.9,24h"
    # Above waits for Ctrl-C...
    sudo ip address del $IP_BASE.1/24 dev "$1"
    sudo service network-manager restart
}

function dive() {
    docker pull wagoodman/dive
    docker run --rm -it \
        -v /var/run/docker.sock:/var/run/docker.sock \
        wagoodman/dive:latest "$@"
}

function git-author-rewrite() {
    if (( $# < 2 )); then
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
    if [ ! -f "$1" ]; then
        echo "'$1' is not a valid file"
    else
        case $1 in
            *.tar.bz2)  tar xjf "$1" ;;
            *.tar.gz)   tar xzf "$1" ;;
            *.bz2)      bunzip2 "$1" ;;
            *.rar)      rar x "$1" ;;
            *.gz)       gunzip "$1" ;;
            *.tar)      tar xf "$1" ;;
            *.tbz2)     tar xjf "$1" ;;
            *.tgz)      tar xzf "$1" ;;
            *.zip)      unzip "$1" ;;
            *.Z)        uncompress "$1" ;;
            *.7z)       7z x "$1" ;;
            *.cpio)     mkdir "$1".dir && cd "$1".dir && cpio -idv ../"$1" ;;
            *)          echo "'$1' cannot be extracted via extract()" ;;
        esac
    fi
}

# for long running commands. Use like 'sleep 10; alert'
function alert() {

    # shellcheck disable=SC2181
    if (( 0 == $? )); then
        ALERT_TITLE="terminal"
        SUMMARY="SUCCESS"
        TERM_MSG_COLOR=$green
    else
        ALERT_TITLE="error"
        SUMMARY="FAILURE"
        TERM_MSG_COLOR=$red
    fi

    COMMAND="$(history | tail -n1 | sed -e 's/^\s    *[0-9]\+\s*//;s/[;&|]\s*alert$//')"

    notify-send --urgency=low -i "$ALERT_TITLE" "$COMMAND"

    echo -e "$TERM_MSG_COLOR"
    echo "==============================================================================="
    echo "SUMMARY: $SUMMARY"
    echo "$COMMAND"
    echo "==============================================================================="
    echo -e "$no_color"
}

function mount-img-partition() {
    if (( 2 > $# )); then
        echo "Usage: mount-img PATH/TO/IMAGE PATH/TO/MOUNT [PARTITION_NUM]"
        return 1
    else
        local IMAGE=$1
        local MNTPT=$2
        if (( 3 == $# )); then
            local PARTITION_FILTER="grep '${IMAGE}$3'"
        else
            local PARTITION_FILTER="tail -1"
        fi
    fi

    echo "fdisk -l $IMAGE:"
    echo "==============================================================================="
    fdisk -l "$IMAGE"
    echo "==============================================================================="

    local BLK_SIZE PART_INFO START_BLK SECTORS OFFSET SIZE
    BLK_SIZE=$(fdisk -l "$IMAGE" | grep Units | awk '{print $8}')
    # shellcheck disable=SC2207
    PART_INFO=($(eval "fdisk -l $IMAGE | $PARTITION_FILTER | tr -d '*'"))
    START_BLK=${PART_INFO[1]}
    if [[ "" == "$START_BLK" ]]; then
        echo "Error: partition $3 not found"
        return 2
    fi
    SECTORS=${PART_INFO[3]}
    OFFSET=$(( BLK_SIZE * START_BLK ))
    SIZE=$(( BLK_SIZE * SECTORS ))

    echo
    echo "Block size = $BLK_SIZE;"
    echo "Start block = $START_BLK;"
    echo "Sectors = $SECTORS;"
    echo "Therefore offset = $OFFSET;"
    echo "and sizelimit = $SIZE."
    echo
    echo "Try:"
    echo "    sudo mount -o loop,offset=$OFFSET,sizelimit=$SIZE $IMAGE $MNTPT"
    echo "or:"
    echo "    sudo mount -o loop,offset=$OFFSET,sizelimit=$SIZE $IMAGE $MNTPT -t sysfs"
    echo
}

function tftpserve() {
    if [[ ! $(which tftp) ]]; then
        TFTP_DIR=/tftpboot
        TFTP_CONFIG_DIR=/var/lib/tftpboot

        sudo apt-get install tftp tftpd-hpa
        if [[ ! -L $TFTP_DIR ]]; then
            sudo ln -s $TFTP_CONFIG_DIR $TFTP_DIR
            sudo chown -R "$USER":"$USER" $TFTP_CONFIG_DIR
        fi
        sudo sed -i 's/--secure/--secure --create/g' /etc/default/tftpd-hpa
        sudo service tftpd-hpa restart
    fi
    if ! service tftpd-hpa status | grep -qi running; then
        sudo service tftpd-hpa restart
    fi
    service tftpd-hpa status | head -n99 #without pipe, waits for input
    TFTP_DIR=$(grep TFTP_DIRECTORY /etc/default/tftpd-hpa | cut -d\" -f2)
    # shellcheck disable=SC2010
    if ls -l /tftpboot | grep -q "$TFTP_DIR"; then
        TFTP_DIR="/tftpboot"
    fi
    echo
    echo "Your TFTP dir: $TFTP_DIR"
}

function dtb2dts() {
    if (( 2 != $# )); then
        echo "Usage: dtb2dts PATH/TO/DTB PATH/TO/DTS"
        return 1
    fi
    dtc -I dtb -O dts -o "$2" "$1"
}

function dts2dtb() {
    if (( 2 != $# )); then
        echo "Usage: dts2dtb PATH/TO/DTS PATH/TO/DTB"
        return 1
    fi
    dtc -I dts -O dtb -o "$2" "$1"
}

function md2pdf() {
    if (( 1 != $# )) || [[ ! -f $1 ]]; then
        echo "Usage: md2pdf PATH/TO/FILE.MD"
        return 1
    fi
    PDF_NAME="${1%.*}.pdf"
    pandoc -f gfm -s -V geometry:margin=1in -o "$PDF_NAME" "$1"
}

function tree-md-links() {
    # From https://stackoverflow.com/questions/23989232/is-there-a-way-to-represent-a-directory-tree-in-a-github-readme-md
    # See also https://github.com/michalbe/md-file-tree
    tree -tf --noreport -I '*~' --charset ascii "$1" |
       sed -e 's/| \+/  /g' -e 's/[|`]-\+/  */g' -e 's:\(* \)\(\(.*/\)\([^/]\+\)\):\1[\4](\2):g'
}
alias tmdl='tree-md-links'

function tree-md() {
    tree -tf --noreport -I '*~' --charset ascii "$1" |
       sed -e 's/| \+/  /g' -e 's/[|`]-\+/  */g' -e 's:\(* \)\(\(.*/\)\([^/]\+\)\):\1\4:g'
}
alias tmd='tree-md'

function awsprofilecmd() {
    if [[ "" != "$MY_AWS_PROFILE" ]]; then
        command "$@" --profile "$MY_AWS_PROFILE"
    else
        command "$@"
    fi
}

function aws() {
    awsprofilecmd aws "$@"
}

function eb() {
    awsprofilecmd eb "$@"
}

function sam() {
    awsprofilecmd sam "$@"
}

function awsiamget() {
    grep -A3 "$MY_AWS_PROFILE" ~/.aws/credentials  | grep "$1" | awk '{print $3}'
}

function awsiam() {
    if (( 0 == $# )); then
        echo "$MY_AWS_PROFILE"
    else
        export MY_AWS_PROFILE=$1
        AWS_ACCESS_KEY_ID=$(awsiamget aws_access_key_id)
        AWS_SECRET_ACCESS_KEY=$(awsiamget aws_secret_access_key)
        export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
    fi
}

function maxcpu() {
    printf "About to consume all CPU. To stop, run\n  > killall yes\n"
    for _ in $(seq 1 "$(nproc)"); do
        yes >/dev/null &
    done
}

function gan() {
    go doc -all $1 | bat --language go --plain
}

function qq() {
    clear
    local logpath="$TMPDIR/q"
    if [[ -z "$TMPDIR" ]]; then
        logpath="/tmp/q"
    fi
    if [[ ! -f "$logpath" ]]; then
        echo 'Q LOG' > "$logpath"
    fi
    tail -100f -- "$logpath"
}

function rmqq() {
    local logpath="$TMPDIR/q"
    if [[ -z "$TMPDIR" ]]; then
        logpath="/tmp/q"
    fi
    if [[ -f "$logpath" ]]; then
        rm "$logpath"
    fi
    qq
}
