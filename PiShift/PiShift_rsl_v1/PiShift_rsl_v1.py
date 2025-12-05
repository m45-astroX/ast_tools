SCRIPT_SHELL="python"
#SCRIPT_NAME="PiShift.py"
#SCRIPT_HELP_ARG="1) input Count PI file made by mathpha 2)output PI file 3)c0 4)c1 5)c2"
SCRIPT_HELP_ARG="Usage : python pifile(in) pifile(out) c0 c1 c2"
#SCRIPT_HELP_SENTENCE="Modify PI Channel with f(x)=c2*x**2+c1*x+c0. Only for Suzaku XIS."
SCRIPT_HELP_SENTENCE_1="    Modify PI Channel with f(x)=c2*x**2+c1*x+c0."
SCRIPT_HELP_SENTENCE_2="    Only for XRISM/Resolve."
SCRIPT_NUM_ARG=5

###IMPORT###
import sys
#import pyfits
from astropy.io import fits
import os
###HELP###

if len(sys.argv[1:])!=SCRIPT_NUM_ARG:
    #print('Name: '+SCRIPT_NAME)
    #print('Arguments: '+SCRIPT_HELP_ARG)
    #print('Explanation: '+SCRIPT_HELP_SENTENCE)
    print(SCRIPT_HELP_ARG)
    print(SCRIPT_HELP_SENTENCE_1)
    print(SCRIPT_HELP_SENTENCE_2)
    sys.exit()


###MAIN###
inf=str(sys.argv[1])
outf=str(sys.argv[2])
c0=float(sys.argv[3])
c1=float(sys.argv[4])
c2=float(sys.argv[5])


#ch_num=4096
ch_num=60000

hdulist = fits.open(inf)

if os.path.isfile(outf) :
    os.remove(outf)

sp=hdulist[1].data

#hdulist[1].header['COMMENT']='Modefied with PiSift.py'
hdulist[1].header['COMMENT']='Modefied with PiShift_rsl_v1.py'
hdulist[1].header['COMMENT']='c0='+str(c0)
hdulist[1].header['COMMENT']='c1='+str(c1)
hdulist[1].header['COMMENT']='c2='+str(c2)

def f(x) :
    x=float(x)
    return c2*x**2+c1*x+c0


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

#    for n in range(ch_num) :
#        sp['COUNTS'][n]=int(round(new_counts[n]))
#        #sp['STAT_ERR'][n]=float(new_counts[n]**0.5)
#        # error = 1.0 + SQRT(N + 0.75)   <-- The algorithm of Gehrels (1986 ApJ, 303, 336)
#        sp['STAT_ERR'][n]=float( 1.0 + (new_counts[n] + 0.75)**0.5 )

    hdulist.writeto(outf)

main()
