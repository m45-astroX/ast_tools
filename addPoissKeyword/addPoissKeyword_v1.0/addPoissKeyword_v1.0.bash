#!/bin/bash

# addPoissKeyword

VERSION='1.0'

if [ $# != 1 ] ; then
    echo "Usage : bash addPoissKeyword_v${VERSION}.bash pifile"
    exit
fi

infile=$1
outfile=$(basename $infile | sed 's/\.gz$//g; s/\.pi$/_POISS0.pi/g')

mathpha \
    expr=$infile \
    units=C \
    outfil=$outfile \
    exposure=$infile \
    areascal=% \
    ncomments=0 \
    errmeth=POISS-0 \
    properr=no \
    clobber=yes
