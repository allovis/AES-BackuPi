#!/bin/bash

# ==============================================================================
# ---------------------------------- EDBackuPi ---------------------------------
#                                 Torino, Italy
# ------------------------------------------------------------------------------
# Backup script for raspberry PI
# ------------------------------------------------------------------------------
# created on 07/07/2017 by DE
# ==============================================================================

echo " =============================================================="
echo "  Backup script for raspberry PI - created on 07/07/2017 by DE"
echo " =============================================================="
echo ""

## modificare file di configurazione e creare il backup
cp /etc/rsnapshot_monthly /etc/rsnapshot.conf
echo $log "setted rsnapshot_monthly as configuration file"

# BACKUP_DISK=sda1

mount="mount -t cifs -o username={USERNAME},password={PASSWORD}"

log=""

DIR[0]="/{NETWORKLOCATION}/{DIRECTORYNAME}"
loc[0]="/mnt/{MOUNTDIR}/{DIRECTORYNAME}"
DIR[1]="//10.0.48.244/DIR-1"
loc[1]="/mnt/mountdir/DIR-1"
# ....... other dir in list

## verificare presenza sda1 collegato ad usb
## verificare che sda1 non è montato in /dev/mapper
## verificare che sda1 non è montato in /mnt

## aprire volume criptato
cryptsetup luksOpen -d /home/pi/key /dev/sda1 sda1
echo $log "crypted /dev/sda1 opened"

## verificare apertura volume

## montare sda1 in /mnt
mount /dev/mapper/sda1 /mnt/BKPDISK
echo $log "mounted /dev/mapper/sda1 in /mnt/BKPDISK"

## verificare montaggio partizione

## montare cartelle 
i=0
for dir in "${DIR[@]}";
	do
		$mount $dir ${loc[$i]};
		echo $log "  mounted" $dir "in" ${loc[$i]};
		i=$i+1;
	done

## verificare cartelle di rete montate

## -----------------------------------------------------------------------------
## ESEGUIRE BACKUP
echo "[!]" "Backing up now! Please wait, it may take a very long time!"
echo $log "For log watching please tailf /var/log/rsnapshot file."
rsnapshot monthly
echo $log "Backup ended."
## -----------------------------------------------------------------------------

## smontare cartelle di backup
for loc in "${loc[@]}";
        do
                $umount $loc;
                echo $log "  unmounted" $loc; 
        done

## smontare partizione /mnt/BKPDISK
umount /mnt/BKPDISK
echo $log "unmounted /mnt/BKPDISK"

## chiudere volume criptato
cryptsetup luksClose sda1
echo $log "crypted /dev/sda1 closed"

## inviare notifica 
echo $log "EDBackuPi finished!"

exit
