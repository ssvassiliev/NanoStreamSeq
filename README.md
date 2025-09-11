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
