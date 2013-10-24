#!/bin/bash
# TIPALDI GIUSEPPE 2-2013
# IMPORTANTE
# Utilizzo  FLYMODE.sh A B
# Se A=[0,1] 1 Attiva modalita di scansione automatica, 0 disattiva.
# In B specificare il tempo.

FLAG=$1;
TIME=$2;


case "$1" in
  0)
	echo  "Automatic scanning mode DISABLE."
	echo "# NOT EDIT THIS FILE. IT AUTOGENERATED FROM FLYMODE.sh" > /mnt/NAND/01_site/sys_state/FLYMODE
	echo "BIT: $FLAG" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "TIME: $TIME" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "echo 'BIT $BIT'" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "echo 'TIME $TIME'" >> /mnt/NAND/01_site/sys_state/FLYMODE
	chmod a+x /mnt/NAND/01_site/sys_state/FLYMODE
    ;;
  1)
	echo  "Automatic scanning mode ACTIVED, acquire time [$2]"
	echo "# NOT EDIT THIS FILE. IT AUTOGENERATED FROM FLYMODE.sh" > /mnt/NAND/01_site/sys_state/FLYMODE
	echo "BIT: $FLAG" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "TIME: $TIME" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "echo 'BIT $BIT'" >> /mnt/NAND/01_site/sys_state/FLYMODE
	echo "echo 'TIME $TIME'" >> /mnt/NAND/01_site/sys_state/FLYMODE
	chmod a+x /mnt/NAND/01_site/sys_state/FLYMODE
    ;;
  *)
	echo "* HELP:"
	echo "*Usage: FLYMODE.sh 0/1 TIME"
	echo "* 0: Disable autmatic scanning mode"
	echo "* 1: Enable autmatic scanning mode"
	echo "* TIME is time.."
    exit 1
    ;;
esac
