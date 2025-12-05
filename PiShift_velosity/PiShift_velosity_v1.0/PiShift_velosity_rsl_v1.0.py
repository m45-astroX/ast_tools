#!/usr/bin/env python

SCRIPT_SHELL = "python"
SCRIPT_HELP_ARG = "Usage : python PiShift4baricorr_rsl_v1.0.py pifile(in) pifile(out) velocity(km/s)"
SCRIPT_HELP_SENTENCE_1 = "    Modify PI Channel with E=E0*(sqrt(1-(v/c)^2)/(1+v/c)"
SCRIPT_HELP_SENTENCE_2 = "    Only for XRISM/Resolve."
SCRIPT_NUM_ARG = 3

VELOCITY_C_KMPS = 299792.458

###IMPORT###
import os
import sys
import numpy
from astropy.io import fits

###HELP###
if len(sys.argv[1:]) != SCRIPT_NUM_ARG :
    print(SCRIPT_HELP_ARG)
    print(SCRIPT_HELP_SENTENCE_1)
    print(SCRIPT_HELP_SENTENCE_2)
    sys.exit()

###MAIN###
inf=str(sys.argv[1])
outf=str(sys.argv[2])
v=float(sys.argv[3])

ch_num=60000

hdulist = fits.open(inf)

if os.path.isfile(outf) :
    os.remove(outf)

sp=hdulist[1].data

hdulist[1].header['COMMENT']='Modefied with PiShift4baricorr_rsl_v1.0.py'
hdulist[1].header['COMMENT']='v='+str(v)+' km/s'

def f(x) :

    x = float(x)

    # E=E0*(sqrt(1-(v/c)^2)/(1+v/c)
    return (x) * numpy.sqrt(1-(v/VELOCITY_C_KMPS)*(v/VELOCITY_C_KMPS)) / (1+v/VELOCITY_C_KMPS)


def main() :

    new_counts=[]

    for n in range(ch_num) :
        new_counts.append(0.0)  
    
    old_counts=sp['COUNTS']
    
    for n in range(ch_num) :
        new_ch0=f(n)
        new_ch1=f(n+1)
        if new_ch1 < new_ch0 :
            sys.exit('Correction function is not monotone.')
        elif new_ch0 > 0 and new_ch1 < ch_num :
            for m in range(int(new_ch0+1),int(new_ch1)) :
                new_counts[m]+=old_counts[n]/(new_ch1-new_ch0)

            new_counts[int(new_ch0)]+=old_counts[n]/(new_ch1-new_ch0)*(int(new_ch0+1)-new_ch0)
            new_counts[int(new_ch1)]+=old_counts[n]/(new_ch1-new_ch0)*(new_ch1-int(new_ch1))

    for n in range(ch_num) :
        sp['COUNTS'][n]=int(round(new_counts[n]))

    hdulist.writeto(outf)

main()
