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

### Install RepeatMasker
#### Install repeatmasker module locally
#### Download the required dfam databases

mkdir -p famdb
cd famdb
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.0.h5.gz
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.16.h5.gz

cd -
famdb.py -i famdb info

RepeatMasker looks for darabases only in the installation directory. 
For this reason it must be installed in user's account.

#### Add partitions (root partition is preonstalled)
cp famdb/dfam39_full.16.h5 $EBROOTREPEATMASKER/Libraries/famdb/


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
5. RepeatMasker

Output files are created in WORK_DIR:
1. calls.fastq
2. overlaps.paf
3. corrected_reads.fasta
4. out_nano/assembly.fasta
5. out_nano/assembly.fasta.*.RMoutput/assembly.fasta.tbl


#### Seq Data:
/project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip


### RepeatMasker submission script:

#!/bin/bash
#SBATCH -c8
#SBATCH --mem-per-cpu=4000
#SBATCH --time=1:0:0

module load repeatmasker
QUERY=$SCRATCH/workdir/out_nano/assembly.fasta

RepeatMasker \
    -parallel $(( ${SLURM_CPUS_PER_TASK:-1} / 4 )) \
    --species fungi \
    $QUERY

Output:

$SCRATCH/workdir/out_nano/assembly.fasta.preThuSep111351182025.RMoutput/assembly.fasta.tbl