#!/bin/bash
#$ -l highp,h_rt=35:00:00,h_data=18G
#$ -pe shared 1
#$ -N <canids_spescies_GATKHC>
#$ -cwd
#$ -m bea
#$ -o <canids_spescies>GVCF.out
#$ -e <canids_spescies>GVC.err
#$ -M dechavezv 
#$ -t 1-38:1

# then load your modules:
. /u/local/Modules/default/init/modules.sh
 
module load java
module load samtools/0.1.19

export BAM=/BQR/BQR_<canid_spescies>_samt_ug_hc.table.bam
export Reference=/canfam31/canfam31.fa
export vcf=/BQR/GVCFs
export temp=/BQR/GVCFs/temp
export HCvcf=/BQR/HC_VCF

##### ERC BP_RESOLUTION not recomended for final versions of vcf files
##### out_mode EMIT_ALL_SITES not necesary if you are alredy calling ERC

cd ${vcf}

java -jar -Xmx30g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.7/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R ${Reference} \
-I ${BAM} \
-L chr$(printf %02d $SGE_TASK_ID) \
-o <canid_spescies>_samt_ug_hc_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz \
-ERC BP_RESOLUTION \
-mbq 20 \
-out_mode EMIT_ALL_SITES \
--dontUseSoftClippedBases

echo "#######"
echo "Joint_VCF_Files"
echo "########"


java -jar -Xmx10g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.7/GenomeAnalysisTK.jar \
-T GenotypeGVCFs \
-R ${Reference} \
-allSites \
$(for i in {01..38} X MT; do echo "-V <canid_spescies>_samt_ug_hc_chr$i.g.vcf.gz";done) \
-o ${HCvcf}/<canid_spescies>_samt_ug_hc_chrALLchr.g.vcf.gz


# Index the bam

echo -e "\nIndexing VCF\n"

/u/home/d/dechavez/tabix-0.2.6/tabix -p vcf \
${HCvcf}/<canid_spescies>_samt_ug_hc_chrALLchr.g.vcf.gz

echo -e "\nFinish Indexing VCF\n"
