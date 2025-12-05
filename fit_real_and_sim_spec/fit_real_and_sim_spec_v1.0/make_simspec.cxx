void export_hist(const char* rootfile, const char* histpath, const char* outfile) {
    
    // ROOTファイルを開く
    TFile *f = TFile::Open(rootfile);
    if (!f || f->IsZombie()) {
        std::cerr << "Failed to open ROOT file: " << rootfile << std::endl;
        return;
    }

    // ヒストグラムを取得
    TH1D *h = (TH1D*)f->Get(histpath);
    if (!h) {
        std::cerr << "Failed to get histogram: " << histpath << std::endl;
        return;
    }

    // 出力ファイルを開く
    std::ofstream out(outfile);
    if (!out.is_open()) {
        std::cerr << "Failed to open output file: " << outfile << std::endl;
        return;
    }

    // ヒストグラムを書き出す
    for (int i = 1; i <= h->GetNbinsX(); ++i) {
        out << h->GetBinCenter(i) << " " << h->GetBinContent(i) << std::endl;
    }

    out.close();
    std::cout << "Exported to " << outfile << std::endl;
}
