#!/bin/bash

source ../helper_scripts/local-helpers.sh

$WSL || exit 1

mkdir -p /mnt/c/wsl/icons
cp images/* /mnt/c/wsl/icons/

cp windows-terminal-settings.json settings.json
sed -i "s/WIN_USER/$WIN_USER/g" settings.json
WIN_TERM_SETTINGS=$(ls /mnt/c/Users/$WIN_USER/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json)
unix2dos -n settings.json "$WIN_TERM_SETTINGS"
rm settings.json

