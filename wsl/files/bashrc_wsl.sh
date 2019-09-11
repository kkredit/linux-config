# ~/.wsl_bashrc

WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"
export WIN_USER WSL_DKTP WIN_DKTP

function winpath2wsl() {
    echo $1 | sed 's,\\,/,g' | sed -E 's,([A-Z]):,/mnt/\L\1,g'
}

function run_cmd() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\""
}

function run_cmd_elevated() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\" -Verb RunAs"
}

function run_bat() {
    # Copy to desktop so Windows can easily see it; run; clean up

    FILE=$1
    if [[ ! -f $FILE ]]; then
        echo run_bat FILENAME
        return 1
    fi
    FILENAME=$(basename $FILE)

    unix2dos -n $FILE $WSL_DKTP/$FILENAME &> /dev/null
    run_cmd "$WIN_DKTP\\$FILENAME"
    rm $WSL_DKTP/$FILENAME
}

function run_bat_elevated() {
    # Copy to desktop so Windows can easily see it; run; clean up

    FILE=$1
    if [[ ! -f $FILE ]]; then
        echo run_bat FILENAME
        return 1
    fi
    FILENAME=$(basename $FILE)

    unix2dos -n $FILE $WSL_DKTP/$FILENAME &> /dev/null
    run_cmd_elevated "$WIN_DKTP\\$FILENAME"
    rm $WSL_DKTP/$FILENAME
}

function choco() {
    powershell.exe -Command "Start-Process cmd -ArgumentList \"/C choco $@\" -Verb RunAs"
}

export -f winpath2wsl run_cmd run_cmd_elevated run_bat run_bat_elevated choco
