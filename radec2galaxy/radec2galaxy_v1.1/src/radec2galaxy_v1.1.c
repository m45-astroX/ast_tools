/*

    radec2galaxy

    2024.05.16 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

/* Constant */
// 昇交点赤経(Ω, deg)
#define _OMEGA_ 284.01667
// 昇交点赤緯(δ_Ω)
#define _DELTA_OMEGA_ 0.0
// 傾斜角(I)
#define _I_ 62.8667
// 対赤道昇交点銀経(θ)
#define _THETA_ 32.93359
// Degree to radian
#define _DEG2RAD_ 0.0174532925


#define _OMEGA_RAD_ 4.957026016385975
#define _I_RAD_ 1.09723090360975
#define _THETA_RAD_ 0.574799579345075


int main ( int argc, char *argv[] ) {

    double ra = 0.0;
    double dec = 0.0;
    double ra_rad = 0.0;
    double dec_rad = 0.0;

    /* Arguments */
    if ( argc == 3 ) {
        ra = atof(argv[1]);
        dec = atof(argv[2]);
        ra_rad = ra * _DEG2RAD_;
        dec_rad = dec * _DEG2RAD_;
    }
    else {
        fprintf(stderr, "Usage : ./galaxy2radec ra dec\n");
        return -1;
    }

    fprintf(stdout, "%lf\n", atanf(((double)sinf((double)_I_RAD_)*(double)sinf((double)dec_rad) + (double)cosf((double)_I_RAD_)*(double)cosf((double)dec_rad)*(double)sinf((double)ra_rad-(double)_OMEGA_RAD_))/((double)cosf((double)dec_rad)*(double)cosf((double)ra_rad-(double)_OMEGA_RAD_)))/(double)_DEG2RAD_ + _THETA_);
    fprintf(stdout, "%lf\n", asinf((cosf(_I_RAD_)*sinf(dec_rad) - sinf(_I_RAD_)*cosf(dec_rad)*sinf(ra_rad-_OMEGA_RAD_)))/_DEG2RAD_);

    return 0;

}