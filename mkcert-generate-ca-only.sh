#!/bin/bash
# input example - /var/www/html/your-project/test
ca_path="ca"
output=$(./generate-ca.sh -cadir "$ca_path") 
echo $output

read -p "Enter the project certificates path: " certificate_path




local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"

sudo cp "$ca_path"/rootCA.pem "$ca_path"/rootCA-key.pem "$(mkcert -CAROOT)"

# Verify if the files were copied successfully
if [ $? -eq 0 ]; then
    echo "CA Files copied"
else
    echo "Error copying CA files"
fi

mkcert -uninstall
mkcert -install

mkdir -p output
cd output

mkcert -cert-file server.crt -key-file private.key localhost $local_ip
mkdir -p $certificate_path
cp server.crt private.key "$certificate_path"
# Verify if the files were copied successfully
if [ $? -eq 0 ]; then
    echo "Files copied to $certificate_path"
else
    echo "Error copying files"
fi

openssl x509 -in server.crt -text -noout
echo "Restarting Server"
sudo systemctl restart apache2