#!/bin/bash
ROOTDIR=$(pwd)

usage() {
    printf "\nUsage:   %s -i <input> -w <workdir> -a <JobID>\n" 
    printf "Example:   %s -i assembly.fasta -w workdir/out_nano -a "NaN"\n" 
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
$sbatch_cmd << EOF
#!/bin/bash
#SBATCH -c8
#SBATCH --mem-per-cpu=4000
#SBATCH --time=1:0:0

module load repeatmasker

RepeatMasker \
    -parallel $(( ${SLURM_CPUS_PER_TASK:-1} / 4 )) \
    --species fungi \
    $WORKDIR/$INPUT
EOF


