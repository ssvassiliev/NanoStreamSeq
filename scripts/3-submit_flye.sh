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

if [[ "$DEPENDENCY" == "NaN" ]]; then
    sbatch_cmd="sbatch"
else
    sbatch_cmd="sbatch --dependency=afterok:$DEPENDENCY"
fi

# feed script once into sbatch
$sbatch_cmd << EOF
#!/bin/bash
#SBATCH -c16 
#SBATCH --mem-per-cpu=4000 
#SBATCH --time=12:0:0

source $ROOTDIR/env-flye/bin/activate
cd $WORKDIR
flye \
    --nano-corr $INPUT \
    --out-dir out_nano \
    --threads \$SLURM_CPUS_PER_TASK
EOF

    

