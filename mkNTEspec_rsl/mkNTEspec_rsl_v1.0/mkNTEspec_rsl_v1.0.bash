#!/bin/bash

# mkNTEspec_rsl

# 2024.06.10 v1.0 by Yuma Aoki (Kindai Univ.)



SCRIPT_VERSION=1.0

if [ $# -ne 2 ] ; then
    echo "Usage : bash mkNTEspec_rsl_v${SCRIPT_VERSION}.bash"
    echo "    \$1 : BASENAME"
    echo "    \$2 : evtfile(uf)"
    exit
else

    BASENAME=$1
    infile=$2
    outfile_evt="${BASENAME}_nte_cl2.evt"
    outfile_lc="${BASENAME}_nte_lc.fits"
    outfile_pi="${BASENAME}_nte.pi"

    if [ ! -e $infile ] ; then
        echo "Infile ($infile) does not exist!"
        echo "abort"
        exit
    fi
    if [ -e $outfile_evt ] ; then
        rm -f $outfile_evt
    fi
    if [ -e $outfile_pi ] ; then
        rm -f $outfile_pi
    fi
    if [ -e $outfile_lc ] ; then
        rm -f $outfile_lc
    fi

fi



### Variables ###
tmpfile1='tmpfile1_mkNTEspec_rsl.tmp'



### log files and dirs ###
d_log=./logfiles_mkNTEspec_rsl
f_log=$d_log/mkNTEspec_rsl.log
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
echo "BASENAME (\$1) : $BASENAME" >> $f_log
echo "infile   (\$2) : $infile" >> $f_log
echo "" >> $f_log
echo "outfile_evt : $outfile_evt" >> $f_log
echo "outfile_lc  : $outfile_lc" >> $f_log
echo "outfile_pi  : $outfile_pi" >> $f_log
echo "END PARAMS" >> $f_log
echo "" >> $f_log



### Extract NTE events ###
echo "BEGIN Extract NTE events" >> $f_log
echo "CMD : ahscreen infile=$infile outfile=$outfile gtifile=$infile[GTIEHKNTE] expr=NONE selectfile=NONE label=PIXELALL mergegti=AND" >> $f_log
echo "" >> $f_log

ahscreen \
    infile="$infile" \
    outfile="$tmpfile1" \
    gtifile="$infile[GTIEHKNTE]" \
    expr=NONE \
    selectfile=NONE \
    label=PIXELALL \
    mergegti=AND \
    1>> $f_log 2>> $f_log

echo "" >> $f_log
echo "END Extract NTE events" >> $f_log
echo "" >> $f_log


# Edit header
fparkey fitsfile=${tmpfile1}+1 keyword=TLMIN46 value=0 


# Make cl2
ftcopy \
    infile="${tmpfile1}[EVENTS][(PI>=600)&&((RISE_TIME>=40&&RISE_TIME<=60&&ITYPE<4)||(ITYPE==4))&&STATUS[4]==b0]" \
    outfile="$outfile_evt" \
    copyall=yes clobber=yes history=yes



### Make spectra ###
echo "BEGIN XSELECT" >> $f_log
echo "CMD : xselect" >> $f_log
echo "" >> $f_log
xselect << EOT 1>> $f_log 2>> $f_log
xsel

! Setup
set mission XRISM

! Read events
read events
.
$outfile_evt

! Filter events
filter column "PIXEL=0:11,13:35"
filter GRADE "0:0"

! Make light curves
extract curve
save curve $outfile_lc

! Make PI files
extract spectrum
save spectrum $outfile_pi

! End of xselect
exit
yes
EOT

echo "" >> $f_log
echo "END XSELECT" >> $f_log
echo "" >> $f_log



# Move files
mv \
    ahscreen.log \
    xsel_ascii_out.xsl \
    xsel_display.def \
    xsel_files.tmp \
    xsel_fits_curve.xsl \
    xsel_hist.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_read_cat.xsl \
    xsel_session.xsl \
    xsel_xronos_out.xsl \
    xselect.log \
    $d_log/


# Zip eventfiles
gzip $outfile_evt

# Remove files
rm -f $tmpfile1



exit
