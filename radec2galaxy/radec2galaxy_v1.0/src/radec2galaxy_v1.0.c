/*

    radec2galaxy

    2024.05.16 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Constant */
// 昇交点赤経(Ω)
#define _OMEGA_ 284.01667
// 昇交点赤緯(δ_Ω)
#define _DELTA_OMEGA_ 0.0
// 傾斜角(I)
#define _I_ 62.8667
// 対赤道昇交点銀経(θ)
#define _THETA_ 32.93359
// Degree to radian
#define _DEG2RAD_ 0.0174532925

int main ( int argc, char *argv[] ) {

    double ra = 0.0;
    double dec = 0.0;

    /* Arguments */
    if ( argc == 3 ) {
        ra = atof(argv[1]);
        dec = atof(argv[2]);
    }
    else {
        fprintf(stderr, "Usage : ./galaxy2radec ra dec\n");
        return -1;
    }

    fprintf(stdout, "%lf\n", atan(_DEG2RAD_*(sin(_I_)*sin(dec) + cos(_I_)*cos(dec)*sin(ra-_OMEGA_))/(cos(dec)*cos(ra-_OMEGA_))) + _THETA_);
    fprintf(stdout, "%lf\n", sin(3.1415926535));
    return 0;

}