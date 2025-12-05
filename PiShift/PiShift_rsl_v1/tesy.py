SCRIPT_SHELL="python"
SCRIPT_NUM_ARG=1

###IMPORT###
import sys
import csv
#import pyfits
from astropy.io import fits
import os
###HELP###

ch_num=60000

if len(sys.argv[1:])!=SCRIPT_NUM_ARG:
    print('Usage : python3 test.py infile')
    sys.exit()

inf=str(sys.argv[1])

hdulist = fits.open(inf)

sp = hdulist[1].data 

new_counts=[]

for n in range(ch_num) :
    new_counts.append(0.0)

old_counts=sp['COUNTS']

print(old_counts)
