#!/bin/bash

infile="Rratio.dat"
outfile="Rratio_edit.dat"

cat $infile | awk '$1<$2 && NF==4 {print}' > $outfile
