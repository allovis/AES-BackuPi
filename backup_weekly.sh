#!/bin/bash

# ==============================================================================
# ------------------------ ALLOVIS ENGINEERING SERVICES ------------------------
#                                 Torino, Italy
# ------------------------------------------------------------------------------
# Backup script for raspberry PI
# ------------------------------------------------------------------------------
# created on 07/07/2017 by DE
# ==============================================================================

echo " =============================================================="
echo " ---------------- ALLOVIS ENGINEERING SERVICES ----------------"
echo "  Backup script for raspberry PI - created on 07/07/2017 by DE"
echo " =============================================================="
echo ""

## modificare file di configurazione e creare il backup
cp /etc/rsnapshot_weekly /etc/rsnapshot.conf
echo $log "setted rsnapshot_weekly as configuration file"

# BACKUP_DISK=sda1

mount="mount -t cifs -o username=admin,password=nerinagrigetta1977"

err=0
log=""

DIR[0]="//10.0.48.244/AEQ-LOG"
loc[0]="/mnt/botte04/AEQ-LOG"
DIR[1]="//10.0.48.244/AEQ-SP"
loc[1]="/mnt/botte04/AEQ-SP"
DIR[2]="//10.0.48.244/AES-EP"
loc[2]="/mnt/botte04/AES-EP"
DIR[3]="//10.0.48.244/ALL-PNSN"
loc[3]="/mnt/botte04/ALL-PNSN"
DIR[4]="//10.0.48.244/info"
loc[4]="/mnt/botte04/info"
DIR[5]="//10.0.48.243/AEQ-Contabilita"
loc[5]="/mnt/botte03/AEQ-Contabilita"
DIR[6]="//10.0.48.243/AEQ-Documenti"
loc[6]="/mnt/botte03/AEQ-Documenti"
DIR[7]="//10.0.48.243/AEQ-Protocollo"
loc[7]="/mnt/botte03/AEQ-Protocollo"
DIR[8]="//10.0.48.243/AES-APL"
loc[8]="/mnt/botte03/AES-APL"
DIR[9]="//10.0.48.243/AES-Contabilita"
loc[9]="/mnt/botte03/AES-Contabilita"
DIR[10]="//10.0.48.243/AES-Documenti"
loc[10]="/mnt/botte03/AES-Documenti"
DIR[11]="//10.0.48.243/AES-Protocollo"
loc[11]="/mnt/botte03/AES-Protocollo"
DIR[12]="//10.0.48.243/ALL-Format"
loc[12]="/mnt/botte03/ALL-Format"
DIR[13]="//10.0.48.243/ALL-Human_Resourse"
loc[13]="/mnt/botte03/ALL-Human_Resourse"
DIR[14]="//10.0.48.243/ALL-Iso_Programmi"
loc[14]="/mnt/botte03/ALL-Iso_Programmi"
DIR[15]="//10.0.48.243/ALL-Office"
loc[15]="/mnt/botte03/ALL-Office"
DIR[16]="//10.0.48.243/ALL-REF"
loc[16]="/mnt/botte03/ALL-REF"
DIR[17]="//10.0.48.243/ALL-Scansioni"
loc[17]="/mnt/botte03/ALL-Scansioni"
DIR[18]="//10.0.48.243/ALL-SMW"
loc[18]="/mnt/botte03/ALL-SMW"
DIR[19]="//10.0.48.243/ALL-Traning"
loc[19]="/mnt/botte03/ALL-Traning"
DIR[20]="//10.0.48.243/ALL-TS"
loc[20]="/mnt/botte03/ALL-TS"
DIR[21]="//10.0.48.243/info"
loc[21]="/mnt/botte03/info"
DIR[22]="//10.0.48.242/Botte02_ALLOVIS"
loc[22]="/mnt/botte02/Botte02_ALLOVIS"

## verificare presenza sda1 collegato ad usb
## verificare che sda1 non è montato in /dev/mapper
## verificare che sda1 non è montato in /mnt

## aprire volume criptato
cryptsetup luksOpen -d /home/pi/key /dev/sda1 sda1
echo $log "crypted /dev/sda1 opened"

## verificare apertura volume
sleep 5

## montare sda1 in /mnt
mount /dev/mapper/sda1 /mnt/BKPDISK
echo $log "mounted /dev/mapper/sda1 in /mnt/BKPDISK"

## verificare montaggio partizione
flagfile='/mnt/BKPDISK/weekly.aesbackup'
if [ -e $flagFile ];
then

## montare cartelle 
	i=0
	for dir in "${DIR[@]}";
		do
			$mount $dir ${loc[$i]};
			echo $log "  mounted" $dir "in" ${loc[$i]};
			i=$i+1;
			sleep 1
		done
	
## verificare cartelle di rete montate
	
## -----------------------------------------------------------------------------
## ESEGUIRE BACKUP
	echo "[!]" "Backing up now! Please wait, it may take a very long time!"
	echo $log "For log watching please tailf /var/log/rsnapshot file."
	rsnapshot weekly
	echo $log "Backup ended."
## -----------------------------------------------------------------------------
	
## smontare cartelle di backup
	for loc in "${loc[@]}";
        	do
        	        umount $loc;
       			echo $log "  unmounted" $loc;
	        done
else
	echo "Flag File not found. It may means that backupdisk is not correct or not present."
	err=$err+1
fi

## smontare partizione /mnt/BKPDISK
umount /mnt/BKPDISK
echo $log "unmounted /mnt/BKPDISK"

## chiudere volume criptato
cryptsetup luksClose sda1
echo $log "crypted /dev/sda1 closed"

## inviare notifica
if [ $err -eq 0 ];
then
	echo $log "AES Backup finished!"
else
	echo $log "Some ERROR occurred! no bakcup done. Exiting."
fi


exit
