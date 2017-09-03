#!/bin/bash

NEXUS_HOME=/opt/nexus
NEXUS_DATA=${mountp}
NEXUS_VERSION=${version}

mkdir -p $NEXUS_DATA && chown -R 200 $NEXUS_DATA

mkdir -p $NEXUS_HOME
cd $NEXUS_HOME || exit 1

# generate ssl certificates
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout server.key -out server.crt -subj "/C=US/ST=/L=/O=/CN=bitbucket.mednetstudy.com"

# create nginx.conf file
cat <<EOF > nginx.conf
  upstream upstream-app {
      server nexus:8081;
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
version: "2"
services:
  nexus:
    image: sonatype/nexus3:$${NEXUS_VERSION}
    environment:
      - JAVA_MAX_MEM=${java_max_mem}
      - JAVA_MIN_MEM=${java_min_mem}
      - EXTRA_JAVA_OPTS=${extra_java_opts}
      - NEXUS_CONTEXT=${context_path}
    volumes:
      - "$${NEXUS_DATA}:/nexus-data"
    ports:
      - "8081:8081"
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./server.key:/etc/ssl/private/server.key:ro
      - ./server.crt:/etc/ssl/private/server.crt:ro
    depends_on:
      - nexus
EOF

# create systemd service
tee /etc/systemd/system/nexus.service << EOF
[Unit]
Description=Nexus Docker Service
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/bin/docker-compose -f $${NEXUS_HOME}/docker-compose.yml up
ExecStop=/bin/docker-compose -f $${NEXUS_HOME}/docker-compose.yml stop

[Install]
WantedBy=multi-user.target
EOF


# reload, enable and start service
systemctl daemon-reload
systemctl enable nexus.service
systemctl start nexus.service

# create crontab for custom metrics
echo '*/5 * * * * /usr/local/aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util  --disk-space-units=gigabytes --disk-path=$NEXUS_DATA --disk-path=/ --from-cron' | crontab -
