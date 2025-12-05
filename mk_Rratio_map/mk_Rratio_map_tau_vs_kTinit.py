#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
import argparse
from matplotlib.patches import Rectangle

def make_edges(array):
    """セル中心 array から pcolormesh の境界 edge を生成（ログスケール対応）"""
    log_vals = np.log10(array)
    # 隣接中心の平均 → edge用の中心
    log_centers = (log_vals[1:] + log_vals[:-1]) / 2
    # 最初と最後の補外
    log_edges = np.concatenate((
        [log_vals[0] - (log_centers[0] - log_vals[0])],
        log_centers,
        [log_vals[-1] + (log_vals[-1] - log_centers[-1])]
    ))
    return 10**log_edges

# --- 引数処理 ---
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("input_file", type=str)
parser.add_argument("kT_value", type=float)
parser.add_argument("output_file", nargs="?", default=None)
parser.add_argument("--rmin", type=float, default=None, help="Colorbar minimum")
parser.add_argument("--rmax", type=float, default=None, help="Colorbar maximum")
parser.add_argument("--w", type=float, default=1.0, help="Rectangle line width")
parser.add_argument("--ln", action="store_true", help="Disable drawing red rectangles")
parser.add_argument("--xmin", type=float, default=None, help="Min τ-axis")
parser.add_argument("--xmax", type=float, default=None, help="Max τ-axis")
parser.add_argument("--ymin", type=float, default=None, help="Min kTinit-axis")
parser.add_argument("--ymax", type=float, default=None, help="Max kTinit-axis")
parser.add_argument("-h", "--help", action="help", help="Show this help message and exit")
args = parser.parse_args()

input_file = args.input_file
target_kT  = args.kT_value
output_file = args.output_file
rmin = args.rmin
rmax = args.rmax
line_w = args.w
disable_lines = args.ln
xmin, xmax = args.xmin, args.xmax
ymin, ymax = args.ymin, args.ymax

# --- データ読み込み（4列未満スキップ） ---
valid_rows = []
with open(input_file, "r") as f:
    for line in f:
        if (not line.strip()) or line.strip().startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 4:
            continue
        try:
            row = [float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])]
            valid_rows.append(row)
        except ValueError:
            pass

if len(valid_rows) == 0:
    print("Error: No valid 4-column rows in file.")
    exit(1)

data = np.array(valid_rows)
kT     = data[:,0]
kTinit = data[:,1]
tau    = data[:,2]
R      = data[:,3]

# --- kT で抽出 ---
mask = np.isclose(kT, target_kT, rtol=1e-4, atol=1e-4)
if not np.any(mask):
    print(f"Error: No data found for kT = {target_kT}")
    exit(1)

sub_kTinit = kTinit[mask]
sub_tau    = tau[mask]
sub_R      = R[mask]

kTinit_list = np.unique(sub_kTinit)
tau_list    = np.unique(sub_tau)

if len(kTinit_list) == 0 or len(tau_list) == 0:
    print("Error: No valid (kTinit, tau) pairs after filtering.")
    exit(1)

# --- Rmap 作成 [kTinit vs tau] ---
Rmap = np.full((len(kTinit_list), len(tau_list)), np.nan)
for i, ki in enumerate(kTinit_list):
    for j, t in enumerate(tau_list):
        if target_kT <= ki:  # RP条件: kT < kTinit でのみ有効
            idx = np.where((sub_kTinit == ki) & (sub_tau == t))[0]
            if len(idx) > 0:
                Rmap[i, j] = sub_R[idx[0]]

# --- pcolormesh 用の境界 ---
kTinit_edges = make_edges(kTinit_list)
tau_edges = make_edges(tau_list)

# --- プロット ---
fig, ax = plt.subplots(figsize=(8,6))
X, Y = np.meshgrid(tau_edges, kTinit_edges)

pcm = ax.pcolormesh(
    X, Y, Rmap, cmap='viridis', shading='auto',
    vmin=rmin, vmax=rmax
)
plt.colorbar(pcm, label="Rratio")

ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel(r"$\tau$ (cm$^{-3}$ s)")
ax.set_ylabel(r"$kT_{\rm init}$ (keV)")
ax.set_title(f"Rratio Map (tau vs kT_init) [kT = {target_kT:.2f} keV]")

# --- 軸範囲の設定 ---
if xmin is not None or xmax is not None:
    ax.set_xlim(left=xmin if xmin is not None else None,
                right=xmax if xmax is not None else None)

if ymin is not None or ymax is not None:
    ax.set_ylim(bottom=ymin if ymin is not None else None,
                top=ymax if ymax is not None else None)

# --- 赤枠（1.24 < R < 2.38） ---
if not disable_lines:
    for i in range(len(kTinit_list)):
        for j in range(len(tau_list)):
            if 1.24 < Rmap[i, j] < 2.38:
                rect = Rectangle(
                    (tau_edges[j], kTinit_edges[i]),
                    tau_edges[j+1] - tau_edges[j],
                    kTinit_edges[i+1] - kTinit_edges[i],
                    fill=False, edgecolor='red', linewidth=line_w
                )
                ax.add_patch(rect)

plt.tight_layout()

if output_file:
    plt.savefig(output_file, dpi=300)
    print(f"Saved to {output_file}")
else:
    plt.show()
