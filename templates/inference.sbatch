#!/bin/bash
#
#SBATCH --partition=gpu
#SBATCH --cpus-per-task=8
#SBATCH --mem=12G
#SBATCH --gpus=1
#SBATCH --constraint=GPU_SKU:H100_SXM5 #constraint required for af3
#SBATCH --time=0-00:10:00

# run from the folder with af3.sif: /scratch/users/rodell/AlphaFold3

# model and database paths variables
MODEL_PARAMS_PATH=/scratch/users/rodell/AlphaFold3
DB_PATH=/scratch/groups/nicolemm/rodell/af3_db

# run alphafold3 singularity container from the folder with af3.sif
singularity run \
     --nv \
     --env JAX_TRACEBACK_FILTERING=off \
     --bind $SCRATCH/AlphaFold3/PUS7_RNA/input:/root/af_input \
     --bind $SCRATCH/AlphaFold3/PUS7_RNA/output:/root/af_output \
     --bind $MODEL_PARAMS_PATH:/root/models \
     --bind $DB_PATH:/root/public_databases \
 af3.sif \
 --norun_data_pipeline \
 --json_path=/root/af_output/pus7_rhbdd2/pus7_rhbdd2_data.json \
 --model_dir=/root/models \
 --output_dir=/root/af_output