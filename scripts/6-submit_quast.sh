#!/bin/bash
ROOTDIR=$(pwd)

usage() {
    printf "\nUsage:   %s -i <input> -w <workdir> -a <JobID>\n" 
    printf "Example:   %s -i assembly.fasta -w workdir/out_nano -a "---"\n" 
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
#SBATCH -c1 --time 1:0:0 --mem-per-cpu=4000

source env-quast/bin/activate
quast.py \
    -o $WORKDIR/out_nano/quast-results \
    $WORKDIR/out_nano/$INPUT
EOF

