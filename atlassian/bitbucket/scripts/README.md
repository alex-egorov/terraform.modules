## Post-Install Scripts

curl http://download.oracle.com/otn/java/jdk/8u112-b15/jdk-8u112-linux-x64.tar.gz

```
yum install -y lvm2
pvcreate /dev/xvdb
vgcreate data /dev/xvdb
lvcreate -l 100%FREE -n bitbucket data
mkfs.ext4 /dev/data/bitbucket
mkdir /mnt/bitbucket_data
echo "/dev/data/bitbucket    /mnt/bitbucket_data    ext4    defaults   0  0" >> /etc/fstab
mount -a
```

To mount new /dev/xvdc disk to lvm

```
umount /mnt/bitbucket_data/
vgextend data /dev/xvdc
lvextend /dev/data/bitbucket /dev/xvdc
```

## Postgres restore and upgrade

rpm -Uvh https://yum.postgresql.org/9.3/redhat/rhel-7-x86_64/pgdg-centos93-9.3-3.noarch.rpm
yum install postgresql93
pg_dump -h mgt-bitbucket.c1fp9kdlngzr.us-east-1.rds.amazonaws.com -U bitbucket --format=c stash > stash.psql

rpm -Uvh  https://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-redhat95-9.5-3.noarch.rpm
yum install postgresql95
pg_restore -h mgt-bitbucket.c1fp9kdlngzr.us-east-1.rds.amazonaws.com -U bitbucket -v -d bitbucket stash.psql


## Install AWS Custom Metrics

```
yum install -y unzip perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https
yum -y install perl-Digest-SHA perl-URI perl-libwww-perl perl-MIME-tools perl-Crypt-SSLeay perl-XML-LibXML
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip -d /usr/local
rm -f CloudWatchMonitoringScripts-1.2.1.zip
cat <(crontab -l) <(echo '*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=/mnt/bitbucket_data --disk-path=/ --from-cron') | crontab -
```
