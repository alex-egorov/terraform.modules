#!/bin/sh

PRODUCT=bamboo
PRODUCT_VERSION=5.14.3.1
PRODUCT_HOME=/$PRODUCT-home
MOUNTP=./bamboo-home


mkdir -p /opt/$PRODUCT
cd /opt/$PRODUCT|| exit 1

if [ ! -f atlassian-$PRODUCT-$PRODUCT_VERSION.tar.gz ]
then
  wget https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-$PRODUCT-$PRODUCT_VERSION.tar.gz
fi

cat <<EOF > Dockerfile
FROM openjdk:8u111-jre-alpine

# Install utilities
RUN apk --update add bash curl nano

ENV PRODUCT $PRODUCT
ENV PRODUCT_VERSION $PRODUCT_VERSION
ENV PRODUCT_HOME /$PRODUCT_HOME
ENV PRODUCT_INSTALL atlassian-\$PRODUCT-\$PRODUCT_VERSION

RUN mkdir -p \$PRODUCT_HOME

# install distribution and untar to current folder
ADD atlassian-\$PRODUCT-\$PRODUCT_VERSION.tar.gz ./
RUN echo "bamboo.home = \$PRODUCT_HOME" > \$PRODUCT_INSTALL/atlassian-\$PRODUCT/WEB-INF/classes/\$PRODUCT-init.properties

EXPOSE 8085
EXPOSE 54663

WORKDIR "\$PRODUCT_INSTALL/bin"
CMD ["./start-bamboo.sh", "-fg"]
EOF

cat <<EOF > docker-compose.yml
version: '2'
services:
#  postgres:
#    image: postgres:9.5-alpine
#    restart: always
#    volumes:
#      - pgdata:/var/lib/postgresql/data
#    ports:
#      - "127.0.0.1:5432:5432"
#    environment:
#      - POSTGRES_DB=bamboo
#      - POSTGRES_USER=bamboo
#      - POSTGRES_PASSWORD=Searsafa2443
  bamboo:
    container_name: bamboo_server
    build: .
    restart: always
    volumes:
      - $MOUNTP:$PRODUCT_HOME
    ports:
      - "80:8085"
      - "54663:54663"
#    depends_on:
#      - postgres
#volumes:
#  pgdata:
EOF

# create systemd service
tee /etc/systemd/system/$PRODUCT.service << EOF
[Unit]
Description=$PRODUCT docker service
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/bin/docker-compose -f /opt/$PRODUCT/docker-compose.yml up
ExecStop=/bin/docker-compose -f /opt/$PRODUCT/docker-compose.yml stop

[Install]
WantedBy=multi-user.target
EOF

docker-compose build --no-cache --force-rm

# reload, enable and start service
systemctl daemon-reload
systemctl enable $PRODUCT.service
systemctl start $PRODUCT.service

# create crontab for custom metrics
echo "*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=/ --from-cron" | crontab -

date > /tmp/date.txt
