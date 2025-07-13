#!/bin/bash

# Wrapper script for PUS7_RNA structure inference

# Base directory for PUS7_RNA project
BASE_DIR="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"

# Directory containing the scripts
SCRIPT_DIR="/scratch/users/rodell/AlphaFold3/AF3"

# Log file
LOG_FILE="$BASE_DIR/PUS7_RNA_inference.log"

# Ensure the base directory exists
mkdir -p "$BASE_DIR"

# Ensure directory for slurm logs exist
mkdir -p /scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA/inference_logs

# Function to log messages
log_message() {
    local message="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$message" >> "$LOG_FILE"
    echo "$message"
}

# Function to create mapping file
create_mapping_file() {
    local map_file="$BASE_DIR/directory_mapping.txt"
    rm -f "$map_file"
    local count=1
    for dir in "$BASE_DIR"/*; do
        if [ -d "$dir" ] && [ -d "$dir/output" ] && [ -f "$dir/output/$(basename "$dir" | tr '[:upper:]' '[:lower:]')/$(basename "$dir" | tr '[:upper:]' '[:lower:]')_data.json" ]; then
            echo "$count $(basename "$dir")" >> "$map_file"
            count=$((count + 1))
        fi
    done
    if [ $count -ne 122 ]; then  # 122 because count is incremented one extra time
        log_message "WARNING: Expected 121 valid directories, but found $((count-1))"
    fi
}

# Function to check job array status
check_job_array_status() {
    local job_id=$1
    local job_name=$2
    
    while true; do
        status=$(sacct -j $job_id --format=State -n | sort -u)
        if [[ $status == *"FAILED"* ]]; then
            log_message "ERROR: $job_name job array failed. Cancelling all jobs."
            scancel -u $USER  # Cancel all jobs for the current user
            exit 1
        elif [[ $status != *"RUNNING"* && $status != *"PENDING"* ]]; then
            log_message "$job_name job array completed successfully."
            break
        fi
        sleep 60  # Check every minute
    done
}

# Start of main script execution
log_message "Starting PUS7_RNA structure inference workflow"

# Create mapping file
create_mapping_file

# Submit inference job array
log_message "Submitting inference job array"
inference_job=$(sbatch --export=ALL,MAP_FILE=$BASE_DIR/directory_mapping.txt --parsable "$SCRIPT_DIR/inference_array.sbatch")

if [ $? -ne 0 ]; then
    log_message "ERROR: Failed to submit inference job array"
    exit 1
fi

log_message "Inference job array submitted with ID: $inference_job"

# Check status of inference job array
check_job_array_status $inference_job "Inference"

# If we've reached here, all jobs completed successfully
log_message "All PUS7_RNA structure inference jobs completed successfully"