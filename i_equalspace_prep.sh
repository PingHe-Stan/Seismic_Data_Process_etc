#!/bin/bash
# First Revise the original individual data; the second variable $2 in new_$individuals denote its position
# The parameter file SHGMT.PAR should be contained in the same file with SHGMT.sum SHGMT.gmt

xx=`awk 'NR=1{print ($1*2)+1}' SHGMT.PAR`

awk -v var=$xx '{if($0~/^>/) {var=var-2;print $0} else print $1,var,$3}' SHGMT.gmt > SHGMT_4.gmt
