#!/bin/bash
#SBATCH -c16 --mem-per-cpu=4000 --time=1:0:0

module load apptainer

apptainer exec \
    --nv \
    ../containers/helixer.sif \
HybridModel.py \
    --load-model-path models/fungi_v0.3_a_0100.h5 \
    --test-data Septoria_cannabis.h5 \
    --overlap \
    --val-test-batch-size 32 \
    -v \
    --predict-phase

