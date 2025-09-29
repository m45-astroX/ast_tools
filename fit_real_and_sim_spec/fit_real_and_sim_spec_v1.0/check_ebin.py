import uproot

# --- 入力 ---
filename = "sim_NH1e23_spectra.root"
histpath = "obs0/spectrum"

# --- 取得処理 ---
with uproot.open(filename) as f:
    hist = f[histpath]
    axis = hist.axis()
    edges = axis.edges()
    counts = hist.values()

    # タイトルの取得：attrsが使えない場合は member("fTitle")
    title = hist.member("fTitle") if hist.has_member("fTitle") else "(none)"

    print("===== Histogram Header Info =====")
    print(f"Name:          {hist.name}")
    print(f"Title:         {title}")
    print(f"Number of bins: {axis.size}")
    print(f"Xmin:          {edges[0]:.4f}")
    print(f"Xmax:          {edges[-1]:.4f}")
    print(f"Bin width:     {(edges[1] - edges[0]):.4f}")
    print(f"Total entries: {hist.entries}")
    print(f"Total sum:     {counts.sum():.1f}")
    print("==================================")
