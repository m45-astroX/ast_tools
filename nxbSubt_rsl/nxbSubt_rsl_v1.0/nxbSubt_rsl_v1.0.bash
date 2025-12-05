#!/bin/bash

# nxbSubt_rsl

# 2024.06.11 v1.0 by Yuma Aoki (Kidnai Univ.)



SCRIPT_VERSION='1.0'

if [ $# -ne 3 ]  ; then
    echo "Usage : bash nxbSubt_rsl_v${SCRIPT_VERSION}.bash orgfile(.pi) nxbfile(.pi) outfile(.pi)"
    exit
else
    orgfile=$1
    nxbfile=$2
    outfile=$3
fi


### Check infiles ###
if [ "$orgfile" = "$nxbfile" ] ; then
    echo "orgfile and nxbfile are same name!"
    echo "abort"
    exit
fi
if [ "$orgfile" = "$outfile" ] ; then
    echo "orgfile and outfile are same name!"
    echo "abort"
    exit
fi
if [ "$nxbfile" = "$outfile" ] ; then
    echo "nxbfile and outfile are same name!"
    echo "abort"
    exit
fi

# Infile name must not contain '-'
if [ ! -z "$(echo "$orgfile" | grep "-" )" ] ; then
    echo "*** Error (\$1)"
    echo "orgfile name must not contain '-'!"
    echo "abort"
    exit
fi
if [ ! -z "$(echo "$nxbfile" | grep "-" )" ] ; then
    echo "*** Error (\$2)"
    echo "nxbfile name must not contain '-'!"
    echo "abort"
    exit
fi

if [ -e $outfile ] ; then
    rm -f $outfile
fi



### logfiles ###
d_log="logfiles_nxbSubt_rsl"
f_log="$d_log/nxbSubt_rsl.log"
if [ -e $d_log ] ; then
    rm -f $d_log/*
else
    mkdir $d_log
fi

echo "" >> $f_log
echo "BEGIN PARAMS" >> $f_log
echo "SCRIPT_VERSION : $SCRIPT_VERSION" >> $f_log
echo "HEADAS         : $HEADAS" >> $f_log
echo "CALDB          : $CALDB" >> $f_log
echo "" >> $f_log
echo "pwd     : $(pwd)" >> $f_log
echo "whoami  : $(whoami)" >> $f_log
echo "\$0     : $0" >> $f_log
echo "\$d_log : $d_log" >> $f_log
echo "\$f_log : $f_log" >> $f_log
echo "" >> $f_log
echo "orgfile (\$1) : $orgfile" >> $f_log
echo "nxbfile (\$2) : $nxbfile" >> $f_log
echo "outfile (\$3) : $outfile" >> $f_log
echo "END PARAMS" >> $f_log
echo "" >> $f_log



### Subtract ###
echo "BEGIN SUBTRACT" >> $f_log
echo "CMD : mathpha expr=${orgfile}-${nxbfile} outfil=$outfile units=R errmeth=POISS-0 properr=yes exposure=null areascal=% ncomments=1" >> $f_log
echo "" >> $f_log

mathpha \
    expr="${orgfile}-${nxbfile}" \
    outfil="$outfile" \
    units=R \
    errmeth="POISS-0" \
    properr=yes \
    exposure=null \
    areascal="%" \
    ncomments="0" \
    1>> $f_log 2>> $f_log

echo "" >> $f_log
echo "END SUBTRACT" >> $f_log
echo "" >> $f_log



### Edit keywords ###
BACKSCAL=$(fkeyprint infile=${orgfile}+1 keynam=BACKSCAL | awk 'NR==6{print}' | cut -c 10- | awk '{print $1}')
fparkey fitsfile=${outfile}+1 keyword=BACKSCAL value=${BACKSCAL} add=yes
EXPOSURE=$(fkeyprint infile=${orgfile}+1 keynam=EXPOSURE | awk 'NR==6{print}' | cut -c 10- | awk '{print $1}')
fparkey fitsfile=${outfile}+1 keyword=EXPOSURE value=${EXPOSURE} add=yes



exit
