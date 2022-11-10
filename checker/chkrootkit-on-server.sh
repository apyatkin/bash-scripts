#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT=$(readlink -f "$0")
SOURCE=$(dirname "$SCRIPT")
HOSTNAME=$(hostname -s)


PACKAGE_DIR="checker/chkrootkit"
WHAT_TO_SEARCH="INFECTED"
HOSTNAME=$(hostname -s)
RUN_DATE=$(date '+%Y-%m-%d')

"$SOURCE"/"$PACKAGE_DIR"/chkrootkit > "$SOURCE"/"$PACKAGE_DIR"/"$HOSTNAME"-"$RUN_DATE".log

cp "$SOURCE"/"$PACKAGE_DIR"/"$HOSTNAME"-"$RUN_DATE".log "$SOURCE"

if grep -q "$WHAT_TO_SEARCH" "$SOURCE"/"$PACKAGE_DIR"/"$HOSTNAME"-"$RUN_DATE".log; then
    echo "'$HOSTNAME' - INFECTED item(s) found."
else
    echo "'$HOSTNAME' - NO INFECTED item(s) found."
fi
