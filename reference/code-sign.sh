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
Usage: ${0##*/} -f FILE [-g | -k KEY] -p KEY_PASSCODE [-hv]

  -f: file to sign
  -g: generate new RSA signing keypair
  -h: print usage and exit
  -k: RSA private key
  -p: passcode to RSA key
  -v: be verbose
"

################################################################################
#                                                                     SETTINGS #
FILE=""
PRIVATE_KEY=""
KEY_PASSCODE=""
GENERATE_KEYS=false
VERBOSE=false

################################################################################
#                                                                      OPTIONS #
while getopts "f:ghk:p:v" arg; do # argument values stored in $OPTARG
  case $arg in
    f) FILE=$OPTARG ;;
    g) GENERATE_KEYS=true ;;
    h) exitprint 0 "$USAGE" ;;
    k) PRIVATE_KEY=$OPTARG ;;
    p) KEY_PASSCODE=$OPTARG ;;
    v) VERBOSE=true ;;
    *) exitprint 128 "$USAGE" ;;
  esac
done

$VERBOSE && set -x

[[ "" == "$FILE" ]] && exitprint 1 "No file to sign specified"
[[ "" == "$KEY_PASSCODE" ]] && exitprint 1 "No key passcode specified"
if [[ "" == "$PRIVATE_KEY" ]] && ! $GENERATE_KEYS; then exitprint 1 "No signing key specified"; fi
if [[ "" != "$PRIVATE_KEY" ]] && $GENERATE_KEYS; then exitprint 1 "Cannot use both -g and -k"; fi

################################################################################
#                                                                       SCRIPT #

function generate_keys {
  PRIVATE_KEY="private.pem"
  openssl genrsa -aes128 -passout pass:"$KEY_PASSCODE" -out $PRIVATE_KEY 2048 &>/dev/null
  openssl rsa -in $PRIVATE_KEY -passin pass:"$KEY_PASSCODE" -pubout -out public.pem &>/dev/null
  echo "RSA KEYPAIR: $PRIVATE_KEY, public.pem"
}

function hash_file_name { echo "$1.sha256"; }
function sig_file_name { echo "$1.sha256.signature"; }

function hash {
  openssl dgst -sha256 "$1" | awk '{print $2}' > "$(hash_file_name "$1")"
  echo "HASH FILE: $(hash_file_name "$1")"
}

function sign_hash {
  local SIG_TMP
  SIG_TMP=$(mktemp)
  openssl dgst -sign "$2" -passin pass:"$3" -out "$SIG_TMP" "$(hash_file_name "$1")"
  openssl base64 -in "$SIG_TMP" -out "$(sig_file_name "$1")"
  echo "SIGNATURE FILE: $(sig_file_name "$1")"
}

$GENERATE_KEYS && generate_keys
hash "$FILE"
sign_hash "$FILE" "$PRIVATE_KEY" "$KEY_PASSCODE"
