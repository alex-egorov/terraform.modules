#!/bin/sh

TERRAFORM_VERSION=0.8.7
PACKER_VERSION=0.12.2



yum update -y
yum install -y nano wget mc unzip
if [ ! -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip ]
then
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
chmod +x terraform
mv terraform /usr/bin/terraform

if [ ! -f packer_${PACKER_VERSION}_linux_amd64.zip ]
then
  wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip
fi
unzip packer_${PACKER_VERSION}_linux_amd64.zip
chmod +x packer
mv packer /usr/bin/packer

################################################################################

export BAMBOO_BUILD_KEY=${bamboo.buildResultKey}

{
    "variables": {
        "version": "{{env `BAMBOO_BUILD_KEY`}}"
    }
}
