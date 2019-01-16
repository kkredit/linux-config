#!/bin/bash

# WSL only -- use "chocolatey" to install Windows programs


# Setup
WSL_DKTP="/mnt/c/Users/kevinkredit/Desktop/"
WIN_DKTP="C:\\Users\\kevinkredit\\Desktop"

INST_CHOCO=install-choco.bat
RUN_CHOCO=choco-install-progs.bat

unix2dos -n $INST_CHOCO $WSL_DKTP/$INST_CHOCO > /dev/null
unix2dos -n $RUN_CHOCO $WSL_DKTP/$RUN_CHOCO > /dev/null


# Install chocolatey
powershell.exe -Command \
    "Start-Process cmd -ArgumentList \"/C $WIN_DKTP\\$INST_CHOCO\" -Verb RunAs"


# Install my windows programs
echo "Waiting 15 seconds for install to complete..."
sleep 15
powershell.exe -Command \
    "Start-Process cmd -ArgumentList \"/K $WIN_DKTP\\$RUN_CHOCO\" -Verb RunAs"



# Teardown

echo "Don't forget to delete the Desktop copy of chocolatey-install.bat"
echo "once the install is complete!"
