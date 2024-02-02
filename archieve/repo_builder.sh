#!/bin/bash

# Define repository information
SERVER_ROOT="/var/www/html"
REPO_NAME="sslcert-repo"
REPO_PATTERN="http://localhost/$REPO_NAME"
REPO_LABEL="SSL Certificate Repository"
REPO_DESCRIPTION="Local repository for sslcert package"
REPO_DIR="sslcert-repo"
SSL_CERT_PACKAGE="sslcert.deb"

# Function to build the Debian package
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
}

deb_builder

sudo sed -i "\|$REPO_PATTERN|d" /etc/apt/sources.list

# Create repository directory structure
mkdir -p "$REPO_DIR/dists/stable/main/binary-amd64"
mkdir -p "$REPO_DIR/pool/main/s/sslcert"

# Copy the Debian package to the repository
cp "$SSL_CERT_PACKAGE" "$REPO_DIR/pool/main/s/sslcert/"

# Generate package information
dpkg-scanpackages "$REPO_DIR/pool" /dev/null | gzip -9c > "$REPO_DIR/dists/stable/main/binary-amd64/Packages.gz"

# Create Release file with proper hash and date entries
cat <<EOF > "$REPO_DIR/dists/stable/Release"
Origin: $REPO_NAME
Label: $REPO_LABEL
Suite: stable
Version: 1.0
Codename: stable
Date: $(LC_TIME=C date -u "+%a, %d %b %Y %T %z")
Architectures: amd64 i386
Components: main
MD5Sum:
 $(cd "$REPO_DIR" && find . -type f -print | grep -v './dists/' | xargs md5sum | sed -e 's|./|   |' -e 's|  | |' -e 's| |  *./|' -e 's|$| |' | tr '\n' '\n')
SHA1:
 $(cd "$REPO_DIR" && find . -type f -print | grep -v './dists/' | xargs sha1sum | sed -e 's|./|   |' -e 's|  | |' -e 's| |  *./|' -e 's|$| |' | tr '\n' '\n')
SHA256:
 $(cd "$REPO_DIR" && find . -type f -print | grep -v './dists/' | xargs sha256sum | sed -e 's|./|   |' -e 's|  | |' -e 's| |  *./|' -e 's|$| |' | tr '\n' '\n')
EOF

# Copy the repository to the web server's document root
sudo rm -r "$SERVER_ROOT/$REPO_DIR"
sudo mv $REPO_DIR $SERVER_ROOT

# Create a temporary sources.list entry
TEMP_SOURCES_LIST_ENTRY="deb [arch=amd64 trusted=yes] http://localhost/$REPO_NAME debian/"

# Update apt cache again
sudo apt-get update

# Add the temporary repository source to sources.list
echo "$TEMP_SOURCES_LIST_ENTRY" | sudo tee -a /etc/apt/sources.list

# Install the sslcert package
sudo apt-get install sslcert