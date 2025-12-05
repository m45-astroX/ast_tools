/*

    mk_Rratio_map.c
 
    2025.11.01 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "framesize.h"
#include "fitsio.h"


int main ( int argc, char *argv[] ) {

    /* Variables */
    int status = 0;
    int colnum_X = 0, colnum_Y = 0, colnum_VALUE = 0;
    int datatype_X = TINT, datatype_Y = TINT, datatype_VALUE = TLONG;
    int X = 0, Y = 0;
    int READX = 0, READY = 0;
    int hdutype_ = 0, nulval_ = 0, anynul_ = 0;
    short count[VUC_HT+IMG_HT+VOC_HT][TRF_LL];       // [READY][READX]
    long VALUE = 0;
    long width_ = 0, repeat_ = 0, n_row = 0;
    char infile_path[FILENAME_MAX];
    char outfile_path[FILENAME_MAX];

    /* Arguments */
    if ( argc != 3 ) {
        fprintf(stderr, "Usage : ./mk_Rratio_map outfile\n");
        return -1;
    }
    else {
        snprintf(infile_path, sizeof(infile_path), "%s", argv[1]);
        snprintf(outfile_path, sizeof(outfile_path), "!%s", argv[2]);
    }
    
    /* Reset */
    for (int i=0; i<TRF_LL; i++) {        // X axis loop
        for (int j=0; j<VUC_HT+IMG_HT+VOC_HT; j++) {    // Y axis loop
            count[j][i] = 0;
        }
    }

    /* Files */
    fitsfile *fp_infile = NULL;
    if ( fits_open_file(&fp_infile, infile_path, READONLY, &status) != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not open infile (%s) status=%d\n", infile_path, status);
        fprintf(stderr, "abort\n");
        return status;
    }
    fitsfile *fp_outfile = NULL;
    if ( fits_create_file(&fp_outfile, outfile_path, &status) != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not create outfile (%s) status=%d\n", outfile_path, status);
        fprintf(stderr, "abort\n");
        return status;
    }
    
    // Move HDU
    fits_movabs_hdu(fp_infile, 2, &hdutype_, &status);
    // Check status
    if ( status != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Failed to move the HDU\n");
        fprintf(stderr, "status = %d\n", status);
        return status;
    }
    // Get rownum
    fits_get_num_rows(fp_infile, &n_row, &status);
    // Get colnum of X, Y and VALUE
    fits_get_colnum(fp_infile, CASESEN, "X", &colnum_X, &status);
    fits_get_colnum(fp_infile, CASESEN, "Y", &colnum_Y, &status);
    fits_get_colnum(fp_infile, CASESEN, "VALUE", &colnum_VALUE, &status);
    // Get datatype
    fits_get_coltype(fp_infile, colnum_X, &datatype_X, &repeat_, &width_, &status);
    fits_get_coltype(fp_infile, colnum_Y, &datatype_Y, &repeat_, &width_, &status);
    fits_get_coltype(fp_infile, colnum_VALUE, &datatype_VALUE, &repeat_, &width_, &status);

    // Check status
    if ( status != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Failed to get the colnum\n");
        fprintf(stderr, "status = %d\n", status);
        return status;
    }
    
    #ifdef DEBUG
    fprintf(stderr, "n_row = %ld, colnum_X = %d, colnum_Y = %d, colnum_VALUE = %d\n", n_row, colnum_X, colnum_Y, colnum_VALUE);
    fprintf(stderr, "datatype_X = %d, datatype_Y = %d, datatype_VALUE = %d\n", datatype_X, datatype_Y, datatype_VALUE);
    #endif

    // Loop
    for (long i=1; i<=n_row; i++) {
        
        // Read coordinates and value
        fits_read_col(fp_infile, datatype_X, colnum_X, i, 1, 1, &nulval_, &X, &anynul_, &status);
        fits_read_col(fp_infile, datatype_Y, colnum_Y, i, 1, 1, &nulval_, &Y, &anynul_, &status);
        fits_read_col(fp_infile, datatype_VALUE, colnum_VALUE, i, 1, 1, &nulval_, &VALUE, &anynul_, &status);
        READX = X - 1;
        READY = Y - 1;

        // Input data
        if ( is_CI_row_ACtrACrd(READY) == 0 && VALUE >= HPIX_THR ) {
            count[READY][READX] ++;
        }

        // Check error code
        if ( status != 0 ) {
            fprintf(stderr, "*** Error\n");
            fprintf(stderr, "Program was aborted at read column loop\n");
            fprintf(stderr, "status = %d\n", status);
            fprintf(stderr, "i      = %ld\n", i);
            return status;
        }

    }

    /* Print result */
    int naxis = 2;
    long naxes[2] = {TRF_LL, VUC_HT+IMG_HT+VOC_HT};   // {X, Y}
    fits_create_img(fp_outfile, SHORT_IMG, naxis, naxes, &status);
    long fpixel = 1;

    int nelements = naxes[0] * naxes[1]; /* number of pixels to write */
    /* Write the array of integers to the image */
    // (*fptr, int datatype, LONGLONG firstelem, LONGLONG nelements, DTYPE *array, int *status);
    fits_write_img(fp_outfile, TSHORT, fpixel, nelements, count[0], &status);

    // Check error code
    if ( status != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "status = %d\n", status);
        return status;
    }

    /* fclose */
    fits_close_file(fp_outfile, &status);
    fits_close_file(fp_infile, &status);

    return 0;

}

