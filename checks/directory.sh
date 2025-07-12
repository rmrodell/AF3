#!/bin/bash

BASE_DIR="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"
SCRIPT_DIR="/scratch/users/rodell/AlphaFold3/AF3"
AF3_SIF="/scratch/users/rodell/AlphaFold3/af3.sif"

# Check main directories
for dir in "$BASE_DIR" "$SCRIPT_DIR"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Directory $dir does not exist"
        exit 1
    fi
done

# Check for script files
for script in "pipeline_array.sbatch" "inference_array.sbatch" "run_PUS7_RNA_prediction.sh"; do
    if [ ! -f "$SCRIPT_DIR/$script" ]; then
        echo "ERROR: Script $script not found in $SCRIPT_DIR"
        exit 1
    fi
done

# Check for af3.sif
if [ ! -f "$AF3_SIF" ]; then
    echo "ERROR: af3.sif not found at $AF3_SIF"
    exit 1
fi

# Check subdirectories and JSON files
count=0
for subdir in "$BASE_DIR"/*; do
    if [ -d "$subdir" ]; then
        if [ ! -d "$subdir/input" ] || [ ! -d "$subdir/output" ]; then
            echo "ERROR: Missing input or output directory in $subdir"
            exit 1
        fi
        if [ ! -f "$subdir/input"/*.json ]; then
            echo "ERROR: No JSON file found in $subdir/input"
            exit 1
        fi
        count=$((count+1))
    fi
done

if [ $count -ne 121 ]; then
    echo "WARNING: Expected 121 subdirectories, found $count"
else
    echo "Found correct number of subdirectories: $count"
fi

echo "All checks passed successfully!"