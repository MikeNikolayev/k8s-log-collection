#!/bin/bash

# Function to generate report for a single pod
generate_report_for_pod() {
    pod_name=$1
    namespace=$2
    output_file=$3

    # Run the command and filter the outbound_tcp_errors
    errors=$(linkerd diagnostics proxy-metrics pod/$pod_name -n $namespace | grep ^outbound_tcp_errors_total)

    if [ -n "$errors" ]; then
        echo "Source Pod: $pod_name" >> $output_file
        echo "----------------------------------------" >> $output_file

        # Loop through each line of errors
        while IFS= read -r line; do
            target_ip=$(echo $line | grep -oP '(?<=target_ip=")[^"]*')
            target_port=$(echo $line | grep -oP '(?<=target_port=")[^"]*')
            error_count=$(echo $line | awk '{print $2}')

            # Find the pod that corresponds to the target IP
            target_pod=$(kubectl get pods -o wide -n $namespace | grep $target_ip | awk '{print $1}')

            echo "Error connecting to IP: $target_ip, Port: $target_port" >> $output_file
            echo "Target Pod: $target_pod" >> $output_file
            echo "Error Count: $error_count" >> $output_file
            echo "----------------------------------------" >> $output_file
        done <<< "$errors"
    else
        echo "Source Pod: $pod_name - No outbound TCP errors detected." >> $output_file
        echo "----------------------------------------" >> $output_file
    fi
}

# Main script
namespace="default"  # Change this to your namespace if needed
output_file="linkerd_outbound_errors_report.txt"

# Clear previous report
> $output_file  # Clear the file without using echo ""

# Get the list of all pods
pods=$(kubectl get pods -n $namespace --no-headers | awk '{print $1}')

# Loop through each pod
for pod in $pods; do
    generate_report_for_pod $pod $namespace $output_file
done

echo "Report generated: $output_file"

