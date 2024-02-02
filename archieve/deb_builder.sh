#!/bin/bash
mkdir -p sslcert/DEBIAN
mkdir -p sslcert/usr/local/bin
cat <<EOF > sslcert/DEBIAN/control
Package: sslcert
Version: 1.0
Architecture: amd64
Maintainer: Shaon Majumder <smazoomder@gmail.com>
Description: A script to simplify the generation and management of SSL certificates. sslcert is a convenient tool for creating and handling SSL certificates for web servers, ensuring a streamlined process for securing your online applications. It supports easy certificate generation, renewal, and customization, making SSL certificate management hassle-free.
EOF
cp sslcert.sh sslcert/usr/local/bin
chmod +x sslcert/usr/local/bin/sslcert.sh
# dpkg-deb --build sslcert
dpkg --build sslcert
chown -R $(whoami) sslcert.deb
# sudo dpkg -i sslcert.deb
# sslcert.sh
# sudo dpkg -r sslcert
# sudo dpkg -P sslcert