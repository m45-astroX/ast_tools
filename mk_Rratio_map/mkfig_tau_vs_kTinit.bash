#!/bin/bash

infile="Rratio_edit.dat"
script="/Users/aoki/git/ast_tools/mk_Rratio_map/mk_Rratio_map_tau_vs_kTinit.py"

kT_list=( \
1.0 2.0 5.0 7.0 \
10.0 20.0 50.0 70.0 \
)

for kT in ${kT_list[@]} ; do

outfile="tau_vs_kTinit_kT_${kT}.png"

python3 $script $infile $kT $outfile --rmin 0.0 --rmax 10.0 --xmin 5e9 --xmax 1e13 --ymin 1.0 --ymax 100.0

done
