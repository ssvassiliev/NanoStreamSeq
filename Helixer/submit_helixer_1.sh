#!/bin/bash
#SBATCH -c1 --mem-per-cpu=4000 --time=3:0:0

module load apptainer

apptainer run \
    -C -B /scratch/idjoly/NanoStreamSeq/Helixer:/home/idjoly \
    ../containers/helixer.sif \
fasta2h5.py \
    --species Septoria_cannabis \
    --h5-output-path Septoria_cannabis.h5 \
    --fasta-path /scratch/idjoly/workdir.sep_12/out_nano/assembly.fasta


