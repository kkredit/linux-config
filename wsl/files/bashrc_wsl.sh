# ~/.wsl_bashrc

WIN_USER=$(powershell.exe '$env:UserName' | sed 's/\r//g')
WSL_DKTP="/mnt/c/Users/$WIN_USER/Desktop"
WIN_DKTP="C:\\Users\\$WIN_USER\\Desktop"
export WIN_USER WSL_DKTP WIN_DKTP

function winpath2wsl() {
    echo $1 | sed 's,\\,/,g' | sed 's, ,\\ ,g' | sed -E 's,([A-Z]):,/mnt/\L\1,g'
}

function run_cmd() {
    cmd.exe /C $@
}

function run_ps() {
    powershell.exe -Command "Start-Process -Wait cmd -ArgumentList \"/C $@\""
}

function run_ps_elevated() {
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
    run_ps "$WIN_DKTP\\$FILENAME"
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
    run_ps_elevated "$WIN_DKTP\\$FILENAME"
    rm $WSL_DKTP/$FILENAME
}

function choco() {
    powershell.exe -Command "Start-Process cmd -ArgumentList \"/C choco $@\" -Verb RunAs"
}

function wincp_headers() {
    BASE=$(winpath2wsl 'C:\wsl')
    if [ ! -d $BASE ]; then
        echo "Create dir '$BASE' first"
        return 1
    fi
    mkdir -p $BASE/usr
    mkdir -p $BASE/usr/local
    cp -r /usr/include $BASE/usr
    cp -r /usr/local/include $BASE/usr/local
}

export -f winpath2wsl run_cmd run_ps run_ps_elevated run_bat run_bat_elevated choco wincp_headers
