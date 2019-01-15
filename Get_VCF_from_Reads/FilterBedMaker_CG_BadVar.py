'''
Make a bed file with coordinates of sites that follow a C or precede a G - 
potential CpG high mutation rate sites

C_ or _G

Make a bed file with coordinates of sites that are within 5bp of MNP, INS, DEL, COMPLEX
_ _ _ _ _ VAR _ _ _ _ _ 
'''

import sys
import gzip
import re

infile=sys.argv[1]

if infile.endswith(".gz") or infile.endswith(".GZ"):
	VCF=gzip.open(infile, 'r')
elif infile.endswith(".vcf") or infile.endswith(".VCF"):	
	VCF=open(infile, 'r')
else:
	print "You must supply a VCF file as input"
	exit()

outputCG=open(sys.argv[1]+"CGSiteFilter.bed", 'w')
outputVar=open(sys.argv[1]+"VarTypeSiteFilter.bed", 'w')

other_reject=("mnp","ins","del","complex")

for line in VCF:
	if line.startswith('#'): continue
	line=line.strip().split('\t')
	INFO=line[7]
	CHR=line[0]
	POS=int(line[1])
	REF=line[3]
	ALT=line[4]
	if any(x in INFO for x in other_reject):
		outputVar.write("%s\t%d\t%d\n" % (CHR,POS-6,POS+5))
		continue
	else:
		if REF=='C':
			outputCG.write("%s\t%d\t%d\n" % (CHR,POS,POS+1))
		elif REF=='G':
			outputCG.write("%s\t%d\t%d\n" % (CHR,POS-2,POS-1))
		if ALT=='.':
			continue
		AF=re.search("(?<=AF=)[^;]+", INFO).group(0)
		if ALT=='C' and AF=='1':
			outputCG.write("%s\t%d\t%d\n" % (CHR,POS,POS+1))
			continue
		elif ALT=='G' and AF=='1':
			outputCG.write("%s\t%d\t%d\n" % (CHR,POS-2,POS-1))
			continue

outputVar.close()
outputCG.close()
VCF.close()

exit()

