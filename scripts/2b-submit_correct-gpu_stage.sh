#!/bin/bash

ROOTDIR=$(pwd)

usage() {
    printf "\nUsage:   %s -i <input> -w <workdir> -a <JobID>\n" 
    printf "Example:   %s -i calls.fastq -w workdir -a "NaN"\n" 
    exit 1
}

# --- Parse arguments ---
while getopts ":i:w:a:" opt; do
    case $opt in
        i) INPUT=$OPTARG ;;
        w) WORKDIR=$OPTARG ;;
	a) DEPENDENCY=$OPTARG ;; 
        *) usage ;;
    esac
done

# --- Check required arguments ---
if [ -z "$INPUT" ] || [ -z "$DEPENDENCY" ] || [ -z "$WORKDIR" ]; then
    usage
fi

if [[ "$DEPENDENCY" == "---" ]]; then
    sbatch_cmd="sbatch"
else
    sbatch_cmd="sbatch --dependency=afterok:$DEPENDENCY"
fi

# feed script once into sbatch
$sbatch_cmd <<EOF
#!/bin/bash
#SBATCH -c 4
#SBATCH --mem-per-cpu=4000
#SBATCH --gpus=nvidia_h100_80gb_hbm3_2g.20gb:1 
#SBATCH --time=1:0:0

module load cuda dorado
export LD_LIBRARY_PATH=$WORKDIR

cd $WORKDIR
ln -s \$EBROOTCUDA/lib64/libnvrtc-builtins.so.12.6 libnvrtc-builtins.so.12.8

dorado correct \
    --device cuda:all \
    -m $ROOTDIR/models/herro-v1 \
    --from-paf overlaps.paf \
    $INPUT > corrected_reads.fasta
EOF


