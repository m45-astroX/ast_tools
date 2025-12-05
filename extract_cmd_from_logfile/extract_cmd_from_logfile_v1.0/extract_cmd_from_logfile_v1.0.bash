#!/bin/bash

name_xspec='XSPEC12'

if [ $# != 2 ] && [ $# != 3 ] ; then
    echo "Usage : bash extract_cmd_from_logfile_v1.0.bash logfile(infile) xcmfile(outfile) clobber(Y/N; optional)"
    exit
elif [ $# = 2 ] ; then
    infile=$1
    outfile=$2
    clobber='N'
elif [ $# = 3 ] ; then
    infile=$1
    outfile=$2
    clobber=$3
fi

if [ ! -e $infile ] ; then
    echo "$infile does not exist!"
    exit
fi
if [ -e $outfile ] ; then

    if [ "$clobber" = "Y" ] || [ "$clobber" = "y" ] || [ "$clobber" = "YES" ] || [ "$clobber" = "yes" ]  ; then
        rm -f $outfile
    else
        echo "$outfile exists!"
        echo "abort"
        exit
    fi
    
fi

cat $infile | \
    sed -e 's/!XSPEC12>/EXTRACT\ /g' | \
    awk '$1=="EXTRACT" {print}' | \
    sed 's/EXTRACT\ //g' > $outfile
