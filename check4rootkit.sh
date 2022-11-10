#!/usr/bin/env bash

SERVERS=$(ls ./Boardreader_configs/servers)
COPY_DIR="/home/$USER"
TMP="/tmp"
PACKAGE_DIR="checker"
RUN_DATE=$(date '+%Y-%m-%d')
### Functions ###
createFolder () {
    # Check folder exists. If not, create it and go to it.
    if [[ ! -d $1 ]]; then
        mkdir "$1"
    fi
} 
createFolder $COPY_DIR/$RUN_DATE
createFolder $TMP/$PACKAGE_DIR
tar -xzf ./bash-scripts/checker/chkrootkit.tgz -C $TMP/$PACKAGE_DIR

for SERVER in $SERVERS; do
  echo "Run script on $SERVER"
  scp -rq $TMP/$PACKAGE_DIR "$SERVER:$COPY_DIR"
  scp -rq ./bash-scripts/checker/chkrootkit-on-server.sh "$SERVER:$COPY_DIR"
  ssh "$SERVER" "sudo su - root -c \"$COPY_DIR/chkrootkit-on-server.sh\"" >> BR-rootkit-check-"$RUN_DATE".log 2>&1
  scp -q "$SERVER":"$COPY_DIR"/"$SERVER"-"$RUN_DATE".log $COPY_DIR/$RUN_DATE
  ssh "$SERVER" "sudo su - root -c \"rm -rf $COPY_DIR/chkrootkit-on-server.sh\""
  ssh "$SERVER" "sudo su - root -c \"rm -rf $COPY_DIR/"$SERVER"-"$RUN_DATE".log\""
  ssh "$SERVER" "sudo su - root -c \"rm -rf $COPY_DIR/checker\""
  echo "......"
done

tar czf BR-rootkit-check-$RUN_DATE.tgz $COPY_DIR/$RUN_DATE > /dev/null 2>&1
rm -rf $COPY_DIR/$RUN_DATE
rm -rf $TMP/$PACKAGE_DIR
