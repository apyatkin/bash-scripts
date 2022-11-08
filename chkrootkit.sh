#!/bin/bash
SYSTEM_OS=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
LOG_DIR=/var/log/chkrootkit.d
LOG_FILENAME=$(date '+%Y-%m-%d').log
WHAT_TO_SEARCH="INFECTED"
REQUIRED_PKG="chkrootkit"

CENTOS_PACKAGE_URL="https://fossies.org/linux/misc/chkrootkit-0.55.tar.gz"

check_installed_package_ubuntu () {
        PKG_OK=$(dpkg --list | grep $REQUIRED_PKG | grep ii)
        if [ "" = "$PKG_OK" ]; then
          sudo apt-get --yes install $REQUIRED_PKG > /dev/null 2>&1
        fi
}

check_installed_package_centos () {
        INSTALL_PATH="/usr/local/chkrootkit"
        if [ ! -f $INSTALL_PATH/$REQUIRED_PKG ]; then
            yum install -y wget gcc-c++ glibc-static > /dev/null 2>&1
            cd /tmp
            wget -c $CENTOS_PACKAGE_URL > /dev/null 2>&1
            tar -xvzf chkrootkit-0.55.tar.gz > /dev/null 2>&1
            if [[ ! -e $INSTALL_PATH ]]; then
              mkdir $INSTALL_PATH
            fi
            mv chkrootkit-0.*/* $INSTALL_PATH
            cd $INSTALL_PATH
            make sense > /dev/null 2>&1
        fi
}

if [[ ! -e $LOG_DIR ]]; then
    mkdir $LOG_DIR
fi

if [[ -f '/usr/bin/apt' ]]; then
    check_installed_package_ubuntu
    INSTALL_PATH="/usr/sbin"
else
    check_installed_package_centos
    INSTALL_PATH="/usr/local/chkrootkit"
fi

$INSTALL_PATH/chkrootkit -q > $LOG_DIR/$LOG_FILENAME

if grep -q $WHAT_TO_SEARCH $LOG_DIR/$LOG_FILENAME; then
    echo "INFECTED item(s) found."
else
    echo "NO INFECTED item(s) found."
fi
