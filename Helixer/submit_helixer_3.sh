#!/bin/bash
#SBATCH -c1 --mem-per-cpu=4000 --time=1:0:0

module load apptainer

apptainer run \
    -C -B /scratch/idjoly/NanoStreamSeq/Helixer:/home/idjoly \
    ../containers/helixer.sif \
helixer_post_bin \
    Septoria_cannabis.h5 \
    predictions.h5 100 0.1 0.8 60 Septoria_cannabis_helixer.gff3
# <predictions.h5> <window_size> <edge_threshold> <peak_threshold> <min_coding_length> <output.gff3>
