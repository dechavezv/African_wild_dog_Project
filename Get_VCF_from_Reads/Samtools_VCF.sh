#!/bin/bash

#$ -l highp,h_rt=40:00:00,h_data=14G
#$ -pe shared 1
#$ -N <canids_spescies>_Samtools
#$ -cwd
#$ -m bea
#$ -o ./<canids_spescies>_Samtools.out
#$ -e ./<canids_spescies>_Samtools.err
#$ -M dechavezv


# then load your modules:
. /u/local/Modules/default/init/modules.sh
module load bcftools/1.2 
module load samtools/1.2
module load bedtools/2.26.0

export BAM=<canid_spescies>_samt_ug_hc.bam
export REF=canfam31/canfam31.fa
export Output=Out_dir/

echo -e "\n Getting genome in FASTA format\n"

cd ${Output}

samtools mpileup -Q 20 -q 20 -u -f ${REF} ${BAM} | \
bcftools call -v -c > ${BAM}.vcf

echo -e "\n Finisined process of getting genome in FASTA format\n"
