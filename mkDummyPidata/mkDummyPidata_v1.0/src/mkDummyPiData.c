/*

    mkDummyPiData

    2024.11.07 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include "fitsio.h"

#define CHAN_MAX 60000

int main ( int argc, char *argv[] ) {
    
    if ( argc != 2 ) {
        fprintf(stderr, "Usage : ./mkDummyPiData outfile\n");
        return -1;
    }

    /* Variables */
    int status = 0;
    char outfile_path[FILENAME_MAX];
    
    int flag = 0;
    int anynul_ = 0;
    long PH_SUM = 0;
    long num_pixel = 0 ;
    char rframe_path[FILENAME_MAX];
    char rframelist_path[FILENAME_MAX];
    char hpixmap_path[FILENAME_MAX];
    char buf[4096];
    char *ttype_list[] = {"CHANNEL", "COUNTS"};
    char *tform_list[] = {"J", "J"};
    char *tunit_list[] = {"", "count"};

    int value_channel = 0;
    int value_count = 10;

    /* Arguments */
    snprintf(outfile_path, sizeof(outfile_path), "%s", argv[1]);

    /* Files */
    fitsfile *fp_outfile = NULL;

    /* Open */
    fits_create_file(&fp_outfile, outfile_path, &status);
    fits_open_file(&fp_outfile, outfile_path, READWRITE, &status);
    if ( status != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not open outfile!\n");
        fprintf(stderr, "abort\n");
        return status;
    }

    fits_create_tbl(fp_outfile, BINARY_TBL, CHAN_MAX, 2, ttype_list, tform_list, tunit_list, "SPECTRUM", &status);

    for (long i=1; i<=CHAN_MAX; i++) {
        
        value_channel = i - 1;
        fits_write_col(fp_outfile, TINT32BIT, 1, i, 1, 1, &value_channel, &status);

        // 500 eV
        if ( i - 1 == 1000 ) {
            //(fitsfile *fptr, int datatype, int colnum, LONGLONG firstrow,LONGLONG firstelem, LONGLONG nelements, DTYPE *array, > int *status)
            fits_write_col(fp_outfile, TINT32BIT, 2, i, 1, 1, &value_count, &status);
        }
        // 6000 eV
        else if ( i - 1 == 12000 ) {
            fits_write_col(fp_outfile, TINT32BIT, 2, i, 1, 1, &value_count, &status);
        }
        // 6700 eV
        else if ( i - 1 == 13400 ) {
            fits_write_col(fp_outfile, TINT32BIT, 2, i, 1, 1, &value_count, &status);
        }
        // 10,000 eV
        else if ( i - 1 == 20000 ) {
            fits_write_col(fp_outfile, TINT32BIT, 2, i, 1, 1, &value_count, &status);
        }

    }

    /* Close files */
    fits_close_file(fp_outfile, &status);

    return 0;

}
