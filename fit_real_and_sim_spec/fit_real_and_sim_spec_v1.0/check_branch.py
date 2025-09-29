import uproot

filename = "sim_NH1e23_spectra.root"
treepath = "obs0/spectrum"

# ROOTファイルとTTreeを開く
with uproot.open(filename) as f:
    tree = f[treepath]
    print(tree.keys())  # ブランチの一覧を表示

