#!/bin/bash
#!/usr/bin/env bash

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Options:
  -p PREFIX   Set the prefix for installation directory (default: cwd)
  -h          Show this help message and exit
EOF
}

# default values
prefix=`pwd`

# parse options with getopts
while getopts ":p:h" opt; do
    case $opt in
        p)
            prefix="$OPTARG"
            ;;
        h)
            show_help
            exit 0
            ;;
        \?)
            echo "Unknown option: -$OPTARG" >&2
            show_help
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            show_help
            exit 1
            ;;
    esac
done

ROOT_DIR=$prefix  
if [[ $(basename "$prefix") != "NanoStreamSeq" ]]; then
   mkdir -p $ROOT_DIR
   cd $ROOT_DIR
   git clone https://github.com/ssvassiliev/NanoStreamSeq.git
   ROOT_DIR=$ROOT_DIR/NanoStreamSeq 
fi

echo "Installing in: $ROOT_DIR"

cd $ROOT_DIR
# Install Dorado models
mkdir models
cd models
module load dorado
dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.2.0
dorado download --model herro-v1

# Install FLye
cd $ROOT_DIR
module load python
virtualenv env-flye
source env-flye/bin/activate
pip install --no-index flye

# Install Busco
mkdir -p containers
module load apptainer
apptainer build containers/busco.sif docker://ezlabgva/busco:v6.0.0_cv1
mkdir busco_downloads
cd busco_downloads
wget https://busco-data.ezlab.org/v5/data/lineages/fungi_odb12.2025-07-01.tar.gz
tar xf fungi_odb12.2025-07-01.tar.gz

# Install Quast
cd $ROOT_DIR
virtualenv env-quast
source env-quast/bin/activate
wget https://github.com/ablab/quast/archive/refs/tags/quast_5.3.0.tar.gz
tar xf quast_5.3.0.tar.gz
pip install quast-quast_5.3.0/
rm -rf quast_5.3.0.tar.gz quast-quast_5.3.0


# Install RepeatMasker
eb RepeatMasker-4.2.1-GCC-12.3.0.eb --rebuild
rm -f dfam39_full.16.h5.gz
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.16.h5.gz
gunzip dfam39_full.16.h5.gz
# Add famdb partitions (root partition comes with the module)
module load repeatmasker
cp dfam39_full.16.h5 $EBROOTREPEATMASKER/Libraries/famdb/
rm dfam39_full.16.h5.gz
