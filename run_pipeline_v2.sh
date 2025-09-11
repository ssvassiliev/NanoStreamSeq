#!/bin/bash
set -euo pipefail

# ===============================================================
# Pipeline submission script
#
# Example usage:
#   # Use defaults:
#   ./pipeline.sh
#
#   # Specify custom directories and model:
#   ./pipeline.sh --workdir /scratch/$USER/run1 \
#                 --pod5dir data/pod5 \
#                 --model my_models/sup@v5.2.0/
# ===============================================================

# Defaults
WORK_DIR="$SCRATCH/workdir"
POD5_DIR="demopod5"
MODEL="models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0/"

print_usage() {
    echo "Usage: $0 [--workdir DIR] [--pod5dir DIR] [--model DIR]"
    exit 1
}

# Parse options
OPTS=$(getopt -o '' \
    --long workdir:,pod5dir:,model:,help \
    -n 'parse-options' -- "$@")
if [ $? != 0 ]; then
    print_usage
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        --workdir) WORK_DIR="$2"; shift 2 ;;
        --pod5dir) POD5_DIR="$2"; shift 2 ;;
        --model)   MODEL="$2"; shift 2 ;;
        --help)    print_usage ;;
        --) shift; break ;;
        *) echo "Unknown option $1"; print_usage ;;
    esac
done

# Initialize job IDs to NaN
for var in JID1 JID2A JID2B JID3; do
    eval "$var=NaN"
done

# Basecaller stage
if [[ ! -f "$WORK_DIR/calls.fastq" ]]; then
    echo "++ File calls.fastq not found — submitting basecaller ++"
    JID1=$(./scripts/1-submit_basecaller.sh -m "$MODEL" -d "$POD5_DIR" -o "$WORK_DIR" | awk '{print $4}')
else
    echo "-- Skipping basecaller — $WORK_DIR/calls.fastq already exists --"
fi

# Correction CPU stage
if [[ ! -f "$WORK_DIR/overlaps.paf" ]]; then
    echo "++ File overlaps.paf not found — submitting correction CPU stage ++"
    JID2A=$(./scripts/2a-submit_correct-cpu_stage.sh -w "$WORK_DIR" -i calls.fastq -a "$JID1" | awk '{print $4}')
else
    echo "-- Skipping correction CPU stage — $WORK_DIR/overlaps.paf already exists. --"
fi

# Correction GPU stage
if [[ ! -f "$WORK_DIR/corrected_reads.fasta" ]]; then
    echo "++ File corrected_reads.fasta not found — submitting correction GPU stage ++"
    JID2B=$(./scripts/2b-submit_correct-gpu_stage.sh -w "$WORK_DIR" -i calls.fastq -a "$JID2A" | awk '{print $4}')
else
    echo "-- Skipping correction GPU stage — $WORK_DIR/corrected_reads.fasta already exists. --"
fi

# Assembly stage
if [[ ! -d "$WORK_DIR/out_nano" ]]; then
    echo "++ Directory out_nano not found — submitting assembly ++"
    JID3=$(./scripts/3-submit_flye.sh -w "$WORK_DIR" -i corrected_reads.fasta -a "$JID2B" | awk '{print $4}')
else
    echo "-- Skipping assembly — $WORK_DIR/out_nano already exists. --"
fi

# Summary
echo
echo "===== Pipeline submission summary ====="
echo "WORK_DIR : $WORK_DIR"
echo "POD5_DIR : $POD5_DIR"
echo "MODEL    : $MODEL"
echo
echo "JID1  (basecaller)          = $JID1"
echo "JID2A (correction CPU)      = $JID2A"
echo "JID2B (correction GPU)      = $JID2B"
echo "JID3  (assembly)            = $JID3"
echo "======================================"

