#!/bin/bash
# input example - /var/www/html/your-project/certificates
local_ip=$(ip addr show | grep -oP '(?<=inet )(\d+\.\d+\.\d+\.\d+)' | grep -v '127.0.0.1' | head -n 1)
echo "Local IP Address: $local_ip"
read -p "Enter the project certificates path: " certificate_path
rm -r "$certificate_path"
mkdir "$certificate_path"
cd "$certificate_path"
openssl genpkey -algorithm RSA -out private.key
# -aes256 not used

cat <<EOF > san.conf
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
CN = localhost
C = BD
ST = Dhaka
L = Gulshan
O = ROBIST
OU = Software
emailAddress = smazoomder@gmail.com

[req_ext]
subjectAltName = DNS:localhost, IP:$local_ip
extendedKeyUsage       = critical, serverAuth, clientAuth
keyUsage               = critical, digitalSignature, keyEncipherment
EOF

openssl req -new -key private.key -out certificate.csr -config san.conf
openssl x509 -req -in certificate.csr -signkey private.key -out server.cert -days 365
sudo systemctl restart apache2

openssl x509 -in server.cert -out server.crt
openssl pkcs12 -export -out certificate.pfx -inkey private.key -in server.cert
sudo cp server.crt /usr/local/share/ca-certificates/server.crt
sudo update-ca-certificates
awk -v cmd='openssl x509 -noout -subject' ' /BEGIN/{close(cmd)};{print | cmd}' < /etc/ssl/certs/ca-certificates.crt | grep -i localhost
openssl verify server.crt
curl -I https://192.168.0.88:3000