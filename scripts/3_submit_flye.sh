#!/bin/bash
#SBATCH -c16 --mem-per-cpu=4000 --time=12:0:0


#Install flye:
#module load python
#virtualenv env-flye
#source env-flye/bin/activate
#pip install --no-index flye

source env-flye/bin/activate

flye \
    --nano-corr calls_sup.fastq \
    --out-dir out_nano \
    --threads $SLURM_CPUS_PER_TASK
