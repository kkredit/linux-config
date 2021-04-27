#!/usr/bin/env bash

################################################################################
#                                                                     PREAMBLE #
set -eEuo pipefail
cd "$(dirname "$0")"

# shellcheck disable=SC1091
source ./pre-commit-helpers.sh

USAGE="
Usage: ${0##*/} [-h | -s | DIR | FILE1 FILE2 ...]

  -h: print usage and exit
  -s: run on staged files
  DIR: run on all source files in given directory
  FILE1...: run on specific files
"

################################################################################
#                                                                      OPTIONS #
CONFIG_FILE=./.astylerc
ASTYLE_CMD="astyle --options=$CONFIG_FILE --suffix=none --formatted --preserve-date --ignore-exclude-errors-x"

(( $# > 0 )) || exitprint 1 "$USAGE"

while getopts "hps" arg; do  # argument values stored in $OPTARG
  case $arg in
    h) exitprint 0 "$USAGE" ;;
    s)  # shellcheck disable=SC2046
        run_cmd_on_files "echo $ASTYLE_CMD" $(source_files_staged); exit $? ;;
    *) ;;
  esac
done

if [ -d "$1" ]; then
    # shellcheck disable=SC2046
    run_cmd_on_files "echo $ASTYLE_CMD" $(source_files_in_dir "$1")
else
    run_cmd_on_files "echo $ASTYLE_CMD" "$@"
fi
