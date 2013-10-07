#!/bin/bash
# TIPALDI GIUSEPPE- 26-10-2012. r03

flag=`(lsusb | grep 16c0:072f | awk  '{ print $6 }' )`
if [ $flag =  "16c0:072f" ]; then
	echo "Firmware is ok"
else
	echo "Loading new firmware.." sleep 1;
        BUS=`( fx2_programmer any any dump_busses | grep 0b39 | awk  '{ print $2 }' )`
        ID=`( fx2_programmer any any dump_busses | grep 0b39 | awk  '{ print $4 }' )`
        fx2_programmer $BUS $ID set 0xE600 1
        fx2_programmer $BUS $ID program /usr/local/sbin/sige.ihx
        fx2_programmer $BUS $ID set 0xE600 0
fi
