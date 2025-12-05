/*

    calcVelocity

    2024.05.08 v1.0 by Yuma Aoki

*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define _SCRIPT_VERSION_ 1.0
#define V_LIGHT_KMPS 300000.0

double velocity_kmps ( double E0_EV, double E_EV );

int main ( int argc, char *argv[] ) {

    if ( argc != 3 ) {
        fprintf(stderr, "Usage : ./calcVelocity initEnergy(eV) shiftedEnergy(eV) \n");
        return 0;
    }

    double E0_EV = (double) atof(argv[1]);    
    double E_EV = (double) atof(argv[2]);

    if ( E_EV < E0_EV ) {
        fprintf(stderr, "shiftedEnergy ($2) must be larger than initEnergy ($3)!\n");
        fprintf(stderr, "abort\n");
        return -1;
    }

    fprintf(stdout, "initEnergy    = %s eV\n", argv[1]);
    fprintf(stdout, "shiftedEnergy = %s eV\n", argv[2]);
    fprintf(stdout, "Velocity      = %.10lf km/s\n", velocity_kmps(E0_EV, E_EV));
    
    return 0;

}


double velocity_kmps ( double E0_EV, double E_EV ) {

    return ( -1.0 * (2.0*E_EV*E_EV)/(V_LIGHT_KMPS) + sqrt((4.0*E_EV*E_EV*E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) - 4.0*((E0_EV*E0_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) + (E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS))*(E0_EV*E0_EV - E_EV*E_EV)) ) / ( 2.0 * ( (E0_EV*E0_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) + (E_EV*E_EV)/(V_LIGHT_KMPS*V_LIGHT_KMPS) ) );

}
