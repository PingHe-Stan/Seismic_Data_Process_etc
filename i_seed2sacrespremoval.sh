#!/bin/bash
# Purpose: Extract SAC from seed downloaded from IRIS, remove instrument response, and organize them into category of the same station
# The folder sacfolder contains a 000RAW folder within which has a station info file named "Nepal_Stations_YL_HiMNT"
# Date: 2015-10-21
seedir=/home/hep/6_Nepal/Nepal_seed_IRIS_YL
sacdir=/home/hep/6_Nepal/Nepal_Stations_YL
rawdir=/home/hep/6_Nepal/Nepal_Stations_YL/000RAW
cd $seedir
for seedf in `ls |grep seed`
do
rdseed -dfR $seedf
sac <<EOF
r *.M.SAC
rtr
rmean
taper
trans from evalresp to none freq 0.01 0.1 1 10
write append .new
q
EOF
rm RESP*
mv *.M.SAC $rawdir
mv *.new $sacdir 
done

# Create Station Folder and categorize SAC file into Station class
cd $sacdir
for stas in `cat ./000RAW/Nepal_Stations_YL* | awk '{print $2}'`
do 
mkdir $stas
mv *$stas* $stas
done

# For the Operation of SAC sifting, the number of SAC files in Station Folder should be less than 999
for stas1 in `cat ./000RAW/Nepal_Stations_YL* | awk '{print $2}'`
do
cd $stas1
## First Remove Incomplete Files
#mkdir Incomplete
#for sacfile in `ls | grep SAC | awk -F. '{print $1"."$2"."$3"."$4"."$5}' | sort -u`
#do
#testSACNumber=`ls |grep $sacfile |nl | sed -n '$p' | awk '{print $1}'`
#if [ $testSACNumber -ne 3 ]
#then 
#printf "mv %s* Incomplete/ \n" $sacfile | sh
#fi
#done
#
# Then Subdivide the current folder into several subfolder if the number of files within exceeds 1000
# Note: If the folder has no file, the $fileNum is void and run "[ $fileNum -gt 1000 ]" will return "unary operator expected" error. 
fileNum=`ls -l | sed -n '2,$p' | nl | tail -1 | awk '{print $1}'`
foldersuffix=1
while [ $fileNum -gt 1000 ]
do
mkdir ${stas1}_${foldersuffix}
mv `ls -l | sed -n '2,$p' | head -999 | awk '{print $NF}'` ${stas1}_${foldersuffix}
mv ${stas1}_${foldersuffix} ..
let foldersuffix=$foldersuffix+1
let fileNum=$fileNum-999
done
cd ..
done

