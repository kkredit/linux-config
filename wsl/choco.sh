#!/bin/bash
# WSL only

# Pass args to choco in an admin command console
powershell.exe -Command "Start-Process cmd -ArgumentList \"/C choco $@\" -Verb RunAs"
