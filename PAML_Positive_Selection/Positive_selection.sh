Author: Daniel Chavez, 2018 (c)

# Before running the pipeline make sure of the following:
## -Within the Genome folder verify that you have 'Ns' in the sequences for low quality sequence, if not they were obtained with GATK alterantive reference, wich may not be recomendable for this Pipeline.
## -Within the Genome folder verify that you DONT HAVE lower case letters, this are basese that were maskes by samtools for having to low or hihg Depth coverage values.
## -If you find lowercase letters in your genomes, use the following command line to fixed them:
## -python lowercase_to_N.py <infile.fasta> # the output will be called Masked_depth_<name_of_input>
## -the tips of the tree must have the same name as the header of fasta files
## -the foreground branch of the tree must be marker with $1. The topology of the tree follows: Chavez et al. (2018) "Comparative genomics provides new insights into the remarkable adaptations of the African wild dog (Lycaon pictus)".
## -make sure that the header of fasta files are seprate by '|' instead of '\t', if not use sed the following:
## $ sed -e 's/\t/\|/g' your_file > output_file
## -make sure that you dont have a database.fas file alredy in the directory,if ss deleted before running the pipeline 

# Get all orthologs in fasta format from BAM files that have passed trough Base quality recalibration (BQR)
export BAM=BQR_<canid_input>.bam
export REF=canfam31.fa # domestic dog reference genome
export Output=BQR/GenomeFasta
export neutral=/Canis_familiaris.bed # Coordinates of Orthologs genes obtained from Ensembl (http://uswest.ensembl.org/biomart/martview/ca987dcba5082c48ee19314c350277f1)

echo -e "\n Getting genome in FASTA format\n"
cd ${Output}
samtools mpileup -Q 20 -q 20 -u -v \
-f ${REF} ${BAM} |
bcftools call -c |
vcfutils.pl vcf2fq -d 4 -D 112 -Q 20 > ${BAM}.fq #-D correpond to the 95th percentile ot total coverage for a particular genomes. This will change depending on the genomes.
/u/home/d/dechavez/seqtk/seqtk seq -aQ33 -q20 -n N ${BAM}.fq > ${BAM}_d4_D112_phred33.fa
bedtools getfasta -fi ${BAM}.fa -bed ${neutral} -fo Genomes/${BAM}_ortoGenes_.fa

echo -e "\n Finisined process of getting genome in FASTA format\n"


# 1. Prepare files for multiple sequence alignment (MSA)
bash Prepare_to_MSA.sh

# 2. Performed MSA of every gene
## within the directory Processing, go to every individual gene directory and run the following:
bash PAML_align_PRANK.sh
 
# 3. Transform aligments to amino acid sequences
bash Create_codon_aminoacid_table.sh 

# 4 . Run PAML for every gene
## ## within the directory Processing, go to every individual gene directory and run the followin
bash Prepare_to_PRANK.sh

## To get all sequences in a different folder
bash Get_Sequences.sh

# 5. Get a table with p-values of all genes
## Get Likelihoods
bash Get_Positive_selceted_genes.sh

## Calculate Likelihood ratio test
python calculate_LRT.py Lilkelihoods_genes.txt LRT_AWD.txt

## Calculate p-values
Rscript calculate_pvalues.R

## Pull out BEB sites
bash Get_BEB_sites_v2.sh 
