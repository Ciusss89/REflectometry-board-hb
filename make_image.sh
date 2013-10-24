#!/bin/bash
# Bash script per la compilazione
# TIPALDI GIUSEPPE 21/10/2013.
# Politecnico di torino, REflectometry projcet
# Dipartimento elettronica, remote sensing.

function cp_src {
        echo '**Copia delle configurazioni, degli script e dei binari extra'; sleep 2
	sudo mkdir -p  rootfs_bd/img-debfs-armhf/etc/ssh/
	sudo cp -v CONFIG_FILE/archivi/*.bz2 rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/71hackberry  rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/fstab rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/inittab rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/lighttpd.conf rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/multistrap.conf rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/sources.list rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/sshd_config rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/dhcpd.conf rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/hostapd.conf rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/interfaces rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/modules rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/rcS rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/sshd_banner rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/config/tmpfs rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/sh/*.sh rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp CONFIG_FILE/sh/flight-plan-control rootfs_bd/img-debfs-armhf/CONFIG_FILE
	sudo cp -rp CONFIG_FILE/sh/sbin rootfs_bd/img-debfs-armhf/CONFIG_FILE/
	sudo chown root -R rootfs_bd/img-debfs-armhf/CONFIG_FILE/*;
	sudo chmod +x rootfs_bd/img-debfs-armhf/CONFIG_FILE/SECOND-STAGE_flash.sh
}

function download {
	read -p "**Download A10 sunxi-tools sunxi-boards [y/n]: " rd

	if [ $rd =  "y" ]; then
		git clone https://github.com/linux-sunxi/sunxi-tools.git
		git clone https://github.com/linux-sunxi/sunxi-boards.git
	else
	if [ -d sunxi-tools ]
	then
		cd sunxi-tools; git pull; cd ..
        	cd sunxi-boards; git pull; cd ..
	fi
	fi

	read -p "**Download sorgenti kernel linux-sunxi ? [y/n]: " rd
	if [ $rd =  "y" ]; then
		git clone --branch sunxi-3.0 git://github.com/linux-sunxi/linux-sunxi.git
	#	cd linux-sunxi; git checkout 23e5456879db0175f571dec43095c49e181e0b10 cd ..
	else
		if [ -d linux-sunxi ]
			then
			cd linux-sunxi; git pull; cd ..
		fi
	fi
}

function Kernel {
	read -p "**menuconfig [y/n]: " rd
	if [ $rd =  "y" ]; then
		cd linux-sunxi
		read -p "**  sun4i defconfig [y/n]: " rd
		if [ $rd =  "y" ]; then
                	make ARCH=arm sun4i_defconfig
		fi
        make ARCH=arm menuconfig
	cd ..
	fi

	read -p "**Compilare il kernel ? [y/n]: " rd
	if [ $rd = "y" ]; then

	COMPILER="arm-linux-gnueabihf-"
	DETAILS="-g.tipaldi-r6"
	cd linux-sunxi
	export ARCH=arm
	export DEB_HOST_ARCH=armhf
	export CONCURRENCY_LEVEL=`grep -m1 cpu\ cores /proc/cpuinfo | cut -d : -f 2`

	clear; echo "**Avvio compilazione del kernel:"; sleep 2
	fakeroot make-kpkg --arch arm --cross-compile arm-linux-gnueabihf- --initrd --append-to-version=$DETAILS kernel_image kernel_headers
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS uImage
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS INSTALL_MOD_PATH=output modules
	make ARCH=arm CROSS_COMPILE=$COMPILER EXTRAVERSION=$DETAILS INSTALL_MOD_PATH=output modules_install
	cd ..
	fi

}

function board {
	read -p "**Compilare script.bin  [y/n]: " rd
	if [ $rd =  "y" ]; then
		cd sunxi-tools; make
		cd ..;
		cp CONFIG_FILE/boot/hackberry.fex sunxi-boards/sys_config/a10/hackberry.fex
		sunxi-tools/fex2bin sunxi-boards/sys_config/a10/hackberry.fex script.bin
	fi
}

function save {
	mkdir -p output_compile/
	read -p "**Acquisire script.bin? [y/n]: " rd
	if [ $rd =  "y" ]; then
		rm -rf output_compile/hackberry-sc*
		mkdir -p output_compile/hackberry-script
		cp -v script.bin output_compile/hackberry-script
	fi
	Current_ver=`cat linux-sunxi/.config | grep Configuration | awk '{print $3}'`
	read -p "**Acquisire le compilazioni del Kernel ? [y/n]: " rd
	if [ $rd = "y" ]; then

	echo "KERNEL UIMAGE"
		mkdir -p output_compile/kernel_image
		cp -vp linux-sunxi/arch/arm/boot/uImage output_compile/kernel_image
		if [ "$(ls -A output_compile/kernel_image/)" ]; then
		     echo "...done"
		else
		     echo "ERROR.";exit
		fi

	echo "KERNEL debian package modules / haders"
		mkdir -p output_compile/kernel.deb
		mv -v  *.deb output_compile/kernel.deb/

		if [ "$(ls -A output_compile/kernel.deb/)" ]; then
		     echo "...done"
		else
		     echo "ERROR.";exit
		fi

	#echo "KERNEL modules "
	#	mkdir -p output_compile/kernel_modules/lib/modules/$Current_ver/
	#	cp -rvp linux-sunxi/output/lib/modules/$Current_ver/kernel output_compile/kernel_modules/lib/modules/$Current_ver/


	cp -vp linux-sunxi/.config output_compile/KERNEL_A10.CONFIG$DETAILS
	ls output_compile/KERNEL_A10.CONFIG$DETAILS
	fi

	read -p "**Acquisisci u-boot e spl [y/n]: " rd
	if [ $rd =  "y" ]; then
		cp -r CONFIG_FILE/boot/u-boot output_compile/
		cp -r CONFIG_FILE/boot/u-boot-spl/ output_compile/
	fi

}


read -p "Download sorgenti [y/n]" rd
if [ $rd =  "y" ]; then
	download
fi

read -p "Kernel setup [y/n]" rd
if [ $rd =  "y" ]; then
	Kernel
fi

read -p "Board/script setup [y/n]" rd
if [ $rd =  "y" ]; then
	board
fi

read -p "Salve compilazioni[y/n]" rd
if [ $rd =  "y" ]; then
	save
fi


read -p "**Creare nuova path (rootfs_bd) e montare un filesistem (ext4) vuoto ? [y/n] : " rd
if [ $rd = "y" ]; then
	echo "*Root:.\img-debfs-armhf  : "
	mkdir -p rootfs_bd ; cd rootfs_bd
	dd if=/dev/zero of=debfs_armhf.img bs=1M count=1024 

	sudo mkfs.ext4 -F debfs_armhf.img
	cd ..
fi

read -p "*Montare il file immagine img-debfs-armhf, [y/n] : " rd
if [ $rd = "y" ]; then
	cd rootfs_bd; mkdir -p img-debfs-armhf 
	sudo mount -o loop debfs_armhf.img img-debfs-armhf
	cd ..
fi

RAMO="jessie" # unstable -> sid, testing -> wheezy, stable -> ?
read -p "*Init Debian/$RAMO/armhf filesystem, setup per chroot : [y/n] : " rd
if [ $rd = "y" ]; then
	cd rootfs_bd
	sudo debootstrap --verbose --arch armhf --variant=minbase --foreign $RAMO img-debfs-armhf http://ftp.debian.org/debian
	cd ..

	sudo cp -v /usr/bin/qemu-arm-static rootfs_bd/img-debfs-armhf/usr/bin
	sudo mkdir -p rootfs_bd/img-debfs-armhf/dev/pts; sudo mkdir -p rootfs_bd/img-debfs-armhf/proc
	
	sudo modprobe binfmt_misc; sleep 1
	echo "***************Montaggio : devpts proc";pwd
	sudo mount -t devpts devpts rootfs_bd/img-debfs-armhf/dev/pts; sleep 1
	sudo mount -t proc proc rootfs_bd/img-debfs-armhf/proc; sleep 1
	sudo modprobe binfmt_misc; sleep 1
fi

for i in {1..2}
do
	read -p "**Setup via deboostrap/chroot...? [y/n] : " rd
	if [ $rd = "y" ]; then

			if [ $i = "1" ]; then
				clear; echo "*****AVVIO DEL PRIMO CICLO, FLASH VERSION";sleep 3;
				sudo mkdir rootfs_bd/img-debfs-armhf/CONFIG_FILE; 
				cp_src
				echo "CONTINUA, LANCIA : './CONFIG_FILE/SECOND-STAGE_flash.sh' "

			else
				clear; echo "*****AVVIO DEL SECONDO CICLO, SD VERSION";sleep 3;
				cp patch/SECOND-STAGE_sd.sh rootfs_bd/img-debfs-armhf/tmp/
				sudo chmod +x rootfs_bd/img-debfs-armhf/tmp/SECOND-STAGE_sd.sh
				sudo cp -v output_compile/kernel.deb/linux-headers* rootfs_bd/img-debfs-armhf/tmp/
				echo "AGGIORNA fstab, LACIA : './tmp/SECOND-STAGE_sd.sh'"
			fi

		sudo chroot rootfs_bd/img-debfs-armhf
	fi

	read -p "**Salva e comprimi immagini? [y/n] : " rd
	if [ $rd = "y" ]; then
		if [ $i = "1" ]; then
			clear;echo "Flash versions rootfs..."; sleep 3
			tar_name="`pwd`/output_compile/nand-image-debfs-armhf.tar.gz"
			cd rootfs_bd/img-debfs-armhf
			sudo tar -pcvzf $tar_name ./ --exclude=proc/* --exclude=dev/pts 
			cd ../..
		else
			clear;echo "Sd version rootfs..."; sleep 3
			tar_name="`pwd`/output_compile/sd-image-debfs-armhf.tar.gz"
			cd rootfs_bd/img-debfs-armhf
			sudo tar -pcvzf  $tar_name ./ --exclude=proc/* --exclude=dev/pts
			cd ../..
		fi
	fi
done

read -p "**Umount rootfs? [y/n] : " rd
if [ $rd = "y" ]; then
	sudo umount rootfs_bd/img-debfs-armhf/proc
	sudo rm -rf rootfs_bd/img-debfs-armhf/dev/pts
	sudo umount rootfs_bd/img-debfs-armhf/dev/pts
	sudo rm -rf rootfs_bd/img-debfs-armhf/usr/bin/qemu-arm-static			
	sudo umount /dev/loop0
fi 
