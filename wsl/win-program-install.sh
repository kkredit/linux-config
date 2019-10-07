#!/bin/bash
# WSL only -- use "chocolatey" to install Windows programs

# Setup
FILES_DIR=files
BAT_DIR=bat_scripts
INST_CHOCO=win-install-choco.bat
RUN_CHOCO=choco-install-packages.bat
PACKAGES=packages.txt

# Install chocolatey
run_bat_elevated $BAT_DIR/$INST_CHOCO

# Install packages
echo "Installing packages..."
unix2dos -n $FILES_DIR/$PACKAGES $WSL_DKTP/$PACKAGES &> /dev/null
run_bat_elevated $BAT_DIR/$RUN_CHOCO
rm $WSL_DKTP/$PACKAGES

# Configure WSLtty (see https://github.com/mintty/wsltty)
echo "Configuring WSLtty..."
run_ps "C:\\Users\\kevinkredit\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\WSLtty\\add default to context menu"
unix2dos -n $FILES_DIR/config_wsltty $(wslpath $APPDATA)/wsltty/config &> /dev/null
cp $FILES_DIR/bash-logo.ico  $(wslpath $APPDATA)/../Local/wsltty/wsl.ico

# Cleanup
echo "Done!"
