import sys
import re

'''
Author: Daniel Chavez (2017) (c)

'''

def ReverseComplement1(seq):
    seq_dict = {'A':'T','T':'A','G':'C','C':'G','N':'N','R':'R','Y':'Y','S':'S','W':'W','K':'K','M':'M','B':'B','D':'D','H':'H','V':'V'}
    return "".join([seq_dict[base] for base in reversed(seq)])

def __main__():
    infile  = sys.argv[1]
    outfile = sys.argv[2]

    with open(infile, 'rb') as fi:
        seqs = fi.read().split('>')[1:]
        seqs = [x.split('\n')[:2] for x in seqs]

    merge = dict()

    for x in seqs:
        key = re.search('(?<=)(\w+\t\w+\t\S)', x[0]).group(0)
        try:
            merge[key] = merge[key] + x[1]
        except KeyError:
            merge[key] = x[1]
        key = x[0]
    with open(outfile, 'w') as fi:
        for x in merge.keys():
            p = re.findall('-', x, re.DOTALL)
            
            if len(p) > 0:
		fi.write('>' + x + '\n')
                fi.write(ReverseComplement1(merge[x]) + '\n')
	          
	    else:
		fi.write('>' + x + '\n')
                fi.write(merge[x] + '\n')
__main__()
