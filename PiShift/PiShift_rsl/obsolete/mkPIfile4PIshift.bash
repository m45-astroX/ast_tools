#!/bin/bash

# mkPIfile4PIshift


if [ $# != 1 ] ; then
    echo "Usage : bash mkPIfile4PIshift.bash infile"
    exit
fi

infile=$1
outfile=$(basename $infile | sed 's/\.gz$//g; s/\.pi$/_POISS1.pi/g')

mathpha \
    expr=$infile \
    units=C \
    outfil=$outfile \
    exposure=$infile \
    areascal=% \
    ncomments=0 \
    errmeth=POISS-1 \
    properr=yes
