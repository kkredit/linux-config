#!/usr/bin/env bash

################################################################################
#                                                                     PREAMBLE #
set -eEuo pipefail
#set -x

cd $(dirname $0)
function cleanup() {
  :
}
trap cleanup EXIT

function exitprint() {
  echo "${@:2}"
  exit $1
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
