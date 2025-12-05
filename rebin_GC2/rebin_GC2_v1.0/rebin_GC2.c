/*
 
    rebin_GC2
        - 指定したエネルギー範囲において、指定した幅の bin に分けるプログラム
        - GC2観測用にカスタムした

    2025.06.25 v1.0 by Yuma Aoki (Kindai Univ.)

 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"

/* Binning 設定 */
#define ENERGY_BOUND_1_KEV 6.35    // FeKa_low_energy_side
#define ENERGY_BOUND_2_KEV 6.45    // FeKa_high_energy_side
#define ENERGY_BOUND_3_KEV 7.0     // FeKb_low_energy_side
#define ENERGY_BOUND_4_KEV 7.1     // FeKb_high_energy_side
//#define N_BINING_BAND_1 50
//#define N_BINING_BAND_2 30

int main ( int argc, char *argv[] ) {

    if ( argc != 4 && argc != 5 ) {
        fprintf(stderr, "Usage : ./rebin_GC2 pifile(in) pifile(out) N_BINING (logfile)\n");
        return -1;
    }
    
    // file
    char infile_path[FILENAME_MAX];
    char outfile_path[FILENAME_MAX];
    char logfile_path[FILENAME_MAX];

    // cfitsio
    int status = 0;
    int ncols = 0;
    int hdutype = 0;
    long nrows = 0;
    int coltype_GROUPING = TINT;
    int colnum_GROUPING = 0;
    int VALUE_GROUPING = 1;
    int VALUE_SKIP_GROUPING = -1;

    // Other
    int current_band = 0;
    long channel = 0;
    long binning_count = 0;

    // input arguments
    snprintf(infile_path, sizeof(infile_path), "%s", argv[1]);
    snprintf(outfile_path, sizeof(outfile_path), "%s", argv[2]);
    if ( argc == 5 ) {
        snprintf(logfile_path, sizeof(logfile_path), "%s", argv[4]);
    }
    else {
        snprintf(logfile_path, sizeof(logfile_path), "rebin_GC2.log");
    }
    int energy_bound_1_ch = (int) ( ENERGY_BOUND_1_KEV * 1000.0 * 2.0);
    int energy_bound_2_ch = (int) ( ENERGY_BOUND_2_KEV * 1000.0 * 2.0);
    int energy_bound_3_ch = (int) ( ENERGY_BOUND_3_KEV * 1000.0 * 2.0);
    int energy_bound_4_ch = (int) ( ENERGY_BOUND_4_KEV * 1000.0 * 2.0);
    int n_binning = atoi(argv[3]);

    // Check arguments
    if ( n_binning < 0 ) {
        fprintf(stderr, "*** Error ***\n");
        fprintf(stderr, "N_BINING must be larger than 0!\n");
        fprintf(stderr, "abort.\n");
        return -1;
    }

    // fits file pointer
    fitsfile *fp_infile = NULL;
    fitsfile *fp_outfile = NULL;
    FILE *fp_logfile = NULL;

    fits_create_file(&fp_outfile, outfile_path, &status);
    fits_open_file(&fp_infile, infile_path, READONLY, &status); 
    fits_open_file(&fp_outfile, outfile_path, READWRITE, &status);
    fp_logfile = fopen(logfile_path, "w");
    if ( fp_logfile == NULL ) {
        fprintf(stderr, "*** Error ***\n");
        fprintf(stderr, "Cannot open logfile!\n");
        fprintf(stderr, "abort.\n");
        return -1;
    }
    
    // BEGIN
    fprintf(stdout, "rebin_GC2 : BEGIN\n");

    // Log
    fprintf(fp_logfile, "rebin_GC2 : BEGIN\n");
    fprintf(fp_logfile, "\n");
    fprintf(fp_logfile, "$1(infile)   : %s\n", infile_path);
    fprintf(fp_logfile, "$2(outfile)  : %s\n", outfile_path);
    fprintf(fp_logfile, "$3(N_BINING) : %d\n", n_binning);
    if ( argc == 5 ) {
        fprintf(fp_logfile, "$4(logfile)  : %s\n", logfile_path);
    }
    else {
        fprintf(fp_logfile, "$4(logfile)  : DEFAULT(%s)\n", logfile_path);
    }
    fprintf(fp_logfile, "\n");
    fprintf(fp_logfile, "ENERGY_BOUND_1_KEV = %f\n", ENERGY_BOUND_1_KEV);
    fprintf(fp_logfile, "ENERGY_BOUND_2_KEV = %f\n", ENERGY_BOUND_2_KEV);
    fprintf(fp_logfile, "ENERGY_BOUND_3_KEV = %f\n", ENERGY_BOUND_3_KEV);
    fprintf(fp_logfile, "ENERGY_BOUND_4_KEV = %f\n", ENERGY_BOUND_4_KEV);
    fprintf(fp_logfile, "\n");

    // Copy hdu
    fits_copy_file(fp_infile, fp_outfile, 1, 1, 1, &status);
    
    // Set hdu (HDU number starts with 1)
    fits_movabs_hdu(fp_outfile, 2, &hdutype, &status);
    
    // Get num_cols and num_rows
    fits_get_num_cols(fp_outfile, &ncols, &status);
    fits_get_num_rows(fp_outfile, &nrows, &status);

    // Get colnum
    fits_get_colnum(fp_outfile, CASESEN, "GROUPING", &colnum_GROUPING, &status);

    // Write column values
    for ( long row_num=1; row_num<=nrows; row_num++ ) {

        channel = row_num - 1;
        
        // バンド1(FeKaまで)の場合の処理
        if ( channel < energy_bound_1_ch ) {
            
            // バンド1の処理フラグ
            if ( current_band != 1 ) {
                current_band = 1;
                binning_count = 0;
            }
            
            if ( binning_count >= n_binning ) {
                // カラムに1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_GROUPING, &status);
                binning_count = 0;
            }
            else {
                // カラムに-1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_SKIP_GROUPING, &status);
            }

        }
        // バンド2(FeKa_ENDからFeKb_BEGINまで)の場合の処理
        else if ( energy_bound_2_ch < channel && channel < energy_bound_3_ch ) {
            
            // バンド2の処理フラグ
            if ( current_band != 2 ) {
                current_band = 2;
                binning_count = 0;
            }
            
            if ( binning_count >= n_binning ) {
                // カラムに1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_GROUPING, &status);
                binning_count = 0;
            }
            else {
                // カラムに-1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_SKIP_GROUPING, &status);
            }

        }
        // FeKb_BEGIN境界の処理
        else if ( channel == energy_bound_3_ch ) {
            
            fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_GROUPING, &status);

        }
        // バンド3(FeKb_END以降)の場合の処理
        else if ( energy_bound_4_ch < channel ) {
            
            // バンド3の処理フラグ
            if ( current_band != 3 ) {
                current_band = 3;
                binning_count = 0;
            }
            
            if ( binning_count >= n_binning ) {
                // カラムに1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_GROUPING, &status);
                binning_count = 0;
            }
            else {
                // カラムに-1を書き込む
                fits_write_col(fp_outfile, coltype_GROUPING, colnum_GROUPING, row_num, 1, 1, &VALUE_SKIP_GROUPING, &status);
            }

        }
        // 関係ないバンド
        else {
            continue;
        }

        binning_count ++;
        
    }
    
    // Log
    fprintf(fp_logfile, "status = %d\n", status);
    fprintf(fp_logfile, "rebin_GC2 : END\n");

    // Close files
    fits_close_file(fp_infile, &status);
    fits_close_file(fp_outfile, &status);
    fclose(fp_logfile);

    // Print status
    fprintf(stdout, "status = %d\n", status);
    fprintf(stdout, "rebin_GC2 : END\n");
    
    return 0;
    
}
