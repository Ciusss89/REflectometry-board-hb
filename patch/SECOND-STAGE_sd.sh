#!/bin/bash
# Second stage.  TIPALDI GIUSEPPE 12/2012

PACCHETTI="libgusb2 libusb-dev libusbprog-dev libusbprog0 usbutils g++ make git build-essential"

read -p "  START BASE SYSTEM INSTALL? [y/n] : " rd
if [ $rd = "y" ]; then
		echo "Linux headers install.." sleep 2;
		dpkg -i /tmp/linux-headers*; rm /tmp/linux-headers*
		echo " Packages will be installed : [$PACCHETTI]"; sleep 10
		apt-get install $PACCHETTI
		echo " Edit last line"
		nano /etc/ssh/sshd_banner
		echo " YOU EDIT FSTAB, AND SPECIFY ROOT PARTIONS.."
		mkdir /mnt/NAND/a; mkdir /mnt/NAND/b; mkdir /mnt/NAND/c; mkdir /mnt/data/;
		nano /etc/fstab
fi

rm -rf  /etc/SECOND-STAGE_bis.sh
echo "DEVELOPEMENT SD-CARD SYSTEM INSTALL COMPLETE :p"

read -p "  EXIT : " rd
if [ $rd = "y" ]; then
	exit
fi
