#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PACKAGE_DIR="chkrootkit"
WHAT_TO_SEARCH="INFECTED"
HOSTNAME=$(hostname -s)
RUN_DATE=$(date '+%Y-%m-%d')

tar xzvf chkrootkit.tgz
cd $PACKAGE_DIR

chkrootkit -q > "$HOSTNAME"-"$RUN_DATE".log

if grep -q $WHAT_TO_SEARCH "$HOSTNAME"-"$RUN_DATE".log; then
    echo "INFECTED item(s) found."
else
    echo "NO INFECTED item(s) found."
fi
