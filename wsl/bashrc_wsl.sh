# shellcheck disable=SC2148
# ~/.wsl_bashrc

# shellcheck disable=SC2016
WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"
export WIN_USER WSL_DKTP WIN_DKTP

function run_cmd_local {
    cmd.exe /C "$@"
}
export -f run_cmd_local

function run_cmd {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $*\""
}
export -f run_cmd

function run_cmd_elevated {
    powershell.exe -Command "Start-Process -Wait -Verb RunAs cmd -ArgumentList \"/C $*\""
}
export -f run_cmd_elevated

function run_bat {
    [ -f "$1" ] || return 1
    ABS_WIN_PATH=$(wslpath -aw "$1")
    run_cmd "$ABS_WIN_PATH"
}
export -f run_bat

function run_bat_elevated {
    [ -f "$1" ] || return 1
    ABS_WIN_PATH=$(wslpath -aw "$1")
    run_cmd_elevated "$ABS_WIN_PATH"
}
export -f run_bat_elevated

function run_ps1 {
    [ -f "$1" ] || return 1
    ABS_WIN_PATH=$(wslpath -aw "$1")
    powershell.exe -Command "Start-Process -Wait powershell -ArgumentList '-file $ABS_WIN_PATH'"
}
export -f run_ps1

function run_ps1_elevated {
    [ -f "$1" ] || return 1
    ABS_WIN_PATH=$(wslpath -aw "$1")
    powershell.exe -Command "Start-Process -Wait -Verb RunAs powershell -ArgumentList '-file $ABS_WIN_PATH'"
}
export -f run_ps1_elevated

function choco {
    run_cmd_elevated "choco $*"
}
export -f choco

function wincp_headers {
    BASE=/mnt/c/wsl
    mkdir -p $BASE/usr/local
    cp -r /usr/include $BASE/usr
    cp -r /usr/local/include $BASE/usr/local
}
export -f wincp_headers
