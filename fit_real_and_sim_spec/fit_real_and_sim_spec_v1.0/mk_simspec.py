import uproot
import numpy as np

filename = "sim_NH1e23_spectra.root"
histpath = "obs0/spectrum"  # histのパス

# TH1オブジェクトの読み込み
with uproot.open(filename) as f:
    hist = f[histpath]
    counts = hist.values()  # カウント（float型）
    channels = np.arange(len(counts))  # チャンネル番号（bin index）

# 2列データを作成
output_array = np.column_stack((channels, counts))

# ASCII形式で保存
np.savetxt("output_from_TH1.txt", output_array, fmt="%d %f", header="CHANNEL COUNTS")
