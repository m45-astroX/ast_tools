/*

    changeSearchflickpixFlag

    2024.09.09 v1.0 by Yuma Aoki (Kindai Univ.)

*/


#include <stdio.h>
#include <string.h>
#include "fitsio.h"

int main ( int argc, char *argv[] ) {
    
    if ( argc != 3 ) {
        fprintf(stderr, "Usage ./changeSearchflickpixFlag infile outfile\n");
        fprintf(stderr, "    $1 : infile (Xtend evtfile)\n");
        fprintf(stderr, "    $2 : outfile (Xtend evtfile)\n");
        return -1;
    }
    
    int status = 0;
    int ACTX = 0;
    int ACTY = 0;
    char STATUS[48];
    int colnum_ACTX = 0;
    int colnum_ACTY = 0;
    int colnum_STATUS = 0;
    int datatype_ACTX = 0;
    int datatype_ACTY = 0;
    int datatype_STATUS = 0;
    long nrows = 0;
    char infile_path[FILENAME_MAX];
    char outfile_path[FILENAME_MAX];
    
    int _nulval = 0;
    int _anynul = 0;
    int _hdutype = 0;
    long _repeat = 0;
    long _width = 0;

    fitsfile *fp_infile = NULL;
    fitsfile *fp_outfile = NULL;
    
    /* Reset*/
    for (int i=0; i<48; i++) {
        STATUS[i] = 0;
    }

    /* Arguments */
    snprintf(infile_path, sizeof(infile_path), "%s", argv[1]);
    snprintf(outfile_path, sizeof(outfile_path), "!%s", argv[2]);

    /* file */
    fits_open_file(&fp_infile, infile_path, READONLY, &status);
    fits_create_file(&fp_outfile, outfile_path, &status);
    fits_copy_file(fp_infile, fp_outfile, 1, 1, 1, &status);

    /* Get fits information  */
    // Move HDU (HDU number starts with 1)
    fits_movabs_hdu(fp_infile, 2, &_hdutype, &status);
    fits_movabs_hdu(fp_outfile, 2, &_hdutype, &status);
    // Get the number of rows (row number starts with 1)
    fits_get_num_rows(fp_infile, &nrows, &status);
    // Get colnum
    fits_get_colnum(fp_infile, CASESEN, "ACTX", &colnum_ACTX, &status);
    fits_get_colnum(fp_infile, CASESEN, "ACTY", &colnum_ACTY, &status);
    fits_get_colnum(fp_infile, CASESEN, "STATUS", &colnum_STATUS, &status);
    // Get coltype
    fits_get_coltype(fp_infile, colnum_ACTX, &datatype_ACTX, &_repeat, &_width, &status);
    fits_get_coltype(fp_infile, colnum_ACTY, &datatype_ACTY, &_repeat, &_width, &status);
    fits_get_coltype(fp_infile, colnum_STATUS, &datatype_STATUS, &_repeat, &_width, &status);
    // Check error
    if ( status != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "    --> Getting fits information\n");
        fprintf(stderr, "    --> status = %d\n", status);
        fits_close_file(fp_infile, &status);
        fits_close_file(fp_outfile, &status);
        return status;
    }
    
    /* Routine */
    for (long i=1; i<=nrows; i++) {
        
        // Read ACTX
        fits_read_col(fp_infile, datatype_ACTX, colnum_ACTX, i, 1, 1, &_nulval, &ACTX, &_anynul, &status);
        // Read ACTY
        fits_read_col(fp_infile, datatype_ACTY, colnum_ACTY, i, 1, 1, &_nulval, &ACTY, &_anynul, &status);
        // Read STATUS
        fits_read_col(fp_infile, datatype_ACTY, colnum_ACTY, i, 1, 1, &_nulval, &ACTY, &_anynul, &status);

        /* Filter (このブロックを書き換える) */
        if ( ACTX == 1 && ACTY == 1 ) {
            STATUS[10] = 0;
        }

        /* Edit column */
        fits_write_col(fp_outfile, datatype_STATUS, colnum_STATUS, i, 10, 1, &STATUS[10], &status);

    }

    /* Close files */
    fits_close_file(fp_infile, &status);
    fits_close_file(fp_outfile, &status);
    
    return status;
    
}
