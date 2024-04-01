# calcCenter4rsl

\# 2024.04.01 v1.0 by Yuma Aoki (Kindai Univ.)

## 使用方法

Makefileがあるディレクトリでコンパイルする。

    $ make

イベントファイルを入力とし、天体の中心を算出する。

    $ ./calcCenter4rsl eventfile Method(AVE or COG) Region(INNER16 or OUTER36)

- Method
    天体中心の算出方法。
    AVE : **使用不可**
    COG : Center of Gravity (重心)

- Region
    計算に使用するピクセル
    INNER16 : 内側16ピクセル
    OUTER36 : **使用不可**
