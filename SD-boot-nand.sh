#!/bin/bash
# Bash script per la creazione di una sd avviabile. finalità testing.
# Sistema ibrido, kernel su sd-card, rootfs nella nand.
# TIPALDI GIUSEPPE 21/12/2012.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.

clear

export UMNT="0"

function sd_mnt {
        mkdir -p sd_boot
        sudo mount /dev/mmcblk0p1 sd_boot
        mkdir -p sd_data
	UMNT="1"
}

echo "Enter now the sd-card, (within 5 seconds)"; sleep 5
echo "**************** OUTPUT OF 'dmesg | tail' *****************"
dmesg | tail
echo "****CONTINUE ONLY IF YOUR SD-CARD RECOGNIZED AS mmcblk0****"

read -p "  Build sd partions?? [y/n]: " rd
if [ $rd =  "y" ]; then
	sudo fdisk -l /dev/mmcblk0
	read -p "  CONTINUE: " rd
	if [ $rd =  "n" ]; then
		exit
	elif [$rd =  "y" ]; then
		sudo fdisk /dev/mmcblk0
		sudo fdisk -l /dev/mmcblk0

		sudo mkfs.vfat -n "HB-BOOT" /dev/mmcblk0p1 
		sudo mkfs.ext4 -L "HB-DATA" /dev/mmcblk0p2

		echo "		Install the SPL loader to the 8th block of the SD"; sleep 2
		sudo dd if=output_compile/IBRID/sunxi-spl.bin of=/dev/mmcblk0 bs=1024 seek=8
		        # dd if=sunxi-spl.bin of=/dev/nand bs=1024 seek=8
		echo "		Install u-boot to block 32 of the SD:"; sleep 2
		sudo dd if=output_compile/IBRID/u-boot.bin of=/dev/mmcblk0 bs=1024 seek=32
		        # dd if=u-boot.bin of=/dev/nand bs=1024 seek=32
		sudo sync
	
		if [ $UMNT =  "0" ]; then
			sd_mnt
		fi

		echo "		Copy script.bin"
		sudo cp -v output_compile/hackberry-script/script.bin sd_boot
       		sudo cp -v patch/flash_boot.cmd sd_boot/boot.cmd

        	cd sd_boot
       		sudo mkimage -C none -A arm -T script -d boot.cmd boot.scr; sudo rm boot.cmd
	        cd ..
		sudo sync
	fi
fi

read -p "  Install uImage and kernel modules?? [y/n]: " rd
if [ $rd =  "y" ]; then

	if [ $UMNT =  "0" ]; then
		sd_mnt
	fi

        echo "		Copy Kernel uImage"; sleep 2
        sudo cp -v output_compile/kernel_image/uImage sd_boot

        sudo sync
fi

read -p "  Umount partions?? [y/n]: " rd
if [ $rd =  "y" ]; then
	sudo umount /dev/mmcblk0p1
fi
