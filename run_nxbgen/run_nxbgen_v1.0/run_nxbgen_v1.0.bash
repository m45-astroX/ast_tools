#!/bin/bash

# run_nxbgen


if [ $# -ne 6 ] ; then
    echo "Usage : bash run_nxbgen_v${VERSION}.bash"
    echo "    clevtfile ($1)"
    echo "    ehkfile ($2)"
    echo "    innxbfile ($3)"
    echo "    innxbehkfile ($4)"
    echo "    outpifile ($5)"
    echo "    logfile ($6)"
    exit
fi

clevtfile=$1
ehkfile=$2
innxbfile=$3
innxbehkfile=$4
outpifile=$5
logfile=$6

rslnxbgen \
    infile=$clevtfile \
    ehkfile=$ehkfile \
    regfile=NONE \
    innxbfile=$innxbfile \
    innxbehk=$innxbehk \
    outpifile=$outpifile \
    pixels="-" cleanup=yes chatter=3 \
    clobber=yes mode=hl \
    logfile=$logfile \
    sortbin=0,4,5,6,7,8,9,10,11,12,13,99 \
    expr="PI>=400 && RISE_TIME>=40 && RISE_TIME<=60 && ITYPE<4 && STATUS[4]==b0"
