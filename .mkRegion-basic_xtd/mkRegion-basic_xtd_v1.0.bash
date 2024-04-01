#!/bin/bash

# mkRegion-basic_xtd

# v1.0 by Yuma Aoki (Kindai Univ.)


if [ $# -ne 1 ] ; then
    f_img=$1
else
    echo "Usage : imgfile"
    exit
fi

DS9='/Applications/SAOImageDS9.app/Contents/MacOS/ds9'

# ds9
DS9 "$f_img" \
