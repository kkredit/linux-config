
# NOTE: must be 'sourced'

ARGS=$(echo "$@" | tr '[:upper:]' '[:lower:]')

# Returns true if the specified arg is present in $ARGS
function has_arg() {
    [[ 1 = $(echo $ARGS | grep $1 | wc -l) ]]
}

# Returns true if the variable specified in $1 has the text specified in $2
function var_has() {
    [[ 0 < $(echo ${!1} | grep "$2" | wc -l) ]]
}

# Returns true if the file specified in $1 has the text specified in $2
function file_has_line() {
    [[ 0 < $(cat $1 | grep "$2" | wc -l) ]]
}
