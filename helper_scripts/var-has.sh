
# Returns true if the variable specified in $1 has the text specified in $2
# NOTE: must be 'sourced'

function var_has() {
    [[ 0 < $(echo ${!1} | grep "$2" | wc -l) ]]
}
