# README

rmfArf-basic_rsl

\# 2024.02.20 v1 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.11 v2 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.19 v3 by Yuma Aoki (Kindai Univ.)  
\# 2024.06.10 v4 by Yuma Aoki (Kindai Univ.) 

## 概要

RMF(energy redistribution matrix file), ARF(ancillary response function), exposure mapを作成するスクリプト。


## 使用方法(Point source)

    $ bash rmfArf-basic_rsl_POINT_v2.4.bash

    $1 BASENAME
    $2 evtfile (cleaned evt)
    $3 ehkfile
    $4 exp gti file
    $5 region file (DEFAULT or filename)
    $6 center calculation method (DEFAULT, NOMINAL, SCRIPT or MANUAL)
    $7 source_ra (This argument is required when \$6 is set to 'MANUAL'.)
    $8 source_dec (This argument is required when \$6 is set to 'MANUAL'.)

## 使用方法(Flat source)

    $ bash rmfArf-basic_rsl_FLAT_v2.4.bash

    $1 BASENAME
    $2 evtfile (cleaned evt)
    $3 ehkfile
    $4 exp gti file
    $5 region file (DEFAULT or filename)
    $6 center calculation method (DEFAULT, NOMINAL, SCRIPT or MANUAL)
    $7 flatradius
    $8 source_ra (This argument is required when \$6 is set to 'MANUAL'.)
    $9 source_dec (This argument is required when \$6 is set to 'MANUAL'.)

## 使用方法(Image source)

    $ bash rmfArf-basic_rsl_IMAGE_v2.4.bash

    $1 BASENAME
    $2 evtfile (cleaned evt)
    $3 ehkfile
    $4 exp gti file
    $5 region file (DEFAULT or filename)
    $6 image file
    $7 center calculation method (DEFAULT, NOMINAL, SCRIPT or MANUAL)
    $8 source_ra (This argument is required when \$6 is set to 'MANUAL'.)
    $9 source_dec (This argument is required when \$6 is set to 'MANUAL'.)
