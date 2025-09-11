1. Install FLye:
cd NanoStreamSeq 
module load python
virtualenv env-flye
source env-flye/bin/activate
pip install --no-index flye

2. Download models
mkdir NanoStreamSeq/models
cd NanoStreamSeq/models
module load dorado
dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.2.0
dorado download --model herro-v1

'''
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
'''

Data:
/project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip
