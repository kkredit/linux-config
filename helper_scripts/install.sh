
# Note: this file to be sourced

if [ -z ${PACKAGE_MANAGER+x} ]; then
    if [[ "" != "$(which apt-get)" ]]; then
        PACKAGE_MANAGER=apt-get
    elif [[ "" != "$(which yum)" ]]; then
        PACKAGE_MANAGER=yum
    else
        echo "Neither apt-get nor yum are present. No suitable package manager found; exiting."
        exit 1
    fi
fi

function pkg-mgr() {
    $PACKAGE_MANAGER $@
}

function sudo-pkg-mgr() {
    sudo $PACKAGE_MANAGER $@
}
