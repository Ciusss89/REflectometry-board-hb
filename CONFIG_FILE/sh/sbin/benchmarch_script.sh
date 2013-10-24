#!/bin/bash
# Giuseppe Tipaldi 12-2012. 
clear

c=`df | grep nandc |awk '{print $6}'`
echo "** Nand devices: $c" &>> benchmarch_reperot.log
s=`df | grep mmcblk0p* |awk '{print $6}'`
echo "** Sd device : $s" &>> benchmarch_reperot.log

echo "**** I/O *****" &>> benchmarch_reperot.log
echo "*** Block size 17MByte count 1:" &>> benchmarch_reperot.log
echo "-* Device NAND" &>> benchmarch_reperot.log
	dd if=/dev/zero of=$c/DDtest.tmp bs=17M count=1 &>> benchmarch_reperot.log ; rm $c/DDtest.tmp 
echo "-* Device SD-card" &>> benchmarch_reperot.log
	dd if=/dev/zero of=$s/DDtest.tmp bs=17M count=1 &>> benchmarch_reperot.log ; rm $s/DDtest.tmp

echo "*** Block size 200MByte count 1:" &>> benchmarch_reperot.log
echo "-* Device NAND" &>> benchmarch_reperot.log
        dd if=/dev/zero of=$c/DDtest.tmp bs=200M count=1 &>> benchmarch_reperot.log ; rm $c/DDtest.tmp
echo "-* Device SD-card" &>> benchmarch_reperot.log
        dd if=/dev/zero of=$s/DDtest.tmp bs=200M count=1 &>> benchmarch_reperot.log ; rm $s/DDtest.tmp

echo "*** Block size 10kByte count 10k:" &>> benchmarch_reperot.log
echo "-* Device NAND" &>> benchmarch_reperot.log
        dd if=/dev/zero of=$c/DDtest.tmp bs=10k count=10k &>> benchmarch_reperot.log ; rm $c/DDtest.tmp
echo "-* Device SD-card" &>> benchmarch_reperot.log
        dd if=/dev/zero of=$s/DDtest.tmp bs=10k count=10k &>> benchmarch_reperot.log ; rm $s/DDtest.tmp

echo "-* Hdparm test, NAND" &>> benchmarch_reperot.log
	hdparm -tT /dev/nandc &>> benchmarch_reperot.log

echo "-* Hdparm test, SD" &>> benchmarch_reperot.log
        hdparm -tT /dev/mmcblk0p2 &>> benchmarch_reperot.log
echo "****END*****" &>> benchmarch_reperot.log

echo "****CPU & RAM*****" &>> benchmarch_reperot.log
echo "-* TEST RAMDISK, Write:" &>> benchmarch_reperot.log
	dd if=/dev/zero of=/run/shm/DDtest.tmp bs=200M count=1  &>> benchmarch_reperot.log
echo "-* TEST RAMDISK, Read:"  &>> benchmarch_reperot.log
        dd if=/run/shm/DDtest.tmp of=/dev/null bs=200M count=1  &>> benchmarch_reperot.log

echo "-* Cpu peferormance test." &>> benchmarch_reperot.log
(time (echo "scale=5000; a(1)*4" | bc -l >/dev/null 2>&1) 2>&1)&>> benchmarch_reperot.log
echo "****END*****" &>> benchmarch_reperot.log

echo "-* Stability test." &>> benchmarch_reperot.log
stress --cpu 8 --io 8 --vm 4 --vm-bytes 208M --timeout 360s &>> benchmarch_reperot.log

mv benchmarch_reperot.log benchmarch_reperot`date +%Y-%m-%d--%H:%M:%S`.log ; mv benchmarch_reperot*.log /mnt/NAND/01_site/sys_state/
