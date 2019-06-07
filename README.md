### This repository describes all the steps necesary to do genome-wide Positive selection analysis of the African wild dog (AWD), extract 25-kb aligments from multiple canid genomes for phylogenomic analysis and 1kb alignments for the demographic model.

## 1. Get variants from raw reads 
### This step will get BAM files for diferent canids
### All scripts necesary for this step can be found within Get_VCF_from_Reads/
`bash from_fastaq_to_VCF.sh`

## 1. Identify selective sweeps
### This step will identify windows will low diversity and high divergence among AWD genomes 
### All scripts necesary for this step can be found within HKA-like_Test/
`bash HKA-like.sh`

## 2. Branch-site test with PAML
### This step will identify genes with a signficant amount of dn/ds changes along the branch of the AWD and the dhole.
### All scripts necesary for this step can be found within PAML_Positive_Selection/
`bash Positive_selection.sh`

## 3. Get 25kb-alignments
### This step will get alignments and best partitions that are necesary for RAXML, ASTRAL and divergence times analysis.
### All scripts necesary for this step can be found within 25KB_windows/
`bash Get_25kb.sh`

## 4. Get 1kb-alignments
### This step will get alignments that are necesary for the demographic model with G-phocs
### All scripts necesary for this step can be found within 1kb_alignments_Gphocs/
`bash Get_1kb_neutral_loci.sh`
