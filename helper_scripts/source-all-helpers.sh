#!/usr/bin/env bash

HELPER_DIR="$(git rev-parse --show-toplevel)/helper_scripts"
HELPERS="$(find $HELPER_DIR -type f -name \*.sh | grep -v source-all-helpers.sh)"

for HELPER in $HELPERS; do
    source $HELPER
done
