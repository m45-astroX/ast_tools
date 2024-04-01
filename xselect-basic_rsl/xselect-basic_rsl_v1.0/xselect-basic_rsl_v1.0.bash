#!/bin/bash

# xselect-basic_rsl

# 2024.02.06 Yuma Aoki (Kindai Univ.)



if [ $# -eq 2 ] ; then
    BASENAME=$1
    f_evt_fullpath=$2
    f_evt_dir=$(dirname $f_evt_fullpath)
    f_evt=$(basename $f_evt_fullpath)
else
    echo "Usage : BASENAME evtfile"
    exit
fi

# Variables
d_log='./xselect_log'
f_evt_clean2="${BASENAME}_clean2.evt"

# Charck log dir
if [ -d $d_log ] ; then
    rm -rf $d_log
fi
mkdir $d_log

# Create clean2 event
ftselect infile="${f_evt}[EVENTS]" outfile=${f_evt_clean2} expression="(PI>=400)&&((RISE_TIME>=40 && RISE_TIME<=60 && ITYPE<4)||(ITYPE==4))"

# XSELECT
xselect << EOT
xsel

! Setup
set mission XRISM

! Read events
read events
$f_evt_dir
$f_evt

! Filter by expr
filter column "PIXEL=0:11,13:35"
filter GRADE "0:0"

! Make spectrum
extract spectrum
save spectrum ${BASENAME}.pi

exit
yes
EOT

# Move files
mv \
    xsel_ascii_out.xsl \
    xsel_display.def \
    xsel_files.tmp \
    xsel_hist.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_read_cat.xsl \
    xsel_session.xsl \
    xselect.log \
    $d_log/


exit
