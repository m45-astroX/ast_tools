#!/bin/bash

# grppha_binning_rsl

# 2024.06.20 v1.0 by Yuma Aoki (Kindai Univ.)


SCRIPT_VERSION=1.0

if [ $# -ne 2 ] ; then
    echo "Usage : bash grppha_binning_rsl_v${SCRIPT_VERSION}.bash infile(pi) mincount"
    exit
fi

infile=$1
mincnt=$2
outfile="$(basename $infile | sed 's/\.gz$//g; s/\.pi$//g')_mincnt${mincnt}.pi"

grppha << EOT
$infile
$outfile
group min $mincnt
exit
EOT

exit
