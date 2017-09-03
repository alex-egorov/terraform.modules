#!/bin/bash

yum update -y
yum install -y nano wget mc

# Amazon EC2 API tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip
mv ec2-api-tools-* /opt/ec2-api-tools

# Install Java
JAVA_HOME=/opt/java
JAVA_VERSION_MAJOR=8
JAVA_VERSION_MINOR=102
JAVA_VERSION_BUILD=14

mkdir -p /opt \
  &&  curl --fail --silent --location --retry 3 \
  --header "Cookie: oraclelicense=accept-securebackup-cookie; " \
  http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/server-jre-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz \
  | gunzip \
  | tar -x -C /opt \
  && ln -s /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR} ${JAVA_HOME}

#  Creating Bamboo user
useradd -m bamboo

# Downloading agent installer to the instance
imageVer=2.2
wget https://maven.atlassian.com/content/repositories/atlassian-public/com/atlassian/bamboo/atlassian-bamboo-elastic-image/${imageVer}/atlassian-bamboo-elastic-image-${imageVer}.zip
sudo mkdir -p /opt/bamboo-elastic-agent
sudo unzip -o atlassian-bamboo-elastic-image-${imageVer}.zip -d /opt/bamboo-elastic-agent
sudo chown -R bamboo /opt/bamboo-elastic-agent
sudo chmod -R u+r+w /opt/bamboo-elastic-agent


tee /etc/profile.d/bamboo.sh << EOF
export JAVA_HOME=<path to JRE used to start the agent>
export EC2_HOME=<location of your EC2 tools installation>
export EC2_PRIVATE_KEY=/root/pk.pem
export EC2_CERT=/root/cert.pem
export PATH=/opt/bamboo-elastic-agent/bin:$EC2_HOME/bin:$JAVA_HOME/bin:$M2_HOME/bin:$MAVEN_HOME/bin:$ANT_HOME/bin:$PATH
EOF
