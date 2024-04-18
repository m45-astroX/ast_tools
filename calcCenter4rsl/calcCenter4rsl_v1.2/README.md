# calcCenter4rsl

本ドキュメントの変更履歴  
\# 2024.04.01 v1 by Yuma Aoki (Kindai Univ.)  
\# 2024.04.11 v2 by Yuma Aoki (Kindai Univ.)  
\#     - 必要なツール、環境変数の説明を追記  
\# 2024.04.18 v3 by Aoki (Kindai Univ.)  
\#     - 軽微な修正  



## 概要

XRISM/Resolveのイベントデータから各ピクセルのイベント数を計算し、天体の重心を計算するスクリプト。



## 必要なツール

- heasoft (heasoft-6.32.1 or latest version)
- make
- gcc



## 使用方法

環境変数 "HEADAS" を正しく設定しておく必要がある。
まずはheasoftの公式インストールドキュメント（https://heasarc.gsfc.nasa.gov/docs/software/heasoft/macos.html）に従って、heasoftのインストールをおこなう。

環境変数が設定されていることを確認。

    $ echo $HEADAS

コンパイルする。

    $ cd calcCenter4rsl_v1.0
    $ make

成功した場合、実行ファイル calcCenter4rsl が生成される。

イベントファイルを入力とし、天体の中心を算出する。

    $ ./calcCenter4rsl eventfile Method(AVE or COG) Region(INNER16 or OUTER36)

- Method
    天体中心の算出方法。
    AVE : **使用不可**
    COG : Center of Gravity (重心)

- Region
    計算に使用するピクセル
    INNER16 : 内側16ピクセルを使用
    OUTER36 : **使用不可**
