

## Install bamboo
```


yum install -y java-1.8.0-openjdk
#yum install postgresql

useradd --create-home -c "Bamboo role account" bamboo
mkdir -p /opt/atlassian/bamboo
chown bamboo: /opt/atlassian/bamboo
mkdir -p /var/atlassian/application/bamboo
chown bamboo: /var/atlassian/application/bamboo/

su - bamboo

cd /opt/atlassian/bamboo
export BAMBOO_VERSION=5.14.3.1
wget https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz
tar -xvf atlassian-bamboo-${BAMBOO_VERSION}.tar.gz
ln -s atlassian-bamboo-$BAMBOO_VERSION current
echo "bamboo.home=/var/atlassian/application/bamboo" >> current/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties


cd /opt/atlassian/bamboo/current
bin/start-bamboo.sh
```
