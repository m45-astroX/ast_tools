#!/bin/bash

# mkrslimg_SKY

# 2024.04.19 v1.0 by Yuma Aoki (Kindai Univ.)



VERSION=1.0

if [ $# -eq 2 ] ; then
    BASENAME=$1
    f_evtcl2_fullpath=$2
else
    echo ""
    echo "Usage : bash mkimg_SKY_v${VERSION}.bash BASENAME clean2evtfile (CLOBBER_OUTFILE)"
    echo "    BASENAME (\$1) : Stem name of outputfile"
    echo "    cleanevtfile (\$2) : A clean '2' event file of RESOLVE"
    echo "    CLOBBER_OUTFILE (\$3; optional) : Whether overwrite outfiles (Y or N)"
    echo ""
    exit
fi

# Variables
IMG_PHAMIN=4000
IMG_PHAMAX=20000

# Set file names and directory names
d_log='./logfiles_mkimg_SKY'
f_log="${d_log}/mkimg_SKY.log"
f_evtcl2_dir=$(dirname $f_evtcl2_fullpath)
f_evtcl2=$(basename $f_evtcl2_fullpath)
f_img="${BASENAME}_PHA${IMG_PHAMIN}-${IMG_PHAMAX}_SKY.img"

# Create log dir
if [ -d $d_log ] ; then
    rm -rf $d_log
fi
mkdir $d_log

# Create log file
echo "BEGIN INFO" >> $f_log
echo "date : $(date)" >> $f_log
echo "whoami : $(whoami)" >> $f_log
echo "pwd : $(pwd)" >> $f_log
echo "HEADAS : ${HEADAS}" >> $f_log
echo "CALDB : ${CALDB}" >> $f_log
echo "SCRIPT VERSION : ${VERSION}" >> $f_log
echo "\$0 : $0" >> $f_log
echo "\$1 : $1" >> $f_log
echo "\$2 : $2" >> $f_log
echo "\$f_evtcl2_dir : $f_evtcl2_dir" >> $f_log
echo "\$f_evtcl2 : $f_evtcl2" >> $f_log
echo "\$d_log : $d_log" >> $f_log
echo "\$f_log : $f_log" >> $f_log
echo "\$f_img : $f_img" >> $f_log
echo "CLOBBER_OUTFILE : $CLOBBER_OUTFILE" >> $f_log
echo "IMG_PHAMIN : $IMG_PHAMIN" >> $f_log
echo "IMG_PHAMAX : $IMG_PHAMAX" >> $f_log
echo "END INFO" >> $f_log
echo "" >> $f_log

# Check outfiles
if [ "$CLOBBER_OUTFILE" = 'Y' ] ; then

    if [ -e "$f_img" ] ; then rm -f $f_img ; fi

elif [ "$CLOBBER_OUTFILE" = 'N' ] ; then

    if [ -e "$f_img" ] ; then echo "\$f_img exists ($f_img)"; echo "abort"; exit; fi

fi

# Extract Broadband Images by SKY coordinate
echo "BEGIN XSELECT" >> $f_log
echo "CMD : xselect" >> $f_log
echo "" >> $f_log
xselect << EOT 1>> $f_log 2>> $f_log
xsel

! Setup
set mission XRISM

! Read events
read events
$f_evtcl2_dir
$f_evtcl2

! Make image
set image SKY
filter pha_cutoff $IMG_PHAMIN $IMG_PHAMAX
extract image
save image $f_img

! End of xselect
exit
yes
EOT

echo "" >> $f_log
echo "END XSELECT" >> $f_log
echo "" >> $f_log


# Move files
mv \
    xsel_ascii_out.xsl \
    xsel_display.def \
    xsel_files.tmp \
    xsel_image.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_read_cat.xsl \
    xsel_session.xsl \
    xselect.log \
    $d_log/


exit
