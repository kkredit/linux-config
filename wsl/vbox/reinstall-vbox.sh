#!/bin/bash -eu
# WSL only -- reinstall VirtualBox

# Download VBox
VBOX_INSTALLER=vbox_install.exe
VBOX_DOWNLOAD_URL=$(curl -s https://www.virtualbox.org/wiki/Downloads | \
                    grep -i "windows hosts" | cut -d'"' -f4)
touch ~/.wget-hsts
chmod 600 ~/.wget-hsts
wget -O $WSL_DKTP/$VBOX_INSTALLER $VBOX_DOWNLOAD_URL

# Run installer
run_cmd_elevated "$WIN_DKTP\\$VBOX_INSTALLER"

# Cleanup
rm $WSL_DKTP/$VBOX_INSTALLER
rm ~/.wget-hsts

