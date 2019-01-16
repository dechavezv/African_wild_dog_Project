#!/bin/bash
#$ -l highp,h_rt=35:00:00,h_data=18G
#$ -pe shared 1
#$ -N <Canid>GVCF
#$ -cwd
#$ -m bea
#$ -o /BQR/<Canid>GVCF.out
#$ -e /BQR/<Canid>GVCF.err
#$ -M dechavezv 
#$ -t 1-38:1


# then load your modules:
. /u/local/Modules/default/init/modules.sh
 
module load java
module load samtools/0.1.19

export BAM=/BQR/BQR_samt_ug_hc_ManedWolf_raw.vcf.table.bam
export Reference=/canfam31/canfam31.fa
export vcf=/BQR/GVCFs
export temp=/BQR/GVCFs
export HCvcf=/BQR/HC_VCF

echo "#######"
echo "Haplotype Caller per chromosome"
echo "########"

##### ERC BP_RESOLUTION not recomended for final versions of vcf files
##### out_mode EMIT_ALL_SITES not necesary if you are alredy calling ERC

cd ${vcf}

java -jar -Xmx30g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.7/GenomeAnalysisTK.jar \
-T HaplotypeCaller \
-R ${Reference} \
-I ${BAM} \
-L chr$(printf %02d $SGE_TASK_ID) \
-o BQR_samt_ug_hc_<canids_Spescies>_chr$(printf %02d $SGE_TASK_ID).g.vcf.gz \
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
-V BQR_samt_ug_hc_bushDog_chr01.g.vcf.gz \
-o ${HCvcf}/BQR_samt_ug_hc_ManedW_chr01.vcf.gz \
-allSites
$(for i in {01..38} X MT ; do ( \
echo "-V African_chr$i.g.vcf.gz" && \
echo "-V Andean_chr$i.g.vcf.gz" && \
echo "-V Coyote_chr$i.g.vcf.gz" && \
echo "-V Dhole_chr$i.g.vcf.gz" && \
echo "-V Ethiopian_chr$i.g.vcf.gz" && \
echo "-V GoldenW_chr$i.g.vcf.gz" && \
echo "-V GrayF_chr$i.g.vcf.gz" && \
echo "-V GrayW_chr$i.g.vcf.gz" && \
echo "-V Jackal_chr$i.g.vcf.gz" && \
echo "-V Kenyan_chr$i.g.vcf.gz" && \
echo "-V SRR2971425_chr$i.g.vcf.gz" && \
echo "-V SRR2971441_chr$i.g.vcf.gz);done)
-o ${HCvcf}/BQR_samt_ug_hc_AllCanids_ALLchr.g.vcf.gz


# Index the bam
echo -e "\nIndexing VCF\n"

/u/home/d/dechavez/tabix-0.2.6/tabix -p vcf \
${HCvcf}/BQR_samt_ug_hc_AllCanids_ALLchr.g.vcf.gz

echo -e "\nFinish Indexing VCF\n"
