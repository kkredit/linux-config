#!/usr/bin/env bash

################################################################################
#                                                                       CONFIG #
# NOTE: Keep EXCLUDE_DIRS up to date
# Add dirs using "/dir1/\|/dir2/" and so on
EXCLUDE_DIRS="/vendor/\|/build/"

################################################################################
#                                                             HELPER FUNCTIONS #
function exitprint() {
    echo "${@:2}" 1>&2
    exit "$1"
}

function run_cmd_on_files {
    for FILE in "${@:2}"; do
        [ ! -f "$FILE" ] || eval "$1 $FILE"
    done
}

function source_files_in_dir {
    # shellcheck disable=SC2046
    echo $(find "$1" -type f -iname '*.c' | grep -v "$EXCLUDE_DIRS") \
         $(find "$1" -type f -iname '*.h' | grep -v "$EXCLUDE_DIRS")
}

function source_files {
    source_files_in_dir .
}

function source_files_staged {
    # shellcheck disable=SC2046
    git diff --cached --name-only | \
        xargs -I '{}' echo ./$(realpath --relative-to=. "$(git rev-parse --show-toplevel)"/'{}') | \
        grep "\.c\|\.h" | grep -v "$EXCLUDE_DIRS"
}
