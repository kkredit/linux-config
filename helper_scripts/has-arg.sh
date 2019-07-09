
# Returns true if the specified arg is present in $ARGS
# NOTE: must be 'sourced'

ARGS=$(echo "$@" | tr '[:upper:]' '[:lower:]')

function has_arg() {
    if [[ 1 = $(echo $ARGS | grep $1 | wc -l) ]]; then
        true
    else
        false
    fi
}
