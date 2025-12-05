# README

rmfArf-basic_rsl

\# 2024.02.20 v1 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.11 v2 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.19 v3 by Yuma Aoki (Kindai Univ.)  
\# 2025.02.24 v4 by Yuma Aoki (Kindai Univ.)  
\# 2025.03.20 v5 by Yuma Aoki (Kindai Univ.)


## 概要

RMF(energy redistribution matrix file), ARF(ancillary response function), expMapを作成するスクリプト。


## 使用方法

    $ bash /path/to/rmfArf-basic_rsl_rmfsiz_X.bash BASENAME evtfile ehkfile expgtifile regionfile centerCalculationMethod

    $1 BASENAME
    $2 evtfile (cleaned evt)
    $3 ehkfile
    $4 exp gti file
    $5 region file (SAO formatted regfile with DET coordinate)
          If this parameter is set to 'DEFAULT',
          $HEADAS/refdata/region_RSL_det.reg will be used.
    $6 Center calculation method (DEFAULT or SCRIPT)
    $7 Source type ('FLATCIRCLE' or 'POINT')
    $8 Flat radius (This argument is required when $7 is set to 'FLAT'.)
