#!/bin/bash
#SBATCH --partition=normal
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=0-01:00:00
#SBATCH --array=1-121%10  # Run 121 jobs, max 10 at a time

# Base directory for all PUS7_RNA predictions
BASE_DIR="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"

# Read the directory name for this task
dir_name=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$MAP_FILE" | awk '{print $2}')

# Set up paths
CURRENT_DIR="$BASE_DIR/$dir_name"
INPUT_DIR="$CURRENT_DIR/input"
OUTPUT_DIR="$CURRENT_DIR/output"

# model and database paths variables
MODEL_PARAMS_PATH=/scratch/users/rodell/AlphaFold3
DB_PATH=/scratch/groups/nicolemm/rodell/af3_db

# Get the JSON filename
JSON_FILE=$(ls $INPUT_DIR/*.json | head -n 1)
JSON_FILENAME=$(basename $JSON_FILE)

# Change to the directory containing af3.sif
cd /scratch/users/rodell/AlphaFold3

# run alphafold3 singularity container
singularity run \
     --nv \
     --bind $INPUT_DIR:/root/af_input \
     --bind $OUTPUT_DIR:/root/af_output \
     --bind $MODEL_PARAMS_PATH:/root/models \
     --bind $DB_PATH:/root/public_databases \
     af3.sif \
     --norun_inference \
     --json_path=/root/af_input/$JSON_FILENAME \
     --model_dir=/root/models \
     --db_dir=/root/public_databases \
     --output_dir=/root/af_output