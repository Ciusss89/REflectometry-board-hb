#!/bin/bash
# Second stage.  TIPALDI GIUSEPPE 10/2013.

echo "*********************SECOND STAGE INSTALL SESSION*********************"
echo "* : debootstrap (second-stage) is beginning."; 
/debootstrap/debootstrap --second-stage
echo "*...debootstrap (second-stage) ended!"; 


PACCHETTI="dhcp3-client udev netbase ifupdown iproute openssh-server iputils-ping wget net-tools ntpdate ntp vim nano less tzdata console-tools console-common module-init-tools cpufrequtils stress htop hdparm firmware-realtek usbutils wireless-tools bzip2  tree lighttpd elinks bc hostapd dhcp3-server wireless-tools iptables rfkill crda"
iptables
echo "*********************CONFIG FILE *********************"
 cd /CONFIG_FILE/
 mkdir -p /etc/lighttpd/; 
 mkdir -p /etc/ssh/
 mkdir -p /etc/dhcp/
 mkdir -p /etc/hostapd/
 echo "hackberry" > /etc/hostname
 mv -v sources.list /etc/apt/sources.list
 mv -v modules /etc/modules
 mv -v hostapd.conf /etc/hostapd/
 mv -v dhcpd.conf /etc/dhcp/dhcpd.conf
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
		clear; echo " Packages will be installed : [$PACCHETTI]"; sleep 4;
		apt-get install $PACCHETTI
		sleep 3;clear;  echo " Install kernel:"
		dpkg -i CONFIG_FILE/linux-image*.deb
		echo "options 8192cu rtw_power_mgnt=0 rtw_enusbss=0" > /etc/modprobe.d/8192cu.conf
		echo "*NAND FINAL VERSION" >> /etc/ssh/sshd_banner
		chmod a+x /etc/init.d/flight-plan-control
		

		chmod a+x /usr/local/sbin/*.sh
		nano /etc/fstab		
		mkdir /mnt/NAND; mkdir /mnt/NAND/01_site/; mkdir /mnt/sd; mkdir /mnt/NAND/01_site/sys_state
		tar -jxvf /CONFIG_FILE/01_site.tar.bz2 -C /mnt/NAND/                                      
		chmod a+x /usr/local/sbin/*.sh	
		tar -jxvf /CONFIG_FILE/hostapd.tar.bz2; apt-mark hold hostapd;
		tar -jxvf /CONFIG_FILE/custom_bin.tar.bz2 -C /usr/local/
		tar -jxvf /CONFIG_FILE/ssh_keys.tar.bz2 -C /etc/ssh/
		echo "*UPDATE rc.d"
		update-rc.d flight-plan-control defaults
		clear ;echo "**CHECK: " sleep 1
		ls -lsh /mnt/NAND/
		ls -lsh /usr/local/sbin/
		ls -lsh /usr/sbin/hostapd*
		ls -lsh /usr/local/bin/
		ls -lsh /etc/ssh/
		echo 'put /etc/hostapd/hostapd.conf DEAMON_CONF in file /etc/default/hostapd'
fi

rm -rf  /CONFIG_FILE/; apt-get clean; apt-get autoclean
echo "BASE SYSTEM INSTALL COMPLETE :p"

read -p "  EXIT : " rd
if [ $rd = "y" ]; then
	exit
fi
