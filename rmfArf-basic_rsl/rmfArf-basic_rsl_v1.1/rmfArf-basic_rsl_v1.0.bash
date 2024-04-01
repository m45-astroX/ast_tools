#!/bin/bash 

# rmfArf-basic_rsl

# 2024.02.07 v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.02.14 v1.1 by Yuma Aoki (Kindai Univ.)
#   rmfのオプション変更


if [ $# -eq 5 ] ; then
    BASENAME=$1
    f_evtcl=$2
    f_ehk=$3
    f_expgti=$4
    f_reg=$5
else
    echo "Usage"
    echo "    \$1 BASENAME"
    echo "    \$2 evtfile (cleaned evt)"
    echo "    \$3 ehkfile"
    echo "    \$4 exp gti file"
    echo "    \$5 region file (SXI region file; fk5)"
    echo ""
    echo "    Outfile"
    echo "      ... exposure map file"
    echo "      ... ancillary response function (ARF)"
    echo "      ... energy redistribution matrix file (RMF)"
    exit
fi



# Variables
expmap_delta=20.0
expmap_numphi=1
expmap_energy=1.5
arf_numphoton=300000
arf_minphoton=1

# Scripts
script_radec2deg="$(cd $(dirname $0) && pwd)/RADEC2deg_v1.0.bash"

# Directories
d_log="./rmfArf_log"
if [ -d $d_log ] ; then
    rm -rf $d_log
fi
mkdir $d_log



# Make rmf file
rslmkrmf \
    infile=${f_evtcl} \
    outfile=${BASENAME} \
    resolist=0 \
    regmode=SKY \
    regionfile=ALLPIX \
    whichrmf=x \
    rmfthresh='1.0e-6'

# Move files
mv \
    rslfrac.fits \
    rslmkrmf.log \
    rslrmf.log \
    $d_log/



# expmap
xaexpmap \
    ehkfile=${f_ehk} \
    gtifile=${f_evtcl} \
    instrume=RESOLVE \
    badimgfile=NONE \
    pixgtifile=${f_expgti} \
    outfile=${BASENAME}.expo \
    outmaptype=EXPOSURE \
    delta=${expmap_delta} numphi=${expmap_numphi} \
    stopsys=SKY \
    instmap=CALDB qefile=CALDB contamifile=CALDB \
    vigfile=CALDB obffile=CALDB fwfile=CALDB \
    gvfile=CALDB \
    maskcalsrc=yes \
    fwtype=OPEN \
    specmode=MONO \
    specfile=spec.fits \
    specform=FITS \
    energy=${expmap_energy} \
    evperchan=DEFAULT \
    abund=1 cols=0 covfac=1 \
    clobber=yes \
    chatter=1 \
    logfile="make_expo.log"

# Movefiles
mv \
    make_expo.log \
    $d_log/



# arf
xaarfgen \
    xrtevtfile=raytrace_${BASENAME}.fits \
    source_ra=$(bash $script_radec2deg RA $(cat $f_reg | awk 'NR==4{print}' | sed -e 's/,/\ /g; s/.*(//g; s/\".*//g' | awk '{print $1}')) \
    source_dec=$(bash $script_radec2deg DEC $(cat $f_reg | awk 'NR==4{print}' | sed -e 's/,/\ /g; s/.*(//g; s/\".*//g' | awk '{print $2}')) \
    telescop=XRISM \
    instrume=RESOLVE \
    emapfile=${BASENAME}.expo \
    regmode=RADEC \
    regionfile=$f_reg \
    sourcetype=POINT \
    rmffile=${BASENAME}.rmf \
    erange="0.4 13.0 0 0" \
    outfile=${BASENAME}.arf \
    numphoton=$arf_numphoton \
    minphoton=$arf_minphoton \
    teldeffile=CALDB \
    qefile=CALDB contamifile=CALDB obffile=CALDB \
    fwfile=CALDB gatevalvefile=CALDB onaxisffile=CALDB \
    onaxiscfile=CALDB mirrorfile=CALDB obstructfile=CALDB \
    frontreffile=CALDB backreffile=CALDB pcolreffile=CALDB \
    scatterfile=CALDB \
    mode=h clobber=yes seed=7

# Move files
mv \
    arfgencgrid.fits \
    arfgencgrid_full.fits \
    coordpnt.log \
    raytrace_${BASENAME}.fits \
    xaarfgen.log \
    xaarfgen_region.lis \
    xaxmaarfgen.log \
    ${BASENAME}.arfregion0.reg \
    $d_log/

exit
