#!/bin/bash
# Bash script per la creazione della sd contenente la versione di sviluppo.
# TIPALDI GIUSEPPE 21/12/2012.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.

sddev="/dev/mmcblk0"
sdp1="/dev/mmcblk0p1"
sdp2="/dev/mmcblk0p2"
sdp3="/dev/mmcblk0p3"

clear

export UMNT="0"

function sd_mnt {
        mkdir -p sd_boot
        sudo mount $sdp1 sd_boot
        mkdir -p sd_rootfs
        sudo mount $sdp2 sd_rootfs
        mkdir -p sd_data	
	sudo mount $sdp3 sd_data
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

		sudo fdisk $sddev
		echo "Partioni:"
		sudo fdisk -l $sddev

		sleep 5

		sudo mkfs.vfat -n "HB-BOOT" $sdp1; sleep 1
		sudo mkfs.ext4 -L "HB-ROOT" $sdp2; sleep 1 
		sudo mkfs.ext4 -L "HB-DATA" $sdp3; sleep 1
		
		echo "		Install the SPL loader to the 8th block of the SD"
		sudo dd if=output_compile/u-boot-spl/sunxi-spl.bin of=$sddev bs=1024 seek=8; sleep 1
	        # dd if=sunxi-spl.bin of=/dev/nand bs=1024 seek=8
		echo "		Install u-boot to block 32 of the SD:"
		sudo dd if=output_compile/u-boot/u-boot.bin of=$sddev bs=1024 seek=32; sleep 1
		        # dd if=u-boot.bin of=/dev/nand bs=1024 seek=32
		sudo sync

		if [ $UMNT =  "0" ]; then
			sd_mnt
		fi

		echo "		Copy script.bin"
		sudo cp -v output_compile/hackberry-script/script.bin sd_boot
	        sudo cp -v patch/sd_boot.cmd sd_boot/boot.cmd

        	cd sd_boot
        	sudo mkimage -C none -A arm -T script -d boot.cmd boot.scr; sudo rm boot.cmd
        	cd ..
		sudo sync
	fi
fi

read -p "	Install rootfs partion?? [y/n]: " rd
if [ $rd =  "y" ]; then

	if [ $UMNT =  "0" ]; then
		sd_mnt
	fi
	
	cd output_compile/
	echo "		Rootfs aveable..."; ls *.tar.gz; read -p "  	type rootfs image... : " rd
	echo "		Extract rootfs image is starting.. "; sleep 2
	cd ..
	sudo tar -pxvzf output_compile/$rd -C ./sd_rootfs/
	sudo cp -v patch/flash_install.sh ./sd_rootfs/usr/local/sbin/; sudo chmod a+x ./sd_rootfs/usr/local/sbin/flash_install.sh

	sudo sync 
fi

read -p "  Install uImage kernel?? [y/n]: " rd
if [ $rd =  "y" ]; then

	if [ $UMNT =  "0" ]; then
		sd_mnt
	fi

        echo "		Copy Kernel uImage"; sleep 2
        sudo cp -v output_compile/kernel_image/uImage sd_boot

        sudo sync
fi

read -p "  Copy to data sd-cad partion 'flash files'?? [y/n]: " rd
if [ $rd =  "y" ]; then

	if [ $UMNT =  "0" ]; then
		sd_mnt
	fi
	
	echo " ** Copy dd image of NANDA partion.."
	sudo cp -v patch/nanda sd_data/
	echo " ** Copy env.txt and special u-boot-bin.."
	sudo cp -v patch/env.txt sd_data/ ; sudo cp -v patch/u-boot.bin  sd_data/; sudo cp -v patch/script.MAC_HWsetup.bin sd_data/ ; 
	echo " ** Copy flash rootfs image.."
	sudo cp -v output_compile/debfs_armhf_flash.tar.bz2 sd_data/
	echo " ** Copy uImage kernel.."
	sudo cp -v output_compile/kernel_image/uImage sd_data/
	echo " ** Copy Script install.."

        sudo sync
fi

read -p "  Copy gn3s and fx2programmer sunxi-tools in to sd-cad partion  ?? [y/n]: " rd
if [ $rd =  "y" ]; then
	if [ $UMNT =  "0" ]; then
		sd_mnt
	fi

	echo "Copy gn3s soruce, fx2progammer sorce, "
	sudo cp -vr gn3s sd_data/
	sudo cp -vr fx2_programmer sd_data/
	sudo cp -vr sunxi-tools sd_data/
fi

read -p "  Umount partions?? [y/n]: " rd
if [ $rd =  "y" ]; then
	sudo umount $sdp2
	sudo umount $sdp1
	sudo umount $sdp3
fi
