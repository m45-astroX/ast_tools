#!/bin/bash

# mergeRslSpec

# 2024.10.28 v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.11.16 v1.0.2 by Yuma Aoki (Kindai Univ.)
#   - 表示する文章の軽微な修正

VERSION='1.0.2'

if [ $# != 3 ] ; then
    echo "Usage : bash mergeRslSpec_v${VERSION}.bash pifile1 pifile2 outfile"
    exit
else
    pifile1=$1
    pifile2=$2
    outfile=$3
    logfile="logfile_mergeRslSpec_$(date '+%Y%m%d%H%M%S').log"
fi

if [ -z $(echo $pifile1 | sed 's/.*-/-/g; s/-.*//g') ] ; then
    echo "*** Error"
    echo "pifile1 : $pifile1"
    echo "Do not include '-' in the filename!"
    echo "abort"
    exit
fi
if [ -z $(echo $pifile2 | sed 's/.*-/-/g; s/-.*//g') ] ; then
    echo "*** Error"
    echo "pifile2 : $pifile2"
    echo "Do not include '-' in the filename!"
    echo "abort"
    exit
fi

echo "expo1=$(fkeyprint infile=${pifile1}+1 keynam=EXPOSURE | awk 'NR==6{print $2}' | sed 's/E/e/g' | xargs printf "%.10f")" 1>>$logfile 2>>$logfile
expo1=$(fkeyprint infile=${pifile1}+1 keynam=EXPOSURE | awk 'NR==6{print $2}' | sed 's/E/e/g' | xargs printf "%.10f")
echo "expo2=$(fkeyprint infile=${pifile2}+1 keynam=EXPOSURE | awk 'NR==6{print $2}' | sed 's/E/e/g' | xargs printf "%.10f")" 1>>$logfile 2>>$logfile
expo2=$(fkeyprint infile=${pifile2}+1 keynam=EXPOSURE | awk 'NR==6{print $2}' | sed 's/E/e/g' | xargs printf "%.10f")
echo "expo_sum=$(echo "scale=10; ${expo1} + ${expo2}" | bc)" 1>>$logfile 2>>$logfile
expo_sum=$(echo "scale=10; ${expo1} + ${expo2}" | bc)

echo "CMD :: mathpha expr="${pifile1}+${pifile2}" units='C' outfil="${outfile}" exposure=${expo_sum} areascal='%' ncomments='0' clobber=yes" 1>>$logfile 2>>$logfile
mathpha expr="${pifile1}+${pifile2}" units='C' outfil="${outfile}" exposure=${expo_sum} areascal='%' ncomments='0' clobber=yes 1>>$logfile 2>>$logfile

echo "CMD :: fparkey keyword=EXPOSURE value=${expo_sum} fitsfile=$outfile add=yes" >> $logfile
fparkey keyword=EXPOSURE value=${expo_sum} fitsfile=$outfile add=yes 1>>$logfile 2>>$logfile
