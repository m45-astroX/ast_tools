#!/bin/bash

# rmfArf-basic_xtd

# v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.05.06 v2.0 by Yuma Aoki (Kindai Univ.)
#   - XRISMのデータ解析方法に修正
# 2025.10.14 v3.0 by Yuma Aoki (Kindai Univ.)
#   - XRISM ABC Guideの解析方法に修正


VERSION_SCRIPT='2.0'

# Variables for expmap
expmap_delta=20.0
expmap_numphi=1
expmap_energy=1.5

# Variables for xaarfgen
arf_numphoton=600000
arf_minphoton=100


if [ $# -eq 7 ] ; then
    BASENAME=$1
    f_evtcl=$2
    f_evtpi=$3
    f_ehk=$4
    f_bimg=$5
    f_reg=$6
    flatradius=$7
else
    echo "Usage : bash rmfArf-basic_xtd_v${VERSION_SCRIPT}.bash"
    echo "    \$1 BASENAME"
    echo "    \$2 evtfile (cleaned evt)"
    echo "    \$3 evtfile (pi)"
    echo "    \$4 ehkfile"
    echo "    \$5 badimage file (bimg)"
    echo "    \$6 region file (SKY coordinate)"
    echo "    \$7 flat circle (arcmin)"
    echo ""
    echo "    Outfile"
    echo "      ... Exposure map file"
    echo "      ... RMF"
    echo "      ... ARF"
    exit
fi

### log file ###
d_log="./logfiles_rmfArf-basic_xtd"
if [ -d $d_log ] ; then
    rm -rf $d_log
fi
mkdir $d_log

### Make master log file ###
log_master="${d_log}/log_master_rmfArf-basic_xtd.log"
echo "BEGIN : PARAMS" >> $log_master
echo "pwd : $(pwd)" >> $log_master
echo "VERSION_SCRIPT : ${VERSION_SCRIPT}" >> $log_master
echo "\$0 : $0" >> $log_master
echo "\$1 : ${BASENAME}" >> $log_master
echo "\$2 : ${f_evtcl}" >> $log_master
echo "\$3 : ${f_evtpi}" >> $log_master
echo "\$4 : ${f_ehk}" >> $log_master
echo "\$5 : ${f_bimg}" >> $log_master
echo "\$6 : ${f_reg}" >> $log_master
echo "END : PARAMS" >> $log_master


### RMF ###
punlearn xtdrmf
xtdrmf \
    infile=$f_evtpi \
    outfile="${BASENAME}.rmf" \
    1>> $log_master 2>> $log_master

# move log files
mv \
    xtdrmf.log \
    $d_log/



### Exposure map ###
punlearn xaexpmap
xaexpmap \
    ehkfile=$f_ehk \
    gtifile=$f_evtcl \
    pixgtifile=NONE \
    instrume=XTEND \
    badimgfile=$f_bimg \
    outfile="${BASENAME}.expo" \
    outmaptype=EXPOSURE \
    delta=$expmap_delta numphi=$expmap_numphi \
    logfile="make_expo.log" \
    1>> $log_master 2>> $log_master

# move log files
mv \
    make_expo.log \
    $d_log/



### Check Coordinates ###
## Read RA_NOM, DEC_NOM and PA_NOM from evtfile
RA_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=RA_NOM outfil=STDOUT exact=no | awk 'NR==6 {print $3}')
DEC_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=DEC_NOM outfil=STDOUT exact=no | awk 'NR==6 {print $3}')
PA_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=PA_NOM outfil=STDOUT exact=no | awk 'NR==6 {print $3}')

echo "BEGIN : CALC-COORD" >> $log_master
echo "RA_NOM  : ${RA_NOM}" >> $log_master
echo "DEC_NOM : ${DEC_NOM}" >> $log_master
echo "PA_NOM  : ${PA_NOM}" >> $log_master
echo "END : CALC-COORD" >> $log_master

### ARF ###
punlearn xaarfgen
xaarfgen \
    xrtevtfile="raytrace_${BASENAME}_ptsrc_evt.fits" \
    source_ra=$RA_NOM source_dec=$DEC_NOM \
    telescop=XRISM instrume=XTEND \
    emapfile="${BASENAME}.expo" \
    regmode=RADEC \
    regionfile=$f_reg \
    sourcetype=FLATCIRCLE flatradius=$flatradius \
    rmffile="${BASENAME}.rmf" \
    erange="0.3 15.0 0 0" \
    outfile="${BASENAME}_ptsrc.arf" \
    numphoton=$arf_numphoton minphoton=$arf_minphoton \
    teldeffile=CALDB qefile=CALDB contamifile=CALDB obffile=CALDB fwfile=CALDB \
    onaxisffile=CALDB onaxiscfile=CALDB mirrorfile=CALDB obstructfile=CALDB \
    frontreffile=CALDB backreffile=CALDB pcolreffile=CALDB scatterfile=CALDB \
    mode=h clobber=yes seed=7 \
    imgfile=NONE \
    1>> $log_master 2>> $log_master

# move log files
mv \
    arfgencgrid.fits \
    arfgencgrid_full.fits \
    coordpnt.log \
    xaarfgen.log \
    xaarfgen_region.lis \
    xaxmaarfgen.log \
    raytrace_${BASENAME}_ptsrc_evt.fits \
    $d_log/


### Compress files ###
gzip "${BASENAME}.rmf"
gzip "${BASENAME}.expo"

exit
