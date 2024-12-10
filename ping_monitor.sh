#!/bin/bash

# Define nodes to monitor
NODES=("10.218.133.170" "10.218.139.136" "10.218.137.240")
LOG_FILE="/var/tmp/ping_monitor.log"

while true; do
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  echo "=== $TIMESTAMP ===" >> $LOG_FILE
  for NODE in "${NODES[@]}"; do
    PING_RESULT=$(ping -c 5 $NODE)
    echo "$PING_RESULT" >> $LOG_FILE
    echo "----------------------------------" >> $LOG_FILE
  done
  sleep 15  # Adjust the interval as needed
done

