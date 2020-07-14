# Note: this file to be sourced

ARGS=$(echo "$@" | tr '[:upper:]' '[:lower:]')

WSL=false
if [[ $(uname -a | grep -i microsoft) ]]; then
    WSL=true
fi

# Returns true if the specified arg is present in $ARGS
function has_arg() {
    echo $ARGS | grep -Pq "(^| )$1( |$)"
}

# Returns true if the variable specified in $1 has the text specified in $2
function var_has() {
    [[ 0 < $(echo ${!1} | grep "$2" | wc -l) ]]
}

# Returns true if the file specified in $1 has the text specified in $2
function file_has_line() {
    [[ 0 < $(cat $1 | grep "$2" | wc -l) ]]
}

if [ -z ${PACKAGE_MANAGER+x} ]; then
    if [[ "" != "$(which apt-get)" ]]; then
        PACKAGE_MANAGER=apt-get
    elif [[ "" != "$(which yum)" ]]; then
        PACKAGE_MANAGER=yum
    else
        echo "Neither apt-get nor yum are present. No suitable package manager found; exiting."
        exit 1
    fi
fi

function pkg-mgr() {
    $PACKAGE_MANAGER $@
}

function sudo-pkg-mgr() {
    sudo $PACKAGE_MANAGER $@
}
