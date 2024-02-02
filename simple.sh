#!/bin/bash
usage() {
    echo "Usage: $0 [[<package_name>] [<executable_file>]]"
    exit 1
}

deb_builder() {
    PACKAGE_NAME=$1
    EXECUTABLE_FILE=$2
    mkdir -p $PACKAGE_NAME/DEBIAN
    mkdir -p $PACKAGE_NAME/usr/local/bin

    cat <<EOF > $PACKAGE_NAME/DEBIAN/control
Package: sslcert
Version: 1.0
Architecture: all
Maintainer: Your Name <smazoomder@gmail.com>
Description: A script to simplify the generation and management of SSL certificates. sslcert is a convenient tool for creating and handling SSL certificates for web servers, ensuring a streamlined process for securing your online applications. It supports easy certificate generation, renewal, and customization, making SSL certificate management hassle-free.
EOF
    cp $EXECUTABLE_FILE $PACKAGE_NAME/usr/local/bin/
    chmod +x $PACKAGE_NAME/usr/local/bin/$EXECUTABLE_FILE
    dpkg-deb --build sslcert
}


# Check if at least one argument is provided
if [ "$#" -lt 1 ]; then
    usage
fi

package_name=$1
executable_file=$2

deb_builder "$package_name" "$executable_file"
rm -r $package_name

REPO_ROOT="sslcert-repo"
if [ -d "$REPO_ROOT" ]; then
    echo "Removing existing $REPO_ROOT folder..."
    rm -r "$REPO_ROOT"
fi

if dpkg -l | grep -q 'sslcert'; then
    # If installed, remove the package
    sudo apt-get remove sslcert -y
fi

mkdir -p $REPO_ROOT/debian
mv sslcert.deb $REPO_ROOT/debian/
dpkg-scanpackages $REPO_ROOT/debian /dev/null | gzip -9c > $REPO_ROOT/debian/Packages.gz
# sudo mv $REPO_ROOT /var/www/html


# sudo rm -r /var/www/html/$REPO_ROOT
# sudo mv $REPO_ROOT /var/www/html

# REPO_PATTERN="http://localhost $REPO_ROOT/debian/"
# sudo sed -i "\|$REPO_PATTERN|d" /etc/apt/sources.list

# TEMP_SOURCES_LIST_ENTRY="deb [trusted=yes] $REPO_PATTERN"
# echo "$TEMP_SOURCES_LIST_ENTRY" | sudo tee -a /etc/apt/sources.list
# sudo apt-get update
# sudo apt-get install sslcert