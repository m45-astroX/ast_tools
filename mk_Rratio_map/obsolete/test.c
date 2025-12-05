#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "fitsio.h"

// cfitsio のエラー処理
void check_fits_status(int status, const char* step) {
    if (status) {
        fprintf(stderr, "FITS error at %s:\n", step);
        fits_report_error(stderr, status);
        exit(EXIT_FAILURE);
    }
}

int main() {
    // ===== 1. グリッド定義 =====
    const long NKT  = 100;         // kTinit bins
    const long NTAU = 120;         // tau bins (log spaced)
    const double KT_MIN  = 0.1;    // keV
    const double KT_MAX  = 5.0;    // keV
    const double TAU_MIN = 1e10;   // cm^-3 s
    const double TAU_MAX = 1e13;   // cm^-3 s

    double* img = (double*)malloc(sizeof(double) * NKT * NTAU);
    if (!img) {
        fprintf(stderr, "Error: cannot allocate memory.\n");
        return 1;
    }

    // ===== 2. ダミーモデル（尤度などに置き換えてOK）=====
    double KT0 = 2.0;        // keV
    double TAU0 = 1.0e12;    // center of Gaussian
    double S2_KT  = 0.30 * 0.30;
    double S2_TAU = (2.0e11)*(2.0e11);

    for (long j=0; j<NTAU; j++) {
        double fTau = (double)j/(NTAU-1);
        double tau = TAU_MIN * pow(TAU_MAX/TAU_MIN, fTau);  // 対数軸

        for (long i=0; i<NKT; i++) {
            double fKT = (double)i/(NKT-1);
            double kt = KT_MIN + fKT*(KT_MAX-KT_MIN);

            double dkt  = kt  - KT0;
            double dtau = tau - TAU0;
            double chi2 = (dkt*dkt)/S2_KT + (dtau*dtau)/S2_TAU;

            img[j*NKT + i] = exp(-0.5 * chi2);
        }
    }

    // ===== 3. FITSファイル書き込み =====
    fitsfile* fptr = NULL;
    int status = 0;
    char filename[] = "!ktinit_tau_map.fits";  // !で上書き許可

    long naxes[2] = {NKT, NTAU};
    check_fits_status(fits_create_file(&fptr, filename, &status), "create_file");
    check_fits_status(fits_create_img(fptr, DOUBLE_IMG, 2, naxes, &status), "create_img");

    // 画像データ全体
    long fpixel[2] = {1, 1};
    check_fits_status(fits_write_pix(fptr, TDOUBLE, fpixel, NKT*NTAU, img, &status), "write_pix");

    // ===== 4. ヘッダに WCS情報などを追記（一例）=====
    double crpix1 = 1.0, crval1 = KT_MIN;
    double cdelt1 = (KT_MAX - KT_MIN) / (NKT - 1);
    check_fits_status(fits_update_key(fptr, TSTRING, "CTYPE1", "kTinit", "Initial temperature", &status), "CTYPE1");
    check_fits_status(fits_update_key(fptr, TSTRING, "CUNIT1", "keV",    "Units of kTinit",   &status), "CUNIT1");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CRPIX1", &crpix1,  "Ref pixel axis1",    &status), "CRPIX1");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CRVAL1", &crval1,  "Value at ref pix",   &status), "CRVAL1");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CDELT1", &cdelt1,  "Increment per pix",  &status), "CDELT1");

    // y軸：tau / 対数軸
    double crpix2 = 1.0, crval2 = log(TAU_MIN);
    double cdelt2 = (log(TAU_MAX) - log(TAU_MIN)) / (NTAU - 1);
    char logaxis = 1; // T=1 (true) in FITS logical
    check_fits_status(fits_update_key(fptr, TSTRING, "CTYPE2", "TAU",      "n_e t timescale", &status), "CTYPE2");
    check_fits_status(fits_update_key(fptr, TSTRING, "CUNIT2", "cm^-3 s", "Units of n_e t", &status), "CUNIT2");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CRPIX2", &crpix2,   "Ref pixel axis2", &status), "CRPIX2");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CRVAL2", &crval2,   "ln(tau) at ref pix",&status), "CRVAL2");
    check_fits_status(fits_update_key(fptr, TDOUBLE, "CDELT2", &cdelt2,   "Increment ln(tau)",&status), "CDELT2");
    check_fits_status(fits_update_key(fptr, TLOGICAL,"LOGAX2", &logaxis,  "Axis2 logscale",   &status), "LOGAX2");

    // 任意の補足情報
    check_fits_status(fits_update_key(fptr, TSTRING, "BTYPE", "LIKELIHOOD",
                                      "Map data example", &status), "BTYPE");

    check_fits_status(fits_close_file(fptr, &status), "close_file");
    free(img);

    printf("FITS file written: ktinit_tau_map.fits\n");
    return 0;
}
