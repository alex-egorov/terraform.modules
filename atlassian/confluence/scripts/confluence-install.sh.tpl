#!/bin/sh

PRODUCT=confluence
PRODUCT_VERSION=${version}
PRODUCT_HOME=/var/atlassian/application-data/confluence
MOUNTP=./confluence_home
MYSQL_VERSION=5.1.38

mkdir /opt/$PRODUCT
cd /opt/$PRODUCT|| exit 1

if [ ! -f atlassian-$PRODUCT-$PRODUCT_VERSION.tar.gz ]
then
  wget https://www.atlassian.com/software/$PRODUCT/downloads/binary/atlassian-$PRODUCT-$PRODUCT_VERSION.tar.gz
fi

if [ ! -f https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_VERSION.tar.gz ]
then
  wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_VERSION.tar.gz
fi

cat <<EOF > Dockerfile
FROM openjdk:8u111-jre-alpine

# Install utilities
RUN apk --update --no-cache add bash curl

ENV PRODUCT confluence
ENV PRODUCT_VERSION $PRODUCT_VERSION
ENV PRODUCT_HOME $PRODUCT_HOME
ENV PRODUCT_INSTALL atlassian-\$PRODUCT-\$PRODUCT_VERSION


# Install distribution and untar to current folder
ADD atlassian-\$PRODUCT-\$PRODUCT_VERSION.tar.gz ./
ADD mysql-connector-java-$MYSQL_VERSION.tar.gz \$PRODUCT_INSTALL/lib
RUN mkdir -p \$PRODUCT_HOME \
  && echo "\$PRODUCT.home = \$PRODUCT_HOME" > \$PRODUCT_INSTALL/atlassian-\$PRODUCT/WEB-INF/classes/\$PRODUCT-application.properties \

#COPY server.xml \$PRODUCT_INSTALL/conf/server.xml

VOLUME ["\$PRODUCT_HOME"]

EXPOSE 8080

WORKDIR "\$PRODUCT_INSTALL/bin"
CMD ["./catalina.sh", "run"]
EOF

cat <<EOF > docker-compose.yml
confluence:
  container_name: confluence_server
  build: .
  restart: always
  volumes:
    - $MOUNTP:$PRODUCT_HOME
  ports:
    - "80:8080"
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

# create confluence connection file
mkdir -p $MOUNTP/shared

cat <<EOF > $MOUNTP/shared/conflunce.properties
jdbc.driver=org.postgresql.Driver
jdbc.url=jdbc:postgresql://${db_host}/${db_name}
jdbc.user=${db_user}
jdbc.password=${db_password}
EOF

docker-compose build --no-cache --force-rm

# reload, enable and start service
systemctl daemon-reload
systemctl enable $PRODUCT.service
systemctl start $PRODUCT.service

# create crontab for custom metrics
echo "*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=/ --from-cron" | crontab -


date > /tmp/date.txt
