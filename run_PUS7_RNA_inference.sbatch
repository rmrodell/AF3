#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G
#SBATCH --gpus=1
#SBATCH --constraint=GPU_SKU:H100_SXM5 #constraint required for af3
#SBATCH --time=1-00:00:00  # Adjust this based on your estimated total runtime
#SBATCH --output=/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA/inference_logs/inference_%j.out
#SBATCH --error=/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA/inference_logs/inference_%j.err

# Base directory for PUS7_RNA project
BASE_DIR="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"

# Directory containing af3.sif
AF3_DIR="/scratch/users/rodell/AlphaFold3"

# Model and database paths
MODEL_PARAMS_PATH=/scratch/users/rodell/AlphaFold3
DB_PATH=/scratch/groups/nicolemm/rodell/af3_db

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Create logs directory
mkdir -p $BASE_DIR/logs

# Iterate through all subdirectories in BASE_DIR
for dir in $BASE_DIR/*/; do
    dir_name=$(basename "$dir")
    INPUT_DIR="$dir/input"
    OUTPUT_DIR="$dir/output"
    
    # Check if the required input file exists
    if [ ! -f "$OUTPUT_DIR/${dir_name,,}/${dir_name,,}_data.json" ]; then
        log_message "Skipping $dir_name: Required input file not found"
        continue
    fi

    log_message "Processing $dir_name"

    # Change to the directory containing af3.sif
    cd $AF3_DIR

    # Run alphafold3 singularity container
    singularity run \
         --nv \
         --env JAX_TRACEBACK_FILTERING=off \
         --bind $INPUT_DIR:/root/af_input \
         --bind $OUTPUT_DIR:/root/af_output \
         --bind $MODEL_PARAMS_PATH:/root/models \
         --bind $DB_PATH:/root/public_databases \
     af3.sif \
     --norun_data_pipeline \
     --json_path=/root/af_output/${dir_name,,}/${dir_name,,}_data.json \
     --model_dir=/root/models \
     --output_dir=/root/af_output

    if [ $? -ne 0 ]; then
        log_message "Error processing $dir_name"
    else
        log_message "Completed processing $dir_name"
    fi
done

log_message "All PUS7_RNA structure inference jobs completed"