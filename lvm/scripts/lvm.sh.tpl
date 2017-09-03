#!/bin/bash

DEVICE=${device}
VGNAME=${vgname}
LVNAME=${lvname}
MOUNTP=${mountp}

yum install -y lvm2
pvcreate $DEVICE
vgcreate $VGNAME $DEVICE
lvcreate -l 100%FREE -n $LVNAME $VGNAME
mkfs.ext4 /dev/$VGNAME/$LVNAME
mkdir $MOUNTP
echo "/dev/$VGNAME/$LVNAME    $MOUNTP    ext4    defaults   0  0" >> /etc/fstab
mount -a
