#!/bin/bash

# Wrapper script for PUS7_RNA structure prediction

# Check for dry run option
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
    echo "Performing dry run - no jobs will be submitted"
fi

# Base directory for PUS7_RNA project
BASE_DIR="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"

# Directory containing the scripts
SCRIPT_DIR="/scratch/users/rodell/AlphaFold3/AF3"

# Log file
LOG_FILE="$BASE_DIR/PUS7_RNA_prediction.log"

# Ensure the base directory exists
mkdir -p "$BASE_DIR"

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
        if [ -d "$dir" ] && [ -d "$dir/input" ] && [ -f "$dir/input"/*.json ]; then
            echo "$count $(basename "$dir")" >> "$map_file"
            count=$((count + 1))
        fi
    done
    if [ $count -ne 122 ]; then  # 122 because count is incremented one extra time
        log_message "WARNING: Expected 121 valid directories, but found $((count-1))"
    fi
}

# Function to check job array status (mock version for dry run)
check_job_array_status() {
    local job_id=$1
    local job_name=$2
    
    if $DRY_RUN; then
        log_message "Dry run: Would check status of $job_name job array with ID $job_id"
        log_message "Dry run: Assuming $job_name job array completed successfully"
    else
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
    fi
}

# Start of main script execution
log_message "Starting PUS7_RNA structure prediction workflow"

# Create mapping file
create_mapping_file

# Submit pipeline job array
log_message "Submitting pipeline job array"
if $DRY_RUN; then
    log_message "Dry run: Would submit job: sbatch --export=ALL,MAP_FILE=$BASE_DIR/directory_mapping.txt $SCRIPT_DIR/pipeline_array.sbatch"
    pipeline_job="dry-run-12345"
else
    pipeline_job=$(sbatch --export=ALL,MAP_FILE=$BASE_DIR/directory_mapping.txt --parsable "$SCRIPT_DIR/pipeline_array.sbatch")
fi

if [ $? -ne 0 ] && [ "$DRY_RUN" = false ]; then
    log_message "ERROR: Failed to submit pipeline job array"
    exit 1
fi

log_message "Pipeline job array submitted with ID: $pipeline_job"

# Check status of pipeline job array
check_job_array_status $pipeline_job "Pipeline"

# If we've reached here, pipeline jobs completed successfully
log_message "Pipeline jobs completed successfully. Submitting inference job array"

# Submit inference job array
if $DRY_RUN; then
    log_message "Dry run: Would submit job: sbatch --export=ALL,MAP_FILE=$BASE_DIR/directory_mapping.txt --dependency=afterok:$pipeline_job $SCRIPT_DIR/inference_array.sbatch"
    inference_job="dry-run-67890"
else
    inference_job=$(sbatch --export=ALL,MAP_FILE=$BASE_DIR/directory_mapping.txt --parsable --dependency=afterok:$pipeline_job "$SCRIPT_DIR/inference_array.sbatch")
fi

if [ $? -ne 0 ] && [ "$DRY_RUN" = false ]; then
    log_message "ERROR: Failed to submit inference job array"
    exit 1
fi

log_message "Inference job array submitted with ID: $inference_job"

# Check status of inference job array
check_job_array_status $inference_job "Inference"

# If we've reached here, all jobs completed successfully
log_message "All PUS7_RNA structure prediction jobs completed successfully"

# Additional dry run checks
if $DRY_RUN; then
    log_message "Dry run: Checking directory structure and mapping"
    if [ -f "$BASE_DIR/directory_mapping.txt" ]; then
        mapped_count=$(wc -l < "$BASE_DIR/directory_mapping.txt")
        log_message "Found $mapped_count mapped directories"
        if [ $mapped_count -ne 121 ]; then
            log_message "WARNING: Expected 121 mapped directories, but found $mapped_count"
        fi
    else
        log_message "WARNING: Mapping file not found"
    fi

    log_message "Dry run: Checking script files"
    for script in "pipeline_array.sbatch" "inference_array.sbatch"; do
        if [ ! -f "$SCRIPT_DIR/$script" ]; then
            log_message "WARNING: Script $script not found in $SCRIPT_DIR"
        fi
    done
    
    log_message "Dry run: Checking for af3.sif"
    if [ ! -f "/scratch/users/rodell/AlphaFold3/af3.sif" ]; then
        log_message "WARNING: af3.sif not found at expected location"
    fi
    
    log_message "Dry run completed. Review the log for any warnings or errors."
fi