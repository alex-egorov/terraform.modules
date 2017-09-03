#!/bin/sh

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh http://yum.spacewalkproject.org/2.6/RHEL/7/x86_64/spacewalk-repo-2.6-0.el7.noarch.rpm

cat > /etc/yum.repos.d/jpackage-generic.repo << EOF
[jpackage-generic]
name=JPackage generic
mirrorlist=http://www.jpackage.org/mirrorlist.php?dist=generic&type=free&release=5.0
enabled=1
gpgcheck=1
gpgkey=http://www.jpackage.org/jpackage.asc
EOF

cat > /tmp/answers.txt << EOF
admin-email = root@localhost
ssl-set-org = ${organization}
ssl-set-org-unit = IT
ssl-set-city = ${city}
ssl-set-state = ${state}
ssl-set-country = ${country}
ssl-password = x234Dfsfas
ssl-set-email = root@localhost
ssl-config-sslvhost = Y
db-backend=postgresql
db-user=spacewalk
db-password=${db_password}
db-name=spacewalk
db-host=
db-port=5432
enable-tftp=N
EOF

yum install -y spacewalk-setup-postgresql
yum install -y spacewalk-postgresql

mkdir -p ${mountp}/redhat
mkdir -p /var/satellite
ln -s ${mountp}/redhat/ /var/satellite/

#spacewalk-setup-postgresql create --db spacewalk --user spacewalk --password Searsafa2443
spacewalk-setup --answer-file=/tmp/answers.txt > /tmp/spacewalk.txt
