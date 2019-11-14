#!/bin/sh
# This is a script created by Stan He based on X. Yuan's sac2sh in Cshell.
# This shell must be run as root for SH_ROOT is stored in / directory, in order to allow further writing adjustment by normal user, we should set umask from 0002 to 0022 
# SAC file will be converted to Q file one by one
# For the proper use of this script, several folders should be prepared.
# 1) "SACfile" directory is where SAC file to be converted is stored. 
# 2) "Qfile" directory is where created Qfile will be placed.
# Date: 2015.6.25 Version 1.0, Email: peace.he@hotmail.com
# Version 1.0 Ajustments: convert from cshell script to correctly executable bash shell script
# Date: 2015.7.3 Version 1.1 
# Version 1.1 Adjustments: (1) Automatic filling SAC_ASC Header files with events info through pattern searching using previous files (*.req, Nepal_Events)
# (2) Automatic setting SH Qfile Header (p-onset, slowness, azimuth) by SH command
# (3) Station latitude longtitude and elevation will be generated in required format in Nepal_Info directory to be transferred to SH_ROOT/inputs/STATINF.DAT
# Note: For the proper use of programs(call statloc ^station("cnt) &slat &slon || call locdiff "slat "slon #1 #2 &dist &azim) in Seismic Handler, the station info should be added to the file
# Date: 2015.7.26 Version 1.2
# Version 1.2 Adjustments: (1) Automatic categorize SAC and created Q for each station contained in SACdatadir named SACstat and Qstat (2) Automatic create event info for each $SACstat and $Qstat, and create a Qfile_$station containing all Qfile for each $Qstat 

Workdir=/home/hep/Nepal
SACdatadir=${Workdir}/Nepal_SAC_Processed
Qdatadir=${Workdir}/Nepal_Q
infodir=${Workdir}/Info_Nepal
shdir=/usr/local/sh/sh

#statinfo=${Workdir}/Info_Nepal/Nepal_Stations
#evtinfo=${Workdir}/Info_Nepal/Nepal_Events
#reqdir=${Workdir}/Info_Nepal/Nepal_Req/

#0.0 Since every file to be created in under root by whom default created files are unwritable/irrevisable by normal user, thus we need to change umask value to allow further writing adjustment by normal user. Here, we set umask from 0022(root) to 0002(usr) 
# To see current file creation mode, simply launch "umask". To understand the value in display, key in 1) touch testfile 2) ls -l testfile to find out
#umask 0002

# Prepare Nepal_Index in order to search event info by station name and record starting time 
# Each line from 11 to last in Nepal_Req *.req will be appendded by files name and echo to a new file *.new
# after that *.req.new will be concatenated into one file "Nepal_Index". This script is accomplished with inspiration by Guangwei Zhang after several times attempts of using awk&sed. while read line makes everything much more easy to do.
#cd $infodir/Nepal_Req
#for ff in `ls $infodir/Nepal_Req/ |grep \.req`
#do
#cat $ff |sed '1,10d' | while read line
#do
#echo "$line $ff" >> ${ff}.new
#done
#done
#cat *.req.new >> Nepal_Index.tmp
#cat Nepal_Index.tmp | awk '{print $1" "$3" "$4" "$5" "$6" "$7" "$8" "$17}' > Nepal_Index
#rm -f *.tmp
#rm -f *.new
#mv Nepal_Index $infodir


# Insert Station info into Seismic-Handler Inputs
#cd $infodir
#cat Nepal_Stations | awk '{print $2,"   lat:",$7,"   lon:",$8,"   elevation:",$9}' >> ${shdir}/inputs/STATINF.DAT
#cat Nepal_Stations | awk '{print $2"-bh-?...                ...                 1.0"}' | tr 'A-Z' 'a-z' >> ${shdir}/inputs/sensitivities.txt
#cat Nepal_Stations | awk '{print $2"-BH-Z "$1}{print $2"-BH-N "$1}{print $2"-BH-E "$1}' >> ${shdir}/inputs/filter_lookup.txt


#0 Read SAC list to be converted.

##########################################1st LOOP for DIR###################################################
############1)For each Station, Creating Station SAC&Q dir 2) Enter SACstat for secondary loop for SACfile processing#############

cd $SACdatadir
for fi_1 in `ls |grep SAC|awk -F"." '{print $8}'|sort -u`
do
mkdir $fi_1
mv *${fi_1}*s $fi_1
done

mkdir -p ${SACdatadir}/000DONE

for stat in `ls |grep -v 000`
do
Qstat=${Qdatadir}/${stat}
SACstat=${SACdatadir}/${stat}
mkdir -p $Qstat
cd $SACstat
saclist=`ls |grep SAC.new.s`
########################################2rd LOOP for SACfile################################################
########1) For Each SAC in separate Station, convert them into Q SAC via binary format 2) Write Q Header file by running Seismic-Handler script####

#0.2 SAC to Qfile Execution, one by one.
for file in $saclist
do
####0.3 Define SAC, SAC_ASC, SHASC, SH name variable
sac_file=$file
sacasc_file=$file.sacasc
shasc_file=`echo $file.SHASC | tr 'a-z' 'A-Z'`
sh_file=$shasc_file:r
# echo $sac_file $sacasc_file $shasc_file $sh_file

####0.4 Define Header variable/parameter from SAC name eg. 2002.304.01.41.15.0160.XF.NTHAK.01.BHE.M.SAC
network=`echo $sac_file | awk -F"." '{print $7}'`
station=`echo $sac_file | awk -F"." '{print $8}'`
startyr=`echo $sac_file | awk -F"." '{print $1}'`
startjday=`echo $sac_file | awk -F"." '{print $2}'`
starthr=`echo $sac_file | awk -F"." '{print $3}'`
######Due to the date format of minutes and seconds in Nepal_Index is single character if they are less then 10
######while the format of minutes and seconds in SAC automatic naming system is double character even if they are less then then. We should convert 0[0-9] to [0-9]. using sed program.
startmin=`echo $sac_file | awk -F"." '{print $4}'| sed 's/0\(.\)/\1/'`
startsec=`echo $sac_file | awk -F"." '{print $5}'| sed 's/0\(.\)/\1/'`
####0.5 Julian to Gregorian using shell command "date"
date -d "`expr $startjday - 1` days $startyr-1-1" +"%m %d" > cday.tmp
startmon=`cat cday.tmp | awk '{print $1}'`
startday=`cat cday.tmp | awk '{print $2}'`
echo "Processing Station $station"

###1. Get Event and Station info for the preparation of writing them in SAC Header using SAC program "chnhdr,writehdr" 
cd $infodir
eventtime=`cat Nepal_Index |grep "$station $startyr $startmon $startday $starthr $startmin" | awk '{print $8}'`
evtyr=`echo $eventtime|awk -F"_" '{print $2}'`
evtmon=`echo $eventtime|awk -F"_" '{print $3}'`
evtday=`echo $eventtime|awk -F"_" '{print $4}'`
evthr=`echo $eventtime|awk -F"_" '{print $5}'`
evtmin=`echo $eventtime|awk -F"_" '{print $6}'`
evtsec=`echo $eventtime|awk -F"_" '{print $7}'|awk -F"." '{print $1}'`
echo "Processing $evtyr $evtmon $evtday $evthr $evtmin $evtsec"

evtinfo=`cat Nepal_Events |grep "$evtyr $evtmon $evtday $evthr $evtmin $evtsec" | awk '{print $7"_"$8"_"$9"_"$10}'`
evtlat=`echo $evtinfo|awk -F"_" '{print $1}'`
evtlon=`echo $evtinfo|awk -F"_" '{print $2}'`
evtdep=`echo $evtinfo|awk -F"_" '{print $3}'`
evtmag=`echo $evtinfo|awk -F"_" '{print $4}'`
echo "Event info: Lat: $evtlat Lon: $evtlon DEP: $evtdep MAGNITUDE: $evtmag"


# The unit of event depth in SAC program is meter, expr can only process integer number, using printf is a clever solution.
evdp=`echo $evtdep|awk '{printf "%.1f",$1*1000}'`


slat=`cat Nepal_Stations | grep $station | awk '{print $7}'`
slon=`cat Nepal_Stations | grep $station | awk '{print $8}'`
elev=`cat Nepal_Stations | grep $station | awk '{print $9}'`
# Edit /etc/profile to add taup_time PATH to root
travel=`taup_time -mod iasp91 -ph P -h $evtdep -sta $slat $slon -evt $evtlat $evtlon -time`
# Ray parameter is the same as horizontal slowness
# e.g. rayp=`taup_time -mod iasp91 -ph P -h 20 -sta 0 0 -evt 0 67 -rayp` || in SH call slowness p ^distance("cnt) ^depth("cnt) &slo  
# i.e.  id est (That is) || e.g. exempli gratia (For example) || etc. et cetera (and so on) || et al. et alibi (and others)
rayp=`taup_time -mod iasp91 -ph P -h $evtdep -sta $slat $slon -evt $evtlat $evtlon -rayp`


# For the setting of SH header, create evtime.tmp where $1 = origin, $2 = theoretical p travel time
echo "`date -d "$evtyr-$evtmon-$evtday $evthr:$evtmin:$evtsec" +"%d-%b-%Y_%H:%M:%S"` $travel" > evtime.tmp
# For the calculating epi_dis of SH, create sta_evt.tmp where $1= slat $2=slon $3=evtlat $4=evtlon $5=slowness/rayparameter
echo "$slat $slon $evtlat $evtlon $rayp" > sta_evt.tmp

mv *.tmp $SACstat

echo "$station $evtyr $evtmon $evtday $evthr $evtmin $evtsec Lat: $evtlat Lon: $evtlon DEP: $evtdep MAGNITUDE: $evtmag" >> ${SACstat}/Events_${station}

####2. Launching Conversion from SAC to ASCII

cd $SACstat
sac << ENDSAC > sac.out
read $sac_file
ch evla $evtlat evlo $evtlon evdp $evdp mag $evtmag
wh
write alpha $sacasc_file
quit
ENDSAC


####3. Convert SAC ASCII Format to SH ASCII Format (DEALTA = Sampling Rate in seconds, LENGTH = Sampling Number)
awk '{{if(NR==1){print "DELTA: ",$1}}{if(NR==16){print "LENGTH: ",$5}}{if(NR>30){print $0}}}' $sacasc_file >  $shasc_file


####5. Creating SH files together with Headfiles to be modified
echo "$SH_ROOT/shc << END > sh.out" > convsh.tmp.sh 
## Reading ascii file
echo "reada $shasc_file" >> convsh.tmp.sh
echo "write $sh_file all" >> convsh.tmp.sh


####6. Fill in the SH HEADER File(QHD)
# 6.0 HEADER and T-origin Setting (For Seismic Handler Memo Only, Used for Time calibration, Default set to zero.)
awk '{if(NR==16){if($2!=-12345.00&&$2!=6){{print "HEADER VERSION DIFFERENT FROM 6 \!\!"}{print "FILE CONVERSION COULD BE FALSE \!\!"}{print "CHECK THE HEADER PARAMETERS \!\!"}}}}' $sacasc_file | nl
awk '{if(NR==2){if($1!=-12345.00){print "set 1 t-origin ",$1}{exit}}}' $sacasc_file >> convsh.tmp.sh


# 6.1 Set trace start time
awk '{{if(NR==15){{start="01-JAN-"$1"_00:00:00.000"}{addt=($2-1)*86400}{printf "%s%s%s%f","calc t &g1 = ",start," tadd ",addt}{print " "}{addt=($3*60.0+$4)*60.0+$5}}}{if(NR==16){{addt=addt+($1/1000.0)}{printf "%s%f","calc t &g2 = \"g1 tadd ",addt}{print " "}{print "set/file 1 start \"g2"}{exit}}}}' $sacasc_file >> convsh.tmp.sh
# 6.2 Latitude, longitude, depth and magnitude of the event
awk '{if(NR==8){{if($1!=-12345.00){print "set/file 1 lat ",$1}}{if($2!=-12345.00){print "set/file 1 lon ",$2}}{if($4!=-12345.00){print "set/file 1 depth ",$4/1000.0}}{if($5!=-12345.00){print "set/file 1 magnitude ",$5}}{exit}}}' $sacasc_file >> convsh.tmp.sh
# 6.3 Set event origin and p-onset using theoretical arrival time calculated in iasp91 model
# Note: In SH, there exist 3 predefined symbol g1, g2, g3, whose value is void, and can be directed called without using "sdef g1", etc 
awk '{{print "set/file 1 origin ",$1}{print "calc t &g3 = "$1" tadd "$2}{print "set/file 1 p-onset \"g3"}}' evtime.tmp >> convsh.tmp.sh
# 6.4 Set backazimuth(station to event), epicentral distance, and slowness 
awk '{{print "sdef dist"}{print "sdef azim"}{print "call locdiff",$1,$2,$3,$4,"&dist &azim"}{print "set/file 1 distance \"dist"}{print "set/file 1 azimuth \"azim"}{print "set/file 1 slowness",$5}}' sta_evt.tmp >> convsh.tmp.sh
## 6.5 station name -> STATION
awk '{if(NR==23){{if($1!=-12345){print "set/file 1 station ",$1}}{exit}}}' $sacasc_file >> convsh.tmp.sh
## 6.6 component -> COMP
awk '{if(NR==29){{if($3!=-12345){{chan=$3}{comp=substr(chan,3,1)}{print "set/file 1 comp ",comp}}}{exit}}}' $sacasc_file >> convsh.tmp.sh
## 6.7 Station Incidence (default 90) -> INCI 
awk '{if(NR==12){{if($4!=-12345.00){print "set/file 1 inci ",$4}}{exit}}}' $sacasc_file >> convsh.tmp.sh
## 6.8 Station Cmpaz in SAC into PWDW
awk '{if(NR==12){{if($3!=-12345.00){print "set/file 1 pwdw ",$3}}}}' $sacasc_file >> convsh.tmp.sh

## event origin -> ORIGIN and first arrvial -> P-ONSET
##awk '{if(NR==2){{if($3!=-12345.00){{print "calc t &g1 = \"g2 tadd ",$3}{print "set/file 1 origin \"g1 "}}}{if($4!=-12345.00){{print "calc t &g1 = \"g2 tadd ",$4}{print "set/file1 P-ONSET \"g1 "}}}{exit}}}' $sacasc_file >> convsh.tmp.sh
## network -> PHASE
##awk '{if(NR==30){{if($1!=-12345){print "set/file 1 phase ",$1}}{exit}}}' $sacasc_file >> convsh.tmp.sh

echo "quit y" >> convsh.tmp.sh
echo "END" >> convsh.tmp.sh

chmod +x convsh.tmp.sh
./convsh.tmp.sh

rm -f convsh.tmp.sh
rm -f *.out 
rm -f *.tmp

done

cat Events_${station} |sort -u >> Evt_${station}
rm -f *.sacasc
rm -f *.SHASC
mv *R.Q* $Qstat
cp Evt_${station} $Qstat

cd $SACdatadir
mv ./$stat 000DONE

cd $Qstat
echo "/usr/local/sh/sh/shc <<END > sh.out" > readQ.sh
for file in `ls |grep QBN |sed 's/.QBN//'`
do
echo "read $file all" >> readQ.sh
done
echo "write qfile_$stat all" >> readQ.sh
echo "quit y" >> readQ.sh
echo "END" >> readQ.sh
chmod +x readQ.sh
./readQ.sh
rm sh.out
rm readQ.sh

done

#chown -R hep $Workdir
#su hep

