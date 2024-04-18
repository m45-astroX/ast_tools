/*

    rslreggen

    XRISM/Resolveの任意のピクセルのRegionファイルを生成するスクリプト

    2024.04.18 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sxs_pixel_definition.h"

#define PIXNUMMAX 36
#define CALSRCPIX 12
#define CALSRCPIX_WARNING 1
#define SCRIPT_VERSION "1.0"


int main ( int argc, char *argv[] ) {

    /* Variables */
    int status = 0;
    int activepixel[PIXNUMMAX];         // ピクセル番号格納用
    int activepixel_element = 0;        // 配列activepixelの要素指定用
    int buf_int = 0;                    // ピクセル番号の読み込み用buffer変数
    int readlinenumber = 0;             // pixreffileの行カウント用
    char buf_char256[256];              // ファイルの読み込み用buffer変数
    char regfile_path[FILENAME_MAX];
    char pixreffile_path[FILENAME_MAX];

    /* Initialize */
    for (int i=0; i<PIXNUMMAX; i++) {
        activepixel[i] = 0;
    }

    /* Arguments */
    if ( argc == 2 ) {
        snprintf(pixreffile_path, sizeof(pixreffile_path), "%s", argv[1]);
        snprintf(regfile_path, sizeof(regfile_path), "./sxs_rslreggen_det.reg");
    }
    else if ( argc == 3 ) {
        snprintf(pixreffile_path, sizeof(pixreffile_path), "%s", argv[1]);
        snprintf(regfile_path, sizeof(regfile_path), "%s", argv[2]);
    }
    else {
        fprintf(stderr, "Usage : ./rslreggen pixreffile (regfile; optional)\n");
        fprintf(stderr, "    pixreffile : input (ASCII format)\n");
        fprintf(stderr, "    regfile : output (ds9 format)\n");
        return -1;
    }


    /* Files */
    // pixreffile
    FILE *fp_pixreffile = NULL;
    fp_pixreffile = fopen(pixreffile_path, "r");
    if ( fp_pixreffile == NULL ) {
        fprintf(stderr, "*** ERROR!!\n");
        fprintf(stderr, "Can not open pixreffile!\n");
        fprintf(stderr, "abort\n");
        return -1;
    }
    // regionfile
    FILE *fp_regfile = NULL;
    fp_regfile = fopen(regfile_path, "w");
    if ( fp_regfile == NULL ) {
        fprintf(stderr, "*** ERROR!!\n");
        fprintf(stderr, "Can not open Regfile!\n");
        fprintf(stderr, "abort\n");
        return -1;
    }

    /* Read pixreffile */
    while ( fgets(buf_char256, sizeof(buf_char256), fp_pixreffile) != NULL ) {
        
        // The counts of readlines
        readlinenumber ++;

        // Read lines
        if ( sscanf(buf_char256, "%d", &buf_int) != 1 ) {
            continue;
        }

        // Safety
        if ( activepixel_element < 0 || 35 < activepixel_element ) {
            fprintf(stderr, "*** Error!!\n");
            fprintf(stderr, "Pixel number must be 0 to 35, but your request is %d (line %d).\n", activepixel_element, readlinenumber);
            fprintf(stderr, "abort\n");
            return -2;
        }
        if ( activepixel_element >= PIXNUMMAX ) {
            fprintf(stdout, "*** Warning!!\n");
            fprintf(stdout, "The total number of pixel must be less than %d.\n", PIXNUMMAX);
            fprintf(stdout, "Line %d and later are ignored.\n\n", readlinenumber);
            status = 1;
            break;
        }

        // Input values
        activepixel[activepixel_element] = buf_int;
        
        // Calsource pixel warning
        if ( activepixel[activepixel_element] == CALSRCPIX && CALSRCPIX_WARNING == 1 ) {
            fprintf(stdout, "*** Warning!!\n");
            fprintf(stdout, "pixreffile contains calibration source pixel (PIXEL=%d).\n\n", CALSRCPIX);
        }

        // If the number of selected regions is N,
        //     the value of this variable is N+1.
        activepixel_element ++;

    }
    
    /* Write Information */
    fprintf(fp_regfile, "# rslreggen (ver %s)\n", SCRIPT_VERSION);
    fprintf(fp_regfile, "# Pixel list : ");
    for (int i=0; i<activepixel_element; i++) {
        
        if ( i == 0 ) {
            fprintf(fp_regfile, "%d", activepixel[i]);
        }
        else {
            fprintf(fp_regfile, ", %d", activepixel[i]);
        }

    }
    fprintf(fp_regfile, "\n");
    fprintf(fp_regfile, "physical\n");

    /* Make region boxes (with DET coordinates) */
    for (int i=0; i<activepixel_element; i++) {
        
        // (x-center, y-center, width, height)
        fprintf(fp_regfile, "+box(%d, %d, 1, 1)\n", xaxis_value_ref[activepixel[i]], yaxis_value_ref[activepixel[i]]);
        
    }

    /* Close files */
    fclose(fp_pixreffile);
    fclose(fp_regfile);

    return status;

}
