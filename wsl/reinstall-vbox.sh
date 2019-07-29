#!/bin/bash -eu
# WSL only -- reinstall VirtualBox

# Setup
WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"

VBOX_INSTALLER=vbox_install.exe

# Function that executes CMD in an elevated prompt
function run_elevated() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\" -Verb RunAs"
}

# Download VBox
VBOX_DOWNLOAD_URL=$(curl -s https://www.virtualbox.org/wiki/Downloads | \
                    grep -i "windows hosts" | cut -d'"' -f4)
wget -O $WSL_DKTP/$VBOX_INSTALLER $VBOX_DOWNLOAD_URL

# Run installer
echo "Running Vbox installer..."
run_elevated "$WIN_DKTP\\$VBOX_INSTALLER"

# Cleanup
rm $WSL_DKTP/$VBOX_INSTALLER
echo "Done!"
