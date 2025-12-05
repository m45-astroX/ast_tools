#!/usr/bin/env python3

import numpy as np
import matplotlib.pyplot as plt
import argparse
from matplotlib.patches import Rectangle

def make_edges(array):
    log_vals = np.log10(array)
    log_centers = (log_vals[1:] + log_vals[:-1]) / 2
    log_edges = np.concatenate(([log_vals[0] - (log_centers[0] - log_vals[0])],
                                log_centers,
                                [log_vals[-1] + (log_vals[-1] - log_centers[-1])]))
    return 10 ** log_edges

# --- 引数処理 ---
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("input_file", type=str)
parser.add_argument("kTinit_value", type=float)
parser.add_argument("output_file", nargs="?", default=None)
parser.add_argument("--rmin", type=float, default=None)
parser.add_argument("--rmax", type=float, default=None)
parser.add_argument("--w", type=float, default=1.0, help="Rectangle line width")
parser.add_argument("--ln", action="store_true", help="Disable drawing red rectangles")
parser.add_argument("--xmin", type=float, default=None, help="Min value for τ axis")
parser.add_argument("--xmax", type=float, default=None, help="Max value for τ axis")
parser.add_argument("--ymin", type=float, default=None, help="Min value for kT axis")
parser.add_argument("--ymax", type=float, default=None, help="Max value for kT axis")
parser.add_argument("-h", "--help", action="help", help="Show help and exit")
args = parser.parse_args()

# --- 引数展開 ---
input_file = args.input_file
target_kTinit = args.kTinit_value
output_file = args.output_file
rmin = args.rmin
rmax = args.rmax
line_w = args.w
disable_lines = args.ln
xmin, xmax = args.xmin, args.xmax  # τ軸
ymin, ymax = args.ymin, args.ymax  # kT軸

# --- データ読み込み（3列以下スキップ） ---
valid_rows = []
with open(input_file) as f:
    for line in f:
        if line.strip() == "" or line.strip().startswith("#"):
            continue
        parts = line.split()
        if len(parts) < 4:
            continue
        try:
            valid_rows.append([float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3])])
        except:
            pass

if len(valid_rows) == 0:
    print("Error: No valid data in file.")
    exit()

data = np.array(valid_rows)
kT, kTinit, tau, R = data.T

# --- 指定 kTinit で抽出 ---
mask = np.isclose(kTinit, target_kTinit, rtol=1e-4, atol=1e-4)
if not np.any(mask):
    print(f"Error: No data found for kTinit = {target_kTinit}")
    exit()

sub_kT = kT[mask]
sub_tau = tau[mask]
sub_R = R[mask]

kT_list = np.unique(sub_kT)
tau_list = np.unique(sub_tau)

# --- Rmap 作成 ---
Rmap = np.full((len(kT_list), len(tau_list)), np.nan)
for i, kt in enumerate(kT_list):
    for j, t in enumerate(tau_list):
        if kt >= target_kTinit:
            continue
        idx = np.where((sub_kT == kt) & (sub_tau == t))[0]
        if len(idx) > 0:
            Rmap[i, j] = sub_R[idx[0]]

# --- セル境界 edges（pcolormesh用） ---
kT_edges = make_edges(kT_list)
tau_edges = make_edges(tau_list)

# --- Plot ---
fig, ax = plt.subplots(figsize=(8,6))
X, Y = np.meshgrid(tau_edges, kT_edges)

pcm = ax.pcolormesh(X, Y, Rmap, shading='auto', cmap='viridis', vmin=rmin, vmax=rmax)
plt.colorbar(pcm, label="Rratio")

ax.set_xscale('log')
ax.set_yscale('log')
ax.set_xlabel(r"$\tau$ (cm$^{-3}$ s)")
ax.set_ylabel(r"$kT$ (keV)")
ax.set_title(f"Rratio Map (tau vs kT) [kTinit = {target_kTinit:.2f} keV]")

# --- 軸範囲の設定（指定があれば優先） ---
# x軸（τ）
if xmin is not None or xmax is not None:
    ax.set_xlim(left=xmin if xmin is not None else None,
                right=xmax if xmax is not None else None)

# y軸（kT）
if ymin is not None or ymax is not None:
    ax.set_ylim(bottom=ymin if ymin is not None else None,
                top=ymax if ymax is not None else None)

# --- 赤枠（条件一致セル） ---
if not disable_lines:
    for i in range(len(kT_list)):
        for j in range(len(tau_list)):
            if 1.24 < Rmap[i, j] < 2.38:
                rect = Rectangle(
                    (tau_edges[j], kT_edges[i]),
                    tau_edges[j+1] - tau_edges[j],
                    kT_edges[i+1] - kT_edges[i],
                    fill=False, edgecolor='red', linewidth=line_w
                )
                ax.add_patch(rect)

plt.tight_layout()

# --- 保存 or 表示 ---
if output_file:
    plt.savefig(output_file, dpi=300)
    print(f"Saved to {output_file}")
else:
    plt.show()
