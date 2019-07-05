#!/bin/bash
## this will backup several critical kubernetes items that run on each control node
## the backup will be created on the openstack persistent storage volume /data0/kubernetes-etcd-backup

## create directory if it doesn't already exist

#sudo mkdir -p /data0/kubernetes-etcd-backup

## use rsync to archive daily backup folder and delete any extra items, creating an identical copy with another name
## cp and mv do not provide this feature, they compile old and new files, we want an identical copy in this case,
## no old files

sudo rsync -a --delete /data0/kubernetes-etcd-backup/ /data0/kubernetes-etcd-backup-previous-day/

## delete old main backup folder

sudo rm -rf /data0/kubernetes-etcd-backup/

## make new backup folder path

sudo mkdir -p /data0/kubernetes-etcd-backup/

## copy kubernetes folder to backup dir

sudo cp -pr /etc/kubernetes/ /data0/kubernetes-etcd-backup/kubernetes

## copy etcd folder with certs in it to backup dir

sudo cp -pr /etc/etcd/ /data0/kubernetes-etcd-backup

## get the endpoint reference of the host control node to build backup commands:

ip=( $(ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1) )

endpoint_URL="https://$ip:2379"

## create and issue etcd v3 items backup command

sudo ETCDCTL_API=3 etcdctl --endpoints="$endpoint_URL" --cacert=LOCATION TO CERT FILE --cert=LOCATIION TO CLIENT PEM --key=LOCATION TO ETCD CLIENT PEM snapshot save /data0/kubernetes-etcd-backup/etcd-v3-backup.db

