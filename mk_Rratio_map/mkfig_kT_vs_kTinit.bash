#!/bin/bash

infile="Rratio_edit.dat"
script="/Users/aoki/git/ast_tools/mk_Rratio_map/mk_Rratio_map_kT_vs_kTinit.py"

n_tau_list=( \
1 2 5 7 \
10 20 50 70 \
100 200 500 700 \
)

for n_tau in ${n_tau_list[@]} ; do

tau=$(echo "${n_tau}E10")
outfile="kT_vs_kTinit_tau_${tau}.png"

python3 $script $infile $tau $outfile --rmin 0.0 --rmax 10.0 --xmin 1 --xmax 100 --ymin 1 --ymax 100

done
