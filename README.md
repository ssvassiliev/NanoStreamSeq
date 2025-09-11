# Scripts for automated basecalling, correction and genome assembly
## Installation
### Install FLye
cd NanoStreamSeq 
module load python
virtualenv env-flye
source env-flye/bin/activate
pip install --no-index flye

### Download Dorado models
mkdir NanoStreamSeq/models
cd NanoStreamSeq/models
module load dorado
dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.2.0
dorado download --model herro-v1

## Usage - pipeline submission script run_pipeline.sh 
### Example usage:

- Use defaults:
   ./run_pipeline.sh 

#### Default directories 
workdir: $SCRATCH/workdir
pod5dir:  demopod5
model:    models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0

- Specify custom directories and model:
   ./run_pipeline.sh \  
       --workdir /scratch/$USER/run1 \
       --pod5dir data/pod5 \
       --model models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0

Script submits jobs for the following steps:
1. Basecalling (Dorado)
2. Correction, CPU stage (Dorado)
3. Correction, GPU stage (Dorado)
4. Assembling (Flye)

Output files are created in WORK_DIR:
1. calls.fastq
2. overlaps.paf
3. corrected_reads.fasta
4. out_dir/


#### Seq Data:
/project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip
