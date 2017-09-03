#!/bin/sh

version=4.14
#mountp=/mnt/bitbucket_home
mountp=/opt/bitbucket/bitbucket_home
db_host=postgres
db_name=bitbucket
db_user=bitbucket
db_password=Searsafa2443
hostname=bitbucket.egorov.net

PRODUCT=bitbucket
PRODUCT_VERSION=${version}
PRODUCT_HOME=/$PRODUCT-home
MOUNTP=${mountp}

mkdir /opt/$PRODUCT
cd /opt/$PRODUCT|| exit 1

# generate ssl certificates
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=US/ST=/L=/O=/CN=${hostname}"

# create nginx.conf file
cat <<EOF > nginx.conf
  upstream upstream-app {
      server bitbucket:7990;
  }

  server {
      listen 80;
      server_name _;

      location / {
          return 301 https://\$http_host\$request_uri;
      }
  }

  server {
      listen 443 ssl;
      server_name _;

      chunked_transfer_encoding on;
      client_max_body_size 0;

      ssl_certificate /etc/ssl/private/server.crt;
      ssl_certificate_key /etc/ssl/private/server.key;
      ssl_ciphers 'EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH';
      ssl_prefer_server_ciphers on;
      ssl_session_cache shared:SSL:10m;

      location / {
          proxy_pass                              http://upstream-app;
          proxy_set_header    Host                \$host;
          proxy_set_header    X-Real-IP           \$remote_addr;
          proxy_set_header    X-Forwarded-For     \$proxy_add_x_forwarded_for;
          proxy_set_header    X-Forwarded-Host    \$host;
          proxy_set_header    X-Forwarded-Server  \$host;
          proxy_set_header    X-Forwarded-Proto   \$scheme;
          proxy_read_timeout                      900;
      }
  }
EOF

# create docker-compose file
cat <<EOF > docker-compose.yml
version: '2'
services:

  postgres:
    image: postgres:9.5-alpine
    restart: always
    volumes:
      - pgdata:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    environment:
      - POSTGRES_DB=${db_name}
      - POSTGRES_USER=${db_user}
      - POSTGRES_PASSWORD=${db_password}

  bitbucket:
    image: atlassian/bitbucket-server:${version}
    restart: always
    volumes:
      - ${MOUNTP}:/var/atlassian/application-data/bitbucket
      - /dev/urandom:/dev/random
    ports:
      - "7990:7990"
      - "7999:7999"
    environment:
      - CATALINA_CONNECTOR_PROXYNAME=${hostname}
      - CATALINA_CONNECTOR_PROXYPORT=443
      - CATALINA_CONNECTOR_SCHEME=https
      - CATALINA_CONNECTOR_SECURE=true
    depends_on:
      - postgres

  nginx:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./server.key:/etc/ssl/private/server.key:ro
      - ./server.crt:/etc/ssl/private/server.crt:ro
    depends_on:
      - bitbucket

volumes:
  pgdata:
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

## create bitbucket connection file
#
#mkdir -p $PRODUCT_HOME/shared
#
#cat <<EOF > $PRODUCT_HOME/shared/bitbucket.properties
#jdbc.driver=org.postgresql.Driver
#jdbc.url=jdbc:postgresql://${db_host}/${db_name}
#jdbc.user=${db_user}
#jdbc.password=${db_password}
#EOF

# reload, enable and start service
systemctl daemon-reload
systemctl enable $PRODUCT.service
systemctl start $PRODUCT.service

## create crontab for custom metrics
#echo "*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=/ --from-cron" | crontab -


date > /tmp/date.txt
