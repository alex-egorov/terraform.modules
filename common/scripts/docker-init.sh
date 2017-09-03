#!/bin/sh

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum update -y
yum install -y nano mc wget docker-engine python-pip
pip install --upgrade pip
pip install --upgrade docker-compose
usermod -a -G docker centos
systemctl enable docker.service
systemctl start docker
