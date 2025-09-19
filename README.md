# Scripts for automated basecalling, correction and genome assembly
## INSTALLATION

Change directory to the root directory of NanoStreamSeq

ROOT_DIR=$SCRATCH

cd $ROOT_DIR
git clone https://github.com/ssvassiliev/NanoStreamSeq.git
cd NanoStreamSeq

### Dorado models
mkdir models
cd models
module load dorado
dorado download --model dna_r10.4.1_e8.2_400bps_sup@v5.2.0
dorado download --model herro-v1

### FLye
cd - 
module load python
virtualenv env-flye
source env-flye/bin/activate
pip install --no-index flye

### RepeatMasker
RepeatMasker must be installed locally because it looks for databases only in the installation directory. Root partition dfam39_full.0.h5 comes with the module.

#### Download required famdb databases
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.16.h5.gz
gunzip dfam39_full.16.h5.gz
#### Add famdb partitions (root partition comes with the module)
module load repeatmasker
cp dfam39_full.16.h5 $EBROOTREPEATMASKER/Libraries/famdb/
rm dfam39_full.16.h5.gz

### Busco
mkdir -p containers
cd containers
apptainer build busco.sif docker://ezlabgva/busco:v6.0.0_cv1
mkdir ../busco_downloads
cd ../busco_downloads
wget https://busco-data.ezlab.org/v5/data/lineages/fungi_odb12.2025-07-01.tar.gz
tar xf fungi_odb12.2025-07-01.tar.gz

### Quast
wget https://github.com/ablab/quast/archive/refs/tags/quast_5.3.0.tar.gz
tar xf quast_5.3.0.tar.gz
pip install quast-quast_5.3.0/
rm -rf quast-quast_5.3.0

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
2. Correction, GPU stage (Dorado)
3. Assembling (Flye)
4. RepeatMasker
5. BUSCO
6. QUAST

Output files (located in WORK_DIR):
1. calls.fastq
2. overlaps.paf 
2. corrected_reads.fasta 
3. out_nano/assembly.fasta
4. out_nano/assembly.fasta.*.RMoutput/assembly.fasta.tbl
5. out_nano/BUSCO_OUTPUT/short_summary.specific.fungi_odb12.BUSCO_OUTPUT.txt
6. out_nano/quast_results/latest

#### Seq Data:
/project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip

## Helixer

apptainer build helixer.sif docker://gglyptodon/helixer-docker:helixer_v0.3.6_cuda_12.2.2-cudnn8

### Download models:
apptainer exec \
    --bind /etc/ssl/certs/ca-bundle.crt:/etc/pki/tls/certs/ca-bundle.crt \
    helixer.sif \
    fetch_helixer_models.py -l fungi

- saves models to:  $HOME/.local/share/Helixer/models
- on fir works with GPU only from salloc 
- container is incompatible with H100

