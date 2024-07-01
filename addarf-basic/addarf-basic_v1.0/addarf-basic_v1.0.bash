#!/bin/bash

# addarf-basic

# 2024.07.01 v1.0 by Yuma Aoki


VERSION_SCRIPT=1.0

if [ $# -ne 2 ] ; then
    echo "Usage : bash addarf-basic_v${VERSION_SCRIPT}.bash arffile weight"
    exit
else
    infile=$1
    weight=$2
    outfile="$(basename $infile | sed 's/\.gz$//g; s/\.arf$/_weight/g')${weight}.arf"
fi


### Make logfile ###
d_log="logfiles_addarf-basic"
f_log="$d_log/addarf-basic.log"
if [ -e $d_log ] ; then
    rm -f $d_log/*
else
    mkdir $d_log
fi

### Check files ###
if [ ! -e $infile ] ; then
    echo "$infile does not exist!"
    echo "abort"
    exit
fi
if [ -e $outfile ] ; then
    rm -f $outfile
fi

echo "BEGIN PARAMS" >> $f_log
echo "pwd            : $(pwd)" >> $f_log
echo "whoami         : $(whoami)" >> $f_log
echo "VERSION_SCRIPT : ${VERSION_SCRIPT}" >> $f_log
echo "" >> $f_log
echo "\$0 : $0" >> $f_log
echo "\$1 : $1" >> $f_log
echo "\$2 : $2" >> $f_log
echo "END PARAMS" >> $f_log
echo "" >> $f_log

echo "CMD : addarf \"$infile\" \"$weight\" \"$outfile\"" >> $f_log
addarf "$infile" "$weight" "$outfile"

exit
