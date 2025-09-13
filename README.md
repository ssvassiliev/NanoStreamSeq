# Scripts for automated basecalling, correction and genome assembly
## Installation

### Dorado models
mkdir NanoStreamSeq/models
cd NanoStreamSeq/models
module load dorado
dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.2.0
dorado download --model herro-v1

### FLye
cd NanoStreamSeq 
module load python
virtualenv env-flye
source env-flye/bin/activate
pip install --no-index flye

### RepeatMasker
RepeatMasker must be installed locally because it looks for databases only in the installation directory.

#### Download required famdb databases
mkdir -p famdb
cd famdb
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.0.h5.gz
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.16.h5.gz
cd -
famdb.py -i famdb info

#### Add famdb partitions (root partition comes with the module)
cp famdb/dfam39_full.16.h5 $EBROOTREPEATMASKER/Libraries/famdb/

### Busco
cd containers
apptainer build busco.sif docker://ezlabgva/busco:v6.0.0_cv1
mkdir busco_downloads
cd busco_downloads
wget https://busco-data.ezlab.org/v5/data/lineages/fungi_odb12.2025-07-01.tar.gz
tar xf fungi_odb12.2025-07-01.tar.gz


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

