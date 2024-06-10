/*

    prparam

    2024.04.29 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "fitsio.h"

#define COLUMN_IGNORE 20    // The number of column that you want to ignore.
#define UNIT_CHARSIZE 64
#define COLNAME_CHARSIZE 64


int main ( int argc, char *argv[] ) {

    int last_errorcol_flag = 0;
    int errorcol_flag = 0;
    int status = 0;
    long repeat = 0;
    long width = 0;
    int anynul = 0;
    int hdutype = 0;
    int coltype = 0;
    int nulval = 0;
    int ncols = 0;
    int units_element = 0;
    int colname_element = 0;
    char paramfile_fullpath[FILENAME_MAX];
    char outfile_fullpath[FILENAME_MAX];
    char outtype_read[32];
    char outtype[32];
    char keyname[32];
    char comment[256];
    char colname_raw[COLNAME_CHARSIZE];
    char colname[COLNAME_CHARSIZE];
    char lastcolname[COLNAME_CHARSIZE];
    char units_raw[UNIT_CHARSIZE];
    char units[UNIT_CHARSIZE];
    
    int value_TINT[2];
    long value_TLONG[2];
    float value_TFLOAT[2];
    double value_TDOUBLE[2];

    FILE *filestream = NULL;
    FILE *fp_outfile = NULL;

    /* Init */
    for (int i=0; i<2; i++) {
        value_TINT[i] = 0;
        value_TLONG[i] = 0;
        value_TFLOAT[i] = 0.0;
        value_TDOUBLE[i] = 0.0;
    }

    /* Read arguments */
    if ( argc == 3 ) {
        snprintf(paramfile_fullpath, sizeof(paramfile_fullpath), "%s", argv[1]);
        snprintf(outtype_read, sizeof(outtype_read), "%s", argv[2]);
    }
    else if ( argc == 4 ) {
        snprintf(paramfile_fullpath, sizeof(paramfile_fullpath), "%s", argv[1]);
        snprintf(outtype_read, sizeof(outtype_read), "%s", argv[2]);
        snprintf(outfile_fullpath, sizeof(outfile_fullpath), "%s", argv[3]);
    }
    else {
        fprintf(stderr, "Usage : ./prparam\n");
        fprintf(stderr, "    $1 paramfile\n");
        fprintf(stderr, "    $2 outtype ('stdout' or 'file')\n");
        fprintf(stderr, "    $3 outfilename (optional)\n");
        return -1;
    }


    /* Check outtype */
    if ( strcmp(outtype_read, "STDOUT") == 0 || strcmp(outtype_read, "stdout") == 0 || strcmp(outtype_read, "S") == 0 || strcmp(outtype_read, "s") == 0 ) {
        snprintf(outtype, sizeof(outtype), "STDOUT");
    }
    else if ( strcmp(outtype_read, "FILE") == 0 || strcmp(outtype_read, "file") == 0 || strcmp(outtype_read, "F") == 0 || strcmp(outtype_read, "f") == 0 ) {
        
        snprintf(outtype, sizeof(outtype), "FILE");
        
        // Make outfile
        if ( argc == 3 ) snprintf(outfile_fullpath, sizeof(outfile_fullpath), "./params.csv");
        fp_outfile = fopen(outfile_fullpath, "w");
        if ( fp_outfile == NULL ) {
            fprintf(stderr, "*** Error\n");
            fprintf(stderr, "Cannot make the outfile!\n");
            fprintf(stderr, "abort\n");
            return -10;
        }

    }
    else {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "outtype ($2) must be 'stdout' or 'file'\n");
        fprintf(stderr, "abort\n");
        return -2;
    }


    /* Read param files */
    fitsfile *fp_param = NULL;
    if ( fits_open_file(&fp_param, paramfile_fullpath, READONLY, &status) != 0 ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "FITS file open error!\n");
        fprintf(stderr, "file   : %s\n", argv[1]);
        fprintf(stderr, "status : %d\n", status);
        fprintf(stderr, "abort\n");
        return -1;
    }


    /* Read information of paramfile */
    // Set HDU (HDU number starts with 1)
    fits_movabs_hdu(fp_param, 2, &hdutype, &status);
    // Get column number
    fits_get_num_cols(fp_param, &ncols, &status);


    for ( long i=1; i<=ncols; i++ ) {
        
        /* Ignore some columns */
        if ( i <= COLUMN_IGNORE ) continue;

        /* Read fits */
        // Get colname
        snprintf(keyname, sizeof(keyname), "TTYPE%ld", i);
        fits_read_keyword(fp_param, keyname, colname_raw, comment, &status);
        // Eliminate single quotations
        colname_element = 0;
        for (int j=0; j<UNIT_CHARSIZE; j++) {
            // 32 and 39 are the character code for spaces and single quotes, respectively.
            if ( colname_raw[j] != 32 && colname_raw[j] != 39 ) {
                colname[colname_element] = colname_raw[j];
                colname_element ++;
            }
        }

        // Get coltype
        fits_get_coltype(fp_param, i, &coltype, &repeat, &width, &status);

        // Error column or not error column
        if ( repeat == 1 ) {
            errorcol_flag = 0;
        }
        else if ( repeat == 2 ) {
            errorcol_flag = 1;
        }
        else {
            fprintf(stderr, "*** Error\n");
            fprintf(stderr, "repeat value must be 1 or 2!\n");
            fprintf(stderr, "value : %ld\n", repeat);
            fprintf(stderr, "abort\n");
            return -1;
        }

        // Get col value
        if ( coltype == TINT ) fits_read_col(fp_param, coltype, i, 1, 1, repeat, &nulval, value_TINT, &anynul, &status);
        else if ( coltype == TLONG ) fits_read_col(fp_param, coltype, i, 1, 1, repeat, &nulval, value_TLONG, &anynul, &status);
        else if ( coltype == TFLOAT ) fits_read_col(fp_param, coltype, i, 1, 1, repeat, &nulval, value_TFLOAT, &anynul, &status);
        else if ( coltype == TDOUBLE ) fits_read_col(fp_param, coltype, i, 1, 1, repeat, &nulval, value_TDOUBLE, &anynul, &status);

        // Get Units
        snprintf(keyname, sizeof(keyname), "TUNIT%ld", i);
        fits_read_keyword(fp_param, keyname, units_raw, comment, &status);
        // Eliminate spaces and single quotations
        units_element = 0;
        for (int j=0; j<UNIT_CHARSIZE; j++) {
            // 32 and 39 are the character code for spaces and single quotes, respectively.
            if ( units_raw[j] != 32 && units_raw[j] != 39 ) {
                units[units_element] = units_raw[j];
                units_element ++;
            }
        }


        /* Write result */
        if ( strcmp(outtype, "STDOUT") == 0 ) filestream = stdout;
        else if ( strcmp(outtype, "FILE") == 0 ) filestream = fp_outfile;

        if ( errorcol_flag == 0 && last_errorcol_flag == 0 ) {
            
            if ( coltype == TINT ) fprintf(filestream, "\n%s, %d", colname, value_TINT[0]);
            else if ( coltype == TLONG ) fprintf(filestream, "\n%s, %ld", colname, value_TLONG[0]);
            else if ( coltype == TFLOAT ) fprintf(filestream, "\n%s, %E", colname, value_TFLOAT[0]);
            else if ( coltype == TDOUBLE ) fprintf(filestream, "\n%s, %E", colname, value_TDOUBLE[0]);
            
        }
        else if ( errorcol_flag == 0 && last_errorcol_flag == 1 ) {

            if ( coltype == TINT ) fprintf(filestream, "%s, %d", colname, value_TINT[0]);
            else if ( coltype == TLONG ) fprintf(filestream, "%s, %ld", colname, value_TLONG[0]);
            else if ( coltype == TFLOAT ) fprintf(filestream, "%s, %E", colname, value_TFLOAT[0]);
            else if ( coltype == TDOUBLE ) fprintf(filestream, "%s, %E", colname, value_TDOUBLE[0]);
            
        }
        else if ( errorcol_flag == 1 && last_errorcol_flag == 0 ) {

            if ( coltype == TINT ) fprintf(filestream, ", %d, %d\n", value_TINT[0], value_TINT[1]);
            else if ( coltype == TLONG ) fprintf(filestream, ", %ld, %ld\n", value_TLONG[0], value_TLONG[1]);
            else if ( coltype == TFLOAT ) fprintf(filestream, ", %E, %E\n", value_TFLOAT[0], value_TFLOAT[1]);
            else if ( coltype == TDOUBLE ) fprintf(filestream, ", %E, %E\n", value_TDOUBLE[0], value_TDOUBLE[1]);
            
        }
        

        /* Reset variables */
        snprintf(lastcolname, sizeof(lastcolname), "%s", colname);
        for (int j=0; j<UNIT_CHARSIZE; j++) {
            units[j] = '\0';
            units_raw[j] = '\0';
        }
        for (int j=0; j<COLNAME_CHARSIZE; j++) {
            colname[j] = '\0';
            colname_raw[j] = '\0';
        }
        last_errorcol_flag = errorcol_flag;

    }

    /* fclose */
    fits_close_file(fp_param, &status);
    if ( strcmp(outtype, "FILE") == 0 ) fclose(fp_outfile);

    return status;

}
