#!/bin/bash
#This script is to calcuate RF automaticly and save calculated RFs by the station name.
# Date: 2015.11.10 Author: Stan He
# Date: 2015.12.22 Revised by: Stan He
# Input Preparation: 1) Station Name File 2) QFILE_ assorted under different Stations 
# Output RF calculation for each station.
Qdirectory=/home/hep/Nepal/Nepal_Q_ALL/Nepal_QFILE
RFdirectory=/home/hep/Nepal/Nepal_Q_ALL/Nepal_RF
stanamefile=/home/hep/Nepal/Nepal_Q_ALL/Nepal_Stations.dat
cd $Qdirectory
for station in `cat $stanamefile`
# for f in `ls |grep QFILE_ | grep Q[BH][ND] | awk -F"." '{print $1}' | sort -u`
do
cd ${Qdirectory}/${station}
#staname=`echo $f|awk -F"_" '{print $2}'`
echo "/usr/local/sh/sh/shc <<END > sh.out" > calcQ.sh
echo "read QFILE_${station} all" >> calcQ.sh
echo "calcprf" >> calcQ.sh
#echo "sdef ntr" >> calcQ.sh
#echo "calc i &ntr = "'$dsptrcs' >> calcQ.sh
#echo "al all p-onset" >> calcQ.sh
#echo "cut all -100 300" >> calcQ.sh
#echo "display_zne" >> calcQ.sh
#echo "ro3t" >> calcQ.sh
#echo "display h:all" >> calcQ.sh
#echo "del |1|-|\"ntr|" >> calcQ.sh
#echo "dec3 -5 60 1" >> calcQ.sh
#echo "display h:all" >> calcQ.sh
#echo "del |1|-|\"ntr|" >> calcQ.sh
#echo "cut all -50 150" >> calcQ.sh
echo "write rf_q_${station} _comp(q)" >> calcQ.sh
echo "write rf_${station} all" >> calcQ.sh
echo "quit y" >> calcQ.sh
echo "END" >> calcQ.sh
chmod +x calcQ.sh
echo "The waveforms recorded by station $station is being processed!"
./calcQ.sh
rm sh.out
rm calcQ.sh
mkdir $station
mv RF* $station
mv $station $RFdirectory
cd $Qdirectory
done

