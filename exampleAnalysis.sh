#!/bin/bash

# This is an example script for a full pipeline of assembly, annotation and core phylogeny
# In order to use it you need prokka, spades.py, hmmsearch, muscle, Gblocks, and raxmlHPC in your PATH or adjust the location below

##### Settings if submitted on a SLURM workload manager by 'sbatch exampleAnalysis.sh' 
#SBATCH -J bcgTree
#SBATCH -n 1
#SBATCH -c 32
#SBATCH --mem 100G

##### Global settings (if on a SLURM manager, should be consistent with settings above
THREADS=32
RAM=100

mkdir -p testdata_phylogeny
cd testdata_phylogeny

##### Getting genome data as test data set
### Reference strain assemblies
# Paenibacillus polymyxa
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/146/875/GCA_000146875.2_ASM14687v2/GCA_000146875.2_ASM14687v2_genomic.fna.gz
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/463/565/GCA_000463565.1_S6/GCA_000463565.1_S6_genomic.fna.gz

# Paenibacillus odorifer
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/758/725/GCA_000758725.1_ASM75872v1/GCA_000758725.1_ASM75872v1_genomic.fna.gz

# Paenibacillus larvae
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/003/265/GCA_002003265.1_ASM200326v1/GCA_002003265.1_ASM200326v1_genomic.fna.gz

# Brevibacillus brevis (outgroup)
wget ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/010/165/GCA_000010165.1_ASM1016v1/GCA_000010165.1_ASM1016v1_genomic.fna.gz

gunzip *.fna.gz

###raw sequencing reads
# Paenibacillus polymyxa MBD06
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR340/009/ERR3402559/ERR3402559_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/ERR340/009/ERR3402559/ERR3402559_2.fastq.gz

##### Assembly of Paenibacillus polymyxa MBD06 (raw reads)

spades.py --careful \
  --pe1-1 ERR3402559_1.fastq.gz \
  --pe1-2 ERR3402559_2.fastq.gz \
  -t $THREADS -m $RAM -o spades_PPol

cp spades_PPol/scaffolds.fasta ./PPol_MBD06.fna

##### Annotation

for genome in $(ls *.fna); 
do 
	prokka --outdir prokka_$genome --cpus $THREADS --norrna --notrna $genome;
	cp prokka_$genome/*.faa ./$genome.faa  
done

##### Config file creation

# basic parameters
echo "--threads=$THREADS" >  testdata_config.txt
echo "--bootstraps=1000" >>  testdata_config.txt
echo "--outdir=testdata_phylogeny" >>  testdata_config.txt

# proteome files
for proteome in $(ls *.faa); 
do 
	echo '--proteome "'$proteome'"="'$proteome'"' >>  testdata_config.txt
done

## optional binary locations, need to be changed for the user if they are necessary (and # removed)
#echo "--hmmsearch-bin=/PATH/TO/BINARY" >>  testdata_config.txt
#echo "--muscle-bin=/PATH/TO/BINARY" >>  testdata_config.txt
#echo "--gblocks-bin=/PATH/TO/BINARY" >>  testdata_config.txt
#echo "--raxml-bin=/PATH/TO/BINARY" >>  testdata_config.txt

##### Phylogenetic calculation
bcgTree.pl @testdata_config.txt 

