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
    outfile_pi="${BASENAME}_nte.pi"
    outfile_lc="${BASENAME}_nte.lc"

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



### Extract NTE events ###
echo "" >> $f_log
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
