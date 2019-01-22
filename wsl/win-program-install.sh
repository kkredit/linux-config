#!/bin/bash
# WSL only -- use "chocolatey" to install Windows programs

# Setup
WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"

BAT_DIR=bat_scripts
INST_CHOCO=win-install-choco.bat
RUN_CHOCO=choco-install-packages.bat
PACKAGES=packages.txt

# Function that executes CMD in an elevated prompt
function run_elevated() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\" -Verb RunAs"
}

# Copy files so CMD can easily see them
echo "Copying necessary files to desktop..."
unix2dos -n $BAT_DIR/$INST_CHOCO $WSL_DKTP/$INST_CHOCO &> /dev/null
unix2dos -n $BAT_DIR/$RUN_CHOCO $WSL_DKTP/$RUN_CHOCO &> /dev/null
unix2dos -n $PACKAGES $WSL_DKTP/$PACKAGES &> /dev/null

# Install chocolatey
echo "Installing chocolatey..."
run_elevated "$WIN_DKTP\\$INST_CHOCO"

# Install packages
echo "Installing packages..."
run_elevated "$WIN_DKTP\\$RUN_CHOCO"

# Cleanup
rm $WSL_DKTP/$INST_CHOCO $WSL_DKTP/$RUN_CHOCO $WSL_DKTP/$PACKAGES
echo "Done!"
