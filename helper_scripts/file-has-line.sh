
# Returns true if the file specified in $1 has the text specified in $2
# NOTE: must be 'sourced'

function file_has_line() {
    [[ 0 < $(cat $1 | grep "$2" | wc -l) ]]
}
