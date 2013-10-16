#!/bin/bash
# Bash script per la compilazione :
#  - Bootloader [u-boot]
#  - Script boot config [sunxi-board, sunxi-tool]
#  - Kernel image. [ linux-sunxi ]
#  - Rootfs build. [ wheezy ]
# Nella direcotory pacht sono contenui le configurazioni sviluppate per il sistema.
# Nella direcotory oput_compile vengono salvati gli ouput prodotti dalla compilazione.
# E' ommessa la verifica sugli errori sul processo in corso.
# TIPALDI GIUSEPPE 21/12/2012.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.

clear;
export mc_flah="0"

function cp_src {
        echo "Start copy config file..."; sleep 2
        sudo cp  patch/sources.list rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/fstab rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/inittab rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/interfaces rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/rcS rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/71hackberry rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo mkdir -p  rootfs_bd/img-debfs-armhf/etc/ssh/
        sudo cp  patch/sshd_banner rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/sshd_config rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp  patch/lighttpd.conf rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp  patch/tmpfs rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp  patch/flight-plan-control rootfs_bd/img-debfs-armhf/CONFIG_FILE
        sudo cp  patch/SECOND-STAGE_flash.sh rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp  patch/01_site.tar.bz2 rootfs_bd/img-debfs-armhf/CONFIG_FILE
#	sudo cp  patch/script.tar.bz2 rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp -r patch/sbin rootfs_bd/img-debfs-armhf/CONFIG_FILE/
	sudo cp  patch/custom_bin.tar.bz2 rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp  patch/ssh_keys.tar.bz2 rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp output_compile/kernel.deb/linux-image* rootfs_bd/img-debfs-armhf/CONFIG_FILE
	echo "...done"
}

function umount_deboostrap {
	sudo umount rootfs_bd/img-debfs-armhf/proc
	sudo rm -rf rootfs_bd/img-debfs-armhf/dev/pts
	sudo umount rootfs_bd/img-debfs-armhf/dev/pts
	sudo rm -rf rootfs_bd/img-debfs-armhf/usr/bin/qemu-arm-static
}

function mount_deboostrap {
	sudo cp /usr/bin/qemu-arm-static rootfs_bd/img-debfs-armhf/usr/bin
	sudo mkdir rootfs_bd/img-debfs-armhf/dev/pts
	sudo modprobe binfmt_misc
	sudo mount devpts  rootfs_bd/img-debfs-armhf/dev/pts -t devpts
	sudo mount -t proc proc rootfs_bd/img-debfs-armhf/proc
	mc_flah="1"
	echo "...mount devs done"
}
###############################################################################################################################################
# Install all packages.
# MACHINE SETUP

com="gcc-4.7-arm-linux-gnueabihf"

echo -e '\E[32m STAGE 1 START... '

read -p "  Install compiler tools? [y/n]: " rd
if [ $rd =  "y" ]; then
	echo "Retrieve compiler tools"
	sudo apt-get install multistrap qemu-user-static binfmt-support debootstrap build-essential git uboot-mkimage libncurses5-dev fakeroot kernel-package u-boot-tools zlib1g-dev libncurses5-dev 
	echo "Compiler is $com,"
	sudo apt-get install $com
fi

echo -e '\E[32m STAGE 1 ENDED...'
################################################################################################################################################

###############################################################################################################################################
# https://github.com/linux-sunxi/u-boot-sunxi/wiki
#
echo -e '\E[35m STAGE 2 START... '

read -p "  Download A10 SoC u-boot-sunxi suorce ? [y/n]: " rd
if [ $rd =  "y" ]; then
	git clone https://github.com/linux-sunxi/u-boot-sunxi.git
	# git clone -b lichee/lichee-dev-ICS https://github.com/linux-sunxi/u-boot-sunxi.git u-boot-lichee-dev-ICS
	# git clone https://github.com/hno/uboot-allwinner.git u-boot-allwinner-hno

else
if [ -d /u-boot-sunxi ]
	then
		cd u-boot-sunxi; git pull; cd ..
	fi
fi

read -p "  Building u-boot target [hackberry]? [y/n]: " rd
if [ $rd =  "y" ]; then
	COMPILER="arm-linux-gnueabihf-"
	cd u-boot-sunxi/
	make Hackberry CROSS_COMPILE=$COMPILER
	cd ..
fi


read -p "  Save u-boot/sunxi-spl? [y/n]: " rd
if [ $rd =  "y" ]; then
	rm -rf output_compile/u-boot*
	mkdir -p output_compile/u-boot-spl; mkdir -p output_compile/u-boot;

	cp -v u-boot-sunxi/spl/sunxi-spl.bin output_compile/u-boot-spl
	cp -v u-boot-sunxi/u-boot.bin output_compile/u-boot
fi

echo -e '\E[35m STAGE 2 ENDED...'
################################################################################################################################################

###############################################################################################################################################
# linux-sn4i tools/boards
echo -e '\E[31m STAGE 3 START... '

read -p "  Download A10 sunxi-tools suorce, and sunxi-boards source  [y/n]: " rd
if [ $rd =  "y" ]; then
	git clone https://github.com/linux-sunxi/sunxi-tools.git
	git clone https://github.com/linux-sunxi/sunxi-boards.git
else

if [ -d /sunxi-tools ]
then
	cd sunxi-tools; git pull; cd ..
        cd sunxi-boards; git pull; cd ..
fi

fi


read -p "  Building script.bin  [y/n]: " rd
if [ $rd =  "y" ]; then
	cd sunxi-tools; make
	cd ..;
	cp patch/hackberry.fex sunxi-boards/sys_config/a10/hackberry.fex
	sunxi-tools/fex2bin sunxi-boards/sys_config/a10/hackberry.fex script.bin
fi

read -p "  Save script.bin? [y/n]: " rd
if [ $rd =  "y" ]; then
	rm -rf output_compile/hackberry-sc*
	mkdir -p output_compile/hackberry-script
	cp -v script.bin output_compile/hackberry-script
	mv -v script.bin patch/script.MAC_HWsetup.bin
fi

echo -e '\E[31m STAGE 3 ENDED...'
################################################################################################################################################

###############################################################################################################################################
# Retrieve kernel source, apply patchs, configure kernerl, and compiling.
# http://linux-sunxi.org/Linux
echo -e '\E[36m STAGE 4 START... '

##
# SOURCES 
read -p "  Download of linux-sunxi kernel suource ? [y/n]: " rd
if [ $rd =  "y" ]; then
	# tesing rapo
	#git clone -b sunxi-3.4 git://github.com/linux-sunxi/linux-sunxi.git
	# stable rapo
	git clone git://github.com/linux-sunxi/linux-sunxi.git
#	cd linux-sunxi; git checkout 23e5456879db0175f571dec43095c49e181e0b10 cd ..
else

if [ -d /linux-sunxi ]
	then
		cd linux-sunxi; git pull; cd ..
	fi
fi

##
# .CONFIG SETUP
read -p "  Make the default .config for allwinner A10 SoC  [y/n]: " rd
if [ $rd =  "y" ]; then
	cd linux-sunxi
	make ARCH=arm sun4i_defconfig
	cd ..
fi

read -p "  Copy custom .config? [y/n]: " rd
if [ $rd = "y" ]; then
	ls patch/KERNEL_A10*
	read -p "  Insert config name : " rd
	cp -v patch/$rd linux-sunxi/.config
fi

read -p "  Add/remove/include modules? [y/n]: " rd
if [ $rd = "y" ]; then
	cd linux-sunxi
	make ARCH=arm menuconfig
	cd ..
fi

read -p "  Start kernel compiling? [y/n]: " rd
if [ $rd = "y" ]; then
##
# SETUP MAKE PROCEDURE
	COMPILER="arm-linux-gnueabihf-"
	DETAILS="-g.tipaldi-r5"
	cd linux-sunxi
	export ARCH=arm
	export DEB_HOST_ARCH=armhf
	export CONCURRENCY_LEVEL=`grep -m1 cpu\ cores /proc/cpuinfo | cut -d : -f 2`

	echo "   Start, kernel compiling"; sleep 2
	fakeroot make-kpkg --arch arm --cross-compile arm-linux-gnueabihf- --initrd --append-to-version=$DETAILS kernel_image kernel_headers
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS uImage
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS INSTALL_MOD_PATH=output modules
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS INSTALL_MOD_PATH=output modules_install
	cd ..
fi

##
# Save output compile.

Current_ver=`cat linux-sunxi/.config | grep Configuration | awk '{print $3}'`
M_PAT=linux-sunxi/output/lib/modules/$Current_ver
read -p "  Save Kernel builds? [y/n]: " rd
if [ $rd = "y" ]; then

	mkdir -p output_compile/kernel_image
	cp -v linux-sunxi/arch/arm/boot/uImage output_compile/kernel_image

	mkdir -p output_compile/kernel_modules/lib/modules/$Current_ver/
	cp -rp linux-sunxi/output/lib/modules/$Current_ver*/kernel output_compile/kernel_modules/lib/modules/$Current_ver/

	mkdir -p output_compile/kernel.deb
	mv -v  *.deb output_compile/kernel.deb/

	cp -v linux-sunxi/.config output_compile/KERNEL_A10.CONFIG$DETAILS
	ls output_compile/KERNEL_A10.CONFIG$DETAILS
fi

echo -e '\E[36m STAGE 4 ENDED... '
###############################################################################################################################################



###############################################################################################################################################
# ROOTFS BUILD.
# http://linux-sunxi.org/Debian
echo -e '\E[33m STAGE 5 START... '

read -p "  Set up working directory and mount empty filesystem, [y/n]: " rd
if [ $rd = "y" ]; then
	echo "  Build ext4 image ( 1Gb ) rootfs, and mount it in .\img-debfs-armhf  : "
	mkdir -p rootfs_bd ; cd rootfs_bd
	dd if=/dev/zero of=debfs_armhf.img bs=1M count=1024 
	echo " Filesystem is ext4"
	sudo mkfs.ext4 -F debfs_armhf.img
	cd ..
fi

read -p "  Mount img-debfs-armhf, [y/n] : " rd
if [ $rd = "y" ]; then
	cd rootfs_bd; mkdir -p img-debfs-armhf 
	sudo mount -o loop debfs_armhf.img img-debfs-armhf
	cd ..
fi

RAMO="jessie" # unstable -> sid, testing -> wheezy, stable -> ?
read -p "  Init Debian/$RAMO/armhf filesystem by debootstrap [y/n] : " rd
if [ $rd = "y" ]; then
	cd rootfs_bd
	sudo debootstrap --verbose --arch armhf --variant=minbase --foreign $RAMO img-debfs-armhf http://ftp.debian.org/debian
	cd ..
fi

for i in {1..2}
do
	read -p "  Basic setup via deboostrap/chroot...? [y/n] : " rd
	if [ $rd = "y" ]; then
		if [ $mc_flah = "0" ]; then
			mount_deboostrap
		fi


			if [ $i = "1" ]; then
				echo "***FIRST RUN. [Building nand rootfs image ]";sleep 3;
				sudo mkdir rootfs_bd/img-debfs-armhf/CONFIG_FILE; 
				cp_src
				echo "CONTINUE SECOND STAGE INSTALLATIONS, RUN : './CONFIG_FILE/SECOND-STAGE_flash.sh' "
			else
				echo "***SECOND RUN. [Building sd-card rootfs image ]"; sleep 3;
				cp patch/SECOND-STAGE_sd.sh rootfs_bd/img-debfs-armhf/tmp/
				sudo cp -v output_compile/kernel.deb/linux-headers* rootfs_bd/img-debfs-armhf/tmp/
				echo "Edit fstab, RUN : './tmp/SECOND-STAGE_sd.sh', install missing developement packages "
			fi

		sudo chroot rootfs_bd/img-debfs-armhf
	fi

	read -p "  Compress and save image? [y/n] : " rd
	if [ $rd = "y" ]; then
		if [ $i = "1" ]; then
			echo "  Compres flash versions rootfs..."; sleep 3
			umount_deboostrap
			cd rootfs_bd/img-debfs-armhf
			sudo tar -pcvzf img-debfs-armhf.tar.gz .
			cd ../..
			sudo mv -v rootfs_bd/img-debfs-armhf/debfs_armhf_flash.tar.gz output_compile/
			mount_deboostrap
		else
			umount_deboostrap
			echo "  Compres sd version rootfs..."; sleep 3
			cd rootfs_bd/img-debfs-armhf
			sudo tar -pcvzf debfs_armhf_sd.tar.gz .
			cd ../..
			sudo mv -v rootfs_bd/img-debfs-armhf/debfs_armhf_sd.tar.gz output_compile/
		fi
	fi
done

read -p "  Umount rootfs? [y/n] : " rd
if [ $rd = "y" ]; then
	sudo umount /dev/loop0
fi
echo -e '\E[33m STAGE 5 ENDED...'       

################################################################################################################################################

du -lsh output_compile/*
