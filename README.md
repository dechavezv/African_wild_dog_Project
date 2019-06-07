### This repository describes all the steps necessary to do genome-wide Positive selection analysis of the African wild dog (AWD), extract 25-kb alignments from multiple canid genomes for phylogenomic analysis and 1kb alignments for the demographic model.

## 1. Get variants from raw reads 
### This step will get BAM files for different canids
### All scripts necesary for this step can be found within Get_VCF_from_Reads/
`bash from_fastaq_to_VCF.sh`

## 2. Identify selective sweeps
### This step will identify windows will low diversity and high divergence among AWD genomes 
### All scripts necessary for this step can be found within HKA-like_Test/
`bash HKA-like.sh`

## 3. Branch-site test with PAML
### This step will identify genes with a significant amount of dn/ds changes along the branch of the AWD and the dhole.
### All scripts necessary for this step can be found within PAML_Positive_Selection/
`bash Positive_selection.sh`

## 4. Get 25kb-alignments
### This step will get alignments and best partitions that are necessary for RAXML, ASTRAL and divergence times analysis.
### All scripts necessary for this step can be found within 25KB_windows/
`bash Get_25kb.sh`

## 5. Get 1kb-alignments
### This step will get alignments that are necessary for the demographic model with G-phocs
### All scripts necessary for this step can be found within 1kb_alignments_Gphocs/
`bash Get_1kb_neutral_loci.sh`


