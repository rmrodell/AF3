#!/bin/bash

# Check for normal partition
if ! sinfo -p normal | grep -q "normal"; then
    echo "ERROR: 'normal' partition not found"
    exit 1
fi

# Check for gpu partition
if ! sinfo -p gpu | grep -q "gpu"; then
    echo "ERROR: 'gpu' partition not found"
    exit 1
fi

# Check for H100_SXM5 GPUs
if ! sinfo -p gpu -o "%f" | grep -q "H100_SXM5"; then
    echo "WARNING: H100_SXM5 GPUs not found. Check GPU availability."
fi

echo "SLURM configuration check passed!"