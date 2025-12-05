/*

    sxs_pixel_definition

    v1.0 by Yuma Aoki (Kindai Univ.)
    v2.0 by Yuma Aoki (Kindai Univ.)
        - DET座標の定義を間違えていたので修正
    
    参考資料 : ASTRO-H COORDINATES DEFINITIONS ASTH-SCT-020
    
    SXSのピクセル配置(Look-up View)

        -------------------
        |23|24|26|34|32|30|
        -------------------
        |21|22|25|33|31|29|
        -------------------
        |19|20|18|35|28|27|
        -------------------
        | 9|10|17| 0| 2| 1|
        -------------------
        |11|13|15| 7| 4| 3|
        -------------------
        |12|14|16| 8| 6| 5|
        -------------------

    Note : Pixel 12 is the calibration pixel   

*/

#ifndef SXS_PIXEL_DEFINITION
#define SXS_PIXEL_DEFINITION

// 要素番号:ピクセル番号(0--35) ,値:DET-X座標(1--6)
static int xaxis_value_ref[36] = {
    4,6,5,6,5,6,5,4,4,
    1,2,1,1,2,2,3,3,3,
    3,1,2,1,2,1,2,3,3,
    6,5,6,6,5,5,4,4,4
};

// 要素番号:ピクセル番号(0--35) ,値:DET-Y座標(1--6)
static int yaxis_value_ref[36] = {
    3,3,3,2,2,1,1,2,1,
    3,3,2,1,2,1,2,1,3,
    4,4,4,5,5,6,6,5,6,
    4,4,5,6,5,6,5,6,4
};

#endif
