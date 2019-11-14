#!/bin/bash
# This script is written to convert queried seismic catalogue from ISC to required events format so as to build breq_fast request file.
# Written by: Stan He Date: 2015-08-13
evt_catalog=2_Nepal_evts_ISC_YL_RAW_5.3_Circle
evt_processed=Nepal_YL_ISC_5.5
# Formatting
cat $evt_catalog |awk -F"," '{if($11>=5.5) print $3" "$4"\t "$5"  "$6"\t"$7"\t"$11" "$11}' | awk -F":" '{print $1" "$2" "$3}' | sed 's/-\(..\)-/ \1 /g' | awk '{if(NF==11) print $0}' | awk '{printf "%4d %02d %02d %02d %02d %02d %10.4f %12.4f %8.1f %6.1f %4.1f\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'  > $evt_processed
# Only print events with magnitude info 
#cat evt.tmp | while read line
#do
#echo $line |awk '{if(NF==11) print $0}' >> $evt_processed
#done
#awk '{if(NF==11) print $0}' evt.tmp > $evt_processed
#rm *.tmp

