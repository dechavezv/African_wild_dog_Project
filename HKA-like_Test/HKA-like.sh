## Author: Daniel Chavez 2018 (c)

## This pipeline will detect regrions with signals of recent events of postice selection (selective sweeps)
## This pipiline has inspired on the Hudson-Kreitman-Aguadé (HKA) test (Hudson, R. R., Kreitman, M. & Aguade, M. A TEST OF NEUTRAL MOLECULAR EVOLUTION BASED ON NUCLEOTIDE DATA. Genetics 116, 153-159 1987).

## Diversity were calculated following this steps:
##  - For each window, compute 2*p*(1-p) for each SNP; where p is the allele frequency in the 4 wild dogs. 
##  - Sum this up over all SNPs in the window and divide by the number of bases in the window that have good quality. Multiply this by n/(n-1), where n=is the number of chromosomes (8 in this case).

## Divergence were calculate following this steps:
## - For each window, compute the number of divergence sites between a single AWD and the domestic dog reference genome. To do this, pick the AWD the highest coverage. 
## - If a site is homozygous non-reference, count this as 1 divergent site. If the wild dog is heterozygous, count it as 0.5 divergent site.
## - Divide this count by the number of bases with good quality sequence within each window.

## Find Selective sweeps
## - For each window, divide Diversity/Divergence
## - The windows with the lowest values will indicate posible selective sweep!  

## To run the pipeline do the following: 
## 1. Perform variant calling with GATK HaplotypeCaller on each African wild dog (AWD) BAM file to create single-sample gVCFs.
##    All available samples are then jointly genotyped by taking the gVCFs produced earlier and running GenotypeGVCFs on all of them together to create a set of raw SNP and indel calls.
bash GATK_HC_GVCFs.sh # This will generate joint gVCF of the 4AWD genomes for each chromosome.

##    Filter the vcf files using this script Filter_VCF_African_Wild_dogs.py # Originally develop by Jacqueline Robinson (UCLA) and later modified for this project. 
for i in {01..38}; do /
python Filter_AWDs.py ALL_AWD_chr$i.vcf.gz;done

## 2. Calculate Diversisty within 100,000 windows
for i in {01..38}; do /
python Sliding_window_HKA_DIVERGENCE.py ALL_AWD_chr$i_filtered.vcf);done > Divergence.txt ; make usre to delete nan values

## 3. Calculate Divergence within 100,000 windows
for i in {01..38}; do /
python Sliding_window_HKA_Diversity.py ALL_AWD_chr$i_filtered.vcf);done > Diversity.txt; make usre to delete nan values

## 4. Calculate Diversisty/Divergence ratio running the folowing script
python Find_selectiveSweep.py Divergence.txt Divergence.txt
grep -v 'nan' Diversity_Divergence_ratio.txt > Fixed_Diversity_Divergence_ratio.txt # make sure to delete nan values

###    Calculate the mean coverage within each 100,000 window
for i in {01..38}; do /
python Sliding_window_Coverage_for_HKA.py ALL_AWD_chr$i_filtered.vcf;done > Coverage_within_100kb.txt 
