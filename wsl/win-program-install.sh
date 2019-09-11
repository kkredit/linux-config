#!/bin/bash
# WSL only -- use "chocolatey" to install Windows programs

# Setup
BAT_DIR=bat_scripts
INST_CHOCO=win-install-choco.bat
RUN_CHOCO=choco-install-packages.bat
PACKAGES=packages.txt

# Install chocolatey
run_bat_elevated $BAT_DIR/$INST_CHOCO

# Install packages
echo "Installing packages..."
unix2dos -n $PACKAGES $WSL_DKTP/$PACKAGES &> /dev/null
run_bat_elevated $BAT_DIR/$RUN_CHOCO
rm $WSL_DKTP/$PACKAGES

# Configure WSLtty (see https://github.com/mintty/wsltty)
echo "Configuring WSLtty..."
run_cmd "C:\\Users\\kevinkredit\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty\\add default to context menu"
unix2dos -n config_wsltty $(winpath2wsl $APPDATA)/wsltty/config &> /dev/null

# Cleanup
echo "Done!"
