#!/bin/bash

usage() {
    printf "\nUsage:   %s -w <workdir> -i <input_file>\n" 
    printf "Example: %s -w ./workdir -i calls.fastq -a "NaN"\n" 
    exit 1
}

# --- Parse arguments ---
while getopts ":w:i:a:" opt; do
    case $opt in
        w) WORKDIR=$OPTARG ;;
        i) INPUT_FILE=$OPTARG ;;
	a) DEPENDENCY=$OPTARG ;; 
        *) usage ;;
    esac
done

# --- Check required arguments ---
if [ -z "$WORKDIR" ] || [ -z "$INPUT_FILE" ] || [ -z "$DEPENDENCY" ]; then
    usage
fi


# build sbatch command depending on dependency
if [[ "$DEPENDENCY" == "NaN" ]]; then
    sbatch_cmd="sbatch"
else
    sbatch_cmd="sbatch --dependency=afterok:$DEPENDENCY"
fi

$sbatch_cmd << EOF
#!/bin/bash
#SBATCH -c 16
#SBATCH --mem-per-cpu=4000
#SBATCH --time=1:0:0

module load dorado

cd $WORKDIR

dorado correct \
    --device cpu \
    --to-paf \
    $INPUT_FILE > overlaps.paf
EOF
