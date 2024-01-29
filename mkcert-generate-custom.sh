#!/bin/bash
# input example - /var/www/html/your-project/test
local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"
read -p "Enter the project certificates path: " certificate_path
rm -r "$certificate_path"
mkdir "$certificate_path"
# undo everything
mkcert -uninstall
mkcert -install
# going to key files of root
cd $(mkcert -CAROOT)
# creating the certificate details
cat <<EOF > openssl-custom.conf
[ req ]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no

[ req_distinguished_name ]
C  = BD
ST = Dhaka
L  = Gulshan
O  = ROBIST
OU = Software
CN = localhost
emailAddress = smazoomder@gmail.com

[ v3_req ]
basicConstraints = CA:TRUE
EOF
# modifying the certificate detials
openssl req -x509 -new -key rootCA-key.pem -out rootCA.pem -days 3650 -config openssl-custom.conf
# again uninstalling
mkcert -uninstall
# intalling with custom info
mkcert -install -cert-file rootCA.pem -key-file rootCA-key.pem


cd "$certificate_path"
mkcert -cert-file server.crt -key-file private.key localhost $local_ip