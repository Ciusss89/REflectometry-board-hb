#!/bin/bash
# Script for install in to sd-card Kernel, and rootfs.  TIPALDI GIUSEPPE 12/2012.
# 
clear
read -p "  Writing flash, continue?? [y/n]: " rd
if [ $rd =  "y" ]; then
	echo "Write by dd command backup of nand partions??"
	read -p "  continue? [y/n]: " rd
	if [ $rd =  "y" ]; then
		mkdir -p /mnt/NAND/a
		dd if=nanda of=/dev/nanda
		umount /dev/nanda; mount /dev/nanda /mnt/NAND/a
	fi
	read -p "  Write rootfs partions?? [y/n]: " rd
	if [ $rd =  "y" ]; then
		mkdir -p /mnt/NAND/b; mount /dev/nandb /mnt/NAND/b
		tar -jxvf *flash.tar.bz2 -C /mnt/NAND/b/ 
		sync
	fi
	read -p "  Copy env.txt u-boot.bin(modded) uImage in to boot part?? [y/n]: " rd
	if [ $rd =  "y" ]; then
		cp -v uImage /mnt/NAND/a/linux/
		cp -v env.txt /mnt/NAND/a/
		cp -v u-boot.bin /mnt/NAND/a/linux/
		sync
	fi
fi
