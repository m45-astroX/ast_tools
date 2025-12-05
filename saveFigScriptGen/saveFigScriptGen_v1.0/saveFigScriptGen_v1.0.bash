#!/bin/bash

# saveFigScriptGen

if [ $# -lt 1 ] ; then
    echo "Usage : BASENAME templatefiles(allow multiple files)"
    exit
else
    BASENAME=$1
fi

yrange_window1='1e-6 2'
yrange_window2='-10 10'


# Read templatefiles
if [ $# -ge 2 ] ; then
    for i in $(seq 0 $(echo "$# - 2" | bc)) ; do
        templatefilearray[${i}]=$(eval "echo \$$(echo $i + 2 | bc)")
    done
fi

### Genarate script ###

## 2-10keV (log)
scriptfile='makefig1.temp'
if [ -e $scriptfile ] ; then
    rm -f $scriptfile
fi
for templatefile in ${templatefilearray[@]}; do
    printf "@${templatefile}\n" >> $scriptfile
done
printf "wi 1\n" >> $scriptfile
printf "r x 2 10\n" >> $scriptfile
printf "r y ${yrange_window1}\n" >> $scriptfile
printf "wi 2\n" >> $scriptfile
printf "r y ${yrange_window2}\n" >> $scriptfile
printf "wi 1\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_lo_2p0-10p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile


## 2-10keV (liner)
scriptfile='makefig2.temp'
if [ -e $scriptfile ] ; then
    rm -f $scriptfile
fi
for templatefile in ${templatefilearray[@]}; do
    printf "@${templatefile}\n" >> $scriptfile
done
printf "wi 1\n" >> $scriptfile
printf "r x 2 10\n" >> $scriptfile
printf "r y ${yrange_window1}\n" >> $scriptfile
printf "wi 2\n" >> $scriptfile
printf "r y ${yrange_window2}\n" >> $scriptfile
printf "wi 1\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_2p0-10p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 2-4keV (liner)
printf "wi 1\n" >> $scriptfile
printf "r x 2 4\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_2p0-4p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 4-6keV (liner)
printf "wi 1\n" >> $scriptfile
printf "r x 4 6\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_4p0-6p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 6-8keV (liner)
printf "wi 1\n" >> $scriptfile
printf "r x 6 8\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_6p0-8p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 8-10keV (liner)
printf "wi 1\n" >> $scriptfile
printf "r x 8 10\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_8p0-10p0.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 6.2-7.1keV (liner)
#printf "wi 1\n" >> $scriptfile
#printf "r x 6.2 7.1\n" >> $scriptfile
#printf "pl\n" >> $scriptfile
#printf "ha ${BASENAME}_li_6p2-7p1.ps/cps\n" >> $scriptfile
#printf "pl\n" >> $scriptfile

## 6.2-6.5keV (FeIKa, liner)
printf "wi 1\n" >> $scriptfile
printf "r x 6.2 6.5\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_6p2-6p5.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 6.5-6.8keV (FeXXV Ka, liner)
printf "wi 1\n" >> $scriptfile
printf "r x 6.5 6.8\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_6p5-6p8.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

## 6.8-7.1keV (FeXXVI Ka, liner)
printf "wi 1\n" >> $scriptfile
printf "r x 6.8 7.1\n" >> $scriptfile
printf "pl\n" >> $scriptfile
printf "ha ${BASENAME}_li_6p8-7p1.ps/cps\n" >> $scriptfile
printf "pl\n" >> $scriptfile

exit
