## Post install steps

```
fdisk -l
fdisk /dev/xvdb n p w
mkfs.ext4 /dev/xvdb1
mkdir /media/nexus
nano /etc/fstab
/dev/xvdb1 /media/nexus   ext4  defaults       0  0
mount -a
lsblk
mkdir /media/nexus/data
rm -rf /var/satellite/redhat
ln -s /media/spacewalk/redhat/ /var/satellite/
```

## How to deploy images

curl --fail -u admin:admin123 --upload-file <image.img> http://127.0.0.1:8081/repository/staging_packer_images/
curl -v -u admin:admin123 --upload-file config.json http://127.0.0.1:8081/repository/releases/images/vagrant/centos7/1.0/



## How to login and push to insecure nexus3 docker registry

add to /etc/docker/daemon.json
 { "insecure-registries":["192.168.11.113:8082"] }
and restart docker

docker login 192.168.11.113:8082

docker tag bamboo_bamboo 192.168.11.113:8082/bamboo-server:1.0
docker tag bamboo_bamboo 192.168.11.113:8082/bamboo-server:latest

docker push 192.168.11.113:8082/bamboo-server:1.0
docker push 192.168.11.113:8082/bamboo-server:latest
