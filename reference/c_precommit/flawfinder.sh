#!/usr/bin/env bash

################################################################################
#                                                                     PREAMBLE #
set -eEuo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091
source ./pre-commit-helpers.sh

USAGE="
Usage: ${0##*/} [-h | -p | -s | DIR | FILE1 FILE2 ...]

  -h: print usage and exit
  -p: run on staged files, and exit non-zero if flaws of severity >= 4 are found
  -s: run on staged files
  DIR: run on all source files in given directory
  FILE1...: run on specific files
"

################################################################################
#                                                                      OPTIONS #

(( $# > 0 )) || exitprint 1 "$USAGE"

while getopts "hps" arg; do  # argument values stored in $OPTARG
  case $arg in
    h) exitprint 0 "$USAGE" ;;
    p)  # shellcheck disable=SC2046
        run_cmd_on_files "echo flawfinder --error-level 4 --" $(source_files_staged); exit $? ;;
    s)  # shellcheck disable=SC2046
        run_cmd_on_files "echo flawfinder --" $(source_files_staged); exit $? ;;
    *) ;;
  esac
done

if [ -d "$1" ]; then
    # shellcheck disable=SC2046
    run_cmd_on_files "echo flawfinder --" $(source_files_in_dir "$1")
else
    run_cmd_on_files "echo flawfinder --" "$@"
fi
