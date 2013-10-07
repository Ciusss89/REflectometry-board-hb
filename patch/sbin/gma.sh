#!/bin/bash
# TIPALDI GIUSEPPE 1-2013
# Gn3s Manual Acquisitions script

clear; echo "** Gn3s Manual Acquisitions, is starting..."; echo "** If you want kill me, trype Ctrl+c :/"; sleep 1;

##
# Set max speed of cpu:
cpu-control.sh

cd /run/shm; rm -rf *;
outpath="/mnt/sd/"

##
# Save size of tmpfs 
Size=`df -h /run/shm | grep tmpfs | awk '{ print $2 }'`


##
# Load new firmware in to gnss ram..
gnss-flash.sh >> Load-firm.log
mv Load-firm.log $outpath
echo "-*firmware check done."

##
# Setup seconds and name of stream.
read -p "-*How many seconds to acquire??  ( Free space : $Size) :" TIME
gn3s -s $TIME 
echo "-* Acquisitions ended."
nameB=`md5sum test.bin | awk '{ print $1 }'`; 
nameA=`date +%Y-%m-%d-%H:%M:%S_row.bin`
nameA=`echo $nameB+$nameA`

mv -v test.bin $outpath$nameA; 
sync
echo "-*Saving in to sd-card. DONE."
