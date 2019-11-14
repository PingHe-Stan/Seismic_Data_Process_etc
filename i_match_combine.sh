#!/bin/bash
# This script is to use one of the field in File A as keyword, to search and match the corresponding content in File B and append the corresponding info in File B to File A.
filea="./PROCESSED_PSPIER.STX"
fileb="./Info.STX"
filec="newfile"
# The -w in grep denotes only to select those lines where they contain the exact keyword excluding those containing extra prefix or suffix of this keyword.
# The "*" in grep is regular expression, where ^ denote the identifier will be located at the first field of $fileb, but there are uncertain number of blank in between. "character\{m,n\}" denotes the "character" will appear from zero to 10 times prior to this identifier.
 
cat $filea |while read line; do identifier=`echo $line|awk '{print $1}'`; info=`grep -w "^ \{0,10\}$identifier" $fileb`; echo $line $info >> $filec; done
