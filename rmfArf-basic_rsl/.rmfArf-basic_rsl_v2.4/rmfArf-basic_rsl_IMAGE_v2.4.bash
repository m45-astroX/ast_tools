#!/bin/bash 

# rmfArf-basic_rsl_IMAGE

# 2024.02.07 v1.0 by Yuma Aoki (Kindai Univ.)
# 2024.02.14 v1.1 by Yuma Aoki (Kindai Univ.)
#   rmfのオプション変更
# 2024.04.11 v2.0 by Yuma Aoki (Kindai Univ.)
#   XRISM用のデータ解析方法に修正
#   本スクリプトのlogファイルを残す仕様に変更
# 2024.04.19 v2.1 by Yuma Aoki (Kindai Univ.)
#   region fileを指定する仕様に変更
# 2024.04.19 v2.2 by Yuma Aoki (Kindai Univ.)
#   Defaultのregion fileのパスを間違えていたため変更
# 2024.04.19 v2.3 by Yuma Aoki (Kindai Univ.)
#   FLATCIRCLEのARF作成に対応できるよう修正
#   whichrmfのデフォルト値を'X'から'L'に変更
# 2024.06.10 v3.0 by Yuma Aoki (Kindai Univ.)
#   source type : Point, Flat, Imageでスクリプトを分離



VERSION=3.0


### Variables ###
rmf_whichrmf='L'    # S, M, L or X
expmap_delta=20.0
expmap_numphi=1
arf_minphoton=100
arf_numphoton=100000
arf_minenergy=0.3
arf_maxenergy=18.0
d_bin=$(cd $(dirname $0) && pwd)


### Arguments ###
if [ $# -eq 9 ] || [ $# -eq 11 ] ; then

    BASENAME=$1
    f_evtcl=$2
    f_ehk=$3
    f_expgti=$4
    f_region_read=$5
    f_image=$6
    arf_img_minenergy=$7
    arf_img_maxenergy=$8
    center_calc_method=$9

    # Check $center_calc_method
    if [ "$center_calc_method" = "MANUAL" ] && [ $# -ne 11 ] ; then
        echo "\$10 and \$11 are required when \$9 is set to 'MANUAL'."
        echo "abort"
        exit
    elif [ "$center_calc_method" = "MANUAL" ] && [ $# -eq 11 ] ; then
        rslsrc_ra_read=$10
        rslsrc_dec_read=$11
    fi

    # Set region file
    if [ "$f_region_read" = 'DEFAULT' ] ; then
        f_region="$HEADAS/refdata/region_RSL_det.reg"
    else
        f_region=$f_region_read
    fi

    ## Check files ##
    # Event file
    fitsinfo $f_evtcl >& /dev/null; status=$?
    if [ ! -e $f_evtcl ] ; then
        echo "*** Error"
        echo "evtfile does not exist!"
        echo "file : $f_evtcl"
        echo "abort"
        exit
    elif [ "$status" -ne 0 ] ; then
        echo "*** Error"
        echo "FITS file open error!"
        echo "file   : $f_evtcl"
        echo "status : $status"
        echo "abort"
        exit
    fi
    # EHK file
    fitsinfo $f_ehk >& /dev/null; status=$?
    if [ ! -e $f_ehk ] ; then
        echo "*** Error"
        echo "ehkfile does not exist!"
        echo "file : $f_ehk"
        echo "abort"
        exit
    elif [ "$status" -ne 0 ] ; then
        echo "*** Error"
        echo "FITS file open error!"
        echo "file   : $f_ehk"
        echo "status : $status"
        echo "abort"
        exit
    fi
    # EXP GTI file
    fitsinfo $f_expgti >& /dev/null; status=$? 
    if [ ! -e $f_expgti ] ; then
        echo "*** Error"
        echo "expgtifile does not exist!"
        echo "file   : $f_expgti"
        echo "abort"
        exit
    elif [ "$status" -ne 0 ] ; then
        echo "*** Error"
        echo "FITS file open error!"
        echo "file   : $f_expgti"
        echo "status : $status"
        echo "abort"
        exit
    fi

else
    echo ""
    echo "Usage : bash rmfArf-basic_rsl_v${VERSION}.bash"
    echo "    \$1 BASENAME"
    echo "    \$2 evtfile (clean2 event file)"
    echo "    \$3 ehkfile"
    echo "    \$4 exp gti file"
    echo "    \$5 region file (SAO formatted regfile with DET coordinate)"
    echo "          If this parameter is set to 'DEFAULT',"
    echo "            \$HEADAS/refdata/region_RSL_det.reg will be used."
    echo "    \$6 image file"
    echo "    \$7 The lower energy of image file"
    echo "    \$8 The upper energy of image file"
    echo "    \$9 Center calculation method (DEFAULT, NOMINAL, SCRIPT or MANUAL)"
    echo "    \$10 source_ra  (This argument is required when \$9 is set to 'MANUAL'.)"
    echo "    \$11 source_dec (This argument is required when \$9 is set to 'MANUAL'.)"
    echo ""
    echo "    Outfile"
    echo "      ... Exposure map file"
    echo "      ... Energy Redistribution Matrix File (RMF)"
    echo "      ... Ancillary Response Function file (ARF)"
    echo ""
    exit
fi


### Scripts ###
calcCenter_VERSION=1.2
calcCenter4rsl="${d_bin}/calcCenter4rsl_v${calcCenter_VERSION}/calcCenter4rsl"


### Directories ###
d_log="./logfiles_rmfArf-basic_rsl"
f_log="${d_log}/rmfArf-basic_rsl.log"
if [ -e $d_log ] ; then
    rm -rf $d_log
else
    mkdir $d_log
fi


### Make ###
if [ -e $calcCenter4rsl ] ; then
    make clean -C ${d_bin}/calcCenter4rsl_v${calcCenter_VERSION} 1>> $f_log 2>> $f_log
fi
make -C ${d_bin}/calcCenter4rsl_v${calcCenter_VERSION} 1>> $f_log 2>> $f_log
status=$?; if [ $status != 0 ] ; then echo "make error (status = $status)"; echo "abort."; exit; fi


### Print information and params ###
echo "BEGIN INFO" >> $f_log
echo "VERSION : ${VERSION}" >> $f_log
echo "pwd     : $(pwd)" >> $f_log
echo "\$0     : $0" >> $f_log
echo "d_bin   : ${d_bin}" >> $f_log
echo "d_log   : ${d_log}" >> $f_log
echo "f_log   : ${f_log}" >> $f_log
echo "calcCenter_VERSION : ${calcCenter_VERSION}" >> $f_log
echo "calcCenter4rsl     : ${calcCenter4rsl}" >> $f_log
echo "END INFO" >> $f_log
echo "" >> $f_log

echo "BEGIN PARAMS" >> $f_log
echo "BASENAME (\$1) : ${BASENAME}" >> $f_log
echo "f_evtcl  (\$2) : ${f_evtcl}" >> $f_log
echo "f_ehk    (\$3) : ${f_ehk}" >> $f_log
echo "f_expgti (\$4) : ${f_expgti}" >> $f_log
echo "f_region (\$5) : ${f_region}" >> $f_log
echo "f_image  (\$6) : ${f_image}" >> $f_log
echo "the lower energy of image file (\$7) : ${arf_img_minenergy}" >> $f_log
echo "the upper energy of image file (\$8) : ${arf_img_maxenergy}" >> $f_log
echo "center_calc_method (\$9) = ${center_calc_method}" >> $f_log
echo "source_ra  (\$10) : ${rslsrc_ra_read}" >> $f_log
echo "source_dec (\$11) : $$rslsrc_dec_read}" >> $f_log
echo "END PARAMS" >> $f_log
echo "" >> $f_log

echo "BEGIN VARIABLES" >> $f_log
echo "rmf_whichrmf  : ${rmf_whichrmf}" >> $f_log
echo "expmap_delta  : ${expmap_delta}" >> $f_log
echo "expmap_numphi : ${expmap_numphi}" >> $f_log
echo "arf_numphoton : ${arf_numphoton}" >> $f_log
echo "arf_minphoton : ${arf_minphoton}" >> $f_log
echo "arf_minenergy : ${arf_minenergy}" >> $f_log
echo "arf_maxenergy : ${arf_maxenergy}" >> $f_log
echo "arf_img_minenergy : ${arf_img_minenergy}" >> $f_log
echo "arf_img_maxenergy = ${arf_img_maxenergy}" >> $f_log
echo "END VARIABLES" >> $f_log
echo "" >> $f_log


### Read nominal values of RA, DEC and PA
echo "" >> $f_log
echo "BEGIN READ NOMINAL ATTITUDE" >> $f_log
echo "CMD : fkeyprint infile=${f_evtcl}+0 keynam=RA_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print \$1}'" >> $f_log
RA_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=RA_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print $1}')
echo "CMD : fkeyprint infile=${f_evtcl}+0 keynam=DEC_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print \$1}'" >> $f_log
DEC_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=DEC_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print $1}')
echo "CMD : fkeyprint infile=${f_evtcl}+0 keynam=PA_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print \$1}'" >> $f_log
PA_NOM=$(fkeyprint infile=${f_evtcl}+0 keynam=PA_NOM | awk 'NR==6{print}' | cut -c 10- | awk '{print $1}')
echo "Result : RA_NOM=${RA_NOM}, DEC_NOM=${DEC_NOM}, PA_NOM=${PA_NOM}" >> $f_log
echo "END READ NOMINAL ATTITUDE" >> $f_log
echo "" >> $f_log


### Calculate center ###
echo "BEGIN CALCULATE CENTER" >> $f_log
echo "Method : ${center_calc_method}" >> $f_log

## DET coordinate ##
if [ "$center_calc_method" = "DEFAULT" ] || [ "$center_calc_method" = "default" ] || [ "$center_calc_method" = "D" ] || [ "$center_calc_method" = "d" ] ; then
    RDETX0=3.5
    RDETY0=3.5
elif [ "$center_calc_method" = "SCRIPT" ] || [ "$center_calc_method" = "script" ] || [ "$center_calc_method" = "S" ] || [ "$center_calc_method" = "s" ] ; then
    RDETX0=$($calcCenter4rsl $f_evtcl COG INNER16 | awk 'NR==1{print $3}')
    RDETY0=$($calcCenter4rsl $f_evtcl COG INNER16 | awk 'NR==2{print $3}')
    echo "CMD : $calcCenter4rsl $f_evtcl COG INNER16 | awk 'NR==1{print \$3}'" >> $f_log
    echo "CMD : $calcCenter4rsl $f_evtcl COG INNER16 | awk 'NR==1{print \$3}'" >> $f_log
else
    echo "Center calculation method(\$5) bust be DEFAULT, NOMINAL, SCRIPT or MANUAL."
    echo "abort."
    exit
fi

## RADEC coordinate ##
if [ "$center_calc_method" = "NOMINAL" ] || [ "$center_calc_method" = "nominal" ] || [ "$center_calc_method" = "N" ] || [ "$center_calc_method" = "n" ]; then

    rslsrc_ra=$RA_NOM
    rslsrc_dec=$DEC_NOM

elif [ "$center_calc_method" = "MANUAL" ] || [ "$center_calc_method" = "manual" ] || [ "$center_calc_method" = "M" ] || [ "$center_calc_method" = "m" ] ; then

    rslsrc_ra=$rslsrc_ra_read
    rslsrc_dec=$rslsrc_dec_read

else

    # source RA
    echo "CMD : punlearn coordpnt" >> $f_log
    punlearn coordpnt
    echo "CALCULATE RA" >> $f_log
    rslsrc_ra=$(coordpnt \
        input="$RDETX0, $RDETY0" \
        outfile=NONE \
        telescop=XRISM \
        instrume=RESOLVE \
        teldeffile=CALDB \
        startsys=DET stopsys=RADEC \
        ra=$RA_NOM dec=$DEC_NOM roll=$PA_NOM \
        ranom=$RA_NOM decnom=$DEC_NOM \
        clobber=yes | awk '{print $4}')
    mv coordpnt.log coordpnt_rslsrc_ra.log

    # source DEC
    echo "CMD : punlearn coordpnt" >> $f_log
    punlearn coordpnt
    echo "CALCULATE DEC" >> $f_log
    rslsrc_dec=$(coordpnt \
        input="$RDETX0, $RDETY0" \
        outfile=NONE \
        telescop=XRISM \
        instrume=RESOLVE \
        teldeffile=CALDB \
        startsys=DET stopsys=RADEC \
        ra=$RA_NOM dec=$DEC_NOM roll=$PA_NOM \
        ranom=$RA_NOM decnom=$DEC_NOM \
        clobber=yes | awk '{print $5}')
    mv coordpnt.log coordpnt_rslsrc_dec.log

fi

## Print result ##
echo "" >> $f_log
echo "Result : RDETX0=${RDETX0}, RDETY0=${RDETY0}" >> $f_log
echo "Result : rslsrc_ra=$rslsrc_ra, rslsrc_dec=$rslsrc_dec" >> $f_log
echo "END CALCULATE CENTER" >> $f_log
echo "" >> $f_log


### Make RMF ###
echo "BEGIN MAKE RMF" >> $f_log
echo "CMD : punlearn rslmkrmf" >> $f_log
punlearn rslmkrmf
echo "CMD : rslmkrmf" >> $f_log
echo "" >> $f_log
rslmkrmf \
    infile=${f_evtcl} \
    outfileroot=${BASENAME} \
    regmode=DET \
    whichrmf=${rmf_whichrmf} \
    resolist=0 \
    regionfile=ALLPIX \
    eminin=0.0 dein=0.5 nchanin=60000 \
    useingrd=no \
    eminout=0.0 deout=0.5 nchanout=60000 \
    1>> $f_log 2>> $f_log

echo "END MAKE RMF" >> $f_log
echo "" >> $f_log



### Make an exposure map ###
echo "BEGIN MAKE EXPMAP" >> $f_log
echo "CMD : punlearn xaexpmap" >> $f_log
punlearn xaexpmap
echo "CMD : xaexpmap" >> $f_log
echo "" >> $f_log
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
    fwtype=FILE \
    specmode=MONO specfile=spec.fits specform=FITS \
    evperchan=DEFAULT \
    abund=1 cols=0 covfac=1 \
    clobber=yes chatter=1 \
    logfile=make_expo.log \
    1>> $f_log 2>> $f_log

echo "END MAKE EXPMAP" >> $f_log
echo "" >> $f_log



### Make ARF ###
echo "BEGIN MAKE ARF" >> $f_log

echo "CMD : punlearn xaarfgen" >> $f_log
punlearn xaarfgen

echo "CMD : xaarfgen xrtevtfile=raytrace_${BASENAME}.fits source_ra=$rslsrc_ra source_dec=$rslsrc_dec telescop=XRISM instrume=RESOLVE emapfile=${BASENAME}.expo regmode=DET regionfile=$f_region sourcetype=IMAGE flatradius=3.0 rmffile=${BASENAME}.rmf erange="0.3 18.0 0 0" outfile=${BASENAME}_image.arf numphoton=$arf_numphoton minphoton=$arf_minphoton teldeffile=CALDB qefile=CALDB contamifile=CALDB obffile=CALDB fwfile=CALDB gatevalvefile=CALDB onaxisffile=CALDB onaxiscfile=CALDB mirrorfile=CALDB obstructfile=CALDB frontreffile=CALDB backreffile=CALDB pcolreffile=CALDB scatterfile=CALDB mode=h clobber=yes seed=7 imgfile=$f_image" >> $f_log
xaarfgen \
    xrtevtfile=raytrace_${BASENAME}.fits \
    source_ra=$rslsrc_ra \
    source_dec=$rslsrc_dec \
    telescop=XRISM \
    instrume=RESOLVE \
    emapfile=${BASENAME}.expo \
    regmode=DET \
    regionfile=$f_region \
    sourcetype=IMAGE \
    flatradius=3.0 \
    rmffile=${BASENAME}.rmf \
    erange="$arf_minenergy $arf_maxenergy $arf_img_minenergy $arf_img_maxenergy" \
    outfile=${BASENAME}_image.arf \
    numphoton=$arf_numphoton \
    minphoton=$arf_minphoton \
    teldeffile=CALDB qefile=CALDB contamifile=CALDB \
    obffile=CALDB fwfile=CALDB gatevalvefile=CALDB \
    onaxisffile=CALDB onaxiscfile=CALDB mirrorfile=CALDB \
    obstructfile=CALDB frontreffile=CALDB backreffile=CALDB \
    pcolreffile=CALDB scatterfile=CALDB \
    mode=h clobber=yes seed=7 \
    imgfile=$f_image \
    1>> $f_log 2>> $f_log

mv \
    rslfrac.fits \
    rslmkrmf.log \
    rslrmf.log \
    make_expo.log \
    coordpnt_rslsrc_ra.log \
    coordpnt_rslsrc_dec.log \
    arfgencgrid.fits \
    arfgencgrid_full.fits \
    coordpnt.log \
    raytrace_${BASENAME}.fits \
    xaarfgen.log \
    xaarfgen_region.lis \
    xaxmaarfgen.log \
    _tmp_* \
    sim_arf.fits \
    srcfile.txt \
    raytracehk* \
    heasim_events.fits \
    heasim_photonlist.fits \
    arf_data.dat \
    arf_columns.lis \
    $d_log/


exit
