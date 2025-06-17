#!/bin/bash

USER="$1"
HOST="$2"
TIMEOUT="$3"
KEY="$4"
INTERVAL=10

END=$((SECONDS + TIMEOUT))

while [ $SECONDS -lt $END ]; do
    ssh -i "$KEY" -o ConnectTimeout=9 -o BatchMode=yes -o StrictHostKeyChecking=no "${USER}@${HOST}" 'exit' && exit 0
    sleep $INTERVAL
done

exit 1