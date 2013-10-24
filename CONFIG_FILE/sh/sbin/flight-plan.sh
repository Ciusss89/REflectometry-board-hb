#!/bin/bash
#  script /usr/local/sbin/flight-plan.sh
# TIPALDI GIUSEPPE 2-2013

# VAR;
TIME=`/mnt/NAND/01_site/sys_state/FLYMODE | grep TIME | awk '{ print $2 }'`
RUN="1";
SD_FULL=`(echo "17000 * $TIME" | bc)`
log_file="/mnt/NAND/01_site/sys_state/flight-plan-control-activity-log"
freespace=`df /dev/mmcblk0p2 | grep mmcblk0p2 | awk '{ print $2 }'`

##
# Cpu:
cpu-control.sh

##
# Clean ram
cd /run/shm; rm -rf *; outpath="/mnt/sd/" 

##
# Size of tmpfs
Size=`df -h /run/shm | grep tmpfs | awk '{ print $2 }'`; echo "Size of tmpfs $Size"

## VERIFICA FIMRWARE
##
# Load new firmware in to gnss ram..
gnss-flash.sh; sleep 5;

echo "Seconds collected [$TIME];"

while [ "$freespace" -ge "$SD_FULL" ]
do
   echo "ITERATIONS NUMBER $RUN"
   gn3s -s $TIME;
   nameC=`date +%Y-%m-%d-%H:%M:%S_row.bin`; nameB=`echo $RUN`; nameA=`md5sum test.bin | awk '{ print $1 }'`
   name=`echo $nameA+$nameB+$nameC`; RUN=`(echo " 1 + $RUN" | bc)`
   mv -v test.bin $outpath$name; sync
   freespace=`df /dev/mmcblk0p2 | grep mmcblk0p2 | awk '{ print $2 }'`

done
