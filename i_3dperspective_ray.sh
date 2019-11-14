#!/bin/bash
#This script is created to draw 3D perspective ray path in grdview map.
#Date: 2016-10-22 Author: Stan He

grdofmoho=./China1.grd
topo=./China.grd
psfileofsh=./PROCESSED_PSPIER.STX
outputforpsxyz=./3drays

#
awk '{print $3,$2}' PROCESSED_PSPIER.STX |grdtrack -G$topo > station.ele
awk '{print $6,$5}' PROCESSED_PSPIER.STX |grdtrack -G$grdofmoho > ps.depth

paste -d" " station.ele ps.depth | awk '{printf ">\n%5.5f %5.5f %5.5f\n%5.5f %5.5f %5.5f\n",$1,$2,$3,$4,$5,$6}' > $outputforpsxyz

# Ps Points at certain depth (-55000) 55km
#cat $outputforpsxyz |awk '{if(NR%3==0) print $1,$2" -55000";else print $0}' > ${outputforpsxyz}_5500

rm station.ele ps.depth

