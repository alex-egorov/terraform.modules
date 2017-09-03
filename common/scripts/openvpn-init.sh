#!/bin/bash

mkdir /opt/openvpn

tee /opt/openvpn/docker-compose.yml << EOF
version: '2'
services:
 openvpn-server:
     image: "kylemanna/openvpn"
     ports:
         - "443:1194/tcp"
     cap_add:
         - NET_ADMIN
     volumes:
         - ovpn-data:/etc/openvpn
volumes:
    ovpn-data:
EOF


tee /etc/systemd/system/openvpn.service << EOF
Description=OpenVPN Docker Service
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/bin/docker-compose -f /opt/openvpn/docker-compose.yml up
ExecStop=/bin/docker-compose -f /opt/openvpn/docker-compose.yml stop

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl enable openvpn.service
