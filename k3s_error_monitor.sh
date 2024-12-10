#!/bin/bash

LOG_FILE="/var/tmp/k3s_error_monitor.log"
ERROR_COUNT_FILE="/var/tmp/k3s_error_count.log"

# Initialize error count
echo "Initializing error count at $(date)" > $ERROR_COUNT_FILE
echo "Total Errors: 0" >> $ERROR_COUNT_FILE

# Function to extract, count, and log errors from k3s logs
monitor_k3s_logs() {
    while true; do
        # Get the last 100 lines of the k3s log and search for errors
        ERRORS=$(sudo journalctl -u k3s -n 100 | grep -E "E[0-9]{4} [0-9]{2}:[0-9]{2}:[0-9]{2}")

        # Count the number of errors found
        ERROR_COUNT=$(echo "$ERRORS" | wc -l)

        # Get the current total error count
        TOTAL_ERRORS=$(grep "Total Errors:" $ERROR_COUNT_FILE | awk '{print $3}')

        # Update the total error count
        NEW_TOTAL_ERRORS=$((TOTAL_ERRORS + ERROR_COUNT))
        echo "Total Errors: $NEW_TOTAL_ERRORS" > $ERROR_COUNT_FILE

        # Log the errors found in this cycle
        echo "[$(date)] Found $ERROR_COUNT new errors. Total errors so far: $NEW_TOTAL_ERRORS" >> $LOG_FILE

        if [ $ERROR_COUNT -gt 0 ]; then
            echo "Error details:" >> $LOG_FILE
            echo "$ERRORS" >> $LOG_FILE
            echo "----------------------------------" >> $LOG_FILE
        fi

        # Sleep for a defined interval (e.g., 60 seconds)
        sleep 60
    done
}

# Run the monitoring function
monitor_k3s_logs

