# README

\# 2025.09.29 v1 by Yuma Aoki (Kindai Univ.)

## database_cross-section file の作成方法

- 以下のリンクから XCOM をダウンロードする

    https://www.nist.gov/pml/xcom-photon-cross-sections-database

- Makefile を作成する

    $ cd /path/to/XCOM
    $ touch Makefile

- 以下の内容を Makefile に書き込む

    FC ?= gfortran
    FFLAGS ?= -O2 -std=legacy

    SRC = XCOM.f
    BIN = xcom

    all: $(BIN)

    $(BIN): $(SRC)
            $(FC) $(FFLAGS) -o $(BIN) $(SRC)

    run: $(BIN)
            ./$(BIN)

    clean:
            rm -f $(BIN) *.o

- 以下の手順で xcom をコンパイルする

    $ make

- データベースの元データを作成する(鉄の場合の例)

    $ ./xcom
    > Iron  // Name of substance
    > 1     // Elemental substance, specified by atomic number
    > 26    // Atomic number of element
    > 1     // Cross sections in barns/atom
    > 1     // Standard energy grid
    > Fe_raw.dat    // outfile
    > 1     // No more output

- データベースを作成する

    cat Fe_raw.dat | awk 'NF==8 && 0<$1 && $1<1e8 {print $1*1e3, $4}' > Fe.dat

    * 1列目 : 入射X線のエネルギー (keV)
    * 2列目 : 光電断面積 (barn)


## 本プログラムのコンパイルと実行

    $ cd /path/to/calc_line_flux_xray_v1.0
    $ make
    $ ./CALC_CROSS_SECTION database_cross-section omega relative_abundance integ_min(keV) integ_max(keV)
