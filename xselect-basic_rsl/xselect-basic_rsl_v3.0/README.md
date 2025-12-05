# xselect-basic_rsl

READMEの変更履歴
\# 2024.02.20 v1 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.01 v2 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.19 v3 by Yuma Aoki (Kindai Univ.)  
\# 2025.02.21 v4 by Yuma Aoki (Kindai Univ.)  


## 概要

Resolve の clean2 event file と PI file を作成するスクリプト



## 実行方法

    $ bash xselect-basic_rsl.bash BASENAME cleanevtfile (CLOBBER_OUTFILE)

        BASENAME ($1) : Stem name of outputfile
        cleanevtfile ($2) : Resolve の clean event file
        CLOBBER_OUTFILE ($3; optional) : 上書き保存するか (Y/N)


### 実行例 (odsid:000126000)

- コマンド

    $ bash xselect-basic_rsl.bash XRISM-RSL-000126000-N132D xa000126000rsl_p0px1000_cl.evt.gz

- 生成されるファイルおよびディレクトリ

    ./
    XRISM-RSL-000126000-N132D_DET.img
    XRISM-RSL-000126000-N132D_Hp_src.pi
    XRISM-RSL-000126000-N132D_cl2.evt
    XRISM-RSL-000126000-N132D_lc.fits
    logfiles_xselect-basic_rsl/
    ├── xsel_ascii_out.xsl
    ├── xsel_display.def
    ├── xsel_files.tmp
    ├── xsel_fits_curve.xsl
    ├── xsel_hist.xsl
    ├── xsel_image.xsl
    ├── xsel_obscat.tmp
    ├── xsel_obslist.def
    ├── xsel_read_cat.xsl
    ├── xsel_session.xsl
    ├── xsel_xronos_out.xsl
    ├── xselect-basic_rsl.log   <-- 本スクリプトのlogファイル
    └── xselect.log             <-- xselectを実行した際に生成されるlogファイル



## 参考資料

- The XRISM Data Reduction Guide v1.0 (November 7, 2024)
https://heasarc.gsfc.nasa.gov/docs/xrism/analysis/abc_guide/xrism_abc.pdf
