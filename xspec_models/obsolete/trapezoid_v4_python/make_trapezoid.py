from astropy.io import fits
import numpy as np

# モデルのパラメータ範囲
E1_values = np.linspace(5.0, 10.0, 10)  # E1 の範囲（5.0keV - 10.0keV）
E2_values = np.linspace(6.0, 12.0, 10)  # E2 の範囲
E3_values = np.linspace(7.0, 14.0, 10)  # E3 の範囲
E4_values = np.linspace(8.0, 16.0, 10)  # E4 の範囲

# エネルギーグリッド
energies = np.linspace(0.1, 20.0, 50)  # 0.1keV - 20keV のエネルギー範囲

# 出力スペクトルの計算（仮の関数）
def trapezoid_model(E1, E2, E3, E4, energy_grid):
    flux = np.zeros_like(energy_grid)
    for i in range(len(energy_grid) - 1):
        E_low = energy_grid[i]
        E_high = energy_grid[i + 1]

        if E_high <= E1 or E_low >= E4:
            flux[i] = 0.0
        elif E_low >= E2 and E_high <= E3:
            flux[i] = 1.0
        elif E_low < E2 and E_high > E1:
            flux[i] = (E_high - E_low) * ((E_high - E1) / (E2 - E1))
        elif E_low < E4 and E_high > E3:
            flux[i] = (E_high - E_low) * ((E4 - E_high) / (E4 - E3))
        else:
            flux[i] = (E_high - E_low)
    return flux

# 全パラメータで計算
spectra = []
for E1, E2, E3, E4 in zip(E1_values, E2_values, E3_values, E4_values):
    spectra.append(trapezoid_model(E1, E2, E3, E4, energies))

# FITS ファイルを作成
col1 = fits.Column(name='ENERG_LO', format='E', array=energies[:-1])
col2 = fits.Column(name='ENERG_HI', format='E', array=energies[1:])
col3 = fits.Column(name='PARAMVALS', format=f'{len(E1_values)}E', array=np.array([E1_values, E2_values, E3_values, E4_values]).T)
col4 = fits.Column(name='SPECTRA', format=f'{len(spectra)}E', array=np.array(spectra).T)

cols = fits.ColDefs([col1, col2, col3, col4])
hdu = fits.BinTableHDU.from_columns(cols, name='SPECTRA')

# **修正: ヘッダーに必要な情報を明示的に追加**
hdu.header['HDUCLASS'] = 'OGIP'
hdu.header['HDUCLAS1'] = 'XSPEC TABLE MODEL'
hdu.header['HDUCLAS2'] = 'ADDITIVE'
hdu.header['HDUCLAS3'] = 'MODEL'
hdu.header['NINTPARM'] = 4  # 整数パラメータの数
hdu.header['NROW'] = len(spectra)  # スペクトルの数
hdu.header['NOFFPARM'] = 0  # オフセットパラメータなし
hdu.header['NVEC'] = 1  # XSPEC用ベクトルモデル
hdu.header['MTYPE1'] = 'ENERGY'  # XSPEC 用
hdu.header['MFORM1'] = f'{len(energies)-1}E'  # エネルギーバンド数

# 保存
hdu.writeto('trapezoid_model.fits', overwrite=True)
