#!/usr/bin/env bash
# See https://gist.github.com/ezimuel/3cb601853db6ebc4ee49

################################################################################
#                                                                     PREAMBLE #
set -eEuo pipefail

function exitprint() {
  echo "${@:2}" 1>&2
  exit "$1"
}

USAGE="
Usage: ${0##*/} -f FILE -k PUBLIC_KEY -s SIG_FILE [-H HASH_FILE] [-hv]

  -f: file to sign or verify
  -h: print usage and exit
  -H: (optional) hash file to validate intermediate step
  -k: RSA or public key
  -s: signature file
  -v: be verbose
"

################################################################################
#                                                                     SETTINGS #
FILE=""
PUBLIC_KEY=""
HASH_FILE=""
SIG_FILE=""
VERBOSE=false

################################################################################
#                                                                      OPTIONS #
while getopts "f:hH:k:p:s:v" arg; do # argument values stored in $OPTARG
  case $arg in
    f) FILE=$OPTARG ;;
    h) exitprint 0 "$USAGE" ;;
    H) HASH_FILE=$OPTARG ;;
    k) PUBLIC_KEY=$OPTARG ;;
    s) SIG_FILE=$OPTARG ;;
    v) VERBOSE=true ;;
    *) exitprint 128 "$USAGE" ;;
  esac
done

$VERBOSE && set -x

[[ "" == "$FILE" ]] && exitprint 1 "No file to verify specified"
[[ "" == "$PUBLIC_KEY" ]] && exitprint 1 "No public key specified"
[[ "" == "$SIG_FILE" ]] && exitprint 1 "No signature file specified"

################################################################################
#                                                                       SCRIPT #

function hash {
  openssl dgst -sha256 "$1" | awk '{print $2}'
}

function verify_hash_files {
  [[ "$(cat "$1")" == "$(cat "$2")" ]] || exitprint 1 "Failure: Hashes don't match"
}

function verify_sig {
  local SIG_TMP
  SIG_TMP=$(mktemp)
  openssl base64 -d -in "$3" -out "$SIG_TMP"
  openssl dgst -sha256 -verify "$2" -signature "$SIG_TMP" "$1"
}

HASH_TMP=$(mktemp)
hash "$FILE" > "$HASH_TMP"
[[ "" != "$HASH_FILE" ]] && verify_hash_files "$HASH_TMP" "$HASH_FILE"
verify_sig "$HASH_TMP" "$PUBLIC_KEY" "$SIG_FILE"
