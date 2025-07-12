#!/bin/bash

# Create the main directory
main_dir="/scratch/users/rodell/AlphaFold3/AF3/PUS7_RNA"
mkdir -p $main_dir

# Path to the JSON files
json_dir="/scratch/users/rodell/AlphaFold3/AF3/json_creation/output_PUS7_RNA"

# Create subdirectories and copy JSON files
for json_file in $json_dir/*.json; do
    # Extract the base name of the JSON file (without path and extension)
    base_name=$(basename "$json_file" .json)
    
    # Create subdirectory
    sub_dir="$main_dir/$base_name"
    mkdir -p "$sub_dir/input" "$sub_dir/output"
    
    # Copy JSON file to input directory
    cp "$json_file" "$sub_dir/input/"
    
    echo "Created directory structure for $base_name"
done

echo "Directory setup complete. Created structures for $(ls $json_dir/*.json | wc -l) RNA sequences."