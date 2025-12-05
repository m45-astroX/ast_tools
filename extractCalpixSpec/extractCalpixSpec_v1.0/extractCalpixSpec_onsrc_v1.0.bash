#!/bin/bash

# extractCalpixSpec_onsrc

# 2024.06.11 v1.0 by Yuma Aoki (Kindai Univ.)



SCRIPT_VERSION='1.0'

if [ $# -ne 2 ] ; then
    echo "Usage : bash extractCalpixSpec_onsrc_v${SCRIPT_VERSION}.bash BASENAME cleanevtfile"
    exit
else
    BASENAME=$1
    f_evt_fullpath=$2
fi



# Set file names and directory names
d_log='./logfiles_extractCalpixSpec_onsrc'
f_log="${d_log}/extractCalpixSpec_onsrc.log"
f_evt_dir=$(dirname $f_evt_fullpath)
f_evt=$(basename $f_evt_fullpath)
f_evt_clean2_dir="."
f_evt_clean2="${BASENAME}_calpix_cl2.evt"
f_pi="${BASENAME}_calpix_Hp_src.pi"

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
echo "" >> $f_log
echo "\$0 : $0" >> $f_log
echo "\$1 : $1" >> $f_log
echo "\$f_evt_dir : $f_evt_dir" >> $f_log
echo "\$f_evt : $f_evt" >> $f_log
echo "\$d_log : $d_log" >> $f_log
echo "\$f_log : $f_log" >> $f_log
echo "\$f_evt_clean2_dir : $f_evt_clean2_dir" >> $f_log
echo "\$f_evt_clean2 : $f_evt_clean2" >> $f_log
echo "\$f_pi : $f_pi" >> $f_log
echo "END INFO" >> $f_log
echo "" >> $f_log


# Create clean2 event
echo "" >> $f_log
echo "CMD : ftcopy infile=${f_evt_fullpath}[EVENTS][(PI>=600)&&((RISE_TIME>=40&&RISE_TIME<=60&&ITYPE<4)||(ITYPE==4))&&STATUS[4]==b0] outfile=${f_evt_clean2} copyall=yes clobber=yes history=yes" >> $f_log
echo "" >> $f_log
ftcopy \
    infile="${f_evt_fullpath}[EVENTS][(PI>=600)&&((RISE_TIME>=40&&RISE_TIME<=60&&ITYPE<4)||(ITYPE==4))&&STATUS[4]==b0]" \
    outfile="${f_evt_clean2}" \
    copyall=yes clobber=yes history=yes


# Extract Broadband Images and Establish Source Center Coordinates
echo "BEGIN XSELECT" >> $f_log
echo "CMD : xselect" >> $f_log
echo "" >> $f_log
xselect << EOT 1>> $f_log 2>> $f_log
xsel

! Setup
set mission XRISM

! Read events
read events
$f_evt_clean2_dir
$f_evt_clean2

! Make PI files
filter column "PIXEL=12:12"
filter GRADE "0:0"
extract spectrum
save spectrum $f_pi

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
    xsel_hist.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_read_cat.xsl \
    xsel_session.xsl \
    xsel_fits_curve.xsl \
    xsel_image.xsl \
    xsel_xronos_out.xsl \
    xselect.log \
    $d_log/


exit
