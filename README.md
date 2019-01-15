### This repository describes all the steps necesary to do Positive selection analysis and extract MSA of 25kb in length.

## 1. Get variants from raw reads 
### All scripts necesary for this step can be found within From_fastaq_to_VCF/
`bash from_fastaq_to_VCF.sh`

## 1. Identify selective sweeps
### All scripts necesary for this step can be found within HKA-like_Test/
`bash HKA-like.sh`

## 2. Branch-site test with PAML
### All scripts necesary for this step can be found within PAML_Positive_Selection/
`bash Positive_selection.sh`

## 3. Get 25kb-alignments
### All scripts necesary for this step can be found within 25kb_alignments_for_Phylogeny/
### This script will get aligments and best partitions that are necesary for RAXML, ASTRAL and divergence times analysis.
`bash Get_25kb.sh'

## 4. Get 1kb-alignments
### All scripts necesary for this step can be found within 1kb_alignments_Gphocs/
### This script will get aligments and best partitions that are necesary for the demographic model with G-phocs
`Get_1kb_neutral_loci.sh`
