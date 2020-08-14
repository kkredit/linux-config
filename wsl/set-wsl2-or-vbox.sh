#!/bin/bash
# WSL only -- toggle Windows settings to either support VirtualBox or WSL2

set -eEuo pipefail

function exitprint() {
  echo "${@:2}" 1>&2
  exit $1
}

$WSL || exitprint 1 "WSL only"

USAGE="
Usage: ${0##*/} [-w|-v] [-f]

  -w: configure Windows to support WSL2 features (at expense of VirtualBox)
  -v: configure Windows to support VirtualBox features (at expense of WSL2)
  -f: force config setting (disregard and overwrite cached state)
"

CACHED_STATE_FILE=~/.wsl2_or_virtualbox
[ -f $CACHED_STATE_FILE ] && CACHED_STATE=$(cat $CACHED_STATE_FILE) || CACHED_STATE=""

function set_wsl2 {
    if [[ "$CACHED_STATE" != "wsl2" ]] || $FORCE; then
        echo "Setting Windows features to support WSL 2; restart is required"
        run_cmd_elevated "dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
        echo "wsl2" > $CACHED_STATE_FILE
    else
        echo "Windows features already set to support WSL 2"
    fi
}

function set_vbox {
    if [[ "$CACHED_STATE" != "vbox" ]] || $FORCE; then
        echo "Setting Windows features to support VirtualBox; restart is required"
        run_cmd_elevated "dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /all /norestart"
        echo "vbox" > $CACHED_STATE_FILE
    else
        echo "Windows features already set to support VirtualBox"
    fi
}

function print_usage {
    exitprint 128 "$USAGE"
}

FORCE=false
FUNC=print_usage
while getopts "fwv" arg; do # argument values stored in $OPTARG
  case $arg in
    f) FORCE=true ;;
    w) FUNC=set_wsl2 ;;
    v) FUNC=set_vbox ;;
    *) print_usage ;;
  esac
done

eval $FUNC
