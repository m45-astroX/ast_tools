import sys

def energy_width_to_velocity_width(delta_E_eV, E0_eV):
    c_km_s = 299792.458  # speed of light in km/s
    return (delta_E_eV / E0_eV) * c_km_s

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python calcVelocity_DopplarWidth.py line_center(eV) width(eV)")
        sys.exit(1)

    try:
        E0 = float(sys.argv[1])
        delta_E = float(sys.argv[2])
        v_width = energy_width_to_velocity_width(delta_E, E0)
        print(f"Dopplar width = {v_width:.2f} km/s")
    except ValueError:
        print("Error: Both arguments must be numbers.")

