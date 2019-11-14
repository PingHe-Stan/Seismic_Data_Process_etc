#!/bin/sh
# This script is
# 1) to automatic enter different SAC dir   
# 2) and then mark (or remove) the desired or undesired SAC by checking its certain HEADER parameter.
# In this script, a positive or defined t9 is the time marker to represent a chosen SAC waveform. The chosen one will be copied in a new name with a appendix ".s".
# Naming System: .M.SAC = original SAC. SAC.new = After response removal of RESP file. & SAC.new = After Phase Picking. *.new.s = selected desired SAC with P arrival phase (a)
# Prerequisite Programs: saclst (contained in SAC package), awk, shell
# Authored by: Stan He Date: 2015.7.1
# Revised: 2015.7.12 
# New Function: Delete incompletely recorded components of SAC files recording different events
# Manually designate SAC data folder and intended storing path

SAC_data_dir=/home/hep/Nepal/Nepal_Stations
SAC_processed_dir=/home/hep/Nepal/Nepal_SAC_Processed

if [ ! -e $SAC_processed_dir ]
then
	mkdir -p $SAC_processed_dir
else
	echo "The folder $SAC_processed_dir has already existed."
fi

cd $SAC_data_dir
stalst=`ls |grep -v 000`

if [ ! -e $SAC_data_dir/000DONE ]
then
	mkdir -p $SAC_data_dir/000DONE
	echo "The folder $$SAC_data_dir/000DONE is created."
else
	echo "The folder DONE has already existed."
fi


for file in $stalst
do
# Enter SAC subdir and begin quality control.
cd $file
echo "Now entering `pwd` directory!"
if [ ! -e Trash ]
then
	mkdir Trash
fi
if [ ! -e Incomplete ]
then
	mkdir Incomplete
	echo "Incomplete directory has been created"
fi

# Move file of which the size is less than 100k to Trash (Normal size would be 180k)
mv `ls -l |grep SAC |  awk '{if($5<100000){print $9}}'` Trash/

# Test whether each event is recorded by three component, if not, mv corresponding SAC to Trash
# Sort according to alphabetic order, and display only (u)nique content of each line
for sacfile in `ls | grep SAC | awk -F. '{print $1"."$2"."$3"."$4"."$5"."$6}' | sort -u`
do
testSACNumber=`ls |grep $sacfile |nl | sed -n '$p' | awk '{print $1}'`
if [ $testSACNumber -ne 6 ]
then 
printf "mv %s* Incomplete/ \n" $sacfile | sh
fi
done

sac << EOF
r *.M.SAC.new
qdp off
trans from none to vel freq 0.01 0.1 1 10
ppk p 3 r m
wh
write append .vel
quit
EOF
##########
# List SACfile certain header, using P-onset "a" value as a criterion and then execute shell command "cp".
saclst a f *.vel | awk '{if($2>0)print "cp",$1,$1".s"}' |sh 
mv *.vel.s $SAC_processed_dir
echo "The selected file *.SAC has been moved to $SAC_processed_dir."
cd ${SAC_data_dir}
mv $file ${SAC_data_dir}/000DONE
echo "The folder $file under ${SAC_data_dir}  has been moved to ${SAC_data_dir}/000DONE."

done
