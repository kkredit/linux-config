
# Returns true if the specified arg OR if 'all' is present in $ARGS
# NOTE: must be 'sourced'

ARGS=$(echo "$@" | tr '[:upper:]' '[:lower:]')

function has_arg() {
    if [[ 1 = $(echo $ARGS | grep "all" | wc -l) ]]; then
        true
    elif [[ 1 = $(echo $ARGS | grep $1 | wc -l) ]]; then
        true
    else
        false
    fi
}
