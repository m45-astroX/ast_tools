/*

    fit_real_and_sim_spec

    - 実データとシミュレーションスペクトルのカイ二乗を計算する
    - 実データとフィットするシミュレーションデータのfactorも算出する
    - 実データはResolve, シミュレーションスペクトルはMonacoを仮定

    - 入力ファイル
        - 観測スペクトル(xspecのiplotで作成したもの)
        - Monacoスペクトル
    - 出力
        - カイ二乗値が最も小さくなるときの、シミュレーションスペクトルのfactor
    - 出力ファイル
        - factor_vs_chi-squared.dat
            - factor vs chi-squared

    2025.06.23 v1.0 by Yuma Aoki (Kindai Univ.)
    
*/

//#define DEBUG
// フィットする範囲の指定
#define FIT_MIN_KEV 5.0
#define FIT_MAX_KEV 8.0
// 観測スペクトルの情報
#define RESOLVE_N_CH 60000
#define RESOLVE_MIN_CH 0
#define RESOLVE_MAX_CH 59999
#define RESOLVE_EV_2_CH 2.0     // eVからchに変換するために掛ける値
// シミュレーションスペクトルの情報
#define SIM_MIN_CH 0
#define SIM_MAX_CH 59999
#define SIM_EV_2_CH 2.0
// factor
#define FACTOR_INIT 0.1
#define FACTOR_MAX 10.0
#define FACTOR_STEP 0.1

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main ( int argc, char *argv[] ) {

    if ( argc != 3 ) {
        fprintf(stdout, "Usage : ./fit_real_and_sim_spec\n");
        fprintf(stdout, "    $1 obs_specfile\n");
        fprintf(stdout, "    $2 sim_specfile\n");
        return -1;
    }
    
    /* Variables */
    int channel = 0;
    int energy_ch = 0;
    double energy_keV = 0.0;
    double energy_eV = 0.0;
    double counts = 0.0;
    int fit_min_ch = FIT_MIN_KEV * 1000.0 * RESOLVE_EV_2_CH;
    int fit_max_ch = FIT_MAX_KEV * 1000.0 * RESOLVE_EV_2_CH;
    // データ読み込み用変数
    char buf[4096];
    double readvalue[10];
    // 計算用変数
    double chiSquare_best = 100000000000.0;
    double factor_best = 0.0;

    // ファイル名
    char obsspec_fullpath[FILENAME_MAX];
    char simspec_fullpath[FILENAME_MAX];
    char chisq_result_fullpath[FILENAME_MAX];
    snprintf(obsspec_fullpath, sizeof(obsspec_fullpath), "%s", argv[1]);
    snprintf(simspec_fullpath, sizeof(simspec_fullpath), "%s", argv[2]);
    snprintf(chisq_result_fullpath, sizeof(chisq_result_fullpath), "factor_vs_chi-squared.dat");

    // メモリ取得
    double *obs_spec = NULL;
    obs_spec = (double*) malloc (sizeof(double) * RESOLVE_N_CH);
    double *sim_spec = NULL;
    sim_spec = (double*) malloc (sizeof(double) * RESOLVE_N_CH);

    /* Files */
    // Observation file
    FILE *fp_obsspec = NULL;
    fp_obsspec = fopen(obsspec_fullpath, "r");
    if ( fp_obsspec == NULL ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not open obs_specfile (%s)\n", obsspec_fullpath);
        fprintf(stderr, "abort\n");
        return -1;
    }
    FILE *fp_simspec = NULL;
    fp_simspec = fopen(simspec_fullpath, "r");
    if ( fp_simspec == NULL ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not open sim_specfile (%s)\n", simspec_fullpath);
        fprintf(stderr, "abort\n");
        return -1;
    }
    FILE *fp_chisq_result = NULL;
    fp_chisq_result = fopen(chisq_result_fullpath, "w");
    if ( fp_chisq_result == NULL ) {
        fprintf(stderr, "*** Error\n");
        fprintf(stderr, "Can not open fp_chisq_result (%s)\n", chisq_result_fullpath);
        fprintf(stderr, "abort\n");
        return -1;
    }

    /* Read the observation file */
    while ( fgets( buf, sizeof(buf), fp_obsspec ) != NULL ) {

        // The format of obsdatafile
        //    $1(0) : Energy (keV)
        //    $3(2) : Counts (counts s^-1 keV^-1)
        if( sscanf( buf, "%lf %lf %lf %lf", &readvalue[0], &readvalue[1], &readvalue[2], &readvalue[3] ) != 4 ) {
            continue;
        }
        
        energy_keV = readvalue[0];
        counts = readvalue[2];
        energy_eV = energy_keV * 1000.0;
        energy_ch = (int) ( energy_eV * RESOLVE_EV_2_CH );
        
        // フォーマット確認
        if ( energy_ch < RESOLVE_MIN_CH || RESOLVE_MAX_CH < energy_ch ) continue;
        if ( counts == 0.0 ) continue;
        
        // スペクトル書き込み
        obs_spec[energy_ch] = counts;
        //fprintf(stdout, "obs_spec[%d] = %lf;\n", energy_ch, obs_spec[energy_ch]);
        
    }

    /* Read the simulation file */
    while ( fgets( buf, sizeof(buf), fp_simspec ) != NULL ) {

        // The format of simdatafile
        //    $1(0) : Energy (keV)
        //    $3(2) : Counts (counts s^-1 keV^-1)
        if( sscanf( buf, "%lf %lf %lf %lf", &readvalue[0], &readvalue[1], &readvalue[2], &readvalue[3] ) != 4 ) {
            continue;
        }
        
        energy_keV = readvalue[0];
        counts = readvalue[2];
        energy_eV = energy_keV * 1000.0;
        energy_ch = (int) ( energy_eV * SIM_EV_2_CH );
        
        // フォーマット確認
        if ( energy_ch < SIM_MIN_CH || SIM_MAX_CH < energy_ch ) continue;
        if ( counts == 0.0 ) continue;
        
        // スペクトル書き込み
        sim_spec[energy_ch] = counts;
        //fprintf(stdout, "sim_spec[%d] = %lf;\n", energy_ch, sim_spec[energy_ch]);
        
    }

    /* シミュレーションスペクトル全埋め */
    // シミュレーションスペクトルの参照値が0にならないよう、
    // 周辺のbinの数値を代入する
    for ( int i=SIM_MIN_CH; i<=SIM_MAX_CH; i++ ) {
        if ( i == 0 && sim_spec[i] == 0.0 ) { // 0番目のビンかつ値なし
            for ( int j=SIM_MIN_CH; j<=SIM_MAX_CH; j++) {
                
                // 値を見つけるまでループ継続
                // 見つけたらbreak
                if ( sim_spec[j] != 0.0 ) {
                    sim_spec[0] = sim_spec[j];
                    break;
                }
                
            }
        }
        else if ( sim_spec[i] == 0.0 ) {
            sim_spec[i] = sim_spec[i-1];
        }
    }

    //for ( int i=0; i<60000; i++) {
    //    printf("sim_spec[%d] = %lf\n", i, sim_spec[i]);
    //}

    /* factor ごとにカイ二乗値を計算 */
    for ( double factor=FACTOR_INIT; factor<=FACTOR_MAX; factor=factor+FACTOR_STEP) {

        #ifdef DEBUG
        printf("factor = %.2f\n", factor);
        #endif

        /* カイ二乗値計算 */
        // もしobsspecのビンに値が入っている場合、カイ二乗を計算
        // 誤差はポアソン
        // i: 観測スペクトルのインクリメント
        double chiSquare = 0.0;
        for ( int i=RESOLVE_MIN_CH; i<=RESOLVE_MAX_CH; i++ ) {
            
            // フィット範囲外ならスキップ
            if ( i < fit_min_ch || fit_max_ch < i ) {
                continue;
            }
            // 値が無ければスキップ
            if ( obs_spec[i] == 0.0 ) {
                continue;
            }
            
            chiSquare += ( ( obs_spec[i] - sim_spec[i]*factor ) / sqrt(obs_spec[i]) ) * ( ( obs_spec[i] - sim_spec[i]*factor ) / sqrt(obs_spec[i]) );
            
        }
        
        // 結果書き込み
        fprintf(fp_chisq_result, "%.5f %.5f\n", factor, chiSquare);

        // カイ二乗値更新
        if ( chiSquare < chiSquare_best ) {
            chiSquare_best = chiSquare;
            factor_best = factor;
        }
        
        #ifdef DEBUG
        fprintf(stdout, "chiSquare = %lf\n", chiSquare);
        #endif

    }

    /* Print results */
    fprintf(stdout, "chiSquare_best = %.2f\n", chiSquare_best);
    fprintf(stdout, "factor_best    = %.2f\n", factor_best);

    /* Close files */
    fclose(fp_obsspec);
    fclose(fp_simspec);
    fclose(fp_chisq_result);
    
    return 0;

}
