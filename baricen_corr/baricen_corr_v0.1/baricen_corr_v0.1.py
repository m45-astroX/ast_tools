#!/usr/bin/env python3

# baricen_corr

# 2024.11.07 v0.1 by Yuma Aoki (Kindai Univ.)

# References
#    https://pyastronomy.readthedocs.io/en/latest/pyaslDoc/aslDoc/baryvel.html


from __future__ import print_function, division
from PyAstronomy import pyasl   # type: ignore
import sys

VERSION = 1.0

def main () :

    # Coordinates of observator
    longitude = 0.0
    latitude = 0.0
    altitude = 0.0

    # Calculate barycentric correction (debug=True show various intermediate results)
    corr, hjd = pyasl.helcorr(longitude, latitude, altitude, ra2000, dec2000, jd, debug=False)

    print("Barycentric correction [km/s]: ", corr)
    #print("Heliocentric Julian day: ", hjd)


if len(sys.argv[1:]) == 3 :

    # Coordinates (J2000.0)
    ra2000 = float(sys.argv[1])
    dec2000 = float(sys.argv[2])

    jd = float(sys.argv[3])

    main ()

else :

    print('Usage : python baricen_corr_v', VERSION,'.py RA(deg) DEC(deg) JulianDay', sep='')
    sys.exit()
