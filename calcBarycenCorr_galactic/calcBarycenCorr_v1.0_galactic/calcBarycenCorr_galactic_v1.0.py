#!/usr/bin/env python3

# calcBarycenCorr
# 2025.06.03 v1.0 by Yuma Aoki (Kindai Univ.)

from __future__ import print_function, division
from PyAstronomy import pyasl   # type: ignore
import sys
from astropy.coordinates import SkyCoord
from astropy import units as u
import numpy as np

VERSION = 1.0

def main(ra2000, dec2000, jd):
    
    longitude = 0.0
    latitude = 0.0
    altitude = 0.0

    # 地球の運動補正（pyasl）
    corr, hjd = pyasl.helcorr(longitude, latitude, altitude, ra2000, dec2000, jd, debug=False)

    # 天体の方向を銀河座標に変換
    coord = SkyCoord(ra=ra2000*u.deg, dec=dec2000*u.deg, frame='icrs')
    l_rad = coord.galactic.l.radian
    b_rad = coord.galactic.b.radian

    # 太陽運動（U,V,W）ベクトル（単位: km/s）
    U, V, W = 11.1, 12.24 + 220.0, 7.25

    # 観測方向ベクトル（銀河座標系）
    n_x = np.cos(b_rad) * np.cos(l_rad)
    n_y = np.cos(b_rad) * np.sin(l_rad)
    n_z = np.sin(b_rad)

    # 太陽運動補正（速度ベクトルの内積）
    v_sun_proj = (-U * n_x) + (V * n_y) + (W * n_z)

    # 合計補正
    total_corr = corr + v_sun_proj

    print(f"Barycentric correction [km/s]  : {corr:.3f}")
    print(f"Solar motion correction [km/s] : {v_sun_proj:.3f}")
    print(f"Total correction [km/s]        : {total_corr:.3f}")

if len(sys.argv[1:]) == 3:
    ra2000, dec2000, jd = map(float, sys.argv[1:])
    main(ra2000, dec2000, jd)
else:
    print(f'Usage : python calcBarycenCorr_v{VERSION}.py RA(deg) DEC(deg) JulianDay')
    sys.exit()
