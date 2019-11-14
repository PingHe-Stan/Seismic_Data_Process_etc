#!/bin/bash
# This script is intended to create recorded catalogue(Nepal_Events_XF_Final) from iris requested catalogue (Nepal_Events_XF)
for evt in `ls |grep seed | awk -F"." '{print $2}'`
do evt1=`echo $evt |sed 's/_/ /g'`
cat Nepal_Events_YL_5.0 |grep "$evt1" >> Nepal_Events_YL_Final5.5
done
