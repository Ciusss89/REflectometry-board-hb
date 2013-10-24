#!/bin/bash
# Bash script per la creazione della sd contenente la versione di sviluppo.
# TIPALDI GIUSEPPE 21/12/2012.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.

#sddev="/dev/sdc"
#sdp1="/dev/sdc1"
#sdp2="/dev/sdc2"
#sdp3="/dev/sdc3"

sddev="/dev/mmcblk0"
sdp1="/dev/mmcblk0p1"
sdp2="/dev/mmcblk0p2"
sdp3="/dev/mmcblk0p3"

clear

export UMNT="0"

function sd_mnt {
        mkdir -p flash_boot
        sudo mount $sdp1 flash_boot
	UMNT="1"
}

echo "Enter now the sd-card, (within 5 seconds)"; sleep 5
echo "**************** OUTPUT OF 'dmesg | tail' *****************"
dmesg | tail
echo "****CONTINUE ONLY IF YOUR SD-CARD RECOGNIZED AS mmcblk0****"

read -p "  Build sd partions?? [y/n]: " rd
if [ $rd =  "y" ]; then
	sudo fdisk -l $sddev
	read -p "  CONTINUE[n/y]: " rd
	if [ $rd =  "n" ]; then
		exit
	elif [ $rd =  "y" ]; then

		sudo fdisk $sddev ; echo "Partioni:"; sudo fdisk -l $sddev
		echo "Clean sd boot"
		dd if=/dev/zero of=$sddev bs=1024 seek=544 count=128
		sleep 5

		sudo mkfs.vfat -n "HB-BOOT" $sdp1; sleep 1
		sudo mkfs.ext4 -L "HB-DATA" $sdp2; sleep 1

		#If using v2013.07 or earlier use this procedure
		echo "		Install the SPL loader to the 8th block of the SD"
		sudo dd if=output_compile/u-boot-spl/sunxi-spl.bin of=$sddev bs=1024 seek=8; sleep 1
		echo "		Install u-boot to block 32 of the SD:"
		sudo dd if=output_compile/u-boot/u-boot.bin of=$sddev bs=1024 seek=32; sleep 1

		sudo sync

		if [ $UMNT =  "0" ]; then
			sd_mnt
		fi

		echo "		Copy script.bin"
		sudo cp -v output_compile/hackberry-script/script.bin flash_boot
	        sudo cp -v CONFIG_FILE/boot/flash_boot.cmd flash_boot/boot.cmd
	        echo "		Copy Kernel uImage"; sleep 2
	        sudo cp -v output_compile/kernel_image/uImage flash_boot

	        sudo sync

	fi
fi

read -p "  Umount partions?? [y/n]: " rd
if [ $rd =  "y" ]; then
 sudo umount $sdp1
 rmdir flash_boot;
fi
