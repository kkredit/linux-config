#!/bin/bash -eu
# Thanks to Stewart Hildebrand for this script! https://github.com/stewdk, http://www.stew.dk/
# Copyright 2020 Stew Hildebrand
# SPDX-License-Identifier: MIT

KERNEL_VARIANT="$(uname -r | awk -F "-" '{print $NF}')"
KERNEL_VERSION="$(uname -r | sed -e "s/-${KERNEL_VARIANT}//")"

echo "Currently running: ${KERNEL_VERSION}-${KERNEL_VARIANT}"

ALL_VER="$(dpkg --list | grep -e linux-image -e linux-headers | \
           grep -v -e linux-headers-"${KERNEL_VARIANT}" -e linux-image-"${KERNEL_VARIANT}" | \
           awk '{print $3}' | sed 's/+.*$//' | sort -uV)"

echo "All installed: ${ALL_VER}"

NUM_INSTALLED="$(echo "${ALL_VER}" | wc -l)"

if [ "${NUM_INSTALLED}" -lt 3 ]; then
    echo "2 or fewer kernel versions installed, quitting"
    exit
fi

NUM_TO_REMOVE=$(("${NUM_INSTALLED}" - 2))
REMOVE_VER="$(echo "${ALL_VER}" | head -n "${NUM_TO_REMOVE}")"
REMOVE_PACKAGES="$(dpkg --list | grep -e "${REMOVE_VER}" | grep -v libc | awk '{print $2}')"

echo "Removing: ${REMOVE_PACKAGES}"

# shellcheck disable=SC2086
sudo apt-get purge ${REMOVE_PACKAGES}
