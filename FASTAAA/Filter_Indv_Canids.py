'''
Author: Jacqueline Robinson, Latter modied by Daniel Chavez (c)
Input = raw VCF
Output = filtered VCF
- Filtered sites are marked as FAIL in the 7th column.
- Sites that pass go on to genotype filtering.
- Filtered out genotypes are changed to '.', all others reported.
'''

import sys
import gzip
import re

vcf_file = sys.argv[1]
inVCF = gzip.open(vcf_file, 'r')

outVCF=open(vcf_file[:-7]+'_filtered.vcf', 'w')

minD=3
maxD={'SV16082018':68,'Cb17082018':112,'Ananku':21,'CDKPEI14051':19,'Dhole':32,'GoldenW':40,'GF041':40,'Kenyan':27,'Coyote':40,'AndeanF':18,'African':37,'Jackal':46,'Kenya_WGF20':26,'GrayW':41}
Overall_minD={'chr01':115,'chr02':98.55,'chr03':111,'chr04':111,'chr05':109,'chr06':101,'chr07':105,'chr08':91,'chr09':98,'chr10':99,'chr11':57,'chr12':100,'chr13':115,'chr14':51,'chr15':38.2,'chr16':84,'chr17':107,'chr18':111,'chr19':103,'chr20':114,'chr21':95,'chr22':97,'chr23':107,'chr24':101,'chr25':96,'chr26':104,'chr27':69,'chr28':91,'chr29':95,'chr30':96,'chr31':84,'chr32':90,'chr33':110,'chr34':110,'chr35':42.5,'chr36':109,'chr37':107,'chr38':107,'chrX':92}
Overall_maxD={'chr01':289,'chr02':294,'chr03':289,'chr04':283,'chr05':280,'chr06':289,'chr07':272,'chr08':272,'chr09':284,'chr10':273,'chr11':338.65,'chr12':277,'chr13':278,'chr14':844,'chr15':266,'chr16':449,'chr17':268,'chr18':275,'chr19':269,'chr20':280,'chr21':270,'chr22':273,'chr23':276,'chr24':281,'chr25':283,'chr26':285,'chr27':269,'chr28':281,'chr29':271,'chr30':274,'chr31':258,'chr32':269,'chr33':272,'chr34':280,'chr35':2826,'chr36':270,'chr37':280,'chr38':272,'chrX':259}


samples=[]
for line in inVCF:
	if line.startswith('##'):
		pass
	else:
		for i in line.split()[9:]: samples.append(i)
		break
inVCF.seek(0)


# Filter to be applied to individual genotypes
def GTfilter(sample,GT_entry):
	if GT_entry=='.': return '.'
	else:
		field=GT_entry.split(':')
		#print(field[2])
		if float(field[3])<20.0: return '.'
		if int(field[2])<minD: return '.'
		elif int(field[2])>maxD[sample]: return '.'
		else: return field[0]

def GTfilter2(sample,GT_entry):
        if GT_entry=='.': return '.'
        else:
             	field=GT_entry.split(':')
                if float(field[2])<20.0: return '.'
                if int(field[1])<minD: return '.'
                elif int(field[1])>maxD[sample]: return '.'
                else: return field[0]

for line0 in inVCF:

### Write header lines
	if line0.startswith('#'): outVCF.write(line0); continue

### For all other lines:
	line=line0.strip().split('\t')
	INFO=line[7]
	
### Site filtering


### Only accept biallelic SNPs
	if ',' in line[4]: outVCF.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), 'FAIL_multiallelic', '\t'.join(line[7:])) ); continue

### Only accept single base mutations
	if len(line[3])>1 or len(line[4])>1: outVCF.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), 'FAIL_multibase', '\t'.join(line[7:])) ); continue

### For variant sites: only accept sites with QUAL>=50, and at least 2 observations on each of the F and R strands for alternate alleles
	if line[4]!='.':
		GQ=float(line[5])
		if GQ<50.0: outVCF.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), 'FAIL_GQ', '\t'.join(line[7:])) ); continue


### Delete weird fields
	A = line[8].split(':')
	if len(A) == 1: outVCF.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), 'FAIL_FewFields', '\t'.join(line[7:])) ); continue

### Filter out sites with missing/failing genotype
	missing=0
	for i in range(0,len(samples)):
		value=line[i+9].split(':')
 		if value[0] == './.': missing+=1
		elif line[8] == 'GT:DP:RGQ' and GTfilter2(samples[i], line[i+9])=='.': missing+=1
		elif line[8] != 'GT:DP:RGQ' and GTfilter(samples[i], line[i+9])=='.': missing+=1
		#elif line[8] == 'GT:DP:RGQ' and GTfilter2(samples[i], line[i+9])=='.': missing2+=1
	if missing>0: outVCF.write('%s\t%s\t%s\n' % ('\t'.join(line[0:6]), 'FAIL_missing', '\t'.join(line[7:])) ); continue	
	

### Genotype filtering

### Write line contents up to first genotype
	outVCF.write('%s' % '\t'.join(line[:9]))


### Check each genotype to see if it passes depth and quality filters, plus AB filter for hets
	
	for i in range(0,len(samples)):
		if line[8] == 'GT:DP:RGQ':
                	value=line[i+9].split(':')
			#if value[0] == './.': continue 	
               		if value[0] == './.': outVCF.write('\t.')
                	else:
                		GT=GTfilter2(samples[i],line[i+9])
                        	if GT=='.': outVCF.write('\t.')
                       		elif GT=='0/0' or GT=='1/1' or GT=='0/1': outVCF.write('\t%s' % line[i+9])

		else:
### Check each genotype to see if it passes depth and quality filters, plus AB filter for het
			value=line[i+9].split(':')
			#if value[0] == './.': continue
			if value[0] == './.': outVCF.write('\t.')
			else:
				GT=GTfilter(samples[i],line[i+9])
				if GT=='.': outVCF.write('\t.')
				elif GT=='0/0' or GT=='1/1' or GT=='0/1': outVCF.write('\t%s' % line[i+9])
	outVCF.write('\n')

inVCF.close()
outVCF.close()

exit()
