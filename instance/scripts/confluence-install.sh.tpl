#!/bin/sh

PRODUCT=confluence
PRODUCT_VERSION=${version}

mkdir /opt/$PRODUCT
cd /opt/$PRODUCT|| exit 1


cat <<EOF > Dockerfile
  FROM atlassian/confluence-server:$PRODUCT_VERSION

  EXPOSE 8080
  WORKDIR "atlassian-$PRODUCT-software-$PRODUCT_VERSION-standalone/bin"
  CMD ["./start-confluence.sh", "-fg"]
EOF

cat <<EOF > docker-compose.yml
confluence:
  container_name: confluence_server
  build: .
  restart: always
  volumes:
    - ./confluence-home:/confluence-home
  ports:
    - "80:8080"
EOF

docker-compose build
docker-compose up -d

date > /tmp/date.txt
