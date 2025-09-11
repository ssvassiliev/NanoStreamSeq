#!/bin/bash

usage() {
    printf "\nUsage:   %s -m <model> -d <data_directory> -o <output_directory>\n"
    printf "Example: %s -m dna_r10.4.1_e8.2_400bps_sup@v5.2.0 -d pod5_skip -o outdir\n" 
    exit 1
}

# --- Parse arguments with getopts ---
while getopts ":m:d:o:" opt; do
    case $opt in
        m) MODEL=$OPTARG ;;
        d) DATA_DIR=$OPTARG ;;
        o) OUT_DIR=$OPTARG ;;
        *) usage ;;
    esac
done

# --- Check required arguments ---
if [ -z "$MODEL" ] || [ -z "$DATA_DIR" ] || [ -z "$OUT_DIR" ]; then
    usage
fi

mkdir -p "$OUT_DIR"

sbatch << EOF
#!/bin/bash
#SBATCH -c 4
#SBATCH --mem-per-cpu=4000
#SBATCH --gpus=nvidia_h100_80gb_hbm3_2g.20gb:1
#SBATCH --time=6:0:0

# --- Load dorado module ---
module load dorado

# --- Run dorado basecaller ---
dorado basecaller \
    --emit-fastq \
    "$MODEL" \
    "$DATA_DIR" > "$OUT_DIR/calls.fastq"
EOF
