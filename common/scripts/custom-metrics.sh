#!/bin/bash

yum install -y unzip perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https
yum -y install perl-Digest-SHA perl-URI perl-libwww-perl perl-MIME-tools perl-Crypt-SSLeay perl-XML-LibXML
curl http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.1.zip -O
unzip CloudWatchMonitoringScripts-1.2.1.zip -d /usr/local
rm -f CloudWatchMonitoringScripts-1.2.1.zip
