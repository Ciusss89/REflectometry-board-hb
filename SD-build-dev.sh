#!/bin/bash
# Bash script per la creazione della sd contenente la versione di sviluppo.
# TIPALDI GIUSEPPE 21/12/2012.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.


clear

export UMNT="0"

function sd_mnt {
        mkdir -p sd_boot
        sudo mount /dev/mmcblk0p1 sd_boot
        mkdir -p sd_rootfs
        sudo mount /dev/mmcblk0p2 sd_rootfs
        mkdir -p sd_data	
	sudo mount /dev/mmcblk0p3 sd_data
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
	elif [ $rd =  "y" ]; then

		sudo fdisk /dev/mmcblk0
		sudo fdisk -l /dev/mmcblk0

		sudo mkfs.vfat -n "HB-BOOT" /dev/mmcblk0p1 
		sudo mkfs.ext4 -L "HB-ROOT" /dev/mmcblk0p2
		sudo mkfs.ext4 -L "HB-DATA" /dev/mmcblk0p3
		
		echo "		Install the SPL loader to the 8th block of the SD"; sleep 2
		sudo dd if=output_compile/u-boot-spl/sunxi-spl.bin of=/dev/mmcblk0 bs=1024 seek=8
	        # dd if=sunxi-spl.bin of=/dev/nand bs=1024 seek=8
		echo "		Install u-boot to block 32 of the SD:"; sleep 2
		sudo dd if=output_compile/u-boot/u-boot.bin of=/dev/mmcblk0 bs=1024 seek=32
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
	echo "		Rootfs aveable..."; ls *.tar.bz2; read -p "  	type rootfs image... : " rd
	echo "		Extract rootfs image is starting.. "; sleep 2
	cd ..
	sudo tar -jxvf output_compile/$rd -C ./sd_rootfs/

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
	sudo cp -v patch/env.txt sd_data/ ; sudo cp -v patch/u-boot.bin  sd_data/ 
	echo " ** Copy flash rootfs image.."
	sudo cp -v output_compile/debfs_armhf_flash.tar.bz2 sd_data/
	echo " ** Copy uImage kernel.."
	sudo cp -v output_compile/kernel_image/uImage sd_data/
	echo " ** Copy Script install.."
	sudo cp -v patch/flash_install.sh sd_data/

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
	sudo umount /dev/mmcblk0p2
	sudo umount /dev/mmcblk0p1
	sudo umount /dev/mmcblk0p3
fi
