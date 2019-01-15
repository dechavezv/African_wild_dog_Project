#! /bin/bash

#$ -l highp,h_rt=26:00:00,h_data=6G
#$ -pe shared 1
#$ -N Isec_<canid>
#$ -cwd
#$ -m bea
#$ -o /ISEC/log/Isec_<canid>.out
#$ -e /ISEC/log/Isec_<canid>.err
#$ -M dechavezv

# Before using this script make sure that you have all the vcf file compress (.gz) and indexed (.tbi)
# You can use the following commands to compress the file
# bigzip -c <your_vcf_file> > <compress_vcf>.gz
# tabix -p vcf <compress_vcf>.gz


export GATK_UG=/UG_VCF/BQR_<canid>_sortRG_rmdup_realign_fixmate_UG_Allchr.vcf.gz
export Samt=/Samtools/BAQR_<canid>_sortRG_rmdup_realign_fixmate_mpileup_Allchr.vcf.gz
export GATK_HC=/HC_VCF/BAQR_<canid>_DupIndelFixmate_HC_Allchr.vcf.gz
export OUT=/ISEC/

cd ${OUT} /
/u/home/tabix-0.2.6/bgzip -c ${Samt} > ${Samt}.gz
/u/home/tabix-0.2.6/bgzip -c ${GATK_UG} > ${GATK_UG}.gz
/u/home/tabix-0.2.6/tabix -p vcf ${Samt}.gz
/u/home/tabix-0.2.6/tabix -p vcf ${GATK_UG}.gz
/u/home/bcftools/bcftools isec -n +2 -c none -O v -p . ${Samt} ${GATK_UG} ${GATK_HC}
for file in 000*vcf; do /u/home/tabix-0.2.6/bgzip ${file}; /u/home/tabix-0.2.6/tabix -p vcf ${file}.gz; done
/u/home/d/dechavez/bcftools/bcftools concat -a -O v `ls 000*.vcf.gz` > BAQR_<canid>_stmp_ug_hc_mbq20_raw.vcf
sed 's/Number=1/Number=./;s/,Version="3">/>/' BAQR_<canid>_stmp_ug_hc_mbq20_raw.vcf > BAQR_<canid>_stmp_ug_hc_mbq20_raw_reheader.vcf
/u/home/tabix-0.2.6/bgzip -c BAQR_<canid>_stmp_ug_hc_mbq20_raw_reheader.vcf > BAQR_<canid>_stmp_ug_hc_mbq20_raw_reheader.vcf.gz
/u/home/tabix-0.2.6/tabix -p vcf BAQR_<canid>_stmp_ug_hc_mbq20_raw_reheader.vcf.gz
rm BAQR_<canid>_stmp_ug_hc_mbq20_raw.vcf
