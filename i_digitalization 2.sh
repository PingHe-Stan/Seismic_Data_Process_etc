#!/bin/bash
# This shell is to convert the JSON Points format into GMT Points format, only Chinese characters and numbers will be left for further usage.
# (1) First compile all JSON directories using the name of each individual figure under into one folder; for each directory, it contains three type of subfolder named "Points, Lines, Areas";
# (2) This script is only valid for the json files under Points directory.
# (3) Naming: the newly created gmt input file will be named with .gmt suffix.

compileddir=/home/hep/ResDigital/
cd $compileddir
# Assume the type of point file to convert is diming.json
#for fi in `ls */Points/di* |grep -v json.gmt`
echo "Step One: process all the Point files."
for fi in `ls */Points/* |grep -v json.gmt`
do
# The following shell script is to convert point file.
cat ${fi} |awk '$0~/coordinates/' |sed 's/[:"{}a-z A-Z]//g' |awk -F"[" '{print $2,$1}' |sed 's/,/ /g'|sed 's/]//g' > ${fi}.gmt
done

echo "Step Two: process all the Area files."
for fi in `ls */Areas/* |grep -v json.gmt`
do
# Debug: the original way for the removal of alphebetic letter is to use:: sed 's/[a-z]//g'. However, during this removal, some Chinese charater encodings seem to be disrupted and malfunctioning. 
#cat ${fi} |tr 'A-Z' 'a-z'|sed 's/name/_/' |awk '$0~/coordinates/' |sed 's/[:"{}a-z A-Z]//g' |sed 's/\[/\n/g' |sed '/^$/d' |sed 's/]/ /g' |sed 's/,/ /g' |awk '{if($0~/^[0-9]/) print $0;else print ">"$0}' > ${fi}.gmt
# Thus, an indirect way is adopted. That is first translate all letters into BLANK using tr 'a-z' ' ', then removal all BLANK using sed 's/ //g'.
# Note: The function of this line: sed 's/name/_/' to artificially create a name for all the lines and areas if the naming is left blank. This can be removed in the final step.
cat ${fi} |tr 'A-Z' 'a-z'|sed 's/name/_/' |awk '$0~/coordinates/' |tr 'a-z' ' '|sed 's/[:"{} ]//g' |sed 's/\[/\n/g' |sed '/^$/d' |sed 's/]/ /g' |sed 's/,/ /g' |awk '{if($0~/^[0-9]/) print $0;else print ">"$0}' > ${fi}.gmt
done

echo "Step Three: process all the Line files."
for fi in `ls */Lines/* |grep -v json.gmt`
do
cat ${fi} |tr 'A-Z' 'a-z'|sed 's/name/_/' |awk '$0~/coordinates/' |tr 'a-z' ' '|sed 's/[:"{} ]//g' |sed 's/\[/\n/g' |sed '/^$/d' |sed 's/]/ /g' |sed 's/,/ /g' |awk '{if($0~/^[0-9]/) print $0;else print ">"$0}' > ${fi}.gmt
done

echo "Congrats! All Files have been processed!"

#If you would like to remove all number and "_" after > , you can simply use the following sentence. 
for fi in `ls */*/* |grep json.gmt`
do
cat ${fi} |awk -F"[0-9 _]" '{if($0~/^>/) printf "%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23;else print $0}' > ${fi}.con
done


# For Individual Processing, use the following script.
#cat Himalaya_zone_merge.json |awk '{if($0~/coordinates/) print $0}' |awk -F"Name" '{print $2}' |awk -F":" '{print "Name_:"$2,$5}' | awk -F"}," '{print $1,$2}' | sed 's/"//g' |tr '[]}' ' ' | sed 's/ , //g' | sed 's/, /,/g'|sed 's/: //' | sed 's/geometry//' | awk '{for(i=1;i<NF;i++)printf "%s\n",$i}' | awk -F"," '{if($1~/^[0-9]/) printf "\n%s\n",$0; else printf "%s",$0}' |awk 'NF>0' | awk -F"," '{if($1~/^[0-9]/) print $1,$2; else printf "> %s\n",$0}' 

