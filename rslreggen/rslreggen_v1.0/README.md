# rslreggen

本ドキュメントの変更履歴  
\# 2024.04.01 v1 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.11 v2 by Yuma Aoki (Kindai Univ.)  
\#    - 必要なツール、環境変数の説明を追記  


## 概要

XRISM/Resolveの任意のピクセルのRegionファイルを生成するスクリプト



## 必要なツール

    - make
    - gcc



## 使用方法

コンパイルする。

    $ make

成功した場合、実行ファイル rslreggen が生成される。

ピクセル定義ファイル (pixreffile) を入力として、スクリプトを実行する。

    $ ./rslreggen pixreffile

成功した場合、sxs_rslreggen.reg が出力される。

### ピクセル参照ファイル (pixreffile)

Regionファイルに含めるピクセルを定義したASCII形式のファイル。`./sample/` にサンプルを置いている。

