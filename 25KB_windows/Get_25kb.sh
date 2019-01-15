### This pipeline will pull out aligments of 25kb in length and best partion strategies for phylogenetic analysis and divergence time stimations.

## 1. Genotype calling [GATK](https://software.broadinstitute.org/gatk/documentation/tooldocs/3.8-0/org_broadinstitute_gatk_tools_walkers_haplotypecaller_HaplotypeCaller.php)
GATK_HaplotypeCaller_GVCFs.sh

## 2. Get informative sites within 25kb
python SlidingWindowAllCanids_v2.py 2nd_call_cat_samt_ug_hc_AllCanids_ALLchr.g.vcf.gz > Windows_25kb_filtered_Phylogeny_Statv2.txt

## 3. Get 25kb Bed files
python Write_BedFile.py Windows_25kb_filtered_Phylogeny_Statv2.txt 25kb_Windows_goodQual.bed

### Get coding regions within 25kb windows
python Get_Partition_25kbWindows.py 25kb_Windows_goodQual.bed Orthologs.bed

### Delete empty files
for file in chr*; do if [ -s $file ]; then echo Not empty;else rm $file;fi;done

### Get neutral regions within 25kb windows [bedtools](https://bedtools.readthedocs.io/en/latest/) 
for file in chr*; do ( echo $file && ~/bedtools2/bin/bedtools complement -i $file -g 25kb_$(printf $file | sed 's/_.*//g').bed > Neutral_$file.bed);done

## 4. Get 25kb alignments
export BAM=2nd_call_cat_samt_ug_hc_fb_<Name_of_canid_Spescies>_raw_Reheader.vcf.table.bam
export REF=canfam31.fa
export Output=<Directory>
export BED=25kb_Windows_goodQual.bed
cd ${Output}
samtools mpileup -Q 20 -q 20 -u -v -f ${REF} ${BAM} |
bcftools call -c |
vcfutils.pl vcf2fq -d 4 -D <95th percentile Total coverage> -Q 20 > ${BAM}.fq
/u/home/d/dechavez/seqtk/seqtk seq -aQ33 -q20 -n N ${BAM}.fq > ${BAM}_d4_D<95th>_phred33.fa
bedtools getfasta -fi ${BAM}.fa -bed ${BED} -fo ${BAM}_25kb.fa

mkdir Merge_File

## Designating_Names'

## replace header names of previous outputs with header of bed files
for file in *.fa; do (python replaceNames_Fasta_V2.py $file ${BED} Name_$file);done

## erasing merged +\- strands # delete sequences that were merged and have a mixture of positive and negative strands
for file in Name*;do sed -i -r -e '/\+\,\-/{N;d;};/\-\,\+/{N;d;}' $file;done

## replacing "," for"_" This is necessary to have the proper header format for the merging exons step
for file in  Name*; do sed -r 's/,\S+//g' $file  > Fixed_For_mergeExons$file;done

## Mergin similar exons
for file in Fixed_For_mergeExons*; do python merge_CDS_Exons.py $file Out$file;done

## Reverse complement - strand
for file in Out*; do python ReverseComplemet_noChr_Pos.py $file ReverseStrand$file;done

## Erase intermidiate files

mv ReverseStrand* Merge_File

rm Fixed_For_mergeExons*
rm Name*
rm Out*


### MSA with [prank](https://www.ebi.ac.uk/Tools/msa/prank/)
cp tree.txt Merge_File
cd Merge_File
for file in *.fa;do (/u/home/d/dechavez/prank-msa/src/prank -d=$file -o=prank_$file -t=tree.txt -F -once);done

### Edit names of aligments
for file in prank_*; do (perl -pe 's/(>chr\d+) /\1_/g' $file.fas > Edited_$file && /
rm $file && mv  Edited_$file  $file);done

### From Fasta to Phylip
for file in prank_*; do (perl /u/home/d/dechavez/project-rwayne/scripts/fasta2phylip.pl $file > $file.phy);done

### Summary of alignments
for file in *.phy; do (python3 /u/home/d/dechavez/AMAS/amas/AMAS.py summary -f phylip -d dna -i $file && mv summary.txt $file_summary.txt);done

## 5. 25kb-Partitions
### Prepare files for PathFinder
for file in *.phy; do (mkdir -p dir_$file && echo $file && cp $file dir_$file && /
cp partition_finder.cfg dir_$file && cd dir_$file && / #cp configuration file to each folder
d=$(printf $(grep '13' $file | sed 's/13 //g')) && sed -i 's/759/'$d'/;s/align.phy/'$file'/g' partition_finder.cfg);done`\
Note:within the configuration file "partition_finder.cfg" edit 759 with the corresponding lenght of each gene

### 6. Calculate partitions
for dir in .phy*; do (echo $dir && /
/u/home/d/dechavez/anaconda2/bin/python2.7 ~/partitionfinder-2.1.1/PartitionFinder.py $dir --raxml);done
