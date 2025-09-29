/*
 
    calc_line_flux.c
 
    2025.09.25 v1.0 by Yuma Aoki (Kindai Univ.)

*/

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define N_DIV 100000        // 分割数
#define NH 21               // 水素柱密度 (×10**22 cm**(-2))
#define PHOTON_INDEX 2.0    // Sgr A* のスペクトルの光子指数
#define L_SGRA 8.0          // 4–8 keV におけるSgr A* の光度 (×10**37 erg s**(-1))
#define D_OBS_SGRA 8.5      // 観測者とSgr A*の距離 (kpc)
#define OMEGA_GC2 0.132942  // Sgr A* から見た GC2 の立体角 (sr)

double calc_A ( void );
double calc_A_index_2 ( void );
double integral_function ( char filename_database_sigma[], double integ_min, double integ_max, double omega, double abundance );

// 上付き文字
const char *sub_num[] = {
    "\xE2\x81\xB0", "\xC2\xB9", "\xC2\xB2", "\xC2\xB3", "\xE2\x81\xB4", "\xE2\x81\xB5",
    "\xE2\x81\xB6", "\xE2\x81\xB7", "\xE2\x81\xB8", "\xE2\x81\xB9", "\xE2\x81\xBA", "\xE2\x81\xBB", "\xC3\x97", "\xC3\xB7"
}; // 0, 1, 2,..., 9, +, -, ×, ÷

int main ( int argc, char *argv[] ) {
    
    if ( argc != 6 ) {
        fprintf(stderr, "Usage : ./CALC_CROSS_SECTION database_cross-section omega relative_abundance integ_min(keV) integ_max(keV)\n");
        fprintf(stderr, "    database_cross-section : The file path of cross-section database.\n");
        fprintf(stderr, "    omega : Fluorescence yield.\n");
        fprintf(stderr, "    relative_abundance : Relative abundance to Hydrogen.\n");
        fprintf(stderr, "    integ_min : The minimum value of integration (keV).\n");
        fprintf(stderr, "    integ_min : The maximum value of integration (keV).\n");
        return -1;
    }
    
    // 変数
    double omega = 0.0;
    double integ_min = 0.0;
    double integ_max = 0.0;
    double abundance = 0.0;
    char filename_database_sigma[FILENAME_MAX];

    // 引数
    snprintf(filename_database_sigma, sizeof(filename_database_sigma), "%s", argv[1]);
    omega = atof(argv[2]);
    abundance = atof(argv[3]);
    integ_min = atof(argv[4]);
    integ_max = atof(argv[5]);

    // 出力
    fprintf(stdout, "%.10lf %s10%s%s photons s%s%s cm%s%s\n", integral_function (filename_database_sigma, integ_min, integ_max, omega, abundance )*1.0e6, sub_num[12], sub_num[11], sub_num[6], sub_num[11], sub_num[1], sub_num[11], sub_num[2]);
    
    return 0;
    
}

double calc_A (void) {

    return ( L_SGRA * pow(10, 4) ) / ( 191.4392292 * (D_OBS_SGRA)*(D_OBS_SGRA) * ( (1.0/(2-PHOTON_INDEX)) * pow(8.0, 2-PHOTON_INDEX) - (1.0/(2-PHOTON_INDEX)) * pow(4.0, 2-PHOTON_INDEX) ));

}

double calc_A_index_2 (void) {

    return ( L_SGRA * pow(10, 4) ) / ( 191.4392292 * (D_OBS_SGRA)*(D_OBS_SGRA) * (log(8.0) - log(4.0)) );

}

double integral_function ( char filename_database_sigma[], double integ_min, double integ_max, double omega, double abundance ) {

    char buf[4096];
    double A = 0.0;
    double sum = 0.0;
    double dE = ( integ_max - integ_min ) / N_DIV;
    double last_energy_read = 0.0;
    double last_sigma_read = 0.0;
    double E = integ_min;
    double sigma = 0.0;
    double sigma_read = 0.0;
    double energy_read = 0.0;

    if ( PHOTON_INDEX == 2.0 ) {
        A = calc_A_index_2();
    }
    else {
        A = calc_A();
    }

    // ファイル開封
    FILE *fp_database_sigma = NULL;
    fp_database_sigma = fopen(filename_database_sigma, "r");
    if ( fp_database_sigma == NULL ) {
        return -1;
    }

    while ( E <= integ_max ) {
        
        last_energy_read = 0.0;
        last_sigma_read = 0.0;

        // エネルギーE(keV)における光電断面積sigmaの読み取り
        while ( fgets(buf, sizeof(buf), fp_database_sigma) != NULL ) {
            
            if ( sscanf(buf, "%lf %lf", &energy_read, &sigma_read) != 2 ) continue;

            if ( last_energy_read <= E && E < energy_read) {
                sigma = last_sigma_read;
                break;
            }

            last_energy_read = energy_read;
            last_sigma_read = sigma_read;
            
        }
        
        // 加算
        sum += sigma * pow(E, -1.0 * PHOTON_INDEX) * dE;
        E += dE;

        // ファイルポインタのリセット
        rewind(fp_database_sigma);

    }

    // ファイル閉じる
    fclose(fp_database_sigma);

    return 0.00079577471 * omega * OMEGA_GC2 * NH * abundance * A * sum;
    
}
