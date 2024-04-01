#!/bin/bash

# rmfArf-basic_xtd

# v1.0 by Yuma Aoki (Kindai Univ.)



# Variables for expmap
expmap_delta=20.0
expmap_numphi=1
expmap_energy=1.5

# Variables for xaarfgen
arf_numphoton=300000
arf_minphoton=1


if [ $# -eq 7 ] ; then
    BASENAME=$1
    f_evtcl=$2
    f_evtpi=$3
    f_ehk=$4
    f_bimg=$5
    f_fpix=$6
    f_reg=$7
else
    echo "Usage"
    echo "    \$1 BASENAME"
    echo "    \$2 evtfile (cleaned evt)"
    echo "    \$3 evtfile (pi)"
    echo "    \$4 ehkfile"
    echo "    \$5 badimage file (bimg)"
    echo "    \$6 flickering pixel file (fpix)"
    echo "    \$7 region file"
    echo ""
    echo "    Outfile"
    echo "      ... rmf file"
    echo "      ... exposure map file"
    exit
fi

# Scripts
script_radec2deg="$(cd $(dirname $0) && pwd)/RADEC2deg_v1.0.bash"

# log file
d_log="./rmfArf_log"
if [ -d $d_log ] ; then
    rm -rf $d_log
fi
mkdir $d_log


# rmf
xtdrmf \
    infile=$f_evtpi \
    outfile="${BASENAME}.rmf" \
    clobber=yes \
    mode=hl

# move log files
mv \
    xtdrmf.log \
    $d_log/


# expmap
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
    instmap=CALDB qefile=CALDB contamifile=CALDB \
    vigfile=CALDB obffile=CALDB fwfile=CALDB \
    gvfile=CALDB maskcalsrc=yes fwtype=OPEN \
    specmode=MONO specfile=spec.fits specform=FITS \
    energy=$expmap_energy evperchan=DEFAULT \
    abund=1 cols=0 covfac=1 \
    clobber=yes chatter=1 \
    logfile="make_expo.log"

# move log files
mv \
    make_expo.log \
    $d_log/

# arf
xaarfgen \
    xrtevtfile=raytrace_${BASENAME}_ptsrc_evt.fits \
    source_ra=$(bash $script_radec2deg RA $(cat $f_reg | awk 'NR==4{print}' | sed -e 's/,/\ /g; s/.*(//g; s/\".*//g' | awk '{print $1}')) \
    source_dec=$(bash $script_radec2deg DEC $(cat $f_reg | awk 'NR==4{print}' | sed -e 's/,/\ /g; s/.*(//g; s/\".*//g' | awk '{print $2}')) \
    telescop=XRISM \
    instrume=XTEND \
    emapfile="${BASENAME}.expo" \
    regmode=RADEC \
    regionfile=$f_reg \
    sourcetype=POINT \
    rmffile="${BASENAME}.rmf" \
    erange="0.4 13.0 0 0" \
    outfile="${BASENAME}.arf" \
    numphoton=$arf_numphoton minphoton=$arf_minphoton \
    teldeffile=CALDB qefile=CALDB contamifile=CALDB \
    onaxisffile=CALDB onaxiscfile=CALDB mirrorfile=CALDB \
    obstructfile=CALDB frontreffile=CALDB backreffile=CALDB \
    pcolreffile=CALDB scatterfile=CALDB \
    mode=h seed=7

# move log files
mv \
    xaarfgen.log \
    xaarfgen_region.lis \
    xaxmaarfgen.log \
    ${BASENAME}.arfregion0.reg \
    arfgencgrid.fits \
    arfgencgrid_full.fits \
    coordpnt.log \
    raytrace_${BASENAME}_ptsrc_evt.fits \
    $d_log/

exit
