'''
Author: Daniel Chavez (2017) (c)

'''

import sys
import re
def __main__():
    infile  = sys.argv[1]
    outfile = sys.argv[2]

    with open(infile, 'rb') as fi:
        seqs = fi.read().split('>')[1:]
        seqs = [x.split('\n')[:2] for x in seqs]

    merge = dict()

    for x in seqs:
        key = re.search('(?<=)(\w+\t\w+\t\W)(?=\t)', x[0]).group(0)
        try:
            merge[key] = merge[key] + x[1]
        except KeyError:
            merge[key] = x[1]
        key = x[0]          
    with open(outfile, 'w') as fi:
        for x in merge.keys():
            fi.write('>' + x + '\n')
            fi.write(merge[x] + '\n')

__main__()
