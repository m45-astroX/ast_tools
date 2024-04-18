# rslreggen

本ドキュメントの変更履歴  
\# 2024.04.18 v1 by Yuma Aoki (Kindai Univ.)  


## 概要

XRISM/Resolveの任意のピクセルのRegionファイルを生成するスクリプト



## 必要なツール

- make
- gcc



## 使用方法

コンパイルする。

    $ make

成功した場合、実行ファイル rslreggen が生成される。

ピクセル定義ファイル (pixreffile) を入力として、スクリプトを実行する。出力されるRegionファイルの名前は第2引数で指定可能。

    $ ./rslreggen pixreffile (regfile; optional)
        pixreffile : input (ASCII format)
        regfile : output (ds9 format)

成功した場合、ds9のフォーマットで sxs_rslreggen_det.reg が出力される。
なお座標系はDET。


### ピクセル参照ファイル (pixreffile)

Regionファイルに含めるピクセルを定義したASCII形式のファイル。ピクセル番号(0--35)を1行ずつ定義する。ピクセル番号の定義は "ASTRO-H COORDINATES DEFINITIONS ASTH-SCT-020" を参照。サンプルは `./sample/` に置いてある。
