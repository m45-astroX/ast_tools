import numpy as np
import matplotlib.pyplot as plt

# --- データ読み込み（kT, τ, Rratio の3列） ---
data = np.loadtxt("Rratio_dummy.dat")
kT  = data[:,0]
tau = data[:,1]
R   = data[:,2]

# --- 軸（ユニーク値） ---
kT_list  = np.unique(kT)        # 例: 1,2,3...90
tau_list = np.unique(tau)       # 例: 1,2,3...900

# --- 2 次元配列 R(kT, τ) を作成 ---
Rmap = np.zeros((len(kT_list), len(tau_list)))
Rmap[:] = np.nan  # 初期化

for i, kt in enumerate(kT_list):
    for j, t in enumerate(tau_list):
        idx = np.where((kT == kt) & (tau == t))
        if len(idx[0]) > 0:
            Rmap[i, j] = R[idx]

# --- プロット（pcolormesh + 両軸log対応）---
plt.figure(figsize=(8,6))

# 不等間隔値に対応するため meshgrid を使用
X, Y = np.meshgrid(tau_list, kT_list)

pcm = plt.pcolormesh(X, Y, Rmap, shading='auto', cmap='viridis')

# ✅ 両軸を log スケールにする
plt.xscale('log')
plt.yscale('log')

# 軸ラベル・タイトルなど
plt.colorbar(pcm, label="Rratio")
plt.xlabel("τ  (cm$^{-3}$ s)")
plt.ylabel("kT$_{init}$  (keV)")
plt.title("Rratio Map (log τ vs log kT)")

plt.tight_layout()
plt.show()
