#!/bin/bash

$WSL || exit 1

mkdir -p /mnt/c/wsl/icons
cp images/* /mnt/c/wsl/icons/

cp windows-terminal-settings.json settings.json
sed -i "s/WIN_USER/$WIN_USER/g" settings.json
WIN_TERM_SETTINGS=$(ls /mnt/c/Users/"$WIN_USER"/AppData/Local/Packages/Microsoft.WindowsTerminal_*/LocalState/settings.json)
unix2dos -n settings.json "$WIN_TERM_SETTINGS" 2>/dev/null
rm settings.json

run_ps1 "$(git top)"/wsl/ps_scripts/setup-wt-context-menu.ps1
