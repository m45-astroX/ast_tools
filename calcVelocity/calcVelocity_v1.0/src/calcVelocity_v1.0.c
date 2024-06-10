/*

    calcVelocity

    2024.05.08 v1.0 by Yuma Aoki

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define V_LIGHT_KMPS 300000.0
#define E0_EV 6000.0

double velocity_kmps ( double E_EV );

int main ( int argc, char *argv[] ) {

    if ( argc != 2 ) {
        fprintf(stderr, "Usage : ./calcVelocity energy@6keV(eV)\n");
        return 0;
    }
    
    double E_EV = (double) atof(argv[1]);

    //fprintf(stdout, "E_EV = %lf\n", E_EV);

    fprintf(stdout, "%lf\n", velocity_kmps(E_EV));

    return 0;

}


double velocity_kmps ( double E_EV ) {

    return ( -1.0 * (2.0*E_EV*E_EV)/(V_LIGHT_KMPS) + sqrt((4.0*E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) - 4.0*((E0_EV*E0_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) + (E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS))*(E0_EV*E0_EV - E_EV*E_EV)) ) / ( 2.0 * ( (E0_EV*E0_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) + (E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) ) );

}
