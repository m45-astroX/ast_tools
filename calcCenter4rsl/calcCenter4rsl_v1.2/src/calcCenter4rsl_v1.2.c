/*

    calcCenter4rsl

    XRISM/Resolveのイベントファイルから各ピクセルのイベント数を計算し、
    天体の重心を求めるスクリプト。

    2024.04.11 v1.0 by Yuma Aoki (Kindai Univ.)
    2024.04.18 v1.2 by Yuma Aoki (Kindai Univ.)
        - sxs_pixel_definition.hの変更(v1.0 -> v2.0)に伴いマスタ側も修正
        - 要求する引数をイベントファイルのみに変更。計算方法は$2および$3で指定可能。

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"
#include "sxs_pixel_definition.h"


int main ( int argc, char *argv[] ) {

    int status = 0;
    long repeat = 0;
    long width = 0;
    int anynul = 0;
    int hdutype = 0;
    int colnum = 0;
    int nulval = 0;
    int read_pixel = 0;
    int datatype_PIXEL = 0;
    int method_num = 0;
    int region_num = 0;
    long counts_sum = 0;
    long counts_projection[6];
    long nrows = 0;
    long counts[6][6];  // 1番目の要素指定子はX, 2番目はY
    char method[256];
    char region[256];

    if ( argc == 2 ) {
        snprintf(method, sizeof(method), "COG");
        snprintf(region, sizeof(region), "INNER16");
    }
    else if ( argc == 4 ) {
        snprintf(method, sizeof(method), "%s", argv[2]);
        snprintf(region, sizeof(region), "%s", argv[3]);
    }
    else {
        fprintf(stderr, "Usage : ./calcCenter4rsl eventfile (Method; optional) (Region; optional)\n");
        fprintf(stderr, "    Method AVE : Average\n");
        fprintf(stderr, "           COG : Center of Gravity   <-- Default\n");
        fprintf(stderr, "    Region INNER16   <-- Default\n");
        fprintf(stderr, "           OUTER36\n");
        return -1;
    }

    /* Reset Variables */
    for (int i=0; i<6; i++) {
        for (int j=0; j<6; j++) {
            counts[i][j] = 0;
        }
    }

    /* Read arguments */
    fitsfile *fp = NULL;
    if ( fits_open_file(&fp, argv[1], READONLY, &status) != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "FITS file open error!\n");
        fprintf(stderr, "file   : %s\n", argv[1]);
        fprintf(stderr, "status : %d\n", status);
        fprintf(stderr, "abort\n");
        return -1;
    }

    // Method
    if ( strcmp(method, "AVE") == 0 || strcmp(method, "ave") == 0 || strcmp(method, "A") == 0 || strcmp(method, "a") == 0 ) {
        method_num = 0;
        // OUTER36用計算コードの作成待ち
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Method AVE is not supported in this version.\n");
        fprintf(stderr, "abort\n");
        return -1;
    }
    else if ( strcmp(method, "COG") == 0 || strcmp(method, "cog") == 0 || strcmp(method, "G") == 0 || strcmp(method, "g") == 0 ) {
        method_num = 1;
    }
    else {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Method($2) must be AVE or COG!\n");
        fprintf(stderr, "abort\n");
        return -1;
    }

    // Region
    if ( strcmp(region, "INNER16") == 0 || strcmp(region, "inner16") == 0 || strcmp(region, "I") == 0 || strcmp(region, "i") == 0 ) {
        region_num = 0;
    }
    else if ( strcmp(region, "OUTER36") == 0 || strcmp(region, "outer36") == 0 || strcmp(region, "O") == 0 || strcmp(region, "o") == 0 ) {
        region_num = 1;
        // OUTER36用計算コードの作成待ち
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Region OUTER36 is not supported in this version.\n");
        fprintf(stderr, "abort\n"); 
    }
    else {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Region($3) must be INNER16 or OUTER36!\n");
        fprintf(stderr, "abort\n");
        return -1;
    }

    /* Read information of eventfile */
    // Set HDU (HDU number starts with 1)
    fits_movabs_hdu(fp, 2, &hdutype, &status);
    // Ger colnum
    fits_get_colnum(fp, CASESEN, "PIXEL", &colnum, &status);
    // Get information of row
    fits_get_coltype(fp, colnum, &datatype_PIXEL, &repeat, &width, &status);
    // Get rownumber
    fits_get_num_rows(fp, &nrows, &status);

    // Count X-ray events
    for (long long i=1; i<=nrows; i++) {

        // Read PIXEL number from fitsfile
        fits_read_col(fp, datatype_PIXEL, colnum, i, 1, 1, &nulval, &read_pixel, &anynul, &status);
        
        // Count ++
        if ( 0 <= read_pixel && read_pixel <= 35 ) {
            // xaxis_value_refとyaxis_value_refに格納されているのはDET座標で1--6の値を取る.
            // 配列の要素番号は0--5なので、countsの要素指定の際に1を引いてる.
            // 「Xの要素番号 = DETX - 1」「Yの要素番号 = DETY - 1」が定義である.
            counts[xaxis_value_ref[read_pixel]-1][yaxis_value_ref[read_pixel]-1]++;
        }

    }

    /* Calculate the center */
    if ( method_num == 0 && region_num == 0 ) {        // Average

        ;

    }
    else if ( method_num == 1 && region_num == 0 ) {   // Center of Gravity
        
        /* イベント総数計算 */
        counts_sum = 0;
        for (int x=1; x<5; x++) {
            for (int y=1; y<5; y++) {
                counts_sum += counts[x][y];
            }
        }

        /* X座標 */
        // 変数リセット
        for (int i=0; i<6; i++) {counts_projection[i] = 0;}
        // Y方向のプロジェクションを計算
        for (int x=1; x<5; x++) {
            for (int y=1; y<5; y++) {
                counts_projection[x] += counts[x][y];
            }
        }
        // X座標
        fprintf(stdout, "RDETX = %.15f\n", ((double)counts_projection[1]*2.0 + (double)counts_projection[2]*3.0 + (double)counts_projection[3]*4.0 + (double)counts_projection[4]*5.0) / (double)counts_sum);

        /* Y座標 */
        // 変数リセット
        for (int i=0; i<6; i++) {counts_projection[i] = 0;}
        // X方向のプロジェクションを計算
        for (int x=1; x<5; x++) {
            for (int y=1; y<5; y++) {
                counts_projection[y] += counts[x][y];
            }
        }
        // Y座標
        fprintf(stdout, "RDETY = %.15f\n", ((double)counts_projection[1]*2.0 + (double)counts_projection[2]*3.0 + (double)counts_projection[3]*4.0 + (double)counts_projection[4]*5.0) / (double)counts_sum);
    }

    /* fclose */
    fits_close_file(fp, &status);

    return status;

}
