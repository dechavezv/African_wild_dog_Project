#!/bin/bash
#$ -l highp,h_rt=35:00:00,h_data=18G
#$ -pe shared 1
#$ -N AWD_gVCF
#$ -cwd
#$ -m bea
#$ -o /AWD/BQR/log/4AWDgVCF.out
#$ -e /AWD/BQR/log/4AWDgVCF.err
#$ -M dechavezv 
#$ -t 1:38:1


# then load your modules:
. /u/local/Modules/default/init/modules.sh
 
module load java
module load samtools/0.1.19

export Reference=canfam31/canfam31.fa
export vcf=/AWD/BQR/GVCFs
export temp=/AWD/BQR/GVCFs
export HCvcf=/AWD/BQR/HC_VCF

echo "#######"
echo "Haplotype Caller per chromosome"
echo "########"

##### ERC BP_RESOLUTION not recomended for final versions of vcf files
##### out_mode EMIT_ALL_SITES not necesary if you are alredy calling ERC

cd ${vcf}

for i in {1..4}; do ( \
java -jar -Xmx30g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.7/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R ${Reference} \
-I  AWD_sample$i.bam \
-L chr$(printf %02d $SGE_TASK_ID) \
-o 2nd_call_cat_samt_ug_hc_bushDog_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz \
-ERC BP_RESOLUTION \
-mbq 20 \
-out_mode EMIT_ALL_SITES \
--dontUseSoftClippedBases);done

echo "#######"
echo "Joint_VCF_Files"
echo "########"

java -jar -Xmx10g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.7/GenomeAnalysisTK.jar \
-T GenotypeGVCFs \
-R ${Reference} \
-V AWD_sample1_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz
-V AWD_sample1_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz
-V AWD_sample1_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz
-V AWD_sample1_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz
-o ${HCvcf}/ALL_AWD_chr$(printf %02d $SGE_TASK_ID).vcf.gz
-allSites

# Index the bam

echo -e "\nIndexing VCF\n"

/u/home/d/dechavez/tabix-0.2.6/tabix -p vcf \
${HCvcf}/ALL_AWD_chr$(printf %02d $SGE_TASK_ID).vcf.gz

echo -e "\nFinish Indexing VCF\n"
