#!/bin/bash

# Define repository information
SERVER_ROOT="/var/www/html"
REPO_NAME="sslcert-repo"
REPO_LABEL="SSL Certificate Repository"
REPO_DESCRIPTION="Local repository for sslcert package"
# REPO_DIR="/var/www/html/$REPO_NAME"  # Change this to your web server's document root
REPO_DIR="sslcert-repo"

# Replace 'sslcert.deb' with the actual name of your Debian package
SSL_CERT_PACKAGE="sslcert.deb"
./local_package_builder.sh
# Create repository directory structure
mkdir -p "$REPO_DIR/dists/stable/main/binary-amd64"
mkdir -p "$REPO_DIR/pool/main/s/sslcert"

# Copy the Debian package to the repository
mv "$SSL_CERT_PACKAGE" "$REPO_DIR/pool/main/s/sslcert/"

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

# # Create a temporary sources.list entry
# # TEMP_SOURCES_LIST_ENTRY="deb [trusted=yes] http://localhost/$REPO_NAME stable main"
# TEMP_SOURCES_LIST_ENTRY="deb [arch=amd64 trusted=yes] http://localhost/$REPO_NAME stable main"

# # Add the temporary repository source to sources.list
# echo "$TEMP_SOURCES_LIST_ENTRY" | sudo tee -a /etc/apt/sources.list

# # Update apt cache again
# sudo apt-get update

# # Install the sslcert package
# sudo apt-get install sslcert

# # Remove the temporary repository source from sources.list
# sudo sed -i "\|$TEMP_SOURCES_LIST_ENTRY|d" /etc/apt/sources.list

# # Update apt cache again
# sudo apt-get update
