#!/bin/bash
# This script is to create Nepal_Index

infodir=/home/hep/Info_Nepal_YL
cd ${infodir}/Nepal_Req_YL
for ff in `ls $infodir/Nepal_Req_YL/ |grep \.req`
do
cat $ff |sed '1,10d' | while read line
do
echo "$line $ff" >> ${ff}.new
done
done
cat *.req.new >> Nepal_Index.tmp
cat Nepal_Index.tmp | awk '{print $1" "$3" "$4" "$5" "$6" "$7" "$8" "$17}' > Nepal_Index_YL
rm -f *.tmp
rm -f *.new
mv Nepal_Index_YL ${infodir}
