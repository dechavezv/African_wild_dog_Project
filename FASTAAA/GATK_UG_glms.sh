#!/bin/bash
#$ -l highp,h_rt=24:00:00,h_data=15G
#$ -pe shared 1
#$ -N UG_<Canids>
#$ -cwd
#$ -m bea
#$ -o UG_<Canids>.out
#$ -e UG_<Canids>.err
#$ -M dechavezv
#$ -t 1-38:1


# then load your modules:
. /u/local/Modules/default/init/modules.sh
module load java

export BAM=BQR_<canid_spescies>_sortRG_rmdup_realign_fixmate.bam
export Output=/UG_VCF
export Reference=/canfam31/canfam31.fa
export temp=/UG_VCF/temp



java -jar -Xmx8g -Djava.io.tmpdir=${temp} /u/local/apps/gatk/3.8.0/GenomeAnalysisTK.jar \
-T UnifiedGenotyper \
-R ${Reference} \
-I ${BAM} \
--output_mode EMIT_VARIANTS_ONLY \
--min_base_quality_score 20 \
-stand_call_conf 30.0 \
-o ${Output}/BQR_<canid_spescies>_sortRG_rmdup_realign_fixmate.bam_chr$(printf %02d $SGE_TASK_ID).vcf.gz \
-metrics ${Output}/BQR_<canid_spescies>_sortRG_rmdup_realign_fixmate.bam_chr$(printf %02d $SGE_TASK_ID).metrics \
-glm BOTH
