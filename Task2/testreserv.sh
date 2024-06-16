#!/bin/bash

RESERV="/archive/backup"
DATETIME=$(date +%Y-%m-%d_%H-%M)

mkdir -p $RESERV

tar -cvp --exclude="/home/goldabsinth/scripts" -f $RESERV/home_$DATETIME.tar /home
tar -cvpf $RESERV/ssh_$DATETIME.tar /etc/ssh
tar -cvpf $RESERV/xrdp_$DATETIME.tar /etc/xrdp
tar -cvpf $RESERV/vsftpd_$DATETIME.tar /etc/vsftpd
tar -cvpf $RESERV/log_$DATETIME.tar /var/log
mv $RESERV/*.tar /archive/

echo "Backup completed successfully at $DATETIME"
