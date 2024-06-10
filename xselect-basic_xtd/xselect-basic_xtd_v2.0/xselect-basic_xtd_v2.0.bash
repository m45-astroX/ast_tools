#!/bin/bash

# xselect-basic_xtd

# v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.05.06 v1.0.2 by Yuma Aoki (Kindai Univ.)
#   - logファイルのディレクトリ名を変更
# 2024.05.06 v2.0 by Yuma Aoki (Kindai Univ.)
#   - XRISMのデータ解析用に改修


VERSION_SCRIPT='2.0'

if [ "$1" = '1' ] && ( [ $# -eq 3 ] || [ $# -eq 4 ] ) ; then
    
    if [ $# -eq 3 ] ; then
        PHASE=$1
        BASENAME=$2
        d_evt=$3
        d_hk=$3
        d_log='./logfiles_xselect-basic_xtd_phase1'
        f_log="${d_log}/logfile_master_xselect-basic_xtd_phase1.log"
    elif [ $# -eq 4 ] ; then
        PHASE=$1
        BASENAME=$2
        d_evt=$3
        d_hk=$4
        d_log='./logfiles_xselect-basic_xtd_phase1'
        f_log="${d_log}/logfile_master_xselect-basic_xtd_phase1.log"
    fi
    
elif [ "$1" = '2' ] && [ $# -eq 4 ] ; then
    PHASE=$1
    BASENAME=$2
    f_evt=$3
    f_reg=$4
    d_log='./logfiles_xselect-basic_xtd_phase2'
    f_log="${d_log}/logfile_master_xselect-basic_xtd_phase2.log"
else
    echo "Usage : bash xselect-basic_xtd_v${VERSION_SCRIPT}.bash"
    echo "    phase 1 : make raw events and raw images"
    echo "               \$1 phase --> 1"
    echo "               \$2 basename"
    echo "               \$3 eventdir"
    echo "               \$4 ehkdir (optional)"
    echo "    phase 2 : make spectrum and light curve"
    echo "               \$1 phase --> 2"
    echo "               \$2 basename"
    echo "               \$3 eventfile"
    echo "               \$4 regionfile (DET coordinate)"
    exit
fi



function phase1 () {

# Variables
files_evt=()
file_hk=''
BASENAME_=$1
d_evt_=$2
d_hk_=$3
d_log_=$4
f_reg_exclude_calsrc_=$5

# Read event files
for file in $(/bin/ls $d_evt_) ; do
    
    if [ "$(echo $file | sed -e 's/\.gz$//g; s/.*\.//g')" != 'evt' ] ; then
        continue
    fi
    
    files_evt=( ${files_evt[@]} $file )

done

# Read hk file
file_hk=$(/bin/ls $d_hk_ | grep "ehk")

# Check files
if [ "$files_evt" = '' ] || [ "$file_hk" = '' ] ; then
    echo "Error occured while reading files!"
    echo "    \$files_evt : $files_evt"
    echo "    \$file_hk   : $file_hk"
    echo "abort"
    exit
fi

# Check log dir
if [ -d $d_log_ ] ; then
    rm -rf $d_log_
fi
mkdir $d_log_


# Make the calsource filter regfile
f_reg_exclude_calsrc='exclude_calsources.reg'
if [ -e $f_reg_exclude_calsrc ] ; then
    rm -f $f_reg_exclude_calsrc
fi
printf "physical\n\
-circle(920.0,1530.0,92.0)\n\
-circle(919.0,271.0,91.0)\n" > $f_reg_exclude_calsrc


### XSELECT ###
echo "BEGIN : XSELECT" >> $f_log
echo "" >> $f_log

xselect << EOT 1>> $f_log 2>> $f_log
xsel

! Setup
set mission XRISM

! Read event files
read events
${d_evt_}
${files_evt[@]}

! Read hk files
read hk
${d_hk_}
${file_hk}
yes

! Change coordinate
set image DET

! Filter by hk
select hk MZDYE_ELV>MZNTE_ELV||MZDYE_ELV>20

! filter by srcreg
filter region ${f_reg_exclude_calsrc}

! Extract events
extract events
save events ${BASENAME_}.evt
yes

! Filter by PHA
filter pha_cutoff 83 1667

! Make image
extract image
save image ${BASENAME_}_DET.img

exit
yes

EOT

echo "" >> $f_log
echo "END : XSELECT" >> $f_log


### Compress files ###
gzip "${BASENAME_}.evt"

### Move log files ###
mv \
    xsel_ascii_out.xsl \
    xsel_display.def \
    xsel_files.tmp \
    xsel_fits_in.xsl \
    xsel_hksel_out.xsl \
    xsel_image.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_out_event.xsl \
    xsel_read_cat.xsl \
    xsel_session.xsl \
    xsel_timefile.asc \
    xsel_region.xsl \
    xselect.log \
    $f_reg_exclude_calsrc \
    $d_log_/

}



function phase2 () {

# Variables
BASENAME_=$1
f_evt_=$2
f_reg_=$3
d_log_=$4

# Check log dir
if [ -d $d_log_ ] ; then
    rm -rf $d_log_
fi
mkdir $d_log_


### XSELECT ###
echo "BEGIN : XSELECT" >> $f_log
echo "" >> $f_log

xselect << EOT 1>> $f_log 2>> $f_log
xsel

! Setup
set mission XRISM

! Read event files
read events
$(dirname $f_evt_)
$(basename $f_evt_)

! Change coordinate
set image DET

! Filter by regfile
filter region $f_reg_

! Make spectrum
extract spectrum
save spectrum ${BASENAME_}.pi

! Make curve
extract curve exposure=0.0
save curve ${BASENAME_}.lc

exit
yes

EOT

echo "" >> $f_log
echo "END : XSELECT" >> $f_log


mv \
    xsel_ascii_out.xsl \
    xsel_display.def \
    xsel_files.tmp \
    xsel_fits_curve.xsl \
    xsel_hist.xsl \
    xsel_obscat.tmp \
    xsel_obslist.def \
    xsel_read_cat.xsl \
    xsel_region.xsl \
    xsel_session.xsl \
    xsel_xronos_out.xsl \
    xselect.log \
    $d_log_/

}



if [ "$PHASE" = '1' ] ; then
    phase1 $BASENAME $d_evt $d_hk $d_log
elif [ "$PHASE" = '2' ] ; then
    phase2 $BASENAME $f_evt $f_reg $d_log
fi


exit
