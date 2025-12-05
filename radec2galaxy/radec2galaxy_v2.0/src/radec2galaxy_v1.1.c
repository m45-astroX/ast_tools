/*

    radec2galaxy

    2024.05.16 v1.0 by Yuma Aoki (Kindai Univ.)
    2024.09.06 v2.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <matrix.h>

/* Constant */
// Degree to radian
#define _DEG2RAD_ 0.0174532925

int main ( int argc, char *argv[] ) {

    double ra = 0.0;
    double dec = 0.0;
    double ra_rad = 0.0;
    double dec_rad = 0.0;
    double x_radec = 0.0;
    double y_radec = 0.0;
    double z_radec = 0.0;
    double x_galactic = 0.0;
    double y_galactic = 0.0;
    double z_galactic = 0.0;

    /* Arguments */
    if ( argc == 3 ) {
        ra = atof(argv[1]);
        dec = atof(argv[2]);
        ra_rad = ra * _DEG2RAD_;
        dec_rad = dec * _DEG2RAD_;
    }
    else {
        fprintf(stderr, "Usage : ./radec2galaxy ra dec\n");
        return -1;
    }

    // Vector (RADEC)
    x_radec = cos(dec_rad) * cos(ra_rad);
    y_radec = cos(dec_rad) * sin(ra_rad);
    z_radec = sin(dec_rad);

    // Vector (Galactic)
    x_galactic = (r2g[0][0] * x_radec + r2g[0][1] * y_radec + r2g[0][2] * z_radec);
    y_galactic = (r2g[1][0] * x_radec + r2g[1][1] * y_radec + r2g[1][2] * z_radec);
    z_galactic = (r2g[2][0] * x_radec + r2g[2][1] * y_radec + r2g[2][2] * z_radec);

    // coordinate
    fprintf(stdout, "l = %0.5f\n", atan( y_galactic / x_galactic ) / _DEG2RAD_);
    fprintf(stdout, "b = %0.5f\n", atan( z_galactic / sqrt ( x_galactic * x_galactic + y_galactic * y_galactic ) ) / _DEG2RAD_);

    return 0;

}