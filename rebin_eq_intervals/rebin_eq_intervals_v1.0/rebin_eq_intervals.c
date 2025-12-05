/*
 
    rebin_eq_intervals
        - 指定したエネルギー範囲において、指定した幅の bin に分けるプログラム

    2025.06.25 v1.0 by Yuma Aoki (Kindai Univ.)
 
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"

int main ( int argc, char *argv[] ) {

    if ( argc != 6 ) {
        fprintf(stderr, "Usage : ./rebin_eq_intervals pifile(in) pifile(out) MIN_ENERGY(keV) MAX_ENERGY(keV) N_BIN\n");
        return -1;
    }
    
    // col type
    int coltype_GROUPING = TINT;
    
    // file
    char infile_path[FILENAME_MAX];
    char outfile_path[FILENAME_MAX];
    
    // cfitsio
    int status = 0;
    int ncols = 0;
    int hdutype = 0;
    long nrows = 0;
    int colnum_GROUPING = 0;
    int VALUE_GROUPING = 1;
    int VALUE_SKIP_GROUPING = -1;

    // Other
    long channel = 0;
    long binning_count = 0;

    // input arguments
    snprintf(infile_path, sizeof(infile_path), "%s", argv[1]);
    snprintf(outfile_path, sizeof(outfile_path), "%s", argv[2]);
    double min_energy_keV = atof(argv[3]);
    double max_energy_keV = atof(argv[4]);
    int min_energy_ch = (int) (min_energy_keV * 1000.0 * 2.0);
    int max_energy_ch = (int) (max_energy_keV * 1000.0 * 2.0);
    int n_binning = atoi(argv[5]);
    
    //printf("min_energy_ch = %d\n", min_energy_ch);
    //printf("max_energy_ch = %d\n", max_energy_ch);
    
    // Check arguments
    if ( min_energy_ch >= max_energy_ch ) {
        fprintf(stderr, "*** Error ***\n");
        fprintf(stderr, "MIN_ENERGY must be smaller than MAX_ENERGY!\n");
        fprintf(stderr, "abort.\n");
        return -1;
    }
    if ( n_binning < 0 ) {
        fprintf(stderr, "*** Error ***\n");
        fprintf(stderr, "n_bin must be larger than 0!\n");
        fprintf(stderr, "abort.\n");
        return -1;
    }

    // fits file pointer
    fitsfile *fp_infile = NULL;
    fitsfile *fp_outfile = NULL;

    fits_create_file(&fp_outfile, outfile_path, &status);
    fits_open_file(&fp_infile, infile_path, READONLY, &status); 
    fits_open_file(&fp_outfile, outfile_path, READWRITE, &status);
    
    // BEGIN
    fprintf(stdout, "rebin_eq_intervals : BEGIN\n");

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
    for (long row_num=1; row_num<=nrows; row_num++) {

        channel = row_num - 1;
        
        // エネルギー範囲外ならスキップ
        if ( channel < min_energy_ch || max_energy_ch < channel ) {
            continue;
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

        binning_count ++;
        
    }

    fits_close_file(fp_infile, &status);
    fits_close_file(fp_outfile, &status);

    fprintf(stdout, "status = %d\n", status);
    fprintf(stdout, "rebin_eq_intervals : END\n");
    
    return 0;
    
}
