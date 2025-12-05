import numpy as np
import pandas as pd

# 定数定義
E_FeKa = 6.40  # Fe-Kα 線のエネルギー (keV)
m_e_c2 = 511   # 電子の静止エネルギー (keV)

# 散乱角 θ（度）をいくつか選択
theta_values = np.array([0, 30, 60, 90, 120, 150, 180])

# Compton Shoulder のエネルギーシフトを計算
E_CS_values = E_FeKa / (1 + (E_FeKa / m_e_c2) * (1 - np.cos(np.radians(theta_values))))
energy_shifts = E_FeKa - E_CS_values

# 結果をデータフレームに格納
df = pd.DataFrame({
    "散乱角 θ (度)": theta_values,
    "Compton Shoulder エネルギー (keV)": E_CS_values,
    "エネルギーシフト量 ΔE (keV)": energy_shifts
})

# 結果を表示
print(df)
