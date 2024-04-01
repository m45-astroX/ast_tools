#!/bin/bash

# RADEC2deg

# v1.0 by Yuma Aoki (Kindai Univ.)


if [ $# -eq 2 ] ; then
    RADEC=$1
    value=$2
else
    echo "Usage : RA/DEC value"
    echo "    Format of \$2 (value)"
    echo "        RA  --> hh:mm:ss"
    echo "        DEC --> deg:mm:ss"
    exit
fi

if [ "$RADEC" = "RA" ] ; then
    # RA(h,m,s) -> degree
    value_out="$(echo "${value}" | sed -e 's/:/\ /g' | awk '{printf "%.10f\n", $1*15 + $2*15/60 + $3*15/3600}')"
elif [ "$RADEC" = "DEC" ] ; then
    # DEC(deg,m,s) -> degree
    value_out="$(if [ "$(echo ${value} | cut -c 1)" = '-' ] ; then echo "-"; fi)$(echo "${value}" | sed -e 's/-//g; s/:/\ /g' | awk '{printf "%.10f\n", $1 + $2/60 + $3/3600}')"
else
    echo "\$1 must be RA or DEC!"
    echo "abort."
    exit
fi

echo $value_out
