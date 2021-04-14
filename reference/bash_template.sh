#!/usr/bin/env bash

################################################################################
#                                                                     PREAMBLE #
set -eEuo pipefail
#set -x

cd "$(dirname "$0")"
function cleanup() {
  :
}
trap cleanup EXIT   # run cleanup() upon exit
trap 'exit 130' INT # call exit upon interrupt

function exitprint() {
  echo "${@:2}" 1>&2
  exit "$1"
}

USAGE="
Usage: ${0##*/} [-hv]

  -h: print usage and exit
  -v: be verbose
"

################################################################################
#                                                                     SETTINGS #
VERBOSE=false

################################################################################
#                                                                      OPTIONS #
while getopts "hv" arg; do # argument values stored in $OPTARG
  case $arg in
    h) exitprint 0 "$USAGE" ;;
    v) VERBOSE=true ;;
    *) exitprint 128 "$USAGE" ;;
  esac
done

################################################################################
#                                                                       SCRIPT #

function header_print {
  printf "\n===============================================================================\n"
  echo "$@"
  printf "===============================================================================\n\n"
}

function run_on_target {
  ssh user@ip_addr bash -esx <<<"$1"
}

# shellcheck disable=SC2086
# Use ^^ to disable a specific shellcheck linting rule
