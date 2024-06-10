#!/bin/bash

# rmfArf-basic_xtd

# v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.05.06 v2.0 by Yuma Aoki (Kindai Univ.)
#   - XRISMのデータ解析方法に修正


VERSION_SCRIPT='2.0'

# Variables for expmap
expmap_delta=20.0
expmap_numphi=1
expmap_energy=1.5

# Variables for xaarfgen
arf_numphoton=300000
arf_minphoton=10


if [ $# -eq 7 ] ; then
    BASENAME=$1
    f_evtcl=$2
    f_evtpi=$3
    f_ehk=$4
    f_bimg=$5
    f_fpix=$6
    f_reg=$7
else
    echo "Usage : bash rmfArf-basic_xtd_v${VERSION_SCRIPT}.bash"
    echo "    \$1 BASENAME"
    echo "    \$2 evtfile (cleaned evt)"
    echo "    \$3 evtfile (pi)"
    echo "    \$4 ehkfile"
    echo "    \$5 badimage file (bimg)"
    echo "    \$6 flickering pixel file (fpix)"
    echo "    \$7 region file (DET coordinate)"
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
echo "\$6 : ${f_fpix}" >> $log_master
echo "\$7 : ${f_reg}" >> $log_master
echo "END : PARAMS" >> $log_master


### RMF ###
punlearn xtdrmf
xtdrmf \
    infile=$f_evtpi \
    outfile="${BASENAME}.rmf" \
    rmfparam=CALDB \
    eminin=200 \
    dein="2,24" \
    nchanin="5900,500" \
    eminout=0 deout=6 nchanout=4096 \
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
    instrume=XTEND \
    badimgfile=$f_bimg \
    pixgtifile=$f_fpix \
    outfile="${BASENAME}.expo" \
    outmaptype=EXPOSURE \
    delta=$expmap_delta numphi=$expmap_numphi \
    stopsys=SKY \
    instmap=CALDB qefile=CALDB \
    contamifile=CALDB vigfile=CALDB obffile=CALDB \
    fwfile=CALDB gvfile=CALDB \
    maskcalsrc=yes \
    fwtype=FILE specmode=MONO \
    specfile=spec.fits specform=FITS \
    evperchan=DEFAULT \
    abund=1 cols=0 covfac=1 \
    clobber=yes chatter=1 \
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
## Read XDETX0 and XDETY0 from src region file
XDETX0=$(cat $f_reg | grep circle | sed 's/.*(//g; s/,/\ /g; s/).*//g' | awk '{print $1}')
XDETY0=$(cat $f_reg | grep circle | sed 's/.*(//g; s/,/\ /g; s/).*//g' | awk '{print $2}')
## DET -> SKY
punlearn coordpnt
xtdsrc_ra=$(coordpnt \
    input="${XDETX0},${XDETY0}" \
    outfile=NONE \
    telescop=XRISM instrume=XTEND \
    teldeffile=CALDB \
    startsys=DET stopsys=RADEC \
    ra=$RA_NOM dec=$DEC_NOM roll=$PA_NOM \
    ranom=$RA_NOM decnom=$DEC_NOM \
    clobber=yes | awk '{print $4}')
mv coordpnt.log coordpnt_xtdsrc_ra.log
mv coordpnt_xtdsrc_ra.log $d_log/

punlearn coordpnt
xtdsrc_dec=$(coordpnt \
    input="${XDETX0},${XDETY0}" \
    outfile=NONE \
    telescop=XRISM instrume=XTEND \
    teldeffile=CALDB \
    startsys=DET stopsys=RADEC \
    ra=$RA_NOM dec=$DEC_NOM roll=$PA_NOM \
    ranom=$RA_NOM decnom=$DEC_NOM \
    clobber=yes | awk '{print $5}')
mv coordpnt.log coordpnt_xtdsrc_dec.log
mv coordpnt_xtdsrc_dec.log $d_log/

echo "BEGIN : CALC-COORD" >> $log_master
echo "RA_NOM  : ${RA_NOM}" >> $log_master
echo "DEC_NOM : ${DEC_NOM}" >> $log_master
echo "PA_NOM  : ${PA_NOM}" >> $log_master
echo "XDETX0  : ${XDETX0}" >> $log_master
echo "XDETY0  : ${XDETY0}" >> $log_master
echo "xtdsrc_ra  : ${xtdsrc_ra}" >> $log_master
echo "xtdsrc_dec : ${xtdsrc_dec}" >> $log_master
echo "END : CALC-COORD" >> $log_master



### ARF ###
punlearn xaarfgen
xaarfgen \
    xrtevtfile="raytrace_${BASENAME}_ptsrc_evt.fits" \
    source_ra=$xtdsrc_ra source_dec=$xtdsrc_dec \
    telescop=XRISM instrume=XTEND \
    emapfile="${BASENAME}.expo" \
    regmode=DET \
    regionfile=$f_reg \
    sourcetype=POINT \
    rmffile="${BASENAME}.rmf" \
    erange="0.3 18.0 0 0" \
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
