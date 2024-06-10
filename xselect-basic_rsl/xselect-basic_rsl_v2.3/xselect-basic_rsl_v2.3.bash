#!/bin/bash

# xselect-basic_rsl

# 2024.02.06 v1.0 Yuma Aoki (Kindai Univ.)
# 2024.04.01 v2.0 Yuma Aoki (Kindai Univ.)
#   - ASTRO-Hの解析方法からXRISMの方法に変更
# 2024.04.19 v2.1 Yuma Aoki (Kindai Univ.)
#   - 引数の説明等を修正
# 2024.04.19 v2.2 Yuma Aoki (Kindai Univ.)
#   - イメージ出力後にclear pha_cutoffを実施する仕様に変更
# 2024.04.19 v2.3 Yuma Aoki (Kindai Univ.)
#   - xselsectにcleanを読み込ませていた。clean2が読み込まれるように修正



VERSION=2.3

if [ $# -eq 2 ] ; then
    BASENAME=$1
    f_evt_fullpath=$2
    CLOBBER_OUTFILE='N'
elif [ $# -eq 3 ] ; then
    BASENAME=$1
    f_evt_fullpath=$2

    if [ "$3" = 'YES' ] || [ "$3" = 'yes' ] || [ "$3" = 'Y' ] || [ "$3" = 'y' ] ; then
        CLOBBER_OUTFILE='Y'
    elif [ "$3" = 'NO' ] || [ "$3" = 'no' ] || [ "$3" = 'N' ] || [ "$3" = 'n' ] ; then
        CLOBBER_OUTFILE='N'
    else
        echo "*** ERROR"
        echo "\$3 must be 'Y' or 'N'!"
        echo "abort"
        exit
    fi
    
else
    echo ""
    echo "Usage : bash xselect-basic_rsl_v${VERSION}.bash"
    echo "    \$1 : BASENAME ; Stem name of outputfile"
    echo "    \$2 : cleanevtfile ; A clean event file of RESOLVE"
    echo "    \$3 : CLOBBER_OUTFILE ; Whether overwrite outfiles (Y or N)"
    echo ""
    exit
fi

# Variables
IMG_PHAMIN=4000
IMG_PHAMAX=20000
LC_EXPOSURE=0.8
LC_BINSIZ=128.0

# Set file names and directory names
d_log='./logfiles_xselect-basic_rsl'
f_log="${d_log}/xselect-basic_rsl.log"
f_evt_dir=$(dirname $f_evt_fullpath)
f_evt=$(basename $f_evt_fullpath)
f_evt_clean2_dir="."
f_evt_clean2="${BASENAME}_cl2.evt"
f_img="${BASENAME}_PHA${IMG_PHAMIN}-${IMG_PHAMAX}_DET.img"
f_lc="${BASENAME}_lc.fits"
f_pi="${BASENAME}_Hp_src.pi"

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
echo "\$f_evt_dir : $f_evt_dir" >> $f_log
echo "\$f_evt : $f_evt" >> $f_log
echo "\$d_log : $d_log" >> $f_log
echo "\$f_log : $f_log" >> $f_log
echo "\$f_evt_clean2_dir : $f_evt_clean2_dir" >> $f_log
echo "\$f_evt_clean2 : $f_evt_clean2" >> $f_log
echo "\$f_img : $f_img" >> $f_log
echo "\$f_lc : $f_lc" >> $f_log
echo "\$f_pi : $f_pi" >> $f_log
echo "CLOBBER_OUTFILE : $CLOBBER_OUTFILE" >> $f_log
echo "IMG_PHAMIN : $IMG_PHAMIN" >> $f_log
echo "IMG_PHAMAX : $IMG_PHAMAX" >> $f_log
echo "LC_EXPOSURE : $LC_EXPOSURE" >> $f_log
echo "LC_BINSIZ : $LC_BINSIZ" >> $f_log
echo "END INFO" >> $f_log
echo "" >> $f_log

# Check outfiles
if [ "$CLOBBER_OUTFILE" = 'Y' ] ; then

    if [ -e "$f_evt_clean2" ] ; then rm -f $f_evt_clean2 ; fi
    if [ -e "$f_img" ] ; then rm -f $f_img ; fi
    if [ -e "$f_lc" ] ; then rm -f $f_lc ; fi
    if [ -e "$f_pi" ] ; then rm -f $f_pi ; fi

elif [ "$CLOBBER_OUTFILE" = 'N' ] ; then

    if [ -e "$f_evt_clean2" ] ; then echo "\$f_evt_clean2 exists ($f_evt_clean2)"; echo "abort"; exit; fi
    if [ -e "$f_img" ] ; then echo "\$f_img exists ($f_img)"; echo "abort"; exit; fi
    if [ -e "$f_lc" ] ; then echo "\$f_lc exists ($f_lc)"; echo "abort"; exit; fi
    if [ -e "$f_pi" ] ; then echo "\$f_pi exists ($f_pi)"; echo "abort"; exit; fi

fi


# Create clean2 event
echo "" >> $f_log
echo "CMD : ftcopy infile=\"${f_evt_fullpath}[EVENTS][(PI>=600)&&((RISE_TIME>=40&&RISE_TIME<=60&&ITYPE<4)||(ITYPE==4))&&STATUS[4]==b0]\" outfile=${BASENAME}_cl2.evt copyall=yes clobber=yes history=yes" >> $f_log
echo "" >> $f_log
ftcopy \
    infile="${f_evt_fullpath}[EVENTS][(PI>=600)&&((RISE_TIME>=40&&RISE_TIME<=60&&ITYPE<4)||(ITYPE==4))&&STATUS[4]==b0]" \
    outfile="${f_evt_clean2_dir}/${f_evt_clean2}" \
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

! Make image
set image DET
filter pha_cutoff $IMG_PHAMIN $IMG_PHAMAX
extract image
save image $f_img

! Clear filter
clear pha_cutoff

! Make light curves
set binsize $LC_BINSIZ
extract curve exposure=${LC_EXPOSURE}
save curve $f_lc

! Make PI files
filter column "PIXEL=0:11,13:35"
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
