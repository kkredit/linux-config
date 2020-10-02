#!/bin/bash

set -eEuo pipefail
$WSL || exit 1

. ../helper_scripts/local-helpers.sh

if has_arg "-s"; then
    run_ps1_elevated $(git top)/wsl/ps_scripts/schedule-internet-toggle.ps1
else
    run_ps1_elevated $(git top)/wsl/ps_scripts/toggle-internet-share.ps1
fi
