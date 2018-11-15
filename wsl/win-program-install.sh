#!/bin/bash

# WSL only -- use "chocolatey" to install Windows programs
unix2dos chocolatey-install.bat > /dev/null
cat chocolatey-install.bat | cmd.exe
dos2unix chocolatey-install.bat > /dev/null
