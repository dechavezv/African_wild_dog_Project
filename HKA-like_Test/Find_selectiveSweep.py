'''
Author Daniel Chavez, March 21, 2007
usage: python Calculate_diversity_divergence_ratio.py file_diversity file_divergence
'''

import sys
outfile=open("Diversity_Divergence_ratio.txt", "w+")

Diversity=[]
Divergence=[]

with open(sys.argv[1],'r') as f1:
        for line1 in f1:
                line1=line1.split()
                Diversity.append(line1[0] + '_' + line1[1] +'\t'+ line1[2] + '\t' + line1[3])

with open(sys.argv[2],'r') as f2:
        for line2 in f2:
                line2=line2.split()
                Divergence.append(line2[0] + '_' + line2[1] +'\t'+ line2[2] + '\t' + line2[3] + '\t' + line2[4])

[i for i in Diversity if i in Divergence]

for i in range(len(Diversity)):
        element1=Diversity[i].split('\t')
        for i in range(len(Divergence)):
                element2=Divergence[i].split('\t')
                if element1[0] == element2[0]:
                        outfile.write(element1[0] + '\t' + str(float(element1[2])/float(element2[2])) + '\t' + element2[3] +'\n')
                else: continue
outfile.close()
