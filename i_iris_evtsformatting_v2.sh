#!/bin/bash
# This script was written to format downloaded events list to accepted format list when making IRIS data request files using make.request.Iris.csh
# Authored by: Ping He, 2015.5.18
# sed: Row selection/operation & Row Pattern Scanning and Replacement  -n (Silence Mode) '2,$p' 2 to last row for print
# awk: Column selection/operation row by row & Column scanning and Selection -F (Defining Field Separator) "\t" (Table Maker between Variable)
# sed 's///g' Replacement format, g for Global. \(* \) of the original content = \1 (Representation of * allocated before) "." mean single character. Its function is to replace "2002-03-23 -10 20" by "2002 3 23 -10 20" instead of "2002 3 23 10 20"
# > Redirection to new file being created.

evt_catalog=1_Nepal_evts_FDSNWS_YL_RAW_5.0_Ring
evt_processed=Nepal_YL_FDSNWS_5.0

sed -n '2,$p' $evt_catalog | awk -F"|" '{if($11 >= 5.0) print $2"\t"$3"\t  "$4"\t"$5"\t"$11" "$11}' | awk -F"T" '{print $1" "$2}' | awk -F":" '{print $1" "$2" "$3}' | sed 's/-\(..\)-/ \1 /g' | sort -u |awk '{if(NF==11) print $0}' | awk '{printf "%4d %02d %02d %02d %02d %02d %10.4f %12.4f %8.1f %6.1f %4.1f\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' > $evt_processed
