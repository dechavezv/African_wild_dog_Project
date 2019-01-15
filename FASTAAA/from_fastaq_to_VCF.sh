### This pipeline will get genetic variants (VCF) from raw reads (fastq) obtained through Next generation sequencing (i.e Illumina and Solid). This pipeline follows [GATK best practice](https://software.broadinstitute.org/gatk/best-practices/).

## 1. Filter raw reads

### fastq [Illumina filter](http://cancan.cshl.edu/labmembers/gordon/fastq_illumina_filter/)

fastq_illumina_filter -Nv -o read_1_filtered.fastq read_1.fastq; fastq_illumina_filter -Nv -o read_2_filtered.fastq read_2.fastq
gunzip -c RWDC001_GCCAAT_L004_R1_001.fastq.gz | fastq_illumina_filter -N | gzip > RWDC001_filtered_R1.fq.gz

### Trim illumina reads with [TrimGalore](http://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)
trim_galore -q 20 --fastqc -a AGATCGGAAGAGC --length 20 --paired RWDC001_filtered_R1.fq.gz  RWDC001_filtered_R2.fq.gz

### Trim Solid sequences with [cutadapt](https://cutadapt.readthedocs.io/en/stable/guide.html)
/opt/cutadapt-1.8.1/bin/cutadapt -q 20 --trim-primer --format=sra-fastq -m 20 --trim-n --double-encode --trim-primer -c -z -a CGCCTTGGCCGTACAGCAG -o Tirmmed_qualsFixed.fq SRR2149874_1.fastq.gz

## 2. Align filtered reads to domestic dog reference genomes
### illumna reads with [Bowtie2](http://bowtie-bio.sourceforge.net/bowtie2/manual.shtml#the-bowtie2-build-indexer)
bowtie2 -q --phred33 -p 12 --very-sensitive-local -X 800 --no-mixed -x canfam31/ -1 <input>_filtered_trimmed_1.fq.gz -2 <input>_filtered_trimmed_2.fq.gz -S <input>.sam

### Solid reads with [Bowtie](https://mcardle.wisc.edu/mprime/help/bowtie/manual.html)
bowtie -C /data3/dechavezv/reference/canfam31.fa -1 <input>_1.fastq -2 <input>_2.fastq -S <input>.sam

### check the mapping process with [Qualimap](http://qualimap.bioinfo.cipf.es)
qualimap bamqc -bam <name_file>.bam -c # for large files use --java-mem-size=4G

## 3 Add group and index to BAM
java -jar -Xmx8g /picard-tools-1.80/AddOrReplaceReadGroups.jar INPUT=<input>_val_sorted.sam OUTPUT=<input>_val_group_sorted.sam RGID=flowcell1lane1 RGLB=lib1 RGPL=ILLUMINA RGPU=GCCAAT RGSM=RWD001 RGCN=A2 VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true

## 4 Mark Duplicates
java -jar -Xmx8g /picard-tools-1.80/MarkDuplicates.jar INPUT=<input>_short_val_sorted.bam OUTPUT=<input>_Dup_val_sorted.bam METRICS_FILE=metrics.txt

### Index the bam
java -jar -Xmx8g -Djava.io.tmpdir=/work/temp /picard-tools-1.80/BuildBamIndex.jar INPUT=<input>_Dup_val_sorted.bam OUTPUT=<input>_Dup_val_sorted.bam.bai VALIDATION_STRINGENCY=LENIENT TMP_DIR=/work/temp

## 5. Indel realigment
java -Xmx8g -jar -Djava.io.tmpdir=/work/temp /GenomeAnalysisTK-3.4-1-g07a4bf8/GenomeAnalysisTK.jar -T IndelRealigner -R /canfam31.fa -I <input>_Dup_val_sorted.bam -targetIntervals <input>_Dup_val_sorted.bam.RealignerTargetCreator.intervals -o <input>_Botiew2_sortRG_MarkPCRDup.bam
### Note: Not necesary if running Haplotype caller later.

## 6. Fix the mate information
java -jar -Xmx8g -Djava.io.tmpdir=/work/temp /picard_tools_location_here/FixMateInformation.jar INPUT=<input>_Botiew2_sortRG_MarkPCRDup.bam OUTPUT=<input>_Botiew2_sortRG_MarkPCRDup_FoxMate.bam SORT_ORDER=coordinate VALIDATION_STRINGENCY=LENIENT TMP_DIR=/work/temp

## 7. Base Quality recalibration (BQR)
### Get a consensus of diferent variant calling tools and treat is as known variants. Use [GATK-HC](https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php), [GATK-UG](https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_genotyper_UnifiedGenotyper.php) and [Samtools-mpileup](http://samtools.sourceforge.net/mpileup.shtml).
bash GATK_HC_GVCFs.sh
bash GATK_UG_glms.sh
bash Samtools_VCF.sh
bash ISEC_Samtools_UG_HC.sh # this will pull out variants that are contained in at least two vcf files

### Filter the consensus
### Hard filer is to conservative and doesnt work with non-model species. 
### Used a custom python scripts originally develop by Jacqueline Robinson (UCLA) and latter modified by Daniel Cahvez (UCLA) for the AWD project.
python Filter_Indv_Canids.py <Names_of_canid>_stmp_ug_hc_mbq20.vcf.gz

### Conduct BQR
BQR.sh

## 8. Variant calling with [GATK Haplotype Caller](https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php)
bash GATK_HC_GVCFs.sh

### Filter the final VCF
python Filter_Indv_Canids.py 2nd_call_cat_samt_ug_hc_$1_raw.vcf
