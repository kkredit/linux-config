#!/bin/bash
# WSL only -- use "chocolatey" to install Windows programs

# shellcheck disable=SC1091
source ../helper_scripts/local-helpers.sh

$WSL || exit 1

# Setup
BAT_DIR=bat_scripts
INST_CHOCO=$BAT_DIR/win-install-choco.bat
RUN_CHOCO=$BAT_DIR/choco-install-packages.bat
PACKAGES_FILE="$WSL_DKTP/packages.txt"

# Setup
[[ $(which choco.exe) ]] || run_bat_elevated $INST_CHOCO

if has_arg "update"; then
  choco upgrade all -y
  exit 0
fi

function choco_install_packages() {
  echo "# Autocreated file; do not modify" > "$PACKAGES_FILE"
  for PACKAGE in "$@"; do
    echo "$PACKAGE" >> "$PACKAGES_FILE"
  done
  unix2dos "$PACKAGES_FILE" &> /dev/null
  run_bat_elevated $RUN_CHOCO
  rm "$PACKAGES_FILE"
}

# Package groups
if has_arg "basic"; then
  choco_install_packages \
    microsoft-windows-terminal \
    googlechrome \
    firefox \
    enpass.install \
    7zip.install \
    adobereader \
    notepadplusplus \
    windirstat \
    sharpkeys\
    unifying \
    shellcheck
fi

if has_arg "wslgit"; then
   URL="https://github.com$(curl -s https://github.com/andy-5/wslgit/releases | \
          grep "releases/download/*.*.*/wslgit.exe" | head -1 | cut -d\" -f2)"
   wget -q "$URL"
   mkdir -p "$(wslpath "C:/wsl/bin")"
   mv wslgit.exe "$(wslpath "C:/wsl/bin")"/
fi

if has_arg "codium"; then
  choco_install_packages \
    vscodium \
    firacode
  # Also consider hexedit and winmerge
fi

if has_arg "drawio"; then
  choco_install_packages drawio
fi

if has_arg "utilities"; then
  choco_install_packages \
    hexedit \
    winmerge \
    filezilla \
    win32diskimage
fi

if has_arg "vbox" || has_arg "virtualbox"; then
  echo "Use VBox-specific scripts in vbox/"
  exit 1
fi

