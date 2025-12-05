/*
 
    calc_line_flux_electron.c 
 
    2025.09.26 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define NH 21                           // 水素柱密度 (×10**22 cm**(-2))
#define ENERGY_DENSITY 19               // 電子のエネルギー密度(eV cm**(-3))
#define ELECTRON_MASS 0.511             // 電子の静止質量(MeV)
#define ELECTRON_INDEX 2.0              // 電子の冪指数
#define ELECTRON_VELOCITY 0.01          // 電子の速度(MeV) 0.01MeV=10keV
#define VELOCITY_LIGHT 2.99792458E10    // 光速(cm/s)
#define SKY_RADIUS 3.0                  // 地球から見たときの分子雲の半径(arcmin)

double calc_K ( double integ_min, double integ_max );
double calc_K_index_2 ( double integ_min, double integ_max );
double calc_n ( double integ_min, double integ_max );
double calc_n_index_1 ( double integ_min, double integ_max );
double calc_velocity (void);
double calc_flux ( double integ_min, double integ_max, double omega, double abundance, double sigma );
double calc_sky_omega (void);

int main ( int argc, char *argv[] ) {
    
    if ( argc != 6 ) {
        fprintf(stderr, "Usage : ./calc_line_flux_electron cross-section omega relative_abundance integ_min(keV) integ_max(keV)\n");
        fprintf(stderr, "    cross-section : Cross-section (barn).\n");
        fprintf(stderr, "    omega : Fluorescence yield.\n");
        fprintf(stderr, "    relative_abundance : Relative abundance to Hydrogen.\n");
        fprintf(stderr, "    integ_min : The minimum value of integration (keV).\n");
        fprintf(stderr, "    integ_min : The maximum value of integration (keV).\n");
        return -1;
    }
    
    // 変数
    double flux = 0.0;
    double sigma = 0.0;
    double omega = 0.0;
    double integ_min = 0.0;
    double integ_max = 0.0;
    double abundance = 0.0;

    // 引数
    sigma = atof(argv[1]);
    omega = atof(argv[2]);
    abundance = atof(argv[3]);
    integ_min = atof(argv[4]);
    integ_max = atof(argv[5]);

    flux = calc_flux ( integ_min, integ_max, omega, abundance, sigma );

    fprintf(stdout, "%.10f\n", flux);

    return 0;
    
}

double calc_K ( double integ_min, double integ_max ) {

    return ( ENERGY_DENSITY * 0.001 ) / ( ( 1.0 / ( 2.0 - ELECTRON_INDEX ) ) * ( pow(integ_max, 2.0-ELECTRON_INDEX) - pow(integ_min, 2.0-ELECTRON_INDEX) ) );
    
}

double calc_K_index_2 ( double integ_min, double integ_max ) {

    return ( ENERGY_DENSITY * 0.001 ) / ( log(integ_max) - log(integ_min) );

}

double calc_n ( double integ_min, double integ_max ) {
    
    double K = 0.0;

    if ( ELECTRON_INDEX == 2 ) {
        K = calc_K_index_2 ( integ_min, integ_max );
    }
    else {
        K = calc_K ( integ_min, integ_max );
    }

    return K * ( 1 / ( 1 - ELECTRON_INDEX ) ) * ( pow(integ_max, 1-ELECTRON_INDEX) - pow(integ_min, 1-ELECTRON_INDEX) );

}

double calc_n_index_1 ( double integ_min, double integ_max ) {
    
    double K = 0.0;
    
    K = calc_K ( integ_min, integ_max );

    return K * ( log(integ_max) - log(integ_min) );

}

double calc_velocity (void) {

    return VELOCITY_LIGHT * sqrt( 1-(1/pow(1+ELECTRON_VELOCITY/ELECTRON_MASS, 2)) );

}

double calc_flux ( double integ_min, double integ_max, double omega, double abundance, double sigma ) {

    double v = 0.0;
    double n = 0.0;
    double sky_omega = 0.0;
    
    if ( ELECTRON_INDEX == 1.0 ) {
        n = calc_n_index_1 ( integ_min, integ_max );
    }
    else {
        n = calc_n ( integ_min, integ_max );
    }

    v = calc_velocity ();
    sky_omega = calc_sky_omega ();

    return ( 0.01 / ( 4 * M_PI ) ) * omega * abundance * sigma * v * n * NH * sky_omega;

}

double calc_sky_omega (void) {

    double radius_rad = SKY_RADIUS * 2.9088820867 * 0.0001;

    return 2 * M_PI * ( 1 - cos(radius_rad) );

}
