# This pipeline will get 1kb-neutral loci that will be later used in the demographic model conducted with G-phocs 

## 1. Get  1kb-alignments
export BAM=BQR_samt_ug_hc_fb_<Name_of_canid_Spescies>_raw_Reheader.vcf.table.bam
export REF=canfam31.fa
export Output=<Directory>
export BED=neutralLoci-geneFlank10k-sep30k-filtered.bed # coordinates for neutral loci were obtained from Freedman, H.A et al (2014) ("Genome Sequencing Highlights the Dynamic Early History of Dogs (vol 10, e1004016, 2014). Plos Genetics 10)"
cd ${Output}
samtools mpileup -Q 20 -q 20 -u -v -f ${REF} ${BAM} |
bcftools call -c |
vcfutils.pl vcf2fq -d 4 -D <95th percentile Total coverage> -Q 20 > ${BAM}.fq
/u/home/d/dechavez/seqtk/seqtk seq -aQ33 -q20 -n N ${BAM}.fq > ${BAM}_d4_D<95th>_phred33.fa
bedtools getfasta -fi ${BAM}.fa -bed ${BED} -fo ${BAM}_1kb.fa

### Concatenate neutral loci from Individual canids into a single file
cat *1kb.fa > database.fasta

#### Split_by_ID_of_molecular_marker'
awk -F "\t" '/^>/ {F = $5".fasta"} {print > F}' database.fasta

rm database.fasta # remove this file so it doesnt be consider in the next step

### Create_subfolders_with_one-hundred_files_each_one'
i=0; for f in *.fasta; do d=dir_$(printf %03d $((i/300+1))); mkdir -p $d; mv "$f" $d; let i++; done

## 2. Alignment with prank
### header of fasta alignmets has to mach name on terminal branches of the tree.txt
### the topology of the tree is based on Chavez et al (2018) ("Comparative genomics provides new insights into the remarkable adaptations of the African wild dog (Lycaon pictus)") 
for dir in dir*; do (cp Prank.sh $dir && cd $dir && \
for file in *.fasta;do (/u/home/d/dechavez/prank-msa/src/prank -d=$file -o=prank_$file -t=tree.txt -F -once);done);done

### Change header of fasta files to IDs in bed file
for dir in dir*; do ( \
cd $dir && for file in *.fasta; do (python replaceNames_Fasta.py *.fa *.bed Name_);done);done
