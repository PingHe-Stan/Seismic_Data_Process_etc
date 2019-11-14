#!/bin/bash
# This script is to use one of the field in File A as keyword, to search and match the corresponding content in File B and append the corresponding info in File B to File A.
# This script is to convert created PSDEPTH.STX into 

file=/home/hep/Nepal/RF_GMT/6_Topo_Moho_3DPersp/Data/AAMOHO
infotoappend=/home/hep/Nepal/RF_GMT/6_Topo_Moho_3DPersp/Data/myhimt2d.tab

# The Moho range to be constrained in second.
lowertime=4.5
uppertime=6

# For Primary energy, select $8, $9 Seondary energy, select $11,$12
# $6, $5 represent Projected Ps Points
cat $file |awk '{printf "%4.4f %4.4f %1.4f %0.2f\n",$6,$5,$8,$9}' | awk -v lt=$lowertime -v ut=$uppertime '$4>lt&&$4<ut' >tmp

# The -w in grep denotes only to select those lines where they contain the exact keyword excluding those containing extra prefix or suffix of this keyword.
# The "*" in grep is regular expression, where ^ denote the identifier will be located at the first field of $fileb, but there are uncertain number of blank in between. "character\{m,n\}" denotes the "character" will appear from zero to 10 times prior to this identifier.
 
cat tmp |while read line; do identifier=`echo $line|awk '{print $4}'`; info=`grep -w "^ \{0,10\}$identifier" $infotoappend`; echo $line $info >> tmp1; done

# Input File for GMT to create GRID
cat tmp1 |awk '{print $1,$2,$NF}' > ${file}.new

rm tmp*
