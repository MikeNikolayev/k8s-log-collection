#!/bin/bash

LOG_FILE="/var/tmp/k3s_restart_monitor.log"
RESTART_COUNT_FILE="/var/tmp/k3s_restart_count.log"

# Initialize restart count
if [ ! -f "$RESTART_COUNT_FILE" ]; then
    echo "Initializing restart count at $(date)" > $RESTART_COUNT_FILE
    echo "Total Restarts: 0" >> $RESTART_COUNT_FILE
fi

# Function to monitor k3s restarts
monitor_k3s_restarts() {
    LAST_RESTART=$(sudo systemctl show k3s --property=ActiveEnterTimestamp | awk -F'=' '{print $2}')
    PREVIOUS_RESTART=""

    while true; do
        CURRENT_RESTART=$(sudo systemctl show k3s --property=ActiveEnterTimestamp | awk -F'=' '{print $2}')
        
        if [ "$CURRENT_RESTART" != "$PREVIOUS_RESTART" ]; then
            PREVIOUS_RESTART="$CURRENT_RESTART"
            
            # Get the current total restart count
            TOTAL_RESTARTS=$(grep "Total Restarts:" $RESTART_COUNT_FILE | awk '{print $3}')
            
            # Update the total restart count
            NEW_TOTAL_RESTARTS=$((TOTAL_RESTARTS + 1))
            echo "Total Restarts: $NEW_TOTAL_RESTARTS" > $RESTART_COUNT_FILE

            # Log the restart time
            echo "[$(date)] k3s service restarted at $CURRENT_RESTART. Total restarts so far: $NEW_TOTAL_RESTARTS" >> $LOG_FILE
        fi
        
        # Sleep for a defined interval (e.g., 60 seconds)
        sleep 60
    done
}

# Run the monitoring function
monitor_k3s_restarts

