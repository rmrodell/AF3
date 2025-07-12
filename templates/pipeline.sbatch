#!/bin/bash
#SBATCH --partition=normal
#SBATCH --cpus-per-task=8
#SBATCH --mem=20G
#SBATCH --time=0-01:00:00

# run from the folder with af3.sif: /scratch/users/rodell/AlphaFold3

# model and database paths variables
MODEL_PARAMS_PATH=/scratch/users/rodell/AlphaFold3
DB_PATH=/scratch/groups/nicolemm/rodell/af3_db

# run alphafold3 singularity container from the folder with af3.sif
singularity run \
     --nv \
     --bind $SCRATCH/AlphaFold3/PUS7_RNA/input:/root/af_input \
     --bind $SCRATCH/AlphaFold3/PUS7_RNA/output:/root/af_output \
     --bind $MODEL_PARAMS_PATH:/root/models \
     --bind $DB_PATH:/root/public_databases \
     af3.sif \
     --norun_inference \
     --json_path=/root/af_input/PUS7_RHBDD2.json \
     --model_dir=/root/models \
     --db_dir=/root/public_databases \
     --output_dir=/root/af_output

