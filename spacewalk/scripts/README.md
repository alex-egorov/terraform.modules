

## Post-Install setup

```
# fdisk -l
# fdisk /dev/xvdb n p w
# mkfs.ext4 /dev/xvdb1
# nano /etc/fstab
# /dev/sdax /media/user/label   ext4  defaults       0  0
# mount -a
# lsblk
#
# mkdir /media/spacewalk/redhat
# rm -rf /var/satellite/redhat
# ln -s /media/spacewalk/redhat/ /var/satellite/
```
