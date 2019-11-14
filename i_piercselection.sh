#!/bin/bash
# This script is to select required PS points along linear profile.
# Date: 2015.12.24 Author: Ping He

# For Distance in kilometers, the -L parameter for mapproject should be appended by /k, for distance in degrees, -L appended by /d

distance_to_profile=0.1
allpiercfile=/home/hep/Nepal/Nepal_Q_ALL/Nepal_RF_Summary/Nepal_ALL_PIERC.STX
profile_line_file=/home/hep/Nepal/Nepal_Q_ALL/Nepal_RF_Summary/Line_GG
outputfile=PROFILE_GG_PSPOINT${distance_to_profile}

awk '{print $6" "$5}' $allpiercfile | mapproject -L"$profile_line_file"/d | awk -v var=$distance_to_profile '$3<var {print $1" "$2}' | sort -u > $outputfile
