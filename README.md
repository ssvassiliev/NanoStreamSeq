# Scripts for automated base calling, correction and genome assembly

## INSTALLATION

- Change directory to the root directory of NanoStreamSeq

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
- RepeatMasker must be installed locally because it looks for databases only in the installation directory. 
- Root partition dfam39_full.0.h5 comes with the module.

#### Download the required database

cd $SCRATCH
wget https://www.dfam.org/releases/current/families/FamDB/dfam39_full.16.h5.gz
gunzip dfam39_full.16.h5.gz

- Since the database is quite large (39 GB), please don’t download it to your $HOME directory. It needs to be extracted into the RepeatMasker installation directory, which is also located under $HOME. If you download it there, there won’t be enough space to extract it.

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

# Using the Pipeline Submission Script: `run_pipeline.sh`

This shell script automates a full genome assembly and evaluation workflow - from **basecalling** raw nanopore reads to **assembly quality assessment**.    
It handles job submission for each stage of the pipeline on the cluster.

---

## Pipeline Overview

The script automatically runs the following sequential steps:

1. **Basecalling (Dorado)**  
   Converts raw `.pod5` signals into basecalled `.fastq` reads.

2. **Correction (Dorado, CPU stage)**  
   Performs initial correction of basecalled reads using CPU resources.

3. **Correction (Dorado, GPU stage)**  
   Further refines reads using GPU acceleration.

4. **Assembly (Flye)**  
   Assembles corrected reads into contigs.

5. **Masking repetitive elements (RepeatMasker)**  
   Masks repetitive elements in the assembled genome.

6. **Assessing completeness (BUSCO)**  
   Assesses completeness of the assembly using known orthologs.

7. **Evaluating assembly quality (QUAST)**  
   Evaluates assembly quality metrics (e.g., N50, misassemblies, GC content).

---

## Default Directory Layout

Unless otherwise specified, the script uses the following directories:

| Parameter    | Default Value | Description |
|--------------|----------------|--------------|
| `workdir`  | `$SCRATCH/workdir` | Main working directory where outputs are written |
| `pod5dir` | `demopod5` | Directory containing `.pod5` raw nanopore data |
| `model` | `models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0` | Dorado basecalling model |

---

## Basic Usage

### 1. Run with defaults
```bash
./run_pipeline.sh
```
This will:
- Read .pod5 files from demopod5/  
- Use the default Dorado model  
- Write results to $SCRATCH/workdir/   

2. Run with custom paths
```
./run_pipeline.sh \
    --workdir /scratch/$USER/run1 \
    --pod5dir data/pod5 \
    --model models/dna_r10.4.1_e8.2_400bps_sup@v5.2.0
```
This example specifies: 
- a custom working directory /scratch/$USER/run1, 
- a dataset in data/pod5/, 
- and an explicit Dorado model version.

## Output Files

All outputs are organized under `$WORKDIR`. Key files include:

| Step | Output File | Description |
|------|-------------|-------------|
| 1    | `calls.fastq` | Basecalled reads |
| 2    | `overlaps.paf` | Read overlap information |
| 2    | `corrected_reads.fasta` | Corrected reads (after CPU+GPU correction) |
| 3    | `out_nano/assembly.fasta` | Assembled genome |
| 4    | `out_nano/assembly.fasta.*.RMoutput/assembly.fasta.tbl` | RepeatMasker summary |
| 5    | `out_nano/BUSCO_OUTPUT/short_summary.specific.fungi_odb12.BUSCO_OUTPUT.txt` | BUSCO completeness report |
| 6    | `out_nano/quast_results/latest/` | QUAST quality metrics |

---

## Example Input Data

Example raw `.pod5` files can be found at:

`/project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip`


To use this dataset:

```bash
./run_pipeline.sh \
    --pod5dir /project/def-idjoly/ETS/20250724_1127_MN40896_FAY04157_b1ab64dd/00_basecaller/pod5_skip
```

## Notes
- Ensure run_pipeline.sh is executable:
`chmod +x run_pipeline.sh`
- Each stage submits a job to the scheduler (e.g., Slurm).
- Intermediate files are retained for troubleshooting or reruns.
- You can rerun the script safely — completed steps are typically skipped.

 
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

Summary:

1. Minimap2: module minimap2/2.28
2. NLRtracker:  Installed 
3. NLR-Annotator: Java - Load java module, clone repo and run .jar file.
4. NLRexpress: Conda only
5. PRGminer: Installed
6. Resistify: Created apptainer image resistify-1.3.0.sif
7. TEtrimmer: Created apptainer image tetrimmer-1.5.4.sif. TEtrimmer uses the TE consensus library from de novo TE annotation tools, like RepeatModeler or EDTA, as input. 
8. EDTA2: Created apptainer image EDTA-2.2.2.sif
9. RepeatModeler: module repeatmodeler/2.0.7
8. DRAGO-API: Shell script to query DRAGO server, downloaded.



## Minimap2 
Module available

## NLRtracker

#### Dependencies:
1. Interproscan/5.53
2. HMMER/3.3.2
3. tidyverse, Bioconductor, Biostrings
4. MEME/5.2.0

#### Installation:
PREFIX=/project/def-idjoly/ETS/software/
cd $PREFIX
git clone https://github.com/slt666666/NLRtracker
cd NLRtracker
#### Install R libraries 
module load r-bundle-bioconductor/3.21
#### Location of R libraries 
mkdir -p $PREFIX/NLRtracker/R/$EBVERSIONR/
export R_LIBS=$PREFIX/NLRtracker/R/$EBVERSIONR/
Rscript -e 'install.packages( "tidyverse", repos="https://cloud.r-project.org/")'

#### Submission script:
#!/bin/bash
#SBATCH -c4 --mem-per-cpu=3000 --time=1:0:0

PREFIX=/project/def-idjoly/ETS/software/
export R_LIBS=$PREFIX/NLRtracker/R/$EBVERSIONR/

module load \
    interproscan/5.73-104.0 \
    meme/5.5.7 \
    hmmer/3.4 \
    r-bundle-bioconductor/3.21

./NLRtracker.sh \
    -s sample_data/sample.fasta \
    -c $SLURM_CPUS_PER_TASK \
    -o out_dir 


## NLR-Annotator: https://github.com/steuernb/NLR-Annotator 
Java - no installation needed. Load java module, clone repo and run .jar file.

## NLRexpress: https://github.com/eliza-m/NLRexpress
Conda

## PRGminer: https://github.com/usubioinfo/PRGminer 
#### It is CPU-only code, GPU disabled in __main.py__
PREFIX=/project/def-idjoly/ETS/software/
cd $PREFIX
module load python mpi4py 
virtualenv --no-download --clear env-prgminer 
source env-prgminer/bin/activate
git clone https://github.com/navduhan/PRGminer.git
cd PRGminer/
#### Fix python version
sed -i 's/>=3\.8,<3\.11/>=3.8,<3.12/g' setup.py
cd PRGminer/models
#### Download models
rm *.h5
wget https://github.com/usubioinfo/PRGminer/raw/refs/heads/main/PRGminer/models/prgminer_phase1.h5
wget https://github.com/usubioinfo/PRGminer/raw/refs/heads/main/PRGminer/models/prgminer_phase2.h5
#### models were originally saved with TensorFlow 2.3
cd $PREFIX/PRGminer
pip install msgpack tensorflow==2.15.1
pip install .

#### Test
#!/bin/bash
#SBATCH -c2 --mem-per-cpu=3000 --time=1:0:0

PREFIX=/project/def-idjoly/ETS/software/
source $PREFIX/env-prgminer/bin/activate

cd $PREFIX/PRGminer/tests/test_data/
PRGminer -i sample.fasta -od results_phase1 -l Phase1

## Resistify: https://github.com/SwiftSeal/resistify

APPTAINER_CACHEDIR=./
export APPTAINER_CACHEDIR
apptainer build resistify-1.3.0.sif \
    docker://quay.io/biocontainers/resistify:1.3.0--pyhdfd78af_0 
rm -rf cache

## TEtrimmer https://github.com/qjiangzhao/TEtrimmer

APPTAINER_CACHEDIR=./
export APPTAINER_CACHEDIR
apptainer build tetrimmer-1.5.4.sif \
    docker://quay.io/biocontainers/tetrimmer:1.5.4--hdfd78af_0
rm -rf cache
#### Download pfam database

- EDTA2 or RepeatModeler2 - create a list of repeats and use it as input to TEtrimmer  
- manually annotate transposable elements

APPTAINER_CACHEDIR=./
export APPTAINER_CACHEDIR
apptainer build EDTA-2.2.2.sif \
    docker://quay.io/biocontainers/edta:2.2.2--hdfd78af_1
rm -rf cache

## DRAGO-API https://github.com/sequentiabiotech/DRAGO-API
Shell script to query DRAGO server.


## Remove host reads — map to reference and keep unmapped reads.

minimap2 -ax map-ont host.fa reads.fastq | samtools view -b -f 4 - | samtools fastq - > clean.fastq

