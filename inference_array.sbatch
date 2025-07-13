#!/bin/bash
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G
#SBATCH --gpus=1
#SBATCH --constraint=GPU_SKU:H100_SXM5 #constraint required for af3
#SBATCH --time=0-00:10:00
#SBATCH --array=1-121%1  # Run 121 jobs, max 10 at a time
#SBATCH --output=/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA/inference_logs/slurm-%A_%a.out
#SBATCH --error=/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA/inference_logs/slurm-%A_%a.err

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

# Change to the directory containing af3.sif
cd /scratch/users/rodell/AlphaFold3

# run alphafold3 singularity container
singularity run \
     --nv \
     --env JAX_TRACEBACK_FILTERING=off \
     --bind $INPUT_DIR:/root/af_input \
     --bind $OUTPUT_DIR:/root/af_output \
     --bind $MODEL_PARAMS_PATH:/root/models \
     --bind $DB_PATH:/root/public_databases \
 af3.sif \
 --norun_data_pipeline \
 --json_path=/root/af_output/$(echo ${dir_name,,})/${dir_name,,}_data.json \
 --model_dir=/root/models \
 --output_dir=/root/af_output