## OpenVPN Post-Install Commands

docker-compose run --rm openvpn-server ovpn_genconfig -D -u tcp://34.197.252.247:443 -n "8.8.8.8" -n "8.8.4.4" -p "route 10.0.0.0 255.128.0.0" -r "10.0.0.0 255.128.0.0"

docker-compose run --rm openvpn-server ovpn_initpki
docker-compose run --rm openvpn-server easyrsa build-client-full mednet nopass
docker-compose run --rm openvpn-server ovpn_getclient mednet > mednet.ovpn
systemctl start openvpn


```
usage() {
    echo "usage: $0 [-d]"
    echo "                  -u SERVER_PUBLIC_URL"
    echo "                 [-e EXTRA_SERVER_CONFIG ]"
    echo "                 [-f FRAGMENT ]"
    echo "                 [-n DNS_SERVER ...]"
    echo "                 [-p PUSH ...]"
    echo "                 [-r ROUTE ...]"
    echo "                 [-s SERVER_SUBNET]"
    echo
    echo "optional arguments:"
    echo " -2    Enable two factor authentication using Google Authenticator."
    echo " -a    Authenticate  packets with HMAC using the given message digest algorithm (auth)."
    echo " -c    Enable client-to-client option"
    echo " -C    A list of allowable TLS ciphers delimited by a colon (cipher)."
    echo " -d    Disable NAT routing and default route"
    echo " -D    Do not push dns servers"
    echo " -m    Set client MTU"
    echo " -N    Configure NAT to access external server network"
    echo " -t    Use TAP device (instead of TUN device)"
    echo " -T    Encrypt packets with the given cipher algorithm instead of the default one (tls-cipher)."
    echo " -z    Enable comp-lzo compression."
}
```
