#!/bin/bash
# This script is to automatic sifting SAC files that do not have good signal-to-noise ratio. (Noisy SAC)
# The measure includes three steps: 
#1) Cut/Create the original SAC into pre-onset file and post-onset file
#2) Obtain the MAX positive amplitude using saclst DEPMAX(program: saclst), and Calculate the SNR for the original SAC(program: bc).
#3) Remove the Created pre and post-onset SAC files and Move Noisy SAC to the Noisy folder
# Date: 2015-10-22 16:06:50

# The requested seed file from IRIS is Events seed, the Theoretical Onset is defined at 300 seconds.
# The time window parameters for SNR calculation (Pre_Onset, Post_Onset)
pre_b=220
pre_e=280
post_b=300
post_e=400
snr_control=4
mkdir SNRLT${snr_control}

# 1) Create Cutted SAC files
sac << EOF
cut $pre_b $pre_e
r *.new
write append .cut${pre_b}${pre_e}
cut off
cut $post_b $post_e
r *.new
write append .cut${post_b}${post_e}
quit
EOF

# 2) Calculate SNR
for sacfile in `ls *.new`
do
post_ponset=`saclst depmax f ${sacfile}.cut${post_b}${post_e} | awk '{print $NF}'`
pre_ponset=`saclst depmax f ${sacfile}.cut${pre_b}${pre_e} |awk '{print $NF}'`
snr=`echo ${post_ponset}/${pre_ponset} | bc`
[ ${snr} -lt ${snr_control} ] && {
mv ${sacfile} SNRLT${snr_control}
}
done

# 3) Directory Cleansing
rm *cut*

