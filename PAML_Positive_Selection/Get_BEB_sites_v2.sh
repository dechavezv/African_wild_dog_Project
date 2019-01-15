#!/bin/bash
#$ -l highp,h_rt=10:00:00,h_data=2G
#$ -pe shared 1
#$ -N BEB
#$ -cwd
#$ -m bea
#$ -o ./BEB.out
#$ -e ./BEB.err
#$ -M dechavezv


#for Dir in dir_*; do (cp Get_BEB_sites.py $Dir && cd $Dir && for dir in Dir*; do (echo $dir && cp Get_BEB_sites.py $dir/tree/modelA/Omega1 && /
#cd $dir/tree/modelA/Omega1 && /
#python Get_BEB_sites.py out_masked_Dhole | grep '*' | sed 's/^.../'$(printf ${PWD##*Dir_} | sed -e 's/\/tree\/modelA\/Omega1//g')'\t/g' > out_modelA_site && /
#mv out_modelA_site ../../../ && cd ../../../ && /
#mv out_modelA_site $(echo ${PWD##*/}_BEB_site.txt) && /
#cp *_BEB_site.txt /u/scratch2/d/dechavez/SWAMP/BEB_PS_sites_WD_Fixed  && /
#rm *);done);done
cp Append_BEB_site_to_table.py /u/scratch2/d/dechavez/SWAMP/BEB_PS_sites_WD_Fixed
cp pvalues_Augus_26_SWAMP_fixed.txt /u/scratch2/d/dechavez/SWAMP/BEB_PS_sites_WD_Fixed
cd /u/scratch2/d/dechavez/SWAMP/BEB_PS_sites_WD_Fixed
for file in *ENSCAF*; do d=$(printf %d $(grep '*' $file | wc -l)); echo $file; if [ $d == 0 ]; then rm $file; else echo 'yes';fi;done
for file in Dir*;do perl -pe 's/(ENSCAFG\d+).phy/\1\|/g' $file | perl -pe 's/\n/,/g' | perl -pe 's/\|/\t/g' | perl -pe 's/$/\n/g'  | perl -pe 's/,ENSC\w+/,/g' | perl -pe 's/,\n/\n/g' | perl -pe 's/,\t\t/,/g' | perl -pe 's/\t\t/\t/g'   > Edited_$file;done
cat Edited* > BEB_genes.txt
python Append_BEB_site_to_table.py pvalues_Augus_26_SWAMP_fixed.txt BEB_genes.txt Consensus_
