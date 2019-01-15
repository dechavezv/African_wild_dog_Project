#!/bin/bash

#$ -l highmem,highp,h_rt=62:00:00,h_data=34G
#$ -pe shared 10
#$ -N BQR_<canids_spescies>
#$ -cwd
#$ -m bea
#$ -o BQR_<canids_spescies>.out
#$ -e BQR_<canids_spescies>.err
#$ -M dechavezv

# load your modules:
. /u/local/Modules/default/init/modules.sh
module load java/1.8.0_77
module load picard_tools

export VCF_DIR=/ISEC/<canids_spescies>_stmp_ug_hc_mbq20_raw_reheader.vcf.gz
export BAM_DIR=/BAM/<canids_spescies>_sortRG_rmdup_realign_fixmate.bam
export BQSR_DIR=/BQR/
export GATK=/u/local/apps/gatk/3.7/GenomeAnalysisTK.jar
export REF=/canfam31/canfam31.fa
export Recal=/BQR/Post_BQR
export PICARD=/u/local/apps/picard-tools/current
export temp=/BQR/temp


### 1st_Base_Recalibration

echo -e "\n1st_Base_Recalibration ${1}\n"

java -jar -Xmx30g -Djava.io.tmpdir=/u/scratch/d/dechavez/ ${GATK} \
-T BaseRecalibrator -nt 1 -nct 7 \
-I ${BAM_DIR} \
-R ${REF} \
-knownSites ${VCF_DIR} \
-o ${BQSR_DIR}/cat_samt_ug_hc_<canids_spescies>_raw.vcf.table

echo -e "\nFinished 1stBase Recalibration ${1}\n"

### 2nd_Base_Recalibration

java -jar -Xmx120g -Djava.io.tmpdir=work/dechavezv/temp ${GATK} \
-T BaseRecalibrator -nt 1 -nct 7 \
-I ${BAM_DIR} \
-R ${REF} \
-knownSites ${VCF_DIR} \
-BQSR ${BQSR_DIR}/cat_samt_ug_hc_<canids_spescies>_raw.vcf.table \
-o ${BQSR_DIR}/post_recal_<canids_spescies>_QD30.vcf.table

echo -e "\nPrint Reads <canids_spescies>\n"

java -jar -Xmx30g -Djava.io.tmpdir=work/dechavezv/temp ${GATK} \
-T PrintReads -nt 1 -nct 12 \
-I ${BAM_DIR} \
-R ${REF} \
-BQSR ${BQSR_DIR}/BQR_samt_ug_hc_<canids_spescies>_raw.vcf.table \
-o ${BQSR_DIR}/BQR_samt_ug_hc_<canids_spescies>_raw.vcf.table.bam

echo -e "\nFinished Printing Reads ${1}\n"

### AnalyzeCovariates

java -jar -Xmx120g -Djava.io.tmpdir=work/dechavezv/temp ${GATK} \
-T AnalyzeCovariates -l DEBUG \
-R ${REF} \
-csv my-report.csv \
-before ${BQSR_DIR}/BQR_samt_ug_hc_<canids_spescies>_raw.vcf.table \
-after ${BQSR_DIR}/post_recal_<canids_spescies>_QD30.vcf.table \
-plots ${BQSR_DIR}/PLOTS_post_recal_<canids_spescies>.vcf.table.pdf

# Index the bam
echo -e "\nIndexing 2nd_call_cat_samt_ug_hc_<canids_spescies>_raw.vcf.table.bam\n"

java -jar -Xmx8g -Djava.io.tmpdir=${temp} ${PICARD} BuildBamIndex \
INPUT=${BQSR_DIR}/cat_samt_ug_hc_<canids_spescies>_raw.vcf.table.bam \
OUTPUT=${BQSR_DIR}/BQR_samt_ug_hc_$1_raw.vcf.table.bam.bai \
VALIDATION_STRINGENCY=LENIENT \
TMP_DIR=${temp}

echo -e "\nFinished Indexing BQR_samt_ug_hc_<canids_spescies>_raw.vcf.table.bam\n"
