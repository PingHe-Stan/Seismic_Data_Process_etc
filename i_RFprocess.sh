#!/bin/bash
# This script is to automatic launch SH and place the different processed RF in separate folders for future use.
# The produced file will be PSMOUT and rf_sum_${station}, as well as SHGMT.* for individual RF plotting
# Date: 2015-11-12 Author: Stan He

#for rfsta in `ls |grep RF_ |grep QBN |sed 's/.QBN//g'`
#do
#mkdir ${rfsta}
#mv ${rfsta}* ${rfsta}
#done

rffolder=/home/hep/Nepal/QFILE_HICLIMB
cd $rffolder
for rfdir in `ls |grep -v 000[DR]`
do
cd $rfdir
staname=`echo $rfdir |awk -F"_" '{print $2}'`
echo "/usr/local/sh/sh/shc <<END > sh.out" > procQ.sh
echo "read $rfdir all" >> procQ.sh
echo "rfshiftlp" >> procQ.sh
echo "set/file 1 station $staname" >> procQ.sh
echo "write rf_sum_${staname} 1" >> procQ.sh
echo "quit y" >> procQ.sh
echo "END" >> procQ.sh
chmod +x procQ.sh
echo "The waveforms recorded by station $staname is being processed!"
./procQ.sh
rm sh.out
rm procQ.sh
cd ..
done

