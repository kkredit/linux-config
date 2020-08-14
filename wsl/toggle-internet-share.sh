#!/bin/bash

set -eEuo pipefail
$WSL || exit 1

run_ps1_elevated $(git top)/wsl/ps_scripts/toggle-internet-share.ps1
