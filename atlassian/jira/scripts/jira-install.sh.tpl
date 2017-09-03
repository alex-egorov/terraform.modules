#!/bin/sh

PRODUCT=jira
PRODUCT_VERSION=7.3.1
PRODUCT_HOME=/$PRODUCT-home
MOUNTP=./jira-home
MYSQL_VERSION=5.1.38

mkdir /opt/$PRODUCT
cd /opt/$PRODUCT|| exit 1

if [ ! -f atlassian-$PRODUCT-software-$PRODUCT_VERSION.tar.gz ]
then
  wget https://www.atlassian.com/software/$PRODUCT/downloads/binary/atlassian-$PRODUCT-software-$PRODUCT_VERSION.tar.gz
fi

if [ ! -f https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_VERSION.tar.gz ]
then
  wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-$MYSQL_VERSION.tar.gz
fi


cat <<EOF > dbconfig.xml
<?xml version="1.0" encoding="UTF-8"?>

<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>postgres72</database-type>
  <schema-name>public</schema-name>
  <jdbc-datasource>
    <url>jdbc:postgresql://${db_host}/${db_name}</url>
    <driver-class>org.postgresql.Driver</driver-class>
    <username>${db_user}</username>
    <password>${db_password}</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <validation-query>select 1</validation-query>
    <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    <pool-test-on-borrow>false</pool-test-on-borrow>
    <pool-test-while-idle>true</pool-test-while-idle>
  </jdbc-datasource>
</jira-database-config>
EOF

cat <<EOF > Dockerfile
FROM openjdk:8u111-jre-alpine

# Install utilities
RUN apk --update --no-cache add bash curl

ENV PRODUCT jira
ENV PRODUCT_VERSION $PRODUCT_VERSION
ENV PRODUCT_HOME $PRODUCT_HOME
ENV PRODUCT_INSTALL atlassian-\$PRODUCT-software-\$PRODUCT_VERSION-standalone

# Install distribution and untar to current folder
ADD atlassian-\$PRODUCT-software-\$PRODUCT_VERSION.tar.gz ./
ADD mysql-connector-java-$MYSQL_VERSION.tar.gz \$PRODUCT_INSTALL/lib
RUN mkdir -p \$PRODUCT_HOME \
  && echo "\$PRODUCT.home = \$PRODUCT_HOME" > \$PRODUCT_INSTALL/atlassian-\$PRODUCT/WEB-INF/classes/\$PRODUCT-application.properties \
  && sed --in-place "s/java version/openjdk version/g" "\$PRODUCT_INSTALL/bin/check-java.sh" \
# && sed -i 's/JVM_MINIMUM_MEMORY="384m"/JVM_MINIMUM_MEMORY="$${JVM_MINIMUM_MEMORY:=1024m}"/' \$PRODUCT_INSTALL/bin/setenv.sh \
# && sed -i 's/JVM_MAXIMUM_MEMORY="768m"/JVM_MAXIMUM_MEMORY="$${JVM_MAXIMUM_MEMORY:=1024m}"/' \$PRODUCT_INSTALL/bin/setenv.sh \


COPY dbconfig.xml \$PRODUCT_HOME/dbconfig.xml

VOLUME ["\$PRODUCT_HOME"]

EXPOSE 8080
WORKDIR "\$PRODUCT_INSTALL/bin"
CMD ["./catalina.sh", "run"]
EOF

cat <<EOF > docker-compose.yml
jira:
  container_name: jira_server
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


# create jira connection file
mkdir -p $PRODUCT_HOME/shared

cat <<EOF > $PRODUCT_HOME/shared/jira.properties
jdbc.driver=org.postgresql.Driver
jdbc.url=jdbc:postgresql://${db_host}/${db_name}
jdbc.user=${db_user}
jdbc.password=${db_password}
EOF

docker-compose build --no-cache --force-rm

# reload, enable and start service
systemctl daemon-reload
systemctl enable jira.service
#systemctl start jira.service

# create crontab for custom metrics
echo "*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=/ --from-cron" | crontab -


date > /tmp/date.txt
