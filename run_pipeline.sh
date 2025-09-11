#!/bin/bash

WORK_DIR=$SCRATCH/workdir
POD5_DIR=demopod5
MODEL=models/dna_r10.4.1_e8.2_400bps_sup\@v5.2.0/ 

JID1=NaN
JID2A=NaN
JID2B=Nan

if [[ ! -f "$WORK_DIR/calls.fastq" ]]; then
    echo "++ File calls.fastq not found — submitting basecaller ++"
    JID1=$(./scripts/1-submit_basecaller.sh -m "$MODEL" -d "$POD5_DIR" -o "$WORK_DIR" | awk '{print $4}')
else
    echo "-- Skipping basecaller — $WORK_DIR/calls.fastq already exists --"
fi

if [[ ! -f "$WORK_DIR/overlaps.paf" ]]; then
    echo "++ File overlaps.paf not found — submitting correction CPU stage ++" 
    JID2A=$(./scripts/2a-submit_correct-cpu_stage.sh -w $WORK_DIR -i calls.fastq -a "$JID1" | awk '{print $4}')
else
    echo "-- Skipping correction CPU stage — $WORK_DIR/overlaps.paf already exists. --"
fi

if [[ ! -f "$WORK_DIR/corrected_reads.fasta" ]]; then
    echo "++ File corrected_reads.fasta not found — submitting correction GPU stage ++"
   JID2B=$(./scripts/2b-submit_correct-gpu_stage.sh -w $WORK_DIR -i calls.fastq -a "$JID2A" | awk '{print $4}')
else
    echo "-- Skipping correction GPU stage — $WORK_DIR/corrected_reads.fasta already exists.--"
fi

