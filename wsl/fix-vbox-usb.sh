#!/bin/bash
# WSL only -- run a few steps to fix VirtualBox USB

# Setup
WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"

BAT_DIR=bat_scripts
FIX_VBOX=fix-vbox-usb.bat

# Function that executes CMD in an elevated prompt
function run_elevated() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\" -Verb RunAs"
}

# Copy files so CMD can easily see them
echo "Copying necessary files to desktop..."
unix2dos -n $BAT_DIR/$FIX_VBOX $WSL_DKTP/$FIX_VBOX &> /dev/null

# Run bat script
echo "Running VBox bat script..."
run_elevated "$WIN_DKTP\\$FIX_VBOX"

# Cleanup
rm $WSL_DKTP/$FIX_VBOX
echo "Done!"
