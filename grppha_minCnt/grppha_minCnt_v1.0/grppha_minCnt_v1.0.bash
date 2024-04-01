#!/bin/bash

# grppha

# 2024.02.19 v1.0 by Yuma Aoki (Kindai Univ.)


if [ $# -ne 1 ] ; then
    echo "Usage : bash grppha_v1.0.bash infile(pi)"
    exit
fi

MIN_CNT='5'

grppha << EOT
$infile
"$(basename $infile | sed -e 's/\.pi$//g')_GRP-MINCNT${MIN_CNT}.pi"
group min ${MIN_CNT}
exit
EOT
