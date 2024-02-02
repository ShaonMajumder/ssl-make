#!/bin/bash
deb_builder() {
    mkdir -p sslcert/DEBIAN
    mkdir -p sslcert/usr/local/bin

    cat <<EOF > sslcert/DEBIAN/control
Package: sslcert
Version: 1.0
Architecture: all
Maintainer: Your Name <smazoomder@gmail.com>
Description: A script to simplify the generation and management of SSL certificates. sslcert is a convenient tool for creating and handling SSL certificates for web servers, ensuring a streamlined process for securing your online applications. It supports easy certificate generation, renewal, and customization, making SSL certificate management hassle-free.
EOF

    cp sslcert.sh sslcert/usr/local/bin/
    chmod +x sslcert/usr/local/bin/sslcert.sh
    dpkg-deb --build sslcert
    rm -r sslcert/
}

deb_builder


repo_root="sslcert-repo"
if [ -d "$repo_root" ]; then
    echo "Removing existing $repo_root folder..."
    rm -r "$repo_root"
fi

if dpkg -l | grep -q 'sslcert'; then
    # If installed, remove the package
    sudo apt-get remove sslcert -y
fi

mkdir -p $repo_root/debian
mv sslcert.deb $repo_root/debian/
dpkg-scanpackages $repo_root/debian /dev/null | gzip -9c > $repo_root/debian/Packages.gz
# sudo mv $repo_root /var/www/html
sudo rm -r /var/www/html/$repo_root
sudo mv $repo_root /var/www/html

REPO_PATTERN="http://localhost $repo_root/debian/"
sudo sed -i "\|$REPO_PATTERN|d" /etc/apt/sources.list

TEMP_SOURCES_LIST_ENTRY="deb [trusted=yes] $REPO_PATTERN"
echo "$TEMP_SOURCES_LIST_ENTRY" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install sslcert