/*

    galaxy2radec

    2024.09.06 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <matrix.h>

/* Constant */
// Degree to radian
#define _DEG2RAD_ 0.0174532925

int main ( int argc, char *argv[] ) {

    double l = 0.0;
    double b = 0.0;
    double l_rad = 0.0;
    double b_rad = 0.0;
    double x_galactic = 0.0;
    double y_galactic = 0.0;
    double z_galactic = 0.0;
    double x_radec = 0.0;
    double y_radec = 0.0;
    double z_radec = 0.0;
    double ra_deg = 0.0;
    double dec_deg = 0.0;
    int ra_h = 0;
    int ra_m = 0;
    double ra_s = 0.0;
    int dec_d = 0;
    int dec_m = 0;
    double dec_s = 0.0;

    /* Arguments */
    if ( argc == 3 ) {
        l = atof(argv[1]);
        b = atof(argv[2]);
        l_rad = l * _DEG2RAD_;
        b_rad = b * _DEG2RAD_;
    }
    else {
        fprintf(stderr, "Usage : ./galaxy2radec l b\n");
        return -1;
    }

    // Vector (Galaxy)
    x_galactic = cos(b_rad) * cos(l_rad);
    y_galactic = cos(b_rad) * sin(l_rad);
    z_galactic = sin(b_rad);
    
    // Vector (RADEC)
    x_radec = (g2r[0][0] * x_galactic + g2r[0][1] * y_galactic + g2r[0][2] * z_galactic);
    y_radec = (g2r[1][0] * x_galactic + g2r[1][1] * y_galactic + g2r[1][2] * z_galactic);
    z_radec = (g2r[2][0] * x_galactic + g2r[2][1] * y_galactic + g2r[2][2] * z_galactic);

    ra_deg = atanf( y_radec / x_radec ) / _DEG2RAD_;
    if ( ra_deg < 0 ) {
        ra_deg = fabs(ra_deg) + 180.0;
    }
    dec_deg = atanf( z_radec / sqrt ( x_radec * x_radec + y_radec * y_radec ) ) / _DEG2RAD_;

    // coordinate
    fprintf(stdout, "RA (deg)  = %0.5f\n", ra_deg);
    fprintf(stdout, "DEC (deg) = %0.5f\n\n", dec_deg);
    
    // 360度 = 24時 --> 1度  = 24/360時
    ra_h = (int) ( 24.0 / 360.0 * ra_deg );
    // 1度 = 60分
    ra_m = (int) ( ( ra_deg - (double)(int)ra_deg ) * 60.0 );
    // 1分 = 1/60度 && 1度 = 3600秒
    ra_s = ( ra_deg - (double)(int)ra_deg - (double) ( ra_m * 1.0 / 60.0 ) ) * 3600.0;

    //fprintf(stdout, "value = %08f\n", ra_deg - (double)(int)ra_deg);
    fprintf(stdout, "RA (hms)  = %02dh%02dm%02.2fs\n", ra_h, ra_m, ra_s);
    //fprintf(stdout, "DEC (hms) = %02dh m s\n", );

    return 0;

}