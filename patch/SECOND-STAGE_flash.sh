#!/bin/bash
# Second stage.  TIPALDI GIUSEPPE 12/2012.

echo "*********************SECOND STAGE INSTALL SESSION*********************"
echo "* : debootstrap (second-stage) is beginning."; 
/debootstrap/debootstrap --second-stage
echo "*...debootstrap (second-stage) ended!"; 


PACCHETTI="dhcp3-client udev netbase ifupdown iproute openssh-server iputils-ping wget net-tools ntpdate ntp vim nano less tzdata console-tools console-common module-init-tools cpufrequtils stress htop hdparm firmware-realtek usbutils wireless-tools bzip2 hardinfo tree lighttpd elinks bc isc-dhcpd-server wireless-tools "

echo "*********************CONFIG FILE *********************"
 cd /CONFIG_FILE/
 mkdir -p /etc/lighttpd/; 
 mkdir -p  /etc/ssh/
 echo "hackberry" > /etc/hostname
 mv -v sources.list /etc/apt/sources.list
 mv -v fstab /etc/fstab
 mv -v inittab /etc/inittab
 mv -v interfaces /etc/network/interfaces
 mv -v rcS /etc/default/rcS
 mv -v 71hackberry /etc/apt/apt.conf.d/71hackberry
 mv -v sshd_banner /etc/ssh/
 mv -v sshd_config /etc/ssh/
 mv -v lighttpd.conf /etc/lighttpd/
 mv -v tmpfs /etc/default/
 mv -v flight-plan-control /etc/init.d/
 mv -v ./sbin /usr/local/
 cd ..
echo "*...Copy configurations file ended!"; 

read -p "  START BASE SYSTEM INSTALL? [y/n] : " rd
if [ $rd = "y" ]; then
                echo " TYPE NEW PASSOWRD"
                passwd
                apt-get update
                export LANG=C
                apt-get install apt-utils dialog locales
                dpkg-reconfigure locales
		dpkg-reconfigure tzdata
		echo " Packages will be installed : [$PACCHETTI]" sleep 10;
		apt-get install $PACCHETTI
		echo " Install kernel:"
		dpkg -i CONFIG_FILE/linux-image*.deb
		 echo "options 8192cu rtw_power_mgnt=0 rtw_enusbss=0" > /etc/modprobe.d/8192cu.conf
		echo "*NAND FINAL VERSION" >> /etc/ssh/sshd_banner
		chmod a+x /etc/init.d/flight-plan-control
		update-rc.d flight-plan-control defaults
		chmod a+x /usr/local/sbin/*.sd
		echo " YOU EDIT FSTAB, AND SPECIFY ROOT PARTIONS.."
		nano /etc/fstab		
		mkdir /mnt/NAND; mkdir /mnt/NAND/01_site/; mkdir /mnt/sd; mkdir /mnt/NAND/01_site/sys_state
		tar -jxvf /CONFIG_FILE/01_site.tar.bz2 -C /mnt/NAND/; ls -lsh /mnt/NAND/
		chmod a+x /usr/local/sbin/*.sh; ls -lsh /usr/local/sbin/
		tar -jxvf /CONFIG_FILE/custom_bin.tar.bz2 -C /usr/local/; ls -lsh /usr/local/bin/
		tar -jxvf /CONFIG_FILE/ssh_keys.tar.bz2 -C /etc/ssh/; ls -lsh /etc/ssh/
fi

ls -lsh /CONFIG_FILE/; rm -rf  /CONFIG_FILE/
echo "BASE SYSTEM INSTALL COMPLETE :p"

read -p "  EXIT : " rd
if [ $rd = "y" ]; then
	exit
fi
