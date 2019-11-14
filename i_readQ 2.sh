#/bin/sh
# This script is for read all Qfile in current directory and save as "qfile"
# Author: Stan He
# Date: 2015-7-15
echo "/usr/local/sh/sh/shc <<END > sh.out" > readQ.sh
for file in `ls |grep RF_SUM |awk -F"." '{print $1}' |sort -u`
do
echo "read $file all" >> readQ.sh
done
echo "write H_RF_ALLSTA all" >> readQ.sh
echo "quit y" >> readQ.sh
echo "END" >> readQ.sh
chmod +x readQ.sh
./readQ.sh
rm sh.out
rm readQ.sh
