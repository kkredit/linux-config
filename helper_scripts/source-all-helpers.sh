#!/usr/bin/env bash

HELPER_DIR="$(dirname $0)"
HELPERS="$(find $HELPER_DIR -type f -name \*.sh)"

for HELPER in $HELPERS; do
    source $HELPER
done
