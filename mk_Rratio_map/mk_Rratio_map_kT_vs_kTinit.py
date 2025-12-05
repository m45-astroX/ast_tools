#!/usr/bin/env python3
import numpy as np
import matplotlib.pyplot as plt
import argparse
from matplotlib.patches import Rectangle

def make_edges(array):
    """セル中心値 array から pcolormesh 用の境界値を生成する"""
    log_vals = np.log10(array)
    log_centers = (log_vals[1:] + log_vals[:-1]) / 2
    log_edges = np.concatenate(([log_vals[0] - (log_centers[0] - log_vals[0])],log_centers,[log_vals[-1] + (log_vals[-1] - log_centers[-1])]))
    return 10**log_edges

# ---------------------------
# 引数処理
# ---------------------------
parser = argparse.ArgumentParser(add_help=False)
parser.add_argument("input_file", type=str)
parser.add_argument("tau_value", type=float)
parser.add_argument("output_file", nargs="?", default=None)
parser.add_argument("--rmin", type=float, default=None)
parser.add_argument("--rmax", type=float, default=None)
parser.add_argument("--w", type=float, default=1.0, help="Rectangle line width")
parser.add_argument("--ln", action="store_true", help="Disable drawing rectangles")
parser.add_argument("--xmin", type=float, default=None, help="Minimum x-axis (kT) limit")
parser.add_argument("--xmax", type=float, default=None, help="Maximum x-axis (kT) limit")
parser.add_argument("--ymin", type=float, default=None, help="Minimum y-axis (kTinit) limit")
parser.add_argument("--ymax", type=float, default=None, help="Maximum y-axis (kTinit) limit")
parser.add_argument("-h", "--help", action="help", help="Show this help message")
args = parser.parse_args()

input_file = args.input_file
target_tau = args.tau_value
output_file = args.output_file
rmin = args.rmin
rmax = args.rmax
line_w = args.w
disable_lines = args.ln
xmin, xmax = args.xmin, args.xmax
ymin, ymax = args.ymin, args.ymax

# ---------------------------
# データ読み込み（3列以下無視）
# ---------------------------
valid = []
with open(input_file) as f:
    for line in f:
        if line.strip()=="" or line.startswith("#"):
            continue
        cols = line.split()
        if len(cols) < 4:
            continue
        try:
            valid.append([float(c) for c in cols[:4]])
        except:
            continue

data = np.array(valid)
kT, kTinit, tau, R = data.T

# τ に一致する行を抽出
mask = np.isclose(tau, target_tau, rtol=1e-4, atol=1e-4)
if not np.any(mask):
    print(f"No data for tau={target_tau}")
    exit()
sub_kT = kT[mask]
sub_kTinit = kTinit[mask]
sub_R = R[mask]

# 軸リスト（中心値）
kT_list = np.unique(sub_kT)
kTinit_list = np.unique(sub_kTinit)

# ---------------------------
# Rmap（kTinit vs kT）作成
# ---------------------------
Rmap = np.full((len(kTinit_list), len(kT_list)), np.nan)
for i, ki in enumerate(kTinit_list):
    for j, kj in enumerate(kT_list):
        if kj >= ki:  # RP条件
            continue
        ix = np.where((sub_kTinit == ki) & (sub_kT == kj))[0]
        if len(ix) > 0:
            Rmap[i, j] = sub_R[ix[0]]

# ---------------------------
# pcolormesh 用に「境界エッジ」を計算
# ---------------------------
kT_edges = make_edges(kT_list)
kTinit_edges = make_edges(kTinit_list)

# ---------------------------
# Plot
# ---------------------------
fig, ax = plt.subplots(figsize=(8,6))
X, Y = np.meshgrid(kT_edges, kTinit_edges)

pcm = ax.pcolormesh(X, Y, Rmap, cmap="viridis", shading="auto",
                    vmin=rmin, vmax=rmax)
plt.colorbar(pcm, label="Rratio")

ax.set_xscale("log")
ax.set_yscale("log")
ax.set_xlabel(r"$kT$ (keV)")
ax.set_ylabel(r"$kT_{\rm init}$ (keV)")
ax.set_title(f"Rratio map (kT vs kTinit) [tau={target_tau:.2e}]")

# ---------------------------
# 軸範囲設定（オプション優先）
# ---------------------------
if xmin is not None and xmax is not None:
    ax.set_xlim(xmin, xmax)
elif xmin is not None:
    ax.set_xlim(left=xmin)
elif xmax is not None:
    ax.set_xlim(right=xmax)
else:
    # デフォルト：対称軸範囲
    axis_min = min(kT_edges.min(), kTinit_edges.min())
    axis_max = max(kT_edges.max(), kTinit_edges.max())
    ax.set_xlim(axis_min, axis_max)

if ymin is not None and ymax is not None:
    ax.set_ylim(ymin, ymax)
elif ymin is not None:
    ax.set_ylim(bottom=ymin)
elif ymax is not None:
    ax.set_ylim(top=ymax)
else:
    axis_min = min(kT_edges.min(), kTinit_edges.min())
    axis_max = max(kT_edges.max(), kTinit_edges.max())
    ax.set_ylim(axis_min, axis_max)

# ---------------------------
# ✅ 条件に合うマスに赤枠（--ln で無効）
# ---------------------------
if not disable_lines:
    for i in range(len(kTinit_list)):
        for j in range(len(kT_list)):
            if 1.24 < Rmap[i, j] < 2.38:
                rect = Rectangle(
                    (kT_edges[j], kTinit_edges[i]),
                    kT_edges[j+1] - kT_edges[j],
                    kTinit_edges[i+1] - kTinit_edges[i],
                    fill=False, edgecolor="red",
                    linewidth=line_w
                )
                ax.add_patch(rect)

plt.tight_layout()

if output_file:
    plt.savefig(output_file, dpi=300)
    print(f"Saved {output_file}")
else:
    plt.show()
