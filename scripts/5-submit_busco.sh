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
#SBATCH -c8 --time 3:0:0 --mem-per-cpu=4000

module load apptainer
apptainer run \
   --env SCRATCH=$SCRATCH \
   containers/busco.sif busco \
   -m genome \
   --offline \
   --force \
   --cpu \$SLURM_CPUS_PER_TASK \
   -i $WORKDIR/assembly.fasta \
   -o $WORKDIR/BUSCO_OUTPUT \
   -l busco_downloads/fungi_odb12 
EOF

